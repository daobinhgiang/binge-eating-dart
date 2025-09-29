# Firebase Cloud Functions Setup for Regular Eating Notifications

This guide will help you set up Firebase Cloud Functions to send Regular Eating notifications to users regardless of whether the app is active or not.

## 🎯 What This Achieves

- **Reliable Notifications**: Users receive meal reminders even when the app is closed
- **Server-Side Processing**: Notifications are sent from Firebase servers
- **Multi-Device Support**: Works across all user's devices
- **Automatic Cleanup**: Invalid tokens are automatically removed
- **Cross-Platform**: Works on mobile, web, and desktop

## 📋 Prerequisites

1. **Firebase CLI**: `npm install -g firebase-tools`
2. **Node.js 18+**: Required for Cloud Functions
3. **Firebase Project**: Your project must be set up in Firebase Console
4. **Billing Enabled**: Cloud Functions require a billing account (Blaze plan)

## 🚀 Quick Setup

### Step 1: Install Dependencies

```bash
cd functions
npm install
```

### Step 2: Deploy Functions

```bash
# From project root
./deploy-functions.sh
```

Or manually:

```bash
firebase login
firebase use bed-app-ef8f8
firebase deploy --only functions
```

### Step 3: Verify Deployment

1. Go to [Firebase Console > Functions](https://console.firebase.google.com/project/bed-app-ef8f8/functions)
2. You should see 4 functions deployed:
   - `sendRegularEatingNotifications`
   - `triggerNotificationCheck`
   - `scheduleRegularEatingNotifications`
   - `updateRegularEatingNotifications`

## 🔧 How It Works

### 1. User Flow
```
User sets Regular Eating settings → App saves FCM token → Cloud Function schedules notifications
```

### 2. Notification Flow
```
Cloud Scheduler (every hour) → Check all users → Calculate meal times → Send notifications
```

### 3. Data Structure
```
users/{userId}/notificationTokens/{token}
├── token: "FCM_TOKEN_HERE"
├── platform: "mobile" | "web"
├── createdAt: timestamp
└── lastUsed: timestamp

users/{userId}/Regular Eating/{settingsId}
├── userId: "USER_ID"
├── mealIntervalHours: 3.0
├── firstMealHour: 8
├── firstMealMinute: 0
├── createdAt: timestamp
└── updatedAt: timestamp
```

## 🧪 Testing

### 1. Test HTTP Function
```bash
curl https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck
```

### 2. Test in App
1. Set Regular Eating settings with a meal time in the next few minutes
2. Wait for the scheduled time
3. Check if notification appears

### 3. Check Logs
```bash
firebase functions:log
```

## 📊 Monitoring

### Firebase Console
- **Functions**: Monitor execution and errors
- **Cloud Messaging**: Check notification delivery
- **Firestore**: Verify data structure

### Logs to Watch
- Function execution logs
- FCM delivery reports
- Token validation errors

## 🔍 Troubleshooting

### Common Issues

#### 1. Functions Not Deploying
```bash
# Check Firebase CLI version
firebase --version

# Re-login if needed
firebase logout
firebase login
```

#### 2. Notifications Not Received
- Check FCM tokens are saved in Firestore
- Verify device notification permissions
- Check function logs for errors

#### 3. Invalid Tokens
- Functions automatically remove invalid tokens
- Check token refresh logic in client app

### Debug Commands
```bash
# View function logs
firebase functions:log --only sendRegularEatingNotifications

# Test specific function
firebase functions:shell

# Check deployment status
firebase functions:list
```

## 💰 Cost Estimation

### Monthly Costs (1000 users)
- **Cloud Functions**: ~$2-5
- **Cloud Scheduler**: Free (up to 3 jobs)
- **Cloud Messaging**: Free
- **Firestore**: ~$1-3
- **Total**: ~$3-8/month

### Cost Optimization
- Functions run only when needed
- Automatic token cleanup reduces storage
- Efficient querying minimizes Firestore reads

## 🔒 Security

### Firestore Rules
Ensure your Firestore rules allow the functions to read user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### IAM Permissions
The functions require these permissions:
- `firebase.projects.get`
- `firestore.databases.get`
- `firestore.documents.get`
- `firestore.documents.list`
- `firestore.documents.create`
- `firestore.documents.update`
- `firestore.documents.delete`

## 📱 Client App Changes

The client app has been updated to:

1. **Save FCM Tokens**: Automatically saves tokens to Firestore
2. **Token Refresh**: Handles token refresh automatically
3. **Dual Notifications**: Uses both local and Cloud Functions
4. **Token Cleanup**: Removes tokens on logout

### Key Files Updated
- `lib/core/services/notification_service.dart`
- `lib/core/services/firebase_token_service.dart`
- `lib/screens/main_navigation.dart`

## 🚀 Deployment Checklist

- [ ] Firebase CLI installed
- [ ] Node.js 18+ installed
- [ ] Firebase project configured
- [ ] Billing enabled (Blaze plan)
- [ ] Functions deployed successfully
- [ ] Test notification sent
- [ ] Logs checked for errors

## 📞 Support

If you encounter issues:

1. **Check Logs**: `firebase functions:log`
2. **Verify Setup**: Ensure all prerequisites are met
3. **Test Functions**: Use the HTTP trigger for testing
4. **Check Permissions**: Verify Firestore rules and IAM permissions

## 🎉 Success!

Once deployed, your app will:
- ✅ Send reliable notifications even when closed
- ✅ Work across all platforms
- ✅ Handle multiple devices per user
- ✅ Automatically clean up invalid tokens
- ✅ Scale to thousands of users

The Regular Eating notifications will now be delivered reliably through Firebase Cloud Functions, ensuring users never miss their meal reminders!
