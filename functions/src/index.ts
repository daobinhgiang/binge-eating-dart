import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { PubSub } from "@google-cloud/pubsub";

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Initialize Pub/Sub client
const pubsub = new PubSub({
  projectId: "bed-app-ef8f8",
});

// Interface for Regular Eating settings
interface RegularEatingSettings {
  id: string;
  userId: string;
  mealIntervalHours: number;
  firstMealHour: number;
  firstMealMinute: number;
  createdAt: number;
  updatedAt: number;
}

// Interface for user notification tokens
interface UserNotificationToken {
  token: string;
  platform: string;
  createdAt: number;
}

/**
 * Cloud Function to send Regular Eating notifications
 * This function can be triggered manually via HTTP
 */
export const sendRegularEatingNotifications = functions.https.onRequest(async (req, res) => {
  try {
    const result = await processRegularEatingNotifications();
    res.status(200).json(result);
  } catch (error) {
    console.error("Error in sendRegularEatingNotifications:", error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

/**
 * Calculate meal times for today based on user settings
 */
function calculateMealTimesForToday(settings: RegularEatingSettings) {
  const mealTimes = [];
  
  // First meal
  const firstMeal = {
    hour: settings.firstMealHour,
    minute: settings.firstMealMinute,
    type: "breakfast",
    title: "🌅 Time for Breakfast!",
    body: "Start your day with a nourishing breakfast! Your regular eating schedule helps maintain healthy habits.",
  };
  mealTimes.push(firstMeal);
  
  // Calculate subsequent meals
  for (let i = 1; i < 4; i++) {
    const intervalMinutes = settings.mealIntervalHours * 60 * i;
    const totalMinutes = (settings.firstMealHour * 60 + settings.firstMealMinute) + intervalMinutes;
    
    const hour = Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    
    // Only add if it's reasonable eating hours (before 10 PM)
    if (hour < 22) {
      const mealTypes = ["lunch", "afternoon_snack", "dinner"];
      const mealTitles = ["☀️ Lunch Time!", "🌤️ Afternoon Snack!", "🌙 Dinner Time!"];
      const mealBodies = [
        `Time for lunch! Keep up with your ${settings.mealIntervalHours}h eating schedule.`,
        "Afternoon snack time! Stay consistent with your regular eating routine.",
        "Dinner time! You're doing great with your regular eating schedule.",
      ];
      
      mealTimes.push({
        hour,
        minute,
        type: mealTypes[i - 1] || "meal",
        title: mealTitles[i - 1] || "🍽️ Meal Reminder!",
        body: mealBodies[i - 1] || `Time for your regular meal! Stay consistent with your ${settings.mealIntervalHours}h eating schedule.`,
      });
    }
  }
  
  return mealTimes;
}

/**
 * Create notification object
 */
function createNotification(meal: any, settings: RegularEatingSettings) {
  return {
    title: meal.title,
    body: meal.body,
    data: {
      type: "regular_eating",
      mealType: meal.type,
      userId: settings.userId,
      clickAction: "FLUTTER_NOTIFICATION_CLICK",
    },
  };
}

/**
 * Remove invalid notification token from database
 */
async function removeInvalidToken(userId: string, token: string): Promise<void> {
  try {
    const tokensSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("notificationTokens")
      .where("token", "==", token)
      .get();
    
    const batch = db.batch();
    tokensSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Removed invalid token for user ${userId}`);
  } catch (error) {
    console.error(`Failed to remove invalid token for user ${userId}:`, error);
  }
}

/**
 * HTTP function to manually trigger notification check (for testing)
 */
export const triggerNotificationCheck = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Manual notification check triggered");
    
    res.status(200).json({
      success: true,
      message: "Manual trigger received - use sendRegularEatingNotifications for actual processing",
    });
  } catch (error) {
    console.error("Error in manual notification check:", error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

/**
 * Function to schedule notifications when user updates their Regular Eating settings
 */
export const scheduleRegularEatingNotifications = functions.firestore
  .document("users/{userId}/Regular Eating/{settingsId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    
    console.log(`New Regular Eating settings created for user ${userId}`);
    
    // The actual scheduling is handled by the cron job
    // This function just logs the event
    return null;
  });

/**
 * Function to handle Regular Eating settings updates
 */
export const updateRegularEatingNotifications = functions.firestore
  .document("users/{userId}/Regular Eating/{settingsId}")
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    
    console.log(`Regular Eating settings updated for user ${userId}`);
    
    // The actual scheduling is handled by the cron job
    // This function just logs the event
    return null;
  });

/**
 * Pub/Sub trigger function for cron job
 * This function is triggered by the Google Cloud Scheduler via Pub/Sub
 */
export const userNotificationCron = functions.pubsub
  .topic("cron-topic")
  .onPublish(async (message) => {
    console.log("Cron job triggered via Pub/Sub");
    console.log("Message data:", message.data ? message.data.toString() : "No data");
    
    try {
      // Call the existing notification function
      const result = await processRegularEatingNotifications();
      
      console.log("Cron job completed successfully:", result);
      return result;
    } catch (error) {
      console.error("Error in cron job:", error);
      throw error;
    }
  });

/**
 * Process Regular Eating notifications (extracted from the HTTP function)
 * This function contains the core logic for sending notifications
 */
async function processRegularEatingNotifications() {
  console.log("Starting Regular Eating notification check...");
  
  const now = new Date();
  const currentHour = now.getUTCHours();
  const currentMinute = now.getUTCMinutes();
  
  console.log(`Current time: ${currentHour}:${currentMinute}`);
  
  // Get all users with Regular Eating settings
  const usersSnapshot = await db.collectionGroup("Regular Eating").get();
  
  if (usersSnapshot.empty) {
    console.log("No Regular Eating settings found");
    return {
      success: true,
      message: "No Regular Eating settings found",
      notificationsSent: 0,
    };
  }
  
  const notificationsToSend: Array<{
    token: string;
    title: string;
    body: string;
    data: any;
  }> = [];
  
  for (const doc of usersSnapshot.docs) {
    const settings = doc.data() as RegularEatingSettings;
    
    // Calculate meal times for today
    const mealTimes = calculateMealTimesForToday(settings);
    
    // Check if current time matches any meal time (within 5 minutes tolerance)
    const matchingMeal = mealTimes.find(meal => {
      const timeDiff = Math.abs(
        (currentHour * 60 + currentMinute) - 
        (meal.hour * 60 + meal.minute)
      );
      return timeDiff <= 5; // 5 minutes tolerance
    });
    
    if (matchingMeal) {
      console.log(`Found matching meal for user ${settings.userId}: ${matchingMeal.type}`);
      
      // Get user's notification tokens
      const tokensSnapshot = await db
        .collection("users")
        .doc(settings.userId)
        .collection("notificationTokens")
        .get();
      
      if (!tokensSnapshot.empty) {
        const notification = createNotification(matchingMeal, settings);
        
        // Add notification for each token
        tokensSnapshot.docs.forEach(tokenDoc => {
          const tokenData = tokenDoc.data() as UserNotificationToken;
          notificationsToSend.push({
            token: tokenData.token,
            ...notification,
          });
        });
      }
    }
  }
  
  // Send all notifications
  if (notificationsToSend.length > 0) {
    console.log(`Sending ${notificationsToSend.length} notifications`);
    
    // Group notifications by token to avoid duplicates
    const tokenGroups = new Map<string, any[]>();
    notificationsToSend.forEach(notif => {
      if (!tokenGroups.has(notif.token)) {
        tokenGroups.set(notif.token, []);
      }
      tokenGroups.get(notif.token)!.push(notif);
    });
    
    // Send notifications in batches
    const batchPromises: Promise<any>[] = [];
    
    for (const [token, notifications] of tokenGroups) {
      // Send the first notification for each token
      const notification = notifications[0];
      
      const message = {
        token: token,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data,
        android: {
          notification: {
            channelId: "regular_eating_reminders",
            priority: "high" as const,
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body,
              },
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      
      batchPromises.push(
        messaging.send(message).catch(error => {
          console.error(`Failed to send notification to token ${token}:`, error);
          // If token is invalid, remove it from the database
          if (error.code === "messaging/invalid-registration-token" ||
              error.code === "messaging/registration-token-not-registered") {
            // Extract userId from the notification data
            const userId = notification.data?.userId;
            if (userId) {
              return removeInvalidToken(userId, token);
            }
          }
          return Promise.resolve();
        })
      );
    }
    
    await Promise.allSettled(batchPromises);
    console.log("All notifications sent successfully");
  } else {
    console.log("No notifications to send at this time");
  }
  
  return {
    success: true,
    message: "Notification check completed",
    notificationsSent: notificationsToSend.length,
  };
}