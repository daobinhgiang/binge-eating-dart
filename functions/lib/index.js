"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendDailyMotivationalNotification = exports.sendDailyNotification = exports.validateQuiz = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const openai_1 = require("openai");
// Initialize Firebase Admin
admin.initializeApp();
// Lazy initialization of OpenAI
let openaiClient = null;
function getOpenAI() {
    var _a;
    if (!openaiClient) {
        const apiKey = process.env.OPENAI_API_KEY || ((_a = functions.config().openai) === null || _a === void 0 ? void 0 : _a.key);
        openaiClient = new openai_1.default({ apiKey });
    }
    return openaiClient;
}
// Import and export quiz validation function
var validateQuiz_1 = require("./validateQuiz");
Object.defineProperty(exports, "validateQuiz", { enumerable: true, get: function () { return validateQuiz_1.validateQuiz; } });
// Helper function to format time as HH:mm in Central Time
function formatTime(date) {
    // Convert to Central Time (handles both CST and CDT automatically)
    const centralTime = new Date(date.toLocaleString("en-US", { timeZone: "America/Chicago" }));
    return `${centralTime.getHours().toString().padStart(2, '0')}:${centralTime.getMinutes().toString().padStart(2, '0')}`;
}
// Helper function to check if user has valid FCM token
function isValidFCMToken(token) {
    return typeof token === 'string' && token.length > 0;
}
// Helper function to send FCM message with retry logic
async function sendFCMMessageWithRetry(message, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await admin.messaging().sendMulticast(message);
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            console.log(`Attempt ${attempt}/${maxRetries} failed:`, errorMessage);
            if (attempt === maxRetries) {
                throw error;
            }
            // Wait before retry (exponential backoff)
            const delay = Math.pow(2, attempt) * 1000; // 2s, 4s, 8s
            console.log(`Waiting ${delay}ms before retry...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
}
// Helper function to fetch user context data from Firestore
async function fetchUserContext(userId) {
    try {
        // Get user data
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return null;
        }
        const userData = userDoc.data();
        // Get recent food diary entries (last 7 days)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        const foodDiariesSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('food_diary')
            .where('createdAt', '>=', weekAgo.getTime())
            .orderBy('createdAt', 'desc')
            .limit(10)
            .get();
        const bingeCount = foodDiariesSnapshot.docs.filter(doc => doc.data().isBinge === true).length;
        const totalMeals = foodDiariesSnapshot.docs.length;
        // Get latest weight entry
        const weightDiariesSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('weight_diary')
            .orderBy('createdAt', 'desc')
            .limit(1)
            .get();
        const latestWeight = !weightDiariesSnapshot.empty ? weightDiariesSnapshot.docs[0].data() : null;
        // Get completed lessons count
        const completedLessonsSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('completed_lessons')
            .get();
        return {
            firstName: (userData === null || userData === void 0 ? void 0 : userData.firstName) || 'there',
            level: (userData === null || userData === void 0 ? void 0 : userData.level) || 1,
            exp: (userData === null || userData === void 0 ? void 0 : userData.exp) || 0,
            totalMeals: totalMeals,
            bingeCount: bingeCount,
            bingeRate: totalMeals > 0 ? (bingeCount / totalMeals * 100).toFixed(1) : 0,
            latestWeight: latestWeight ? `${latestWeight.weight} ${latestWeight.unit}` : null,
            completedLessons: completedLessonsSnapshot.size,
        };
    }
    catch (error) {
        console.error(`Error fetching user context for ${userId}:`, error);
        return null;
    }
}
// Helper function to generate personalized motivational message with OpenAI
async function generateMotivationalMessage(userContext) {
    var _a, _b;
    try {
        const contextString = userContext ? `
User Context:
- Name: ${userContext.firstName}
- Level: ${userContext.level} (${userContext.exp} XP)
- Recent meals logged: ${userContext.totalMeals}
- Binge episodes in last 7 days: ${userContext.bingeCount}
- Binge rate: ${userContext.bingeRate}%
- Completed lessons: ${userContext.completedLessons}
${userContext.latestWeight ? `- Latest weight: ${userContext.latestWeight}` : ''}
` : '';
        const openai = getOpenAI();
        const completion = await openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: [
                {
                    role: 'system',
                    content: `You are a compassionate recovery companion for someone with binge eating disorder. Generate a brief, personalized motivational message (2-3 sentences max) that:
- Acknowledges their progress and efforts
- Offers gentle encouragement
- Is warm and supportive
- Avoids mentioning specific numbers or data
- Focuses on one positive aspect
- Ends with hope or motivation
Keep it conversational and authentic.`
                },
                {
                    role: 'user',
                    content: `Generate a personalized motivational message for this user's check-in today.\n\n${contextString}`
                }
            ],
            max_tokens: 150,
            temperature: 0.8,
        });
        return ((_b = (_a = completion.choices[0]) === null || _a === void 0 ? void 0 : _a.message) === null || _b === void 0 ? void 0 : _b.content) || 'You\'re doing great on your recovery journey. Keep taking it one day at a time! 💚';
    }
    catch (error) {
        console.error('Error generating motivational message:', error);
        // Return a default encouraging message if OpenAI fails
        return 'You\'re doing great on your recovery journey. Keep taking it one day at a time! 💚';
    }
}
// Scheduled function that sends push notifications every 30 minutes starting at 6am
exports.sendDailyNotification = functions.pubsub
    .schedule('0,30 6-23 * * *') // Every 30 minutes from 6am to 11:30pm
    .timeZone('America/Chicago')
    .onRun(async (context) => {
    const startTime = new Date();
    console.log('Starting meal time notification at:', startTime.toISOString());
    try {
        // Get current time in HH:mm format
        const currentTime = formatTime(startTime);
        console.log('Current time:', currentTime);
        // Array to collect FCM tokens for users with matching meal times
        const arrayTokens = [];
        let processedUsers = 0;
        let usersWithMealTimes = 0;
        let usersWithTokens = 0;
        // Get all users with pagination to handle large user bases
        let lastDoc = null;
        const batchSize = 100;
        while (true) {
            let usersQuery = admin.firestore()
                .collection('users')
                .limit(batchSize);
            if (lastDoc) {
                usersQuery = usersQuery.startAfter(lastDoc);
            }
            const usersSnapshot = await usersQuery.get();
            if (usersSnapshot.empty) {
                break;
            }
            console.log(`Processing batch of ${usersSnapshot.size} users for daily notification`);
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                processedUsers++;
                try {
                    // Get user's regular eating settings
                    const regularEatingSnapshot = await admin.firestore()
                        .collection('users')
                        .doc(userId)
                        .collection('Regular Eating')
                        .orderBy('updatedAt', 'desc')
                        .limit(1)
                        .get();
                    if (regularEatingSnapshot.empty) {
                        continue;
                    }
                    const regularEatingData = regularEatingSnapshot.docs[0].data();
                    const mealTimes = regularEatingData.mealTimes || [];
                    if (mealTimes.length > 0) {
                        usersWithMealTimes++;
                        console.log(`User ${userId} has ${mealTimes.length} meal times:`, mealTimes);
                        // Check if current time matches any meal time
                        const hasMatchingMealTime = mealTimes.includes(currentTime);
                        if (hasMatchingMealTime) {
                            console.log(`User ${userId} has a meal at ${currentTime}`);
                            // Get user's FCM token
                            const userData = userDoc.data();
                            const fcmToken = userData.fcmToken;
                            if (isValidFCMToken(fcmToken)) {
                                arrayTokens.push(fcmToken);
                                usersWithTokens++;
                                console.log(`Added FCM token for user ${userId}`);
                            }
                            else {
                                console.log(`No valid FCM token found for user ${userId}`);
                            }
                        }
                        else {
                            console.log(`User ${userId} has no meal at ${currentTime}`);
                        }
                    }
                }
                catch (userError) {
                    console.error(`Error processing user ${userId}:`, userError);
                    // Continue processing other users even if one fails
                }
            }
            // Update pagination cursor
            lastDoc = usersSnapshot.docs[usersSnapshot.docs.length - 1];
            // Break if we got fewer docs than batch size (last batch)
            if (usersSnapshot.size < batchSize) {
                break;
            }
        }
        // Send push notifications to users with matching meal times
        if (arrayTokens.length > 0) {
            console.log(`Attempting to send notifications to ${arrayTokens.length} users with matching meal times`);
            let successCount = 0;
            let failureCount = 0;
            const failedTokens = [];
            const successfulTokens = [];
            // Process tokens in smaller batches to avoid 404 errors
            const batchSize = 500; // FCM multicast supports up to 500 tokens
            const batches = [];
            for (let i = 0; i < arrayTokens.length; i += batchSize) {
                batches.push(arrayTokens.slice(i, i + batchSize));
            }
            console.log(`Processing ${batches.length} batches of tokens`);
            for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
                const batch = batches[batchIndex];
                console.log(`Processing batch ${batchIndex + 1}/${batches.length} with ${batch.length} tokens`);
                try {
                    // Try multicast first for each batch
                    const message = {
                        notification: {
                            title: 'Fuck You reminder 🌱',
                            body: 'Eating regularly helps your body and mind. It\'s time for your meal.',
                        },
                        data: {
                            type: 'daily_reminder',
                            timestamp: new Date().toISOString(),
                        },
                        tokens: batch,
                    };
                    const response = await sendFCMMessageWithRetry(message);
                    successCount += response.successCount;
                    failureCount += response.failureCount;
                    console.log(`Batch ${batchIndex + 1}: Successfully sent to ${response.successCount} users, failed: ${response.failureCount}`);
                    // Track successful and failed tokens
                    response.responses.forEach((resp, idx) => {
                        if (resp.success) {
                            successfulTokens.push(batch[idx]);
                        }
                        else {
                            failedTokens.push(batch[idx]);
                            console.error(`Failed to send to token in batch ${batchIndex + 1}:`, resp.error);
                        }
                    });
                }
                catch (batchError) {
                    console.error(`Batch ${batchIndex + 1} failed with multicast, trying individual sends:`, batchError);
                    // If multicast fails for this batch, try individual sends
                    for (const token of batch) {
                        try {
                            const individualMessage = {
                                notification: {
                                    title: 'Gentle reminder 🌱',
                                    body: 'Eating regularly helps your body and mind. It\'s time for your meal.',
                                },
                                data: {
                                    type: 'daily_reminder',
                                    timestamp: new Date().toISOString(),
                                },
                                token: token,
                            };
                            await admin.messaging().send(individualMessage);
                            successCount++;
                            successfulTokens.push(token);
                            console.log(`Individual message sent successfully`);
                        }
                        catch (individualError) {
                            failureCount++;
                            failedTokens.push(token);
                            console.error(`Individual message failed:`, individualError);
                        }
                    }
                }
            }
            console.log(`Final results: Successfully sent to ${successCount} users, failed: ${failureCount}`);
            // Save notification results to Firestore
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'meal_time_reminder',
                currentTime: currentTime,
                totalTokens: arrayTokens.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers: processedUsers,
                usersWithMealTimes: usersWithMealTimes,
                usersWithTokens: usersWithTokens,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                method: 'batch_with_individual_fallback',
                successfulTokens: successfulTokens.length,
                failedTokens: failedTokens.length
            };
            await admin.firestore()
                .collection('notifications')
                .doc('dailyNotification')
                .set(notificationData, { merge: true });
            console.log(`Meal time notification completed:`);
            console.log(`- Processed ${processedUsers} users`);
            console.log(`- ${usersWithMealTimes} users have meal times configured`);
            console.log(`- ${usersWithTokens} users have valid FCM tokens and matching meal times`);
            console.log(`- Successfully sent to ${successCount} users`);
            console.log(`- Failed to send to ${failureCount} users`);
            console.log(`- Execution time: ${notificationData.executionTime}ms`);
            return {
                success: true,
                totalTokens: arrayTokens.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers,
                usersWithMealTimes,
                usersWithTokens
            };
        }
        else {
            console.log('No users with matching meal times found. Skipping notification send.');
            // Still save the results even if no tokens
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'meal_time_reminder',
                currentTime: currentTime,
                totalTokens: 0,
                successCount: 0,
                failureCount: 0,
                processedUsers: processedUsers,
                usersWithMealTimes: usersWithMealTimes,
                usersWithTokens: 0,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                message: 'No users with matching meal times found'
            };
            await admin.firestore()
                .collection('notifications')
                .doc('dailyNotification')
                .set(notificationData, { merge: true });
            return {
                success: true,
                totalTokens: 0,
                successCount: 0,
                failureCount: 0,
                processedUsers,
                usersWithMealTimes,
                usersWithTokens: 0
            };
        }
    }
    catch (error) {
        console.error('Error in meal time notification:', error);
        // Save error information to Firestore for debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        await admin.firestore()
            .collection('notifications')
            .doc('dailyNotification')
            .set({
            error: errorMessage,
            errorTime: admin.firestore.FieldValue.serverTimestamp(),
            type: 'meal_time_reminder',
            currentTime: formatTime(new Date())
        }, { merge: true });
        throw error;
    }
});
// Motivational notification function - sends personalized AI-generated messages to all users
exports.sendDailyMotivationalNotification = functions.pubsub
    .schedule('0 8,18 * * *') // At 8am and 6pm daily
    .timeZone('America/Chicago')
    .onRun(async (context) => {
    const startTime = new Date();
    console.log('Starting personalized motivational notification at:', startTime.toISOString());
    try {
        // Array to collect users with their data
        const users = [];
        let processedUsers = 0;
        // Get all users with pagination to handle large user bases
        let lastDoc = null;
        const batchSize = 100;
        while (true) {
            let usersQuery = admin.firestore()
                .collection('users')
                .limit(batchSize);
            if (lastDoc) {
                usersQuery = usersQuery.startAfter(lastDoc);
            }
            const usersSnapshot = await usersQuery.get();
            if (usersSnapshot.empty) {
                break;
            }
            console.log(`Fetching batch of ${usersSnapshot.size} users for motivational notification`);
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                processedUsers++;
                try {
                    // Get user's FCM token
                    const userData = userDoc.data();
                    const fcmToken = userData.fcmToken;
                    if (isValidFCMToken(fcmToken)) {
                        users.push({ userId, fcmToken });
                        console.log(`Added user ${userId} for personalized notification`);
                    }
                    else {
                        console.log(`No valid FCM token found for user ${userId}`);
                    }
                }
                catch (userError) {
                    console.error(`Error processing user ${userId}:`, userError);
                    // Continue processing other users even if one fails
                }
            }
            // Update pagination cursor
            lastDoc = usersSnapshot.docs[usersSnapshot.docs.length - 1];
            // Break if we got fewer docs than batch size (last batch)
            if (usersSnapshot.size < batchSize) {
                break;
            }
        }
        // Send personalized push notifications to each user
        if (users.length > 0) {
            console.log(`Generating personalized messages for ${users.length} users`);
            let successCount = 0;
            let failureCount = 0;
            const successfulUsers = [];
            const failedUsers = [];
            // Process users individually to generate personalized messages
            for (let i = 0; i < users.length; i++) {
                const user = users[i];
                console.log(`[${i + 1}/${users.length}] Processing user ${user.userId}`);
                try {
                    // Fetch user context from Firestore
                    const userContext = await fetchUserContext(user.userId);
                    // Generate personalized message with OpenAI
                    const personalizedMessage = await generateMotivationalMessage(userContext);
                    console.log(`Generated message for ${user.userId}: ${personalizedMessage.substring(0, 50)}...`);
                    // Send personalized notification
                    const message = {
                        notification: {
                            title: 'Your Daily Motivation 💚',
                            body: personalizedMessage,
                        },
                        data: {
                            type: 'motivational_reminder',
                            timestamp: new Date().toISOString(),
                        },
                        token: user.fcmToken,
                    };
                    await admin.messaging().send(message);
                    successCount++;
                    successfulUsers.push(user.userId);
                    console.log(`✓ Successfully sent personalized notification to ${user.userId}`);
                }
                catch (individualError) {
                    failureCount++;
                    failedUsers.push(user.userId);
                    console.error(`✗ Failed to send to ${user.userId}:`, individualError);
                }
                // Add a small delay to avoid rate limiting
                if (i < users.length - 1) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                }
            }
            console.log(`Final results: Successfully sent to ${successCount} users, failed: ${failureCount}`);
            // Save notification results to Firestore
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'motivational_reminder_personalized',
                totalUsers: users.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers: processedUsers,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                method: 'personalized_ai_generated',
                successfulUsers: successfulUsers.length,
                failedUsers: failedUsers.length
            };
            await admin.firestore()
                .collection('notifications')
                .doc('motivationalNotification')
                .set(notificationData, { merge: true });
            console.log(`Personalized motivational notification completed:`);
            console.log(`- Processed ${processedUsers} users`);
            console.log(`- ${users.length} users have valid FCM tokens`);
            console.log(`- Successfully sent to ${successCount} users`);
            console.log(`- Failed to send to ${failureCount} users`);
            console.log(`- Execution time: ${notificationData.executionTime}ms`);
            return {
                success: true,
                totalUsers: users.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers,
            };
        }
        else {
            console.log('No users with valid FCM tokens found. Skipping notification send.');
            // Still save the results even if no tokens
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'motivational_reminder_personalized',
                totalUsers: 0,
                successCount: 0,
                failureCount: 0,
                processedUsers: processedUsers,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                message: 'No users with valid FCM tokens found'
            };
            await admin.firestore()
                .collection('notifications')
                .doc('motivationalNotification')
                .set(notificationData, { merge: true });
            return {
                success: true,
                totalUsers: 0,
                successCount: 0,
                failureCount: 0,
                processedUsers,
            };
        }
    }
    catch (error) {
        console.error('Error in personalized motivational notification:', error);
        // Save error information to Firestore for debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        await admin.firestore()
            .collection('notifications')
            .doc('motivationalNotification')
            .set({
            error: errorMessage,
            errorTime: admin.firestore.FieldValue.serverTimestamp(),
            type: 'motivational_reminder_personalized'
        }, { merge: true });
        throw error;
    }
});
//# sourceMappingURL=index.js.map