"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.awardUrgeSurfingActivityExp = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const exp_utils_1 = require("./utils/exp-utils");
/**
 * Cloud Function: Award EXP for Urge Surfing Activities
 *
 * Triggered when urge surfing activities are added/updated.
 * Awards 5 EXP for each NEW activity added.
 *
 * Logging: Logs all steps for debugging and monitoring
 */
exports.awardUrgeSurfingActivityExp = functions.firestore
    .document('users/{userId}/urgeSurfingActivities/activities')
    .onWrite(async (change, context) => {
    const { userId } = context.params;
    const startTime = Date.now();
    console.log('═══════════════════════════════════════════════════════════');
    console.log('🌊 URGE SURFING ACTIVITY EXP AWARD FUNCTION TRIGGERED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📍 Path: users/${userId}/urgeSurfingActivities/activities`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`⏰ Trigger Time: ${new Date().toISOString()}`);
    try {
        // Get before and after data
        const beforeData = change.before.exists ? change.before.data() : null;
        const afterData = change.after.exists ? change.after.data() : null;
        console.log(`\n🔍 ANALYZING ACTIVITY CHANGES`);
        // If document was deleted, skip
        if (!afterData) {
            console.log(`⚠️  SKIPPING: Document deleted`);
            console.log('═══════════════════════════════════════════════════════════\n');
            return;
        }
        const beforeActivities = (beforeData === null || beforeData === void 0 ? void 0 : beforeData.activities) || [];
        const afterActivities = (afterData === null || afterData === void 0 ? void 0 : afterData.activities) || [];
        console.log(`   Activities before: ${beforeActivities.length}`);
        console.log(`   Activities after: ${afterActivities.length}`);
        // Count NEW activities (activities that were added, not updated)
        const beforeIds = new Set(beforeActivities.map((a) => a.id));
        const newActivities = afterActivities.filter((a) => !beforeIds.has(a.id));
        const newActivityCount = newActivities.length;
        console.log(`   New activities added: ${newActivityCount}`);
        // If no new activities, skip
        if (newActivityCount === 0) {
            console.log(`⚠️  SKIPPING: No new activities added (update or delete operation)`);
            console.log('═══════════════════════════════════════════════════════════\n');
            return;
        }
        console.log(`✅ Found ${newActivityCount} new activities, proceeding...`);
        const EXP_PER_ACTIVITY = 5;
        const totalExp = EXP_PER_ACTIVITY * newActivityCount;
        const entryType = 'urge_surfing_activity';
        console.log(`💰 EXP per activity: ${EXP_PER_ACTIVITY}`);
        console.log(`💰 Total EXP to award: ${totalExp}`);
        // List new activities
        console.log(`\n📝 New activities:`);
        newActivities.forEach((activity, index) => {
            console.log(`   ${index + 1}. ${activity.name || 'Unnamed'}`);
        });
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
            const newTotalExp = currentExp + totalExp;
            const levelResult = (0, exp_utils_1.determineNewLevel)(newTotalExp, currentLevel);
            console.log(`\n🔢 Step 2: Calculating new level...`);
            console.log(`   Old EXP: ${currentExp}`);
            console.log(`   + Award: ${totalExp} (${newActivityCount} activities × ${EXP_PER_ACTIVITY} EXP)`);
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
            // Create ledger entry for urge surfing activities
            console.log(`\n📋 Step 4: Creating EXP ledger entry...`);
            const ledgerRef = admin.firestore().collection('exp_ledger').doc();
            const ledgerData = {
                userId,
                entryType,
                expAwarded: totalExp,
                score: newActivityCount, // Number of activities added
                oldLevel: currentLevel,
                newLevel: levelResult.newLevel,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            console.log(`   Ledger ID: ${ledgerRef.id}`);
            console.log(`   Entry Type: ${entryType}`);
            console.log(`   User ID: ${userId}`);
            console.log(`   Activities Added: ${newActivityCount}`);
            console.log(`   Old Level: ${currentLevel} → New Level: ${levelResult.newLevel}`);
            transaction.set(ledgerRef, ledgerData);
            console.log(`✅ Ledger entry queued for creation`);
            // Log summary
            const summary = `✓ Urge Surfing Activity EXP awarded: User ${userId}: +${totalExp} EXP (${newActivityCount} activities), Level ${currentLevel} → ${levelResult.newLevel}${levelResult.leveledUp ? ' 🎉 LEVEL UP!' : ''}`;
            console.log(`\n${summary}`);
        });
        const executionTime = Date.now() - startTime;
        console.log(`\n⏱️  Transaction completed successfully in ${executionTime}ms`);
        console.log(`\n✨ SUCCESS: ${newActivityCount} urge surfing activities processed!`);
        console.log('═══════════════════════════════════════════════════════════\n');
    }
    catch (error) {
        const executionTime = Date.now() - startTime;
        console.error(`\n❌ ERROR in urge surfing activity processing (after ${executionTime}ms)`);
        console.error(`Error message: ${error instanceof Error ? error.message : String(error)}`);
        console.error(`Stack trace: ${error instanceof Error ? error.stack : 'N/A'}`);
        console.log('═══════════════════════════════════════════════════════════\n');
        // Don't rethrow - let the function complete so Firestore doesn't retry infinitely
    }
});
//# sourceMappingURL=awardUrgeSurfingActivityExp.js.map