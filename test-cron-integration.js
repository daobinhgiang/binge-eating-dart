#!/usr/bin/env node

/**
 * Test script for Pub/Sub cron job integration
 * This script helps test the cron job by publishing a message to the Pub/Sub topic
 */

const { PubSub } = require('@google-cloud/pubsub');

// Initialize Pub/Sub client
const pubsub = new PubSub({
  projectId: 'bed-app-ef8f8',
});

async function testCronJob() {
  try {
    console.log('Testing Pub/Sub cron job integration...');
    
    // Get the topic
    const topic = pubsub.topic('cron-topic');
    
    // Check if topic exists
    const [exists] = await topic.exists();
    if (!exists) {
      console.error('❌ Topic "cron-topic" does not exist!');
      console.log('Please make sure you created the topic in Google Cloud Console.');
      return;
    }
    
    console.log('✅ Topic "cron-topic" exists');
    
    // Publish a test message
    const message = {
      data: Buffer.from(JSON.stringify({
        test: true,
        timestamp: new Date().toISOString(),
        message: 'Test cron job trigger'
      })),
      attributes: {
        source: 'test-script',
        type: 'cron-test'
      }
    };
    
    console.log('📤 Publishing test message to cron-topic...');
    const messageId = await topic.publishMessage(message);
    console.log(`✅ Message published with ID: ${messageId}`);
    
    console.log('\n🎉 Test completed! Check your Cloud Functions logs to see if the function was triggered.');
    console.log('You can view logs with: firebase functions:log --only userNotificationCron');
    
  } catch (error) {
    console.error('❌ Error testing cron job:', error);
    
    if (error.code === 7) {
      console.log('\n💡 This might be a permissions issue. Make sure you have:');
      console.log('1. Enabled the Pub/Sub API in Google Cloud Console');
      console.log('2. Set up proper IAM permissions for your service account');
      console.log('3. Authenticated with gcloud: gcloud auth login');
    }
  }
}

// Run the test
testCronJob();
