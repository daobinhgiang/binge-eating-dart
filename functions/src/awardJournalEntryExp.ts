import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { determineNewLevel } from './utils/exp-utils';

/**
 * Cloud Function: Award EXP for Journal Entries
 * 
 * Triggered when a food_diary, weight_diary, body_image_diary, or money_diary document is created.
 * Awards 5 EXP and updates user level atomically.
 * 
 * Logging: Logs all steps for debugging and monitoring
 */
export const awardJournalEntryExp = functions.firestore
  .document('users/{userId}/weeks/{weekId}/{diaryType}/{entryId}')
  .onCreate(async (snapshot, context) => {
    const { userId, weekId, diaryType, entryId } = context.params;
    const startTime = Date.now();
    
    console.log('═══════════════════════════════════════════════════════════');
    console.log('🎯 JOURNAL ENTRY EXP AWARD FUNCTION TRIGGERED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📍 Path: users/${userId}/weeks/${weekId}/${diaryType}/${entryId}`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`📅 Week: ${weekId}`);
    console.log(`📔 Diary Type: ${diaryType}`);
    console.log(`📝 Entry ID: ${entryId}`);
    console.log(`⏰ Trigger Time: ${new Date().toISOString()}`);
    
    try {
      // Only process diary collections, not other subcollections
      const validDiaryTypes = ['foodDiaries', 'weightDiaries', 'bodyImageDiaries', 'moneyDiaries'];
      
      console.log(`\n🔍 VALIDATION STEP`);
      console.log(`Valid diary types: ${validDiaryTypes.join(', ')}`);
      console.log(`Received diary type: ${diaryType}`);
      
      if (!validDiaryTypes.includes(diaryType)) {
        console.log(`⚠️  SKIPPING: Invalid diary type "${diaryType}"`);
        console.log('═══════════════════════════════════════════════════════════\n');
        return;
      }

      console.log(`✅ Diary type is valid, proceeding...`);

      const JOURNAL_ENTRY_EXP = 5;
      const diaryTypeMap: { [key: string]: string } = {
        'foodDiaries': 'food_diary',
        'weightDiaries': 'weight_diary',
        'bodyImageDiaries': 'body_image_diary',
        'moneyDiaries': 'money_diary',
      };

      const entryType = diaryTypeMap[diaryType] || diaryType;
      console.log(`📌 Mapped diary type: ${diaryType} → ${entryType}`);
      console.log(`💰 EXP to award: ${JOURNAL_ENTRY_EXP}`);

      // Use transaction to atomically update user and create ledger entry
      console.log(`\n💳 STARTING FIRESTORE TRANSACTION`);
      
      await admin.firestore().runTransaction(async (transaction) => {
        const userRef = admin.firestore().collection('users').doc(userId);
        
        console.log(`\n📖 Step 1: Reading user document...`);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error(`User ${userId} not found in users collection`);
        }

        const userData = userDoc.data();
        const currentLevel = userData?.level || 1;
        const currentExp = userData?.exp || 0;
        
        console.log(`✅ User found!`);
        console.log(`   Current Level: ${currentLevel}`);
        console.log(`   Current EXP: ${currentExp}`);

        // Calculate new EXP and level
        const newTotalExp = currentExp + JOURNAL_ENTRY_EXP;
        const levelResult = determineNewLevel(newTotalExp, currentLevel);

        console.log(`\n🔢 Step 2: Calculating new level...`);
        console.log(`   Old EXP: ${currentExp}`);
        console.log(`   + Award: ${JOURNAL_ENTRY_EXP}`);
        console.log(`   = New EXP: ${newTotalExp}`);
        console.log(`   Old Level: ${currentLevel}`);
        console.log(`   New Level: ${levelResult.newLevel}`);
        console.log(`   Level Up: ${levelResult.leveledUp ? 'YES! 🎉' : 'No'}`);

        // Update user document
        console.log(`\n📝 Step 3: Updating user document...`);
        transaction.update(userRef, {
          exp: newTotalExp,
          level: levelResult.newLevel,
        });
        console.log(`✅ User document queued for update`);

        // Create ledger entry for journal entry
        console.log(`\n📋 Step 4: Creating EXP ledger entry...`);
        const ledgerRef = admin.firestore().collection('exp_ledger').doc();
        const ledgerData = {
          userId,
          entryType,
          expAwarded: JOURNAL_ENTRY_EXP,
          score: 1,
          oldLevel: currentLevel,
          newLevel: levelResult.newLevel,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        
        console.log(`   Ledger ID: ${ledgerRef.id}`);
        console.log(`   Entry Type: ${entryType}`);
        console.log(`   User ID: ${userId}`);
        console.log(`   Old Level: ${currentLevel} → New Level: ${levelResult.newLevel}`);
        
        transaction.set(ledgerRef, ledgerData);
        console.log(`✅ Ledger entry queued for creation`);

        // Log summary
        const summary = `✓ Journal entry EXP awarded: User ${userId}: +${JOURNAL_ENTRY_EXP} EXP, Level ${currentLevel} → ${levelResult.newLevel}${levelResult.leveledUp ? ' 🎉 LEVEL UP!' : ''}`;
        console.log(`\n${summary}`);
      });

      const executionTime = Date.now() - startTime;
      console.log(`\n⏱️  Transaction completed successfully in ${executionTime}ms`);
      console.log(`\n✨ SUCCESS: Journal entry ${entryId} processed!`);
      console.log('═══════════════════════════════════════════════════════════\n');
      
    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`\n❌ ERROR in journal entry processing (after ${executionTime}ms)`);
      console.error(`Entry ID: ${entryId}`);
      console.error(`Error message: ${error instanceof Error ? error.message : String(error)}`);
      console.error(`Stack trace: ${error instanceof Error ? error.stack : 'N/A'}`);
      console.log('═══════════════════════════════════════════════════════════\n');
      // Don't rethrow - let the function complete so Firestore doesn't retry infinitely
    }
  });
