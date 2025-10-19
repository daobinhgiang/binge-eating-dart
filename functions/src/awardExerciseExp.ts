import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { determineNewLevel } from './utils/exp-utils';

/**
 * Cloud Function: Award EXP for Exercise Completions
 * 
 * Triggered when an exercise is completed (problem solving, urge surfing, etc.).
 * Awards 10 EXP and updates user level atomically.
 * 
 * Logging: Logs all steps for debugging and monitoring
 */
export const awardExerciseExp = functions.firestore
  .document('users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}')
  .onCreate(async (snapshot, context) => {
    const { userId, exerciseType, exerciseId } = context.params;
    const startTime = Date.now();
    
    console.log('═══════════════════════════════════════════════════════════');
    console.log('🏋️ EXERCISE EXP AWARD FUNCTION TRIGGERED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📍 Path: users/${userId}/exercises/${exerciseType}/exercises/${exerciseId}`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`🎯 Exercise Type: ${exerciseType}`);
    console.log(`📝 Exercise ID: ${exerciseId}`);
    console.log(`⏰ Trigger Time: ${new Date().toISOString()}`);
    
    try {
      // Only process valid exercise types
      const validExerciseTypes = [
        'problemSolving',
        'urgeSurfing',
        'addressingSetbacks',
        'addressingOverconcern',
        'mealPlan'
      ];
      
      console.log(`\n🔍 VALIDATION STEP`);
      console.log(`Valid exercise types: ${validExerciseTypes.join(', ')}`);
      console.log(`Received exercise type: ${exerciseType}`);
      
      if (!validExerciseTypes.includes(exerciseType)) {
        console.log(`⚠️  SKIPPING: Invalid exercise type "${exerciseType}"`);
        console.log('═══════════════════════════════════════════════════════════\n');
        return;
      }

      console.log(`✅ Exercise type is valid, proceeding...`);

      // Variable EXP amounts based on exercise type
      const expAmounts: { [key: string]: number } = {
        'problemSolving': 12,
        'urgeSurfing': 10,
        'addressingSetbacks': 12,
        'addressingOverconcern': 12,
        'mealPlan': 15,  // First time creation
      };

      const exerciseTypeMap: { [key: string]: string } = {
        'problemSolving': 'problem_solving',
        'urgeSurfing': 'urge_surfing',
        'addressingSetbacks': 'addressing_setbacks',
        'addressingOverconcern': 'addressing_overconcern',
        'mealPlan': 'meal_planning',
      };

      const EXERCISE_EXP = expAmounts[exerciseType] || 10;
      const entryType = exerciseTypeMap[exerciseType] || exerciseType;
      console.log(`📌 Mapped exercise type: ${exerciseType} → ${entryType}`);
      console.log(`💰 EXP to award: ${EXERCISE_EXP}`);

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
        const newTotalExp = currentExp + EXERCISE_EXP;
        const levelResult = determineNewLevel(newTotalExp, currentLevel);

        console.log(`\n🔢 Step 2: Calculating new level...`);
        console.log(`   Old EXP: ${currentExp}`);
        console.log(`   + Award: ${EXERCISE_EXP}`);
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

        // Create ledger entry for exercise
        console.log(`\n📋 Step 4: Creating EXP ledger entry...`);
        const ledgerRef = admin.firestore().collection('exp_ledger').doc();
        const ledgerData = {
          userId,
          entryType,
          expAwarded: EXERCISE_EXP,
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
        const summary = `✓ Exercise EXP awarded: User ${userId}: +${EXERCISE_EXP} EXP, Level ${currentLevel} → ${levelResult.newLevel}${levelResult.leveledUp ? ' 🎉 LEVEL UP!' : ''}`;
        console.log(`\n${summary}`);
      });

      const executionTime = Date.now() - startTime;
      console.log(`\n⏱️  Transaction completed successfully in ${executionTime}ms`);
      console.log(`\n✨ SUCCESS: Exercise ${exerciseId} processed!`);
      console.log('═══════════════════════════════════════════════════════════\n');
      
    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`\n❌ ERROR in exercise processing (after ${executionTime}ms)`);
      console.error(`Exercise ID: ${exerciseId}`);
      console.error(`Error message: ${error instanceof Error ? error.message : String(error)}`);
      console.error(`Stack trace: ${error instanceof Error ? error.stack : 'N/A'}`);
      console.log('═══════════════════════════════════════════════════════════\n');
      // Don't rethrow - let the function complete so Firestore doesn't retry infinitely
    }
  });

/**
 * Cloud Function: Award EXP for Meal Plan Updates
 * 
 * Triggered when a meal plan is updated (not created).
 * Awards 3 EXP for updating an existing meal plan.
 * 
 * Logging: Logs all steps for debugging and monitoring
 */
export const awardMealPlanUpdateExp = functions.firestore
  .document('users/{userId}/exercises/mealPlan/exercises/{planId}')
  .onUpdate(async (change, context) => {
    const { userId, planId } = context.params;
    const startTime = Date.now();
    
    console.log('═══════════════════════════════════════════════════════════');
    console.log('🍽️ MEAL PLAN UPDATE EXP AWARD FUNCTION TRIGGERED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📍 Path: users/${userId}/exercises/mealPlan/exercises/${planId}`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`📝 Plan ID: ${planId}`);
    console.log(`⏰ Trigger Time: ${new Date().toISOString()}`);
    
    try {
      const UPDATE_EXP = 3;
      const entryType = 'meal_planning_update';
      
      console.log(`💰 EXP to award for update: ${UPDATE_EXP}`);

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
        const newTotalExp = currentExp + UPDATE_EXP;
        const levelResult = determineNewLevel(newTotalExp, currentLevel);

        console.log(`\n🔢 Step 2: Calculating new level...`);
        console.log(`   Old EXP: ${currentExp}`);
        console.log(`   + Award: ${UPDATE_EXP}`);
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

        // Create ledger entry for meal plan update
        console.log(`\n📋 Step 4: Creating EXP ledger entry...`);
        const ledgerRef = admin.firestore().collection('exp_ledger').doc();
        const ledgerData = {
          userId,
          entryType,
          expAwarded: UPDATE_EXP,
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
        const summary = `✓ Meal Plan Update EXP awarded: User ${userId}: +${UPDATE_EXP} EXP, Level ${currentLevel} → ${levelResult.newLevel}${levelResult.leveledUp ? ' 🎉 LEVEL UP!' : ''}`;
        console.log(`\n${summary}`);
      });

      const executionTime = Date.now() - startTime;
      console.log(`\n⏱️  Transaction completed successfully in ${executionTime}ms`);
      console.log(`\n✨ SUCCESS: Meal plan update ${planId} processed!`);
      console.log('═══════════════════════════════════════════════════════════\n');
      
    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`\n❌ ERROR in meal plan update processing (after ${executionTime}ms)`);
      console.error(`Plan ID: ${planId}`);
      console.error(`Error message: ${error instanceof Error ? error.message : String(error)}`);
      console.error(`Stack trace: ${error instanceof Error ? error.stack : 'N/A'}`);
      console.log('═══════════════════════════════════════════════════════════\n');
      // Don't rethrow - let the function complete so Firestore doesn't retry infinitely
    }
  });

