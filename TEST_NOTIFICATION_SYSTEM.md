# Testing the Notification System

## 🧪 Complete Testing Guide

This guide shows you how to test both the Firebase Functions and the in-app popup notification feature.

## Method 1: Test Firebase Functions (Backend)

### 1.1 Test HTTP Function Directly
```bash
# Test the main notification function
curl -X POST https://us-central1-bed-app-ef8f8.cloudfunctions.net/sendRegularEatingNotifications

# Expected response:
# {"success":true,"message":"Notification check completed","notificationsSent":0,"inAppNotificationsCreated":0}
```

### 1.2 Test Trigger Check Function
```bash
# Test the trigger check function
curl https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck

# Expected response:
# {"success":true,"message":"Manual trigger received - use sendRegularEatingNotifications for actual processing"}
```

### 1.3 Monitor Function Logs
```bash
# View all function logs
firebase functions:log

# View specific function logs
firebase functions:log --only userNotificationCron
firebase functions:log --only sendRegularEatingNotifications
```

## Method 2: Test In-App Popup (Frontend)

### 2.1 Create Test Notification in Firestore

**Step 1:** Go to [Firebase Console](https://console.firebase.google.com/project/bed-app-ef8f8/firestore)

**Step 2:** Navigate to Firestore Database

**Step 3:** Create a new document at this path:
```
/users/{YOUR_USER_ID}/notifications/{RANDOM_ID}
```

**Step 4:** Add this data:
```json
{
  "userId": "YOUR_USER_ID",
  "title": "🍽️ Test Meal Reminder",
  "body": "This is a test notification popup!",
  "type": "reminder",
  "isRead": false,
  "createdAt": [Current Timestamp],
  "actionUrl": "/profile/regular-eating",
  "data": {
    "type": "regular_eating",
    "mealType": "lunch"
  }
}
```

**Expected Result:** If you have the Flutter app open, you should see a popup slide down from the top within 1-2 seconds!

### 2.2 Test FCM Foreground Message

**Step 1:** Go to [Firebase Console > Cloud Messaging](https://console.firebase.google.com/project/bed-app-ef8f8/messaging)

**Step 2:** Click "Send your first message"

**Step 3:** Fill in:
- **Notification title:** "🌅 Test Breakfast Reminder"
- **Notification text:** "Time for your test meal!"
- **Target:** Select your app

**Step 4:** Click "Send test message"

**Expected Result:** If you have the Flutter app open in the foreground, you should see:
1. An in-app popup slides down from the top
2. A local notification also appears (on mobile)

## Method 3: Test Complete System (End-to-End)

### 3.1 Set Up Regular Eating Schedule

**Step 1:** Open your Flutter app
**Step 2:** Go to Profile → Regular Eating
**Step 3:** Set up a meal time for the next few minutes
**Step 4:** Save the settings

### 3.2 Wait for Automatic Trigger

**Option A:** Wait for the next 30-minute cron job
**Option B:** Manually trigger the function:
```bash
curl -X POST https://us-central1-bed-app-ef8f8.cloudfunctions.net/sendRegularEatingNotifications
```

### 3.3 Expected Results

**If you're in the app:**
- ✨ In-app popup appears
- 📱 Local notification (mobile only)

**If you're not in the app:**
- 📱 Push notification in system tray
- Tapping opens app and navigates to Regular Eating screen

## Method 4: Debug and Monitor

### 4.1 Check Function Execution
```bash
# View recent logs
firebase functions:log --lines 20

# Filter for specific function
firebase functions:log --only userNotificationCron --lines 10
```

### 4.2 Check Flutter App Logs
```bash
# Run Flutter app with verbose logging
flutter run --verbose

# Look for these messages:
# "Received foreground message: ..."
# "Triggered in-app popup for foreground message"
# "New notification received: ..."
```

### 4.3 Check Firestore Data
1. Go to [Firebase Console > Firestore](https://console.firebase.google.com/project/bed-app-ef8f8/firestore)
2. Navigate to `/users/{userId}/notifications/`
3. Check if new notifications are being created
4. Verify `isRead` status

## Method 5: Test Different Scenarios

### 5.1 Test App States

**Foreground (App Open):**
- Should show in-app popup
- Should show local notification (mobile)
- Should trigger `onNewNotification` callback

**Background (App Minimized):**
- Should show push notification in system tray
- Tapping should open app and navigate

**Closed (App Not Running):**
- Should show push notification
- Should save notification in Firestore
- Opening app should show notification in notifications screen

### 5.2 Test Different Notification Types

Create test notifications with different types:

```json
// Achievement notification
{
  "type": "achievement",
  "title": "🏆 Milestone Reached!",
  "body": "You've completed 7 days of regular eating!"
}

// Lesson notification
{
  "type": "lesson", 
  "title": "📚 New Lesson Available",
  "body": "Check out the latest lesson on mindful eating"
}

// System notification
{
  "type": "system",
  "title": "ℹ️ App Update",
  "body": "New features are now available!"
}
```

## Troubleshooting

### No Popup Appearing?

**Check 1:** Is the app open and user logged in?
```dart
// In Flutter app, check if callback is set
print('onNewNotification callback set: ${NotificationService().onNewNotification != null}');
```

**Check 2:** Is the notification listener initialized?
```dart
// Check if user is initialized
ref.read(notificationPopupProvider.notifier).initializeForUser(userId);
```

**Check 3:** Check Firestore notification age
- Only notifications < 10 seconds old trigger popups
- Check `createdAt` timestamp

### No Push Notifications?

**Check 1:** FCM token exists in Firestore
- Go to `/users/{userId}/notificationTokens/`
- Should see at least one token document

**Check 2:** Device notification permissions
- Android: Settings → Apps → Your App → Notifications
- iOS: Settings → Your App → Notifications

**Check 3:** Function logs for errors
```bash
firebase functions:log --only userNotificationCron
```

### Function Not Executing?

**Check 1:** Cloud Scheduler status
```bash
gcloud scheduler jobs describe User_Noti --project=bed-app-ef8f8 --location=us-central1
```

**Check 2:** Pub/Sub topic
- Go to [Google Cloud Console > Pub/Sub](https://console.cloud.google.com/cloudpubsub/topic/list?project=bed-app-ef8f8)
- Check if `cron-topic` exists and has messages

**Check 3:** Function deployment
```bash
firebase functions:list
```

## Quick Test Commands

```bash
# Test HTTP function
curl -X POST https://us-central1-bed-app-ef8f8.cloudfunctions.net/sendRegularEatingNotifications

# Test trigger function  
curl https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck

# View logs
firebase functions:log --only userNotificationCron

# Check scheduler
gcloud scheduler jobs describe User_Noti --project=bed-app-ef8f8 --location=us-central1
```

## Expected Success Indicators

✅ **HTTP Function:** Returns success response  
✅ **Firestore Trigger:** Creates notification documents  
✅ **In-App Popup:** Slides down from top when app is open  
✅ **Push Notification:** Appears in system tray when app is closed  
✅ **Navigation:** Tapping popup/notification navigates to correct screen  
✅ **Mark as Read:** Notification marked as read after interaction  

## Next Steps After Testing

1. **Verify all test cases pass**
2. **Monitor logs for any errors**
3. **Test on multiple devices (Android, iOS, Web)**
4. **Test with different meal times**
5. **Gather user feedback on notification timing**

Happy testing! 🎉
