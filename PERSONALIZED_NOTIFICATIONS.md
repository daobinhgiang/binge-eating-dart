# Personalized Motivational Notifications

## Overview

The `sendDailyMotivationalNotification` Firebase Cloud Function now generates **personalized AI-powered motivational messages** for each user using OpenAI's GPT-4o-mini model.

## Features

### 🤖 AI-Generated Messages
- Each user receives a **unique, personalized message** based on their recovery data
- Messages are generated using OpenAI's GPT-4o-mini model
- Falls back to default encouraging message if OpenAI fails

### 📊 Data-Driven Personalization
The function fetches user context from Firestore including:
- User's first name and level/XP
- Recent meals logged (last 7 days)
- Binge episodes count and rate
- Latest weight entry
- Completed lessons count

### ⏰ Scheduling
- Runs **twice daily**: at 8:00 AM and 6:00 PM Central Time
- Uses Cloud Scheduler for reliable execution

### 🔔 Notification Details
- **Title**: "Your Daily Motivation 💚"
- **Body**: Personalized 2-3 sentence motivational message
- **Type**: `motivational_reminder`

## Implementation Details

### Functions Structure

```typescript
// Helper function to fetch user data
async function fetchUserContext(userId: string)

// Helper function to generate personalized message
async function generateMotivationalMessage(userContext: any)

// Main scheduled function
export const sendDailyMotivationalNotification
```

### Message Generation Prompt

The AI is instructed to:
- Acknowledge user's progress and efforts
- Offer gentle encouragement
- Be warm and supportive
- Avoid mentioning specific numbers or data
- Focus on one positive aspect
- End with hope or motivation
- Keep it conversational (2-3 sentences max)

### User Data Queried

```
users/{userId}
  ├─ firstName, level, exp
  ├─ food_diary/
  │   └─ Last 7 days of entries
  ├─ weight_diary/
  │   └─ Latest weight entry
  └─ completed_lessons/
      └─ Total count
```

## Setup Instructions

### 1. Install Dependencies

Already completed:
```bash
cd functions
npm install openai
```

### 2. Set OpenAI API Key

Run this command with your OpenAI API key:
```bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
```

### 3. Deploy the Function

```bash
firebase deploy --only functions:sendDailyMotivationalNotification
```

## Monitoring

### Check Function Logs
```bash
firebase functions:log --only sendDailyMotivationalNotification
```

### Firestore Tracking

Results are saved to:
```
notifications/motivationalNotification
```

Fields tracked:
- `totalUsers`: Number of users processed
- `successCount`: Successful notifications sent
- `failureCount`: Failed notifications
- `executionTime`: Time taken in milliseconds
- `method`: "personalized_ai_generated"
- `type`: "motivational_reminder_personalized"

## Example Messages

Based on user context, the AI might generate messages like:

- *"Hi Sarah! It's wonderful to see you staying committed to your recovery journey. Every meal you log brings you closer to understanding your patterns. Keep up the amazing work! 💚"*

- *"You're making real progress, Emma. Remember that recovery isn't about perfection - it's about showing up for yourself each day. You're doing exactly that! 🌟"*

- *"Great job staying engaged with your lessons, Alex! Building these recovery tools takes courage and dedication. You're investing in yourself, and that matters. 💪"*

## Performance Considerations

- **Processing Time**: ~100ms per user (includes Firestore queries + OpenAI API call)
- **Rate Limiting**: 100ms delay between users to avoid rate limits
- **Fallback**: Default message used if OpenAI fails
- **Error Handling**: Individual user failures don't stop the batch

## Cost Considerations

### OpenAI API Costs
- Model: GPT-4o-mini
- Tokens per message: ~150-200
- Cost: ~$0.0001 per message
- Example: 100 users × 2 times/day = **~$0.02/day** or **~$0.60/month**

### Firebase Costs
- Function execution time: ~10-30 seconds per run
- Firestore reads: ~5 reads per user
- FCM notifications: Free

## Troubleshooting

### OpenAI API Key Not Set
**Error**: "Missing credentials. Please pass an `apiKey`"
**Solution**: Run `firebase functions:config:set openai.key="YOUR_API_KEY"`

### Function Timeout
**Error**: Function execution timeout
**Solution**: Function timeout is set to 540s by default. If needed, increase in Firebase Console.

### Rate Limiting
**Error**: OpenAI rate limit exceeded
**Solution**: Increase delay between users or batch users differently

## Future Enhancements

Potential improvements:
1. **Message Variety**: Different message types (morning motivation vs evening reflection)
2. **User Preferences**: Allow users to opt-in/out of personalized messages
3. **Message History**: Store generated messages for analytics
4. **A/B Testing**: Compare personalized vs. generic message engagement
5. **Multi-language Support**: Generate messages in user's preferred language
6. **Sentiment Analysis**: Track emotional tone of messages over time

## Dependencies

- `firebase-functions`: ^5.1.0
- `firebase-admin`: ^12.0.0
- `openai`: Latest version (automatically installed)

## Related Files

- `/functions/src/index.ts` - Main function implementation
- `/functions/package.json` - Dependencies
- `/lib/core/services/openai_service.dart` - Flutter app's OpenAI service (for reference)

