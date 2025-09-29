#!/bin/bash

# Test script for Regular Eating notifications
# This script helps verify that the Cloud Functions are working correctly

set -e

echo "🧪 Testing Regular Eating Notifications Setup..."

# Check if Firebase CLI is available
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Test 1: Check if functions are deployed
echo "📋 Checking deployed functions..."
firebase functions:list

echo ""
echo "🔍 Testing HTTP trigger function..."

# Test 2: Trigger the notification check function
FUNCTION_URL="https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck"

echo "Calling: $FUNCTION_URL"

# Make the HTTP request
RESPONSE=$(curl -s -w "\n%{http_code}" "$FUNCTION_URL")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

echo "HTTP Status: $HTTP_CODE"
echo "Response: $BODY"

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ HTTP function is working correctly!"
else
    echo "❌ HTTP function returned error code: $HTTP_CODE"
    echo "Response: $BODY"
fi

echo ""
echo "📊 Checking function logs..."

# Test 3: Check recent logs
echo "Recent function logs:"
firebase functions:log --limit 10

echo ""
echo "🎯 Next steps to test notifications:"
echo "1. Open your app and set Regular Eating settings"
echo "2. Set a meal time for the next few minutes"
echo "3. Wait for the scheduled time"
echo "4. Check if you receive a notification"
echo ""
echo "📱 To test manually, you can also:"
echo "1. Go to Firebase Console > Functions"
echo "2. Click on 'sendRegularEatingNotifications'"
echo "3. Click 'Test' to trigger it manually"
echo ""
echo "🔍 To monitor in real-time:"
echo "firebase functions:log --follow"
