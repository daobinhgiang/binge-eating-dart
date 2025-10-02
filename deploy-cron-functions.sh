#!/bin/bash

# Deploy Cloud Functions with Pub/Sub cron job integration
# This script installs dependencies and deploys the functions

echo "🚀 Deploying Cloud Functions with Pub/Sub cron job integration..."

# Navigate to functions directory
cd functions

echo "📦 Installing dependencies..."
npm install

echo "🔨 Building TypeScript..."
npm run build

echo "🚀 Deploying functions..."
firebase deploy --only functions

echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Make sure your Google Cloud Scheduler job is configured to publish to the 'cron-topic'"
echo "2. Test the integration with: node ../test-cron-integration.js"
echo "3. Check logs with: firebase functions:log --only userNotificationCron"
echo ""
echo "🔧 Your cron job should publish messages to: projects/bed-app-ef8f8/topics/cron-topic"
