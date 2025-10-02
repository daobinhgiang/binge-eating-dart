# Notification System: In-App Popup & Push Notifications

## Overview

The app now has a **dual notification system** that works when the Cloud Scheduler job is activated:

1. **In-App Popup**: Shows a popup notification if the user is actively using the app
2. **Push Notification**: Sends a push notification to the user's mobile device

## Architecture

### Complete Flow

```
Cloud Scheduler (Cron Job)
    ↓
Pub/Sub Topic ("cron-topic")
    ↓
Firebase Function (userNotificationCron)
    ↓
    ├─→ Creates Firestore Notification
    │   └─→ Flutter App Listens to Firestore
    │       └─→ In-App Popup (if user is in app)
    │
    └─→ Sends FCM Push Notification
        └─→ Mobile Device Shows Push Notification
            ├─→ If app is in foreground: In-App Popup + Local Notification
            └─→ If app is in background: Push Notification in system tray
```

## Components

### 1. Firebase Functions (`functions/src/index.ts`)

**Function: `userNotificationCron`**
- Triggered by Cloud Scheduler via Pub/Sub
- Checks all users' Regular Eating settings
- For each matching meal time:
  - Creates in-app notification in Firestore
  - Sends FCM push notification to all user devices

**Key Features:**
- ✅ Creates Firestore notifications at `/users/{userId}/notifications/`
- ✅ Sends FCM messages to registered device tokens
- ✅ Supports Android, iOS, and Web platforms
- ✅ Automatically removes invalid tokens
- ✅ 5-minute tolerance window for meal times

### 2. Flutter App - NotificationService

**File: `lib/core/services/notification_service.dart`**

**Key Methods:**

- `initialize()` - Sets up FCM and local notifications
- `initializeForUser(userId)` - Initializes token service and Firestore listener
- `startListeningForNotifications(userId)` - Listens to Firestore for new notifications
- `_handleForegroundMessage(message)` - Handles FCM messages when app is in foreground

**Notification Flows:**

#### A. Firestore Listener (Real-time Database)
```dart
// Listens to: /users/{userId}/notifications
// Triggers: onNewNotification callback
// Shows: In-app popup
```

#### B. FCM Foreground Messages
```dart
FirebaseMessaging.onMessage.listen((message) {
  // Creates AppNotification object
  // Triggers: onNewNotification callback
  // Shows: In-app popup + local notification
});
```

### 3. Flutter App - NotificationPopupOverlay

**File: `lib/widgets/notification_popup_overlay.dart`**

- Wraps the entire app in `main.dart`
- Displays popup when `notificationPopupProvider` has a value
- Auto-dismisses after 5 seconds
- Handles tap to navigate to action URL
- Marks notification as read when tapped

### 4. Flutter App - NotificationPopup Widget

**File: `lib/widgets/notification_popup.dart`**

- Beautiful animated popup that slides from top
- Shows title, body, and icon based on notification type
- Color-coded by type (reminder, lesson, achievement, system)
- Dismissible by clicking X or tapping the notification

## Setup & Configuration

### Prerequisites

1. ✅ Cloud Scheduler job configured (see `CLOUD_FUNCTIONS_SETUP.md`)
2. ✅ Firebase Cloud Messaging enabled
3. ✅ User has FCM token saved in Firestore
4. ✅ User has Regular Eating settings configured

### Firebase Functions Deployment

```bash
# Build TypeScript
cd functions
npm run build

# Deploy all functions
npm run deploy

# Or deploy specific function
firebase deploy --only functions:userNotificationCron
```

### Cloud Scheduler Setup

The cron job is configured to run every 5 minutes:

```bash
gcloud scheduler jobs create pubsub user-notification-cron \
  --schedule="*/5 * * * *" \
  --topic=cron-topic \
  --message-body='{"action":"checkNotifications"}' \
  --time-zone="America/New_York"
```

See `CLOUD_FUNCTIONS_SETUP.md` for full setup instructions.

## Testing the System

### 1. Manual HTTP Test (Development)

Test the notification function directly:

```bash
# Get the function URL
firebase functions:config:get

# Trigger manually
curl -X POST https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/sendRegularEatingNotifications
```

### 2. Test Cron Job

```bash
# Trigger the Cloud Scheduler job manually
gcloud scheduler jobs run user-notification-cron --project=YOUR-PROJECT-ID
```

### 3. Test from Flutter App

1. **Set up Regular Eating schedule:**
   - Go to Profile → Regular Eating
   - Set meal times
   - Save settings

2. **Verify FCM token:**
   - Check Firestore: `/users/{userId}/notificationTokens/`
   - Should see your device token

3. **Wait for notification time:**
   - When meal time arrives (within 5-minute tolerance)
   - You should see:
     - **If app is open:** In-app popup slides from top
     - **If app is closed:** Push notification in system tray

### 4. Test In-App Popup Directly

You can trigger a test notification by manually creating a Firestore document:

```javascript
// In Firebase Console → Firestore
// Path: /users/{YOUR_USER_ID}/notifications/

{
  "userId": "YOUR_USER_ID",
  "title": "Test Notification",
  "body": "This is a test notification popup",
  "type": "reminder",
  "isRead": false,
  "createdAt": Timestamp.now(),
  "data": {
    "type": "regular_eating",
    "mealType": "lunch"
  },
  "actionUrl": "/profile/regular-eating"
}
```

The popup should appear within seconds if you're using the app.

## Notification Types

| Type | Icon | Color | Use Case |
|------|------|-------|----------|
| `reminder` | 🍽️ restaurant_menu | Green | Regular eating reminders |
| `lesson` | 📚 school | Blue | Lesson completions |
| `achievement` | 🏆 celebration | Amber | Milestones reached |
| `system` | ℹ️ info | Grey | System messages |

## Troubleshooting

### In-App Popup Not Showing

1. **Check notification listener:**
   ```dart
   // Should be called when user logs in
   NotificationService().initializeForUser(userId);
   ```

2. **Verify Firestore notification:**
   - Go to Firebase Console → Firestore
   - Check `/users/{userId}/notifications/`
   - Look for `isRead: false` and recent `createdAt`

3. **Check callback initialization:**
   - NotificationPopupNotifier sets `onNewNotification` callback
   - NotificationPopupOverlay initializes on mount

### Push Notifications Not Arriving

1. **Check FCM token:**
   ```bash
   # In Firestore
   /users/{userId}/notificationTokens/{token}
   ```

2. **Check Firebase Functions logs:**
   ```bash
   firebase functions:log --only userNotificationCron
   ```

3. **Test FCM directly:**
   ```bash
   # Use Firebase Console → Cloud Messaging → Send test message
   ```

4. **Verify permissions:**
   - Android: Check notification permissions in device settings
   - iOS: Check notification permissions in device settings
   - Web: Check browser notification permissions

### Notifications Sent But Not Received

1. **Check time tolerance:**
   - Function uses 5-minute tolerance window
   - Meal time must be ± 5 minutes from current time

2. **Check timezone:**
   - Functions run in UTC
   - Ensure meal times are calculated correctly

3. **Check token validity:**
   - Invalid tokens are automatically removed
   - Check if token still exists in Firestore

## Code Examples

### Trigger In-App Popup Programmatically

```dart
final notificationService = NotificationService();

// Create a notification
final notification = AppNotification(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  userId: 'user123',
  title: '🌅 Breakfast Time!',
  body: 'Start your day with a nourishing breakfast!',
  type: 'reminder',
  createdAt: DateTime.now(),
  isRead: false,
  actionUrl: '/profile/regular-eating',
);

// Trigger popup if callback is set
if (notificationService.onNewNotification != null) {
  notificationService.onNewNotification!(notification);
}
```

### Listen to Notifications in Custom Widget

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationPopupProvider);
    
    if (notification != null) {
      // Handle notification
      print('New notification: ${notification.title}');
    }
    
    return Container();
  }
}
```

## Performance Considerations

1. **Firestore Listener:**
   - Only listens to unread notifications
   - Limited to 1 most recent notification
   - Only triggers for notifications < 10 seconds old (prevents old notifications on app start)

2. **FCM Messages:**
   - Batched sending in Firebase Functions
   - Invalid tokens automatically removed
   - Maximum 500 devices per batch

3. **Notification Frequency:**
   - Cron runs every 5 minutes
   - Meal time tolerance: ± 5 minutes
   - Prevents duplicate notifications

## Security Rules

Make sure your Firestore security rules allow users to read their own notifications:

```javascript
match /users/{userId}/notifications/{notificationId} {
  allow read: if request.auth.uid == userId;
  allow write: if false; // Only Cloud Functions can write
}

match /users/{userId}/notificationTokens/{tokenId} {
  allow read, write: if request.auth.uid == userId;
}
```

## Next Steps

1. ✅ Deploy Firebase Functions
2. ✅ Test notification flow
3. [ ] Monitor Cloud Scheduler logs
4. [ ] Monitor Firebase Functions logs
5. [ ] Gather user feedback on notification timing

## Related Documentation

- `CLOUD_FUNCTIONS_SETUP.md` - Cloud Functions and Scheduler setup
- `NOTIFICATION_SETUP.md` - General notification setup
- `ANALYTICS_INTEGRATION.md` - Analytics tracking

## Support

For issues or questions, check:
1. Firebase Functions logs: `firebase functions:log`
2. Cloud Scheduler status: `gcloud scheduler jobs describe user-notification-cron`
3. Flutter app logs: Look for NotificationService debug messages

