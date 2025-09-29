# Firebase Cloud Functions for Regular Eating Notifications

This directory contains Firebase Cloud Functions that handle Regular Eating notifications for the BED Support App.

## Overview

The Cloud Functions provide reliable, server-side notification delivery that works regardless of whether the app is active or not. This ensures users receive their meal reminders even when the app is closed or in the background.

## Functions

### 1. `sendRegularEatingNotifications`
- **Type**: Scheduled Function (runs every hour)
- **Purpose**: Checks all users' Regular Eating settings and sends notifications at meal times
- **Trigger**: Cloud Scheduler (every hour at minute 0)
- **Features**:
  - Calculates meal times for each user
  - Sends notifications with 5-minute tolerance
  - Handles multiple devices per user
  - Removes invalid tokens automatically

### 2. `triggerNotificationCheck`
- **Type**: HTTP Function
- **Purpose**: Manual trigger for testing notifications
- **Usage**: `GET /triggerNotificationCheck`

### 3. `scheduleRegularEatingNotifications`
- **Type**: Firestore Trigger
- **Purpose**: Logs when new Regular Eating settings are created
- **Trigger**: New document in `users/{userId}/Regular Eating/{settingsId}`

### 4. `updateRegularEatingNotifications`
- **Type**: Firestore Trigger
- **Purpose**: Logs when Regular Eating settings are updated
- **Trigger**: Update to document in `users/{userId}/Regular Eating/{settingsId}`

## Setup Instructions

### Prerequisites
1. Firebase CLI installed: `npm install -g firebase-tools`
2. Node.js 18+ installed
3. Firebase project configured

### Installation

1. **Install dependencies:**
   ```bash
   cd functions
   npm install
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Set your project:**
   ```bash
   firebase use bed-app-ef8f8
   ```

4. **Deploy functions:**
   ```bash
   firebase deploy --only functions
   ```

### Testing

1. **Test the HTTP trigger:**
   ```bash
   curl https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck
   ```

2. **Check function logs:**
   ```bash
   firebase functions:log
   ```

3. **Test locally (optional):**
   ```bash
   npm run serve
   ```

## How It Works

### 1. User Setup
- User configures Regular Eating settings in the app
- App saves FCM token to Firestore (`users/{userId}/notificationTokens/{token}`)
- Settings are saved to Firestore (`users/{userId}/Regular Eating/{settingsId}`)

### 2. Notification Scheduling
- Cloud Function runs every hour
- Checks all users' Regular Eating settings
- Calculates meal times for the current day
- Sends notifications to users whose meal time matches current time (within 5 minutes)

### 3. Notification Delivery
- Uses Firebase Cloud Messaging (FCM)
- Supports multiple devices per user
- Handles both mobile and web platforms
- Automatically removes invalid tokens

## Configuration

### Environment Variables
No additional environment variables are required. The functions use the default Firebase Admin SDK configuration.

### Firestore Security Rules
Ensure your Firestore security rules allow the functions to read user data:

```javascript
// Allow functions to read user data
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  
  // Allow functions to read all user data
  allow read: if request.auth.token.admin == true;
}
```

### IAM Permissions
The functions require the following IAM permissions:
- `firebase.projects.get`
- `firestore.databases.get`
- `firestore.documents.get`
- `firestore.documents.list`
- `firestore.documents.create`
- `firestore.documents.update`
- `firestore.documents.delete`

## Monitoring

### View Logs
```bash
firebase functions:log --only sendRegularEatingNotifications
```

### Monitor Performance
- Check Firebase Console > Functions
- Monitor execution time and memory usage
- Set up alerts for function failures

### Debug Issues
1. Check function logs for errors
2. Verify FCM tokens are valid
3. Ensure Regular Eating settings are properly formatted
4. Check Firestore security rules

## Troubleshooting

### Common Issues

1. **Functions not triggering:**
   - Check Cloud Scheduler is enabled
   - Verify function deployment was successful
   - Check function logs for errors

2. **Notifications not received:**
   - Verify FCM tokens are saved in Firestore
   - Check device notification permissions
   - Ensure app is properly configured for FCM

3. **Invalid tokens:**
   - Functions automatically remove invalid tokens
   - Check token refresh logic in client app
   - Verify FCM configuration

### Support
For issues with the Cloud Functions, check:
1. Firebase Console > Functions logs
2. Firebase Console > Cloud Scheduler
3. Firebase Console > Cloud Messaging

## Cost Considerations

- **Cloud Functions**: Pay per invocation and execution time
- **Cloud Scheduler**: Free for up to 3 jobs
- **Cloud Messaging**: Free for unlimited messages
- **Firestore**: Pay per read/write operation

Estimated monthly cost for 1000 users: ~$5-10 USD
