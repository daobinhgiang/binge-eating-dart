# Firebase Analytics Integration for App Retention

This document describes the Firebase Analytics integration implemented for tracking app retention and user engagement metrics.

## Overview

The integration provides comprehensive analytics tracking for:
- **Daily Active Users (DAU)**
- **Weekly Active Users (WAU)**
- **User engagement with specific features**
- **Session duration tracking**
- **Retention milestones**
- **Feature usage patterns**

## Components Added

### 1. Firebase Analytics Service (`lib/core/services/firebase_analytics_service.dart`)

A comprehensive service that handles all analytics tracking:

- **App lifecycle tracking**: `trackAppOpen()`, `trackDailyActiveUser()`, `trackWeeklyActiveUser()`
- **Feature engagement**: `trackFeatureEngagement()`, `trackJournalEntry()`, `trackFoodDiaryEntry()`, etc.
- **User properties**: `setUserProperties()` for user segmentation
- **Retention tracking**: `trackRetentionMilestone()`, `trackSessionDuration()`
- **Authentication events**: `trackUserLogin()`, `trackUserRegistration()`, `trackOnboardingCompletion()`

### 2. Analytics Provider (`lib/providers/firebase_analytics_provider.dart`)

Riverpod providers for easy access to analytics functionality:

- `firebaseAnalyticsServiceProvider`: Main service provider
- `appOpenTrackingProvider`: Tracks app open events
- `featureEngagementProvider`: Tracks feature usage
- `sessionTrackingProvider`: Tracks session duration
- `retentionTrackingProvider`: Tracks retention milestones
- `userPropertiesProvider`: Sets user properties

### 3. Analytics Tracker Widget (`lib/widgets/analytics_tracker.dart`)

A wrapper widget that automatically tracks app lifecycle events:

- Tracks app open/resume events
- Monitors session duration
- Handles app pause/detach events
- Automatically wraps the main app

### 4. Integration Points

Analytics tracking has been added to key user actions:

#### Authentication (`lib/providers/auth_provider.dart`)
- Login events (email/password, Google)
- Registration events
- Onboarding completion

#### Diary Entries
- **Food Diary** (`lib/providers/food_diary_provider.dart`): Tracks food diary entry creation
- **Weight Diary** (`lib/providers/weight_diary_provider.dart`): Tracks weight diary entry creation
- **Body Image Diary** (`lib/providers/body_image_diary_provider.dart`): Tracks body image diary entry creation

#### Surveys and Tasks
- **EMA Survey** (`lib/providers/ema_survey_provider.dart`): Tracks survey completion
- **Todo Items** (`lib/providers/todo_provider.dart`): Tracks task completion

## Events Tracked

### Core Retention Events
- `app_open`: App launch/resume
- `daily_active_user`: Daily active user tracking
- `weekly_active_user`: Weekly active user tracking
- `session_duration`: Session length tracking

### Feature Engagement Events
- `feature_engagement`: General feature usage
- `journal_entry`: Journal/diary usage
- `food_diary_entry`: Food diary entries
- `weight_diary_entry`: Weight tracking entries
- `body_image_diary_entry`: Body image diary entries
- `ema_survey_completion`: EMA survey completion
- `todo_completion`: Task completion
- `onboarding_completed`: Onboarding completion

### User Lifecycle Events
- `user_login`: User authentication
- `user_registration`: New user registration
- `retention_milestone`: Retention milestone tracking

## User Properties Set

- `user_id`: Firebase user ID
- `user_role`: Patient or Clinician
- `onboarding_completed`: Onboarding status
- `app_version`: App version for segmentation

## Firebase Console Analytics

Once deployed, you can view analytics in the Firebase Console:

1. **Audiences**: Create custom audiences based on user properties
2. **Events**: View all tracked events and their parameters
3. **Retention**: Analyze user retention patterns
4. **Funnels**: Track user journey through features
5. **Cohorts**: Analyze user behavior over time

## Key Metrics for Retention Analysis

### Daily Active Users (DAU)
- Tracked via `daily_active_user` event
- Includes date parameter for daily segmentation
- Automatically triggered on app open

### Weekly Active Users (WAU)
- Tracked via `weekly_active_user` event
- Includes week start/end dates
- Automatically triggered on app open

### Session Duration
- Tracked via `session_duration` event
- Measures time spent in app
- Automatically calculated on app pause/close

### Feature Engagement
- Individual events for each major feature
- Helps identify most/least used features
- Enables feature-specific retention analysis

## Implementation Notes

### Automatic Tracking
- App lifecycle events are automatically tracked via `AnalyticsTracker` widget
- No manual intervention required for basic retention metrics

### Manual Tracking
- Feature-specific events require manual implementation
- Already integrated into key user actions
- Easy to add to new features using the analytics service

### Error Handling
- All analytics calls are wrapped in try-catch blocks
- Errors are logged but don't affect app functionality
- Graceful degradation if analytics service fails

## Usage Examples

### Tracking Custom Events
```dart
// In any provider or service
final analytics = FirebaseAnalyticsService();

// Track feature usage
await analytics.trackFeatureEngagement('custom_feature');

// Track with parameters
await analytics.trackFeatureEngagement(
  'tool_usage', 
  parameters: {'tool_name': 'urge_surfing'}
);
```

### Setting User Properties
```dart
await analytics.setUserProperties(
  userRole: 'patient',
  onboardingCompleted: true,
  appVersion: '1.0.0',
);
```

## Dependencies Added

- `firebase_analytics: ^11.3.3` - Firebase Analytics SDK

## Configuration

The analytics service automatically uses the existing Firebase configuration from `firebase_options.dart`. No additional configuration is required.

## Testing

To test the analytics integration:

1. Run the app in debug mode
2. Check Firebase Console for events (may take a few minutes to appear)
3. Use Firebase Analytics DebugView for real-time event monitoring
4. Verify events are being sent with correct parameters

## Privacy Considerations

- All analytics data is anonymized by Firebase
- No personally identifiable information is tracked
- User consent should be obtained before enabling analytics
- GDPR compliance should be considered for EU users

## Future Enhancements

- Custom conversion events
- A/B testing integration
- Advanced user segmentation
- Cohort analysis
- Custom dashboards
- Real-time analytics monitoring
