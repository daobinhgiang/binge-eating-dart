#!/bin/bash
# Deploy notification-related Firebase Functions

echo "🔧 Building Firebase Functions..."
cd functions
npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful!"
echo ""
echo "🚀 Deploying notification functions..."
echo ""

# Deploy only the notification-related functions
firebase deploy --only functions:userNotificationCron,functions:sendRegularEatingNotifications,functions:scheduleRegularEatingNotifications,functions:updateRegularEatingNotifications

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Deployment successful!"
  echo ""
  echo "📋 Next steps:"
  echo "1. Verify Cloud Scheduler is running: gcloud scheduler jobs describe user-notification-cron"
  echo "2. Test manually: firebase functions:shell"
  echo "3. Check logs: firebase functions:log --only userNotificationCron"
  echo ""
  echo "📖 See NOTIFICATION_POPUP_SETUP.md for full documentation"
else
  echo ""
  echo "❌ Deployment failed!"
  echo "Check the error messages above for details."
  exit 1
fi

