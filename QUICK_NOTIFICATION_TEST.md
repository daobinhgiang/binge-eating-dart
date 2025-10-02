# Quick Notification Testing Guide

## ✅ Implementation Complete

The app now shows **both** in-app popups and push notifications when the Cloud Scheduler job is activated!

## What Was Changed

### 1. Fixed Firebase Functions
- ✅ Fixed syntax error in `functions/src/index.ts`
- ✅ Added `actionUrl` to FCM messages for proper navigation
- ✅ Added `webpush` configuration for web notifications
- ✅ Built successfully

### 2. Enhanced Flutter App
- ✅ Modified `NotificationService._handleForegroundMessage()` to trigger in-app popup
- ✅ FCM messages now create `AppNotification` objects
- ✅ Popup appears automatically when message arrives
- ✅ Backup local notification still shown on mobile

### 3. Architecture Verified
- ✅ NotificationPopupOverlay wraps entire app
- ✅ Firestore listener configured correctly
- ✅ Both FCM and Firestore paths trigger popups

## How It Works Now

When Cloud Scheduler triggers:

```
Cloud Scheduler (every 30 mins)
    ↓
userNotificationCron Function
    ↓
    ├─→ Creates Firestore doc → Flutter Listener → In-App Popup ✨
    └─→ Sends FCM message → Device Receives Push Notification 📱
```

**If user is in the app:**
- ✨ In-app popup slides from top
- 📱 Local notification (mobile only, as backup)

**If user is NOT in the app:**
- 📱 Push notification appears in system tray
- When tapped, opens app and navigates to action URL

## Deployment

### Option 1: Deploy All Functions (Recommended)
```bash
cd /home/daobinhgiang/projects/binge-eating-dart
./deploy-notification-functions.sh
```

### Option 2: Deploy Manually
```bash
cd functions
npm run build
firebase deploy --only functions
```

## Testing

### Test 1: Manual Trigger (Easiest)

```bash
# From project root
cd functions

# Run the HTTP function
firebase functions:shell

# In the shell, type:
sendRegularEatingNotifications()
```

### Test 2: Cloud Scheduler

```bash
# Trigger the cron job
gcloud scheduler jobs run user-notification-cron
```

### Test 3: Create Test Notification in Firestore

Go to Firebase Console → Firestore and create a document:

**Path:** `/users/{YOUR_USER_ID}/notifications/`

**Data:**
```json
{
  "userId": "YOUR_USER_ID",
  "title": "🍽️ Test Meal Reminder",
  "body": "This is a test notification!",
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

**Expected Result:** Popup should appear in your app within seconds!

### Test 4: Send Test FCM Message

Use Firebase Console:
1. Go to Cloud Messaging
2. Click "Send your first message"
3. Enter title and body
4. Select your app
5. Send

## Verification Checklist

Before testing, verify:

- [ ] User has Regular Eating settings configured
- [ ] User's FCM token exists in Firestore: `/users/{userId}/notificationTokens/`
- [ ] App is open and user is logged in
- [ ] Notification permissions granted on device
- [ ] Cloud Scheduler job is enabled

## Expected Behavior

### Scenario 1: App in Foreground
1. Meal time arrives (e.g., 12:00 PM)
2. Cloud Scheduler triggers at next 5-minute mark (e.g., 12:00 or 12:05)
3. Firebase Function runs
4. FCM message sent to device
5. **In-app popup appears immediately** ✨
6. **Local notification also shown** (mobile only)
7. Firestore notification created
8. Firestore listener detects it
9. **Same popup (if not already shown)**

### Scenario 2: App in Background
1. Meal time arrives
2. Cloud Scheduler triggers
3. Firebase Function runs
4. **Push notification appears in system tray** 📱
5. User taps notification
6. App opens to `/profile/regular-eating`

### Scenario 3: App Closed
1. Meal time arrives
2. Cloud Scheduler triggers
3. **Push notification appears** 📱
4. Notification saved in Firestore
5. When user opens app later, sees notification in notifications screen

## Troubleshooting

### Popup Not Appearing

**Check 1: Is callback set?**
```dart
// Should be initialized in NotificationPopupNotifier
_notificationService.onNewNotification = _handleNewNotification;
```

**Check 2: Is user initialized?**
```dart
// Should be called in NotificationPopupOverlay
ref.read(notificationPopupProvider.notifier).initializeForUser(user.id);
```

**Check 3: Check logs**
```
flutter run
# Look for:
# "Received foreground message: ..."
# "Triggered in-app popup for foreground message"
# "New notification received: ..."
```

### Push Notification Not Arriving

**Check 1: Token exists?**
- Go to Firestore
- Check `/users/{userId}/notificationTokens/`
- Should have at least one token

**Check 2: Function logs**
```bash
firebase functions:log --only userNotificationCron
# Look for:
# "Sending X push notifications"
# "All push notifications sent successfully"
```

**Check 3: Permissions**
- Android: Settings → Apps → Your App → Notifications → Enabled
- iOS: Settings → Your App → Notifications → Allow Notifications
- Web: Browser settings → Site permissions → Notifications

## What to Watch For

### Success Indicators
- ✅ Popup slides smoothly from top
- ✅ Shows meal icon and colored background
- ✅ Auto-dismisses after 5 seconds
- ✅ Clicking navigates to Regular Eating screen
- ✅ Push notification appears when app is background
- ✅ Notification marked as read after tap

### Common Issues
- ❌ No popup = Check callback initialization
- ❌ No push notification = Check FCM token
- ❌ Old notifications appearing = Check 10-second age filter
- ❌ Duplicate popups = Normal (FCM + Firestore), will self-dismiss

## Monitoring

### View Logs in Real-Time
```bash
# Firebase Functions
firebase functions:log --only userNotificationCron --lines 50

# Cloud Scheduler
gcloud scheduler jobs describe user-notification-cron

# Flutter App
flutter run --verbose
```

### Check Notification History
```bash
# In Firebase Console
# Firestore → users → {userId} → notifications
# Should see recent notifications with isRead status
```

## Next Steps After Testing

1. ✅ Verify popup appears correctly
2. ✅ Verify push notifications work
3. ✅ Test on multiple devices (Android, iOS, Web)
4. ✅ Monitor for 24 hours to ensure reliability
5. ✅ Gather user feedback on notification timing
6. 📊 Track analytics on notification engagement

## Support

See detailed documentation:
- `NOTIFICATION_POPUP_SETUP.md` - Complete system documentation
- `CLOUD_FUNCTIONS_SETUP.md` - Cloud Functions setup
- `NOTIFICATION_SETUP.md` - General notification configuration

## Quick Commands Reference

```bash
# Deploy functions
./deploy-notification-functions.sh

# Test manually
firebase functions:shell
> sendRegularEatingNotifications()

# Trigger cron
gcloud scheduler jobs run user-notification-cron

# View logs
firebase functions:log --only userNotificationCron

# Check Flutter logs
flutter run --verbose
```

Happy testing! 🎉

