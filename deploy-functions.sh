#!/bin/bash

# Deploy Firebase Cloud Functions for Regular Eating Notifications
# This script sets up and deploys the Cloud Functions

set -e  # Exit on any error

echo "🚀 Deploying Firebase Cloud Functions for Regular Eating Notifications..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "firebase.json" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the functions
echo "🔨 Building functions..."
npm run build

# Go back to project root
cd ..

# Deploy functions
echo "🚀 Deploying functions to Firebase..."
firebase deploy --only functions

echo "✅ Functions deployed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Test the functions using the Firebase Console"
echo "2. Check the function logs: firebase functions:log"
echo "3. Test notifications by updating Regular Eating settings in the app"
echo ""
echo "🔗 Useful commands:"
echo "  - View logs: firebase functions:log"
echo "  - Test HTTP function: curl https://us-central1-bed-app-ef8f8.cloudfunctions.net/triggerNotificationCheck"
echo "  - Redeploy: firebase deploy --only functions"
