"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendDailyAccountabilityReminder = exports.sendDailyEducationProgress = exports.sendDailyProgressReview = exports.sendDailyMotivationalNotification = exports.sendDailyNotification = exports.awardUrgeSurfingActivityExp = exports.awardMealPlanUpdateExp = exports.awardExerciseExp = exports.awardJournalEntryExp = exports.validateQuiz = void 0;
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
// Import and export journal entry EXP function
var awardJournalEntryExp_1 = require("./awardJournalEntryExp");
Object.defineProperty(exports, "awardJournalEntryExp", { enumerable: true, get: function () { return awardJournalEntryExp_1.awardJournalEntryExp; } });
// Import and export exercise EXP functions
var awardExerciseExp_1 = require("./awardExerciseExp");
Object.defineProperty(exports, "awardExerciseExp", { enumerable: true, get: function () { return awardExerciseExp_1.awardExerciseExp; } });
Object.defineProperty(exports, "awardMealPlanUpdateExp", { enumerable: true, get: function () { return awardExerciseExp_1.awardMealPlanUpdateExp; } });
// Import and export urge surfing activity EXP function
var awardUrgeSurfingActivityExp_1 = require("./awardUrgeSurfingActivityExp");
Object.defineProperty(exports, "awardUrgeSurfingActivityExp", { enumerable: true, get: function () { return awardUrgeSurfingActivityExp_1.awardUrgeSurfingActivityExp; } });
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
        // Get current week number (simplified - assuming week 1 for now)
        const currentWeek = 1;
        const foodDiariesSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('weeks')
            .doc(`week_${currentWeek}`)
            .collection('foodDiaries')
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
            .collection('weeks')
            .doc(`week_${currentWeek}`)
            .collection('weightDiaries')
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
// Helper function to fetch comprehensive progress data from Firestore
async function fetchProgressContext(userId) {
    try {
        // Get user data
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return null;
        }
        const userData = userDoc.data();
        // Get current week number (simplified - assuming week 1 for now)
        const currentWeek = 1;
        // Get food diary entries for the current week
        const foodDiariesSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('weeks')
            .doc(`week_${currentWeek}`)
            .collection('foodDiaries')
            .orderBy('createdAt', 'desc')
            .get();
        const bingeCount = foodDiariesSnapshot.docs.filter(doc => doc.data().isBinge === true).length;
        const totalMeals = foodDiariesSnapshot.docs.length;
        const bingeRate = totalMeals > 0 ? (bingeCount / totalMeals * 100).toFixed(1) : 0;
        // Get weight diary entries for trend analysis
        const weightDiariesSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('weeks')
            .doc(`week_${currentWeek}`)
            .collection('weightDiaries')
            .orderBy('createdAt', 'desc')
            .limit(5)
            .get();
        const weightEntries = weightDiariesSnapshot.docs.map(doc => doc.data());
        // Get body image diary entries
        const bodyImageSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('weeks')
            .doc(`week_${currentWeek}`)
            .collection('bodyImageDiaries')
            .orderBy('checkTime', 'desc')
            .get();
        const bodyImageCount = bodyImageSnapshot.size;
        // Get completed lessons count
        const completedLessonsSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('completed_lessons')
            .get();
        // Calculate progress metrics
        const daysSinceStart = Math.floor((Date.now() - ((userData === null || userData === void 0 ? void 0 : userData.createdAt) || Date.now())) / (1000 * 60 * 60 * 24));
        const lessonsCompleted = completedLessonsSnapshot.size;
        const avgMealsPerDay = daysSinceStart > 0 ? (totalMeals / daysSinceStart).toFixed(1) : 0;
        return {
            firstName: (userData === null || userData === void 0 ? void 0 : userData.firstName) || 'there',
            level: (userData === null || userData === void 0 ? void 0 : userData.level) || 1,
            exp: (userData === null || userData === void 0 ? void 0 : userData.exp) || 0,
            daysSinceStart: daysSinceStart,
            totalMeals: totalMeals,
            bingeCount: bingeCount,
            bingeRate: bingeRate,
            avgMealsPerDay: avgMealsPerDay,
            weightEntries: weightEntries,
            bodyImageCount: bodyImageCount,
            completedLessons: lessonsCompleted,
            latestWeight: weightEntries.length > 0 ? `${weightEntries[0].weight} ${weightEntries[0].unit}` : null,
        };
    }
    catch (error) {
        console.error(`Error fetching progress context for ${userId}:`, error);
        return null;
    }
}
// Helper function to fetch education lesson progress data from Firestore
async function fetchEducationProgressContext(userId) {
    try {
        // Get user data
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return null;
        }
        const userData = userDoc.data();
        // Get completed lessons with details
        const completedLessonsSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('completed_lessons')
            .orderBy('completedAt', 'desc')
            .get();
        const completedLessons = completedLessonsSnapshot.docs.map(doc => {
            const data = doc.data();
            return Object.assign({ lessonId: doc.id, completedAt: data.completedAt }, data);
        });
        // Get recent lesson completions (last 7 days)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        const recentLessons = completedLessons.filter(lesson => lesson.completedAt && lesson.completedAt.toDate() > weekAgo);
        // Calculate education metrics
        const totalLessonsCompleted = completedLessons.length;
        const recentLessonsCompleted = recentLessons.length;
        const daysSinceStart = Math.floor((Date.now() - ((userData === null || userData === void 0 ? void 0 : userData.createdAt) || Date.now())) / (1000 * 60 * 60 * 24));
        const avgLessonsPerWeek = daysSinceStart > 0 ? (totalLessonsCompleted / (daysSinceStart / 7)).toFixed(1) : 0;
        // Get user's current level and experience
        const currentLevel = (userData === null || userData === void 0 ? void 0 : userData.level) || 1;
        const currentExp = (userData === null || userData === void 0 ? void 0 : userData.exp) || 0;
        // Determine learning streak (consecutive days with lesson completion)
        let learningStreak = 0;
        const today = new Date();
        for (let i = 0; i < 30; i++) { // Check last 30 days
            const checkDate = new Date(today);
            checkDate.setDate(today.getDate() - i);
            const dayStart = new Date(checkDate.getFullYear(), checkDate.getMonth(), checkDate.getDate());
            const dayEnd = new Date(dayStart.getTime() + 24 * 60 * 60 * 1000);
            const hasLessonOnDay = completedLessons.some(lesson => {
                if (!lesson.completedAt)
                    return false;
                const lessonDate = lesson.completedAt.toDate();
                return lessonDate >= dayStart && lessonDate < dayEnd;
            });
            if (hasLessonOnDay) {
                learningStreak++;
            }
            else {
                break;
            }
        }
        return {
            firstName: (userData === null || userData === void 0 ? void 0 : userData.firstName) || 'there',
            level: currentLevel,
            exp: currentExp,
            totalLessonsCompleted: totalLessonsCompleted,
            recentLessonsCompleted: recentLessonsCompleted,
            avgLessonsPerWeek: avgLessonsPerWeek,
            learningStreak: learningStreak,
            daysSinceStart: daysSinceStart,
            recentLessons: recentLessons.slice(0, 3), // Last 3 lessons for context
        };
    }
    catch (error) {
        console.error(`Error fetching education progress context for ${userId}:`, error);
        return null;
    }
}
// Helper function to fetch to-do list data and completion status from Firestore
async function fetchTodoContext(userId) {
    try {
        // Get user data
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            return null;
        }
        const userData = userDoc.data();
        // Get today's date range
        const today = new Date();
        const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
        const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
        // Get all to-do items for the user
        const todosSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('todos')
            .get();
        const allTodos = todosSnapshot.docs.map(doc => {
            const data = doc.data();
            return Object.assign({ id: doc.id, dueDate: data.dueDate, isCompleted: data.isCompleted, completedAt: data.completedAt, title: data.title }, data);
        });
        // Filter for today's tasks
        const todayTodos = allTodos.filter(todo => {
            var _a;
            const dueDate = ((_a = todo.dueDate) === null || _a === void 0 ? void 0 : _a.toDate()) || new Date(todo.dueDate);
            return dueDate >= startOfDay && dueDate < endOfDay;
        });
        // Separate completed and pending tasks
        const completedTodos = todayTodos.filter(todo => todo.isCompleted === true);
        const pendingTodos = todayTodos.filter(todo => todo.isCompleted === false);
        // Get overdue tasks (from previous days)
        const overdueTodos = allTodos.filter(todo => {
            var _a;
            if (todo.isCompleted)
                return false;
            const dueDate = ((_a = todo.dueDate) === null || _a === void 0 ? void 0 : _a.toDate()) || new Date(todo.dueDate);
            return dueDate < startOfDay;
        });
        // Calculate completion rate for today
        const completionRate = todayTodos.length > 0 ? (completedTodos.length / todayTodos.length * 100).toFixed(1) : 0;
        // Get recent completion history (last 7 days)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        const recentCompletedTodos = allTodos.filter(todo => {
            var _a;
            if (!todo.isCompleted || !todo.completedAt)
                return false;
            const completedAt = ((_a = todo.completedAt) === null || _a === void 0 ? void 0 : _a.toDate()) || new Date(todo.completedAt);
            return completedAt >= weekAgo;
        });
        return {
            firstName: (userData === null || userData === void 0 ? void 0 : userData.firstName) || 'there',
            level: (userData === null || userData === void 0 ? void 0 : userData.level) || 1,
            exp: (userData === null || userData === void 0 ? void 0 : userData.exp) || 0,
            todayTodosCount: todayTodos.length,
            completedTodosCount: completedTodos.length,
            pendingTodosCount: pendingTodos.length,
            overdueTodosCount: overdueTodos.length,
            completionRate: completionRate,
            recentCompletedCount: recentCompletedTodos.length,
            pendingTodos: pendingTodos.slice(0, 3), // Top 3 pending tasks
            overdueTodos: overdueTodos.slice(0, 2), // Top 2 overdue tasks
        };
    }
    catch (error) {
        console.error(`Error fetching todo context for ${userId}:`, error);
        return null;
    }
}
// Helper function to generate personalized accountability message with OpenAI
async function generateAccountabilityMessage(todoContext, timeOfDay) {
    var _a, _b;
    try {
        const contextString = todoContext ? `
Accountability Context:
- Name: ${todoContext.firstName}
- Level: ${todoContext.level} (${todoContext.exp} XP)
- Today's tasks: ${todoContext.todayTodosCount}
- Completed today: ${todoContext.completedTodosCount}
- Pending today: ${todoContext.pendingTodosCount}
- Overdue tasks: ${todoContext.overdueTodosCount}
- Today's completion rate: ${todoContext.completionRate}%
- Recent completions (7 days): ${todoContext.recentCompletedCount}
${todoContext.pendingTodos.length > 0 ? `- Next tasks: ${todoContext.pendingTodos.map((t) => t.title).join(', ')}` : ''}
${todoContext.overdueTodos.length > 0 ? `- Overdue: ${todoContext.overdueTodos.map((t) => t.title).join(', ')}` : ''}
- Time of day: ${timeOfDay}
` : '';
        const openai = getOpenAI();
        const completion = await openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: [
                {
                    role: 'system',
                    content: `You are a supportive accountability partner helping someone stay on track with their daily recovery tasks. Generate a MOBILE PUSH NOTIFICATION message that:

MOBILE NOTIFICATION REQUIREMENTS:
- MAXIMUM 60 characters total (very short!)
- Single sentence only
- No line breaks or special characters
- Easy to read on small mobile screens
- Focus on accountability and task completion

CONTENT GUIDELINES:
- Be encouraging but gently accountable
- Acknowledge progress made or remind about pending tasks
- Use time-appropriate language (morning/afternoon/evening)
- Avoid specific numbers or sensitive data
- Focus on ONE key message
- Use simple, clear language
- End with motivation or gentle nudge
- Be warm but action-oriented

TIME-SPECIFIC EXAMPLES:
Morning (9am): "Good morning! Ready to tackle today's goals?"
Afternoon (4pm): "How's your day going? Keep up the momentum!"
Evening (8pm): "Almost there! Finish strong today"

Generate ONLY the notification text, nothing else.`
                },
                {
                    role: 'user',
                    content: `Generate a personalized accountability message for this user's ${timeOfDay} check-in.\n\n${contextString}`
                }
            ],
            max_tokens: 50,
            temperature: 0.7,
        });
        return ((_b = (_a = completion.choices[0]) === null || _a === void 0 ? void 0 : _a.message) === null || _b === void 0 ? void 0 : _b.content) || 'You\'ve got this! Stay focused 💚';
    }
    catch (error) {
        console.error('Error generating accountability message:', error);
        // Return a default encouraging message if OpenAI fails
        return 'You\'ve got this! Stay focused 💚';
    }
}
// Helper function to generate personalized education progress message with OpenAI
async function generateEducationProgressMessage(educationContext) {
    var _a, _b;
    try {
        const contextString = educationContext ? `
Education Progress Context:
- Name: ${educationContext.firstName}
- Level: ${educationContext.level} (${educationContext.exp} XP)
- Total lessons completed: ${educationContext.totalLessonsCompleted}
- Recent lessons (last 7 days): ${educationContext.recentLessonsCompleted}
- Average lessons per week: ${educationContext.avgLessonsPerWeek}
- Learning streak: ${educationContext.learningStreak} days
- Days in recovery: ${educationContext.daysSinceStart}
${educationContext.recentLessons.length > 0 ? `- Recent lessons: ${educationContext.recentLessons.map((l) => l.lessonId).join(', ')}` : ''}
` : '';
        const openai = getOpenAI();
        const completion = await openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: [
                {
                    role: 'system',
                    content: `You are a supportive education coach reviewing someone's learning progress in binge eating disorder recovery. Generate a MOBILE PUSH NOTIFICATION message that:

MOBILE NOTIFICATION REQUIREMENTS:
- MAXIMUM 60 characters total (very short!)
- Single sentence only
- No line breaks or special characters
- Easy to read on small mobile screens
- Focus on learning achievements and progress

CONTENT GUIDELINES:
- Acknowledge their learning progress and dedication
- Highlight educational achievements or consistency
- Be encouraging about their knowledge growth
- Avoid specific numbers or sensitive data
- Focus on ONE key learning achievement
- Use simple, clear language
- End with motivation to continue learning
- Be warm and supportive

EXAMPLES OF GOOD EDUCATION NOTIFICATIONS:
- "Your learning journey inspires me! Keep growing 💚"
- "Knowledge is power. You're doing amazing!"
- "Every lesson counts. You're getting stronger!"
- "Your dedication to learning shows. Keep it up!"

Generate ONLY the notification text, nothing else.`
                },
                {
                    role: 'user',
                    content: `Generate a personalized education progress message for this user's daily learning check-in.\n\n${contextString}`
                }
            ],
            max_tokens: 50,
            temperature: 0.7,
        });
        return ((_b = (_a = completion.choices[0]) === null || _a === void 0 ? void 0 : _a.message) === null || _b === void 0 ? void 0 : _b.content) || 'Your learning journey matters! Keep growing 💚';
    }
    catch (error) {
        console.error('Error generating education progress message:', error);
        // Return a default encouraging message if OpenAI fails
        return 'Your learning journey matters! Keep growing 💚';
    }
}
// Helper function to generate personalized progress review message with OpenAI
async function generateProgressReviewMessage(progressContext) {
    var _a, _b;
    try {
        const contextString = progressContext ? `
Progress Context:
- Name: ${progressContext.firstName}
- Level: ${progressContext.level} (${progressContext.exp} XP)
- Days in recovery: ${progressContext.daysSinceStart}
- Total meals logged: ${progressContext.totalMeals}
- Average meals per day: ${progressContext.avgMealsPerDay}
- Binge episodes this week: ${progressContext.bingeCount}
- Binge rate: ${progressContext.bingeRate}%
- Body image checks: ${progressContext.bodyImageCount}
- Lessons completed: ${progressContext.completedLessons}
${progressContext.latestWeight ? `- Latest weight: ${progressContext.latestWeight}` : ''}
` : '';
        const openai = getOpenAI();
        const completion = await openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: [
                {
                    role: 'system',
                    content: `You are a supportive recovery coach reviewing someone's progress in binge eating disorder recovery. Generate a MOBILE PUSH NOTIFICATION message that:

MOBILE NOTIFICATION REQUIREMENTS:
- MAXIMUM 60 characters total (very short!)
- Single sentence only
- No line breaks or special characters
- Easy to read on small mobile screens
- Focus on progress and achievements

CONTENT GUIDELINES:
- Acknowledge their progress and efforts
- Highlight positive changes or consistency
- Be encouraging about their journey
- Avoid specific numbers or sensitive data
- Focus on ONE key achievement or progress
- Use simple, clear language
- End with motivation to continue
- Be warm and supportive

EXAMPLES OF GOOD PROGRESS NOTIFICATIONS:
- "Your consistency is inspiring! Keep it up 💚"
- "Progress takes courage. You're doing great!"
- "Every day counts. You're stronger than you know"
- "Your dedication shows. Keep going!"

Generate ONLY the notification text, nothing else.`
                },
                {
                    role: 'user',
                    content: `Generate a personalized progress review message for this user's daily check-in.\n\n${contextString}`
                }
            ],
            max_tokens: 50,
            temperature: 0.7,
        });
        return ((_b = (_a = completion.choices[0]) === null || _a === void 0 ? void 0 : _a.message) === null || _b === void 0 ? void 0 : _b.content) || 'Your progress matters! Keep going 💚';
    }
    catch (error) {
        console.error('Error generating progress review message:', error);
        // Return a default encouraging message if OpenAI fails
        return 'Your progress matters! Keep going 💚';
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
                    content: `You are a compassionate recovery companion for someone with binge eating disorder. Generate a MOBILE PUSH NOTIFICATION message that is:

MOBILE NOTIFICATION REQUIREMENTS:
- MAXIMUM 60 characters total (very short!)
- Single sentence only
- No line breaks or special characters
- Easy to read on small mobile screens
- Instant impact and motivation

CONTENT GUIDELINES:
- Acknowledge their progress briefly
- Offer gentle encouragement
- Be warm and supportive
- Avoid specific numbers, data, or sensitive details
- Focus on ONE positive aspect
- Use simple, clear language
- End with hope or motivation
- Be conversational and authentic

EXAMPLES OF GOOD MOBILE NOTIFICATIONS:
- "You're making progress! Keep going 💚"
- "Every step counts. You've got this!"
- "Your strength inspires me today"
- "Small wins lead to big changes"

Generate ONLY the notification text, nothing else.`
                },
                {
                    role: 'user',
                    content: `Generate a personalized mobile push notification message for this user's daily motivation.\n\n${contextString}`
                }
            ],
            max_tokens: 50,
            temperature: 0.7,
        });
        return ((_b = (_a = completion.choices[0]) === null || _a === void 0 ? void 0 : _a.message) === null || _b === void 0 ? void 0 : _b.content) || 'You\'re doing great! Keep going 💚';
    }
    catch (error) {
        console.error('Error generating motivational message:', error);
        // Return a default encouraging message if OpenAI fails
        return 'You\'re doing great! Keep going 💚';
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
                            title: 'Gentle reminder 🌱',
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
// Daily progress review notification function - sends personalized AI-generated progress reviews to all users
exports.sendDailyProgressReview = functions.pubsub
    .schedule('0 12 * * *') // At 12pm daily
    .timeZone('America/Chicago')
    .onRun(async (context) => {
    const startTime = new Date();
    console.log('Starting daily progress review notification at:', startTime.toISOString());
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
            console.log(`Fetching batch of ${usersSnapshot.size} users for progress review notification`);
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                processedUsers++;
                try {
                    // Get user's FCM token
                    const userData = userDoc.data();
                    const fcmToken = userData.fcmToken;
                    if (isValidFCMToken(fcmToken)) {
                        users.push({ userId, fcmToken });
                        console.log(`Added user ${userId} for progress review notification`);
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
        // Send personalized progress review notifications to each user
        if (users.length > 0) {
            console.log(`Generating personalized progress reviews for ${users.length} users`);
            let successCount = 0;
            let failureCount = 0;
            const successfulUsers = [];
            const failedUsers = [];
            // Process users individually to generate personalized progress reviews
            for (let i = 0; i < users.length; i++) {
                const user = users[i];
                console.log(`[${i + 1}/${users.length}] Processing progress review for user ${user.userId}`);
                try {
                    // Fetch comprehensive progress context from Firestore
                    const progressContext = await fetchProgressContext(user.userId);
                    // Generate personalized progress review message with OpenAI
                    const progressReviewMessage = await generateProgressReviewMessage(progressContext);
                    console.log(`Generated progress review for ${user.userId}: ${progressReviewMessage.substring(0, 50)}...`);
                    // Send personalized progress review notification
                    const message = {
                        notification: {
                            title: 'Your Progress Update 📊',
                            body: progressReviewMessage,
                        },
                        data: {
                            type: 'progress_review',
                            timestamp: new Date().toISOString(),
                        },
                        token: user.fcmToken,
                    };
                    await admin.messaging().send(message);
                    successCount++;
                    successfulUsers.push(user.userId);
                    console.log(`✓ Successfully sent progress review notification to ${user.userId}`);
                }
                catch (individualError) {
                    failureCount++;
                    failedUsers.push(user.userId);
                    console.error(`✗ Failed to send progress review to ${user.userId}:`, individualError);
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
                type: 'progress_review_personalized',
                totalUsers: users.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers: processedUsers,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                method: 'personalized_ai_progress_review',
                successfulUsers: successfulUsers.length,
                failedUsers: failedUsers.length
            };
            await admin.firestore()
                .collection('notifications')
                .doc('progressReviewNotification')
                .set(notificationData, { merge: true });
            console.log(`Daily progress review notification completed:`);
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
            console.log('No users with valid FCM tokens found. Skipping progress review notification send.');
            // Still save the results even if no tokens
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'progress_review_personalized',
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
                .doc('progressReviewNotification')
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
        console.error('Error in daily progress review notification:', error);
        // Save error information to Firestore for debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        await admin.firestore()
            .collection('notifications')
            .doc('progressReviewNotification')
            .set({
            error: errorMessage,
            errorTime: admin.firestore.FieldValue.serverTimestamp(),
            type: 'progress_review_personalized'
        }, { merge: true });
        throw error;
    }
});
// Daily education progress notification function - sends personalized AI-generated education progress reviews to all users
exports.sendDailyEducationProgress = functions.pubsub
    .schedule('0 15 * * *') // At 3pm daily
    .timeZone('America/Chicago')
    .onRun(async (context) => {
    const startTime = new Date();
    console.log('Starting daily education progress notification at:', startTime.toISOString());
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
            console.log(`Fetching batch of ${usersSnapshot.size} users for education progress notification`);
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                processedUsers++;
                try {
                    // Get user's FCM token
                    const userData = userDoc.data();
                    const fcmToken = userData.fcmToken;
                    if (isValidFCMToken(fcmToken)) {
                        users.push({ userId, fcmToken });
                        console.log(`Added user ${userId} for education progress notification`);
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
        // Send personalized education progress notifications to each user
        if (users.length > 0) {
            console.log(`Generating personalized education progress reviews for ${users.length} users`);
            let successCount = 0;
            let failureCount = 0;
            const successfulUsers = [];
            const failedUsers = [];
            // Process users individually to generate personalized education progress reviews
            for (let i = 0; i < users.length; i++) {
                const user = users[i];
                console.log(`[${i + 1}/${users.length}] Processing education progress review for user ${user.userId}`);
                try {
                    // Fetch comprehensive education progress context from Firestore
                    const educationContext = await fetchEducationProgressContext(user.userId);
                    // Generate personalized education progress message with OpenAI
                    const educationProgressMessage = await generateEducationProgressMessage(educationContext);
                    console.log(`Generated education progress review for ${user.userId}: ${educationProgressMessage.substring(0, 50)}...`);
                    // Send personalized education progress notification
                    const message = {
                        notification: {
                            title: 'Your Learning Progress 📚',
                            body: educationProgressMessage,
                        },
                        data: {
                            type: 'education_progress',
                            timestamp: new Date().toISOString(),
                        },
                        token: user.fcmToken,
                    };
                    await admin.messaging().send(message);
                    successCount++;
                    successfulUsers.push(user.userId);
                    console.log(`✓ Successfully sent education progress notification to ${user.userId}`);
                }
                catch (individualError) {
                    failureCount++;
                    failedUsers.push(user.userId);
                    console.error(`✗ Failed to send education progress to ${user.userId}:`, individualError);
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
                type: 'education_progress_personalized',
                totalUsers: users.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers: processedUsers,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                method: 'personalized_ai_education_progress',
                successfulUsers: successfulUsers.length,
                failedUsers: failedUsers.length
            };
            await admin.firestore()
                .collection('notifications')
                .doc('educationProgressNotification')
                .set(notificationData, { merge: true });
            console.log(`Daily education progress notification completed:`);
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
            console.log('No users with valid FCM tokens found. Skipping education progress notification send.');
            // Still save the results even if no tokens
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'education_progress_personalized',
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
                .doc('educationProgressNotification')
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
        console.error('Error in daily education progress notification:', error);
        // Save error information to Firestore for debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        await admin.firestore()
            .collection('notifications')
            .doc('educationProgressNotification')
            .set({
            error: errorMessage,
            errorTime: admin.firestore.FieldValue.serverTimestamp(),
            type: 'education_progress_personalized'
        }, { merge: true });
        throw error;
    }
});
// Daily accountability notification function - sends personalized AI-generated accountability reminders to all users
exports.sendDailyAccountabilityReminder = functions.pubsub
    .schedule('0 9,16,20 * * *') // At 9am, 4pm, and 8pm daily
    .timeZone('America/Chicago')
    .onRun(async (context) => {
    const startTime = new Date();
    const currentHour = startTime.getHours();
    // Determine time of day for personalized messaging
    let timeOfDay = 'morning';
    if (currentHour >= 9 && currentHour < 12) {
        timeOfDay = 'morning';
    }
    else if (currentHour >= 12 && currentHour < 17) {
        timeOfDay = 'afternoon';
    }
    else {
        timeOfDay = 'evening';
    }
    console.log(`Starting daily accountability notification at ${timeOfDay} (${startTime.toISOString()})`);
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
            console.log(`Fetching batch of ${usersSnapshot.size} users for accountability notification`);
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                processedUsers++;
                try {
                    // Get user's FCM token
                    const userData = userDoc.data();
                    const fcmToken = userData.fcmToken;
                    if (isValidFCMToken(fcmToken)) {
                        users.push({ userId, fcmToken });
                        console.log(`Added user ${userId} for accountability notification`);
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
        // Send personalized accountability notifications to each user
        if (users.length > 0) {
            console.log(`Generating personalized accountability reminders for ${users.length} users`);
            let successCount = 0;
            let failureCount = 0;
            const successfulUsers = [];
            const failedUsers = [];
            // Process users individually to generate personalized accountability messages
            for (let i = 0; i < users.length; i++) {
                const user = users[i];
                console.log(`[${i + 1}/${users.length}] Processing accountability reminder for user ${user.userId}`);
                try {
                    // Fetch comprehensive to-do context from Firestore
                    const todoContext = await fetchTodoContext(user.userId);
                    // Generate personalized accountability message with OpenAI
                    const accountabilityMessage = await generateAccountabilityMessage(todoContext, timeOfDay);
                    console.log(`Generated accountability message for ${user.userId}: ${accountabilityMessage.substring(0, 50)}...`);
                    // Send personalized accountability notification
                    const message = {
                        notification: {
                            title: 'Accountability Check-in 🤝',
                            body: accountabilityMessage,
                        },
                        data: {
                            type: 'accountability_reminder',
                            timestamp: new Date().toISOString(),
                            timeOfDay: timeOfDay,
                        },
                        token: user.fcmToken,
                    };
                    await admin.messaging().send(message);
                    successCount++;
                    successfulUsers.push(user.userId);
                    console.log(`✓ Successfully sent accountability notification to ${user.userId}`);
                }
                catch (individualError) {
                    failureCount++;
                    failedUsers.push(user.userId);
                    console.error(`✗ Failed to send accountability reminder to ${user.userId}:`, individualError);
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
                type: 'accountability_reminder_personalized',
                timeOfDay: timeOfDay,
                totalUsers: users.length,
                successCount: successCount,
                failureCount: failureCount,
                processedUsers: processedUsers,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                executionTime: new Date().getTime() - startTime.getTime(),
                method: 'personalized_ai_accountability',
                successfulUsers: successfulUsers.length,
                failedUsers: failedUsers.length
            };
            await admin.firestore()
                .collection('notifications')
                .doc('accountabilityNotification')
                .set(notificationData, { merge: true });
            console.log(`Daily accountability notification completed:`);
            console.log(`- Time of day: ${timeOfDay}`);
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
                timeOfDay,
            };
        }
        else {
            console.log('No users with valid FCM tokens found. Skipping accountability notification send.');
            // Still save the results even if no tokens
            const notificationData = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                type: 'accountability_reminder_personalized',
                timeOfDay: timeOfDay,
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
                .doc('accountabilityNotification')
                .set(notificationData, { merge: true });
            return {
                success: true,
                totalUsers: 0,
                successCount: 0,
                failureCount: 0,
                processedUsers,
                timeOfDay,
            };
        }
    }
    catch (error) {
        console.error('Error in daily accountability notification:', error);
        // Save error information to Firestore for debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        await admin.firestore()
            .collection('notifications')
            .doc('accountabilityNotification')
            .set({
            error: errorMessage,
            errorTime: admin.firestore.FieldValue.serverTimestamp(),
            type: 'accountability_reminder_personalized',
            timeOfDay: timeOfDay
        }, { merge: true });
        throw error;
    }
});
//# sourceMappingURL=index.js.map