"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.awardLessonExp = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const exp_utils_1 = require("./utils/exp-utils");
/**
 * Cloud Function: Award EXP for Lesson Completions
 *
 * Triggered when a lesson is marked as completed.
 * Awards 10 EXP and updates user level atomically.
 *
 * Logging: Logs all steps for debugging and monitoring
 */
exports.awardLessonExp = functions.firestore
    .document('user_progress/{userId}/completed_lessons/{lessonId}')
    .onCreate(async (snapshot, context) => {
    const { userId, lessonId } = context.params;
    const startTime = Date.now();
    console.log('═══════════════════════════════════════════════════════════');
    console.log('📚 LESSON EXP AWARD FUNCTION TRIGGERED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📍 Path: user_progress/${userId}/completed_lessons/${lessonId}`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`📖 Lesson ID: ${lessonId}`);
    console.log(`⏰ Trigger Time: ${new Date().toISOString()}`);
    try {
        const LESSON_EXP = 10;
        const entryType = 'lesson_completion';
        console.log(`💰 EXP to award: ${LESSON_EXP}`);
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
            const currentLevel = (userData === null || userData === void 0 ? void 0 : userData.level) || 1;
            const currentExp = (userData === null || userData === void 0 ? void 0 : userData.exp) || 0;
            console.log(`✅ User found!`);
            console.log(`   Current Level: ${currentLevel}`);
            console.log(`   Current EXP: ${currentExp}`);
            // Calculate new EXP and level
            const newTotalExp = currentExp + LESSON_EXP;
            const levelResult = (0, exp_utils_1.determineNewLevel)(newTotalExp, currentLevel);
            console.log(`\n🔢 Step 2: Calculating new level...`);
            console.log(`   Old EXP: ${currentExp}`);
            console.log(`   + Award: ${LESSON_EXP}`);
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
            // Create ledger entry for lesson completion
            console.log(`\n📋 Step 4: Creating EXP ledger entry...`);
            const ledgerRef = admin.firestore().collection('exp_ledger').doc();
            const ledgerData = {
                userId,
                entryType,
                expAwarded: LESSON_EXP,
                lessonId,
                oldLevel: currentLevel,
                newLevel: levelResult.newLevel,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            transaction.set(ledgerRef, ledgerData);
            console.log(`✅ EXP ledger entry queued for creation`);
            console.log(`   Entry Type: ${entryType}`);
            console.log(`   Lesson ID: ${lessonId}`);
            console.log(`   EXP Awarded: ${LESSON_EXP}`);
            console.log(`\n🎯 TRANSACTION COMPLETED SUCCESSFULLY`);
        });
        const duration = Date.now() - startTime;
        console.log(`\n✅ LESSON EXP AWARDED SUCCESSFULLY`);
        console.log(`   User: ${userId}`);
        console.log(`   Lesson: ${lessonId}`);
        console.log(`   EXP Awarded: ${LESSON_EXP}`);
        console.log(`   Duration: ${duration}ms`);
        console.log('═══════════════════════════════════════════════════════════\n');
    }
    catch (error) {
        console.error(`❌ ERROR in awardLessonExp:`, error);
        console.error(`   User ID: ${userId}`);
        console.error(`   Lesson ID: ${lessonId}`);
        console.error(`   Error Details:`, error);
        throw error;
    }
});
//# sourceMappingURL=awardLessonExp.js.map