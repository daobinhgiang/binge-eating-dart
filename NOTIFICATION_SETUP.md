# Regular Eating Notifications Setup

This document explains how the Regular Eating notification system works in the BED Support App.

## Overview

The notification system helps users maintain regular eating habits by sending reminders at scheduled meal times based on their Regular Eating settings.

## Features

### 1. Automatic Notification Scheduling
- Notifications are automatically scheduled when users save their Regular Eating settings
- Notifications are based on:
  - `firstMealHour`: The hour (0-23) when the first meal should be eaten
  - `firstMealMinute`: The minute (0-59) when the first meal should be eaten  
  - `mealIntervalHours`: The interval between meals (2-6 hours)

### 2. Smart Meal Time Calculation
- The system calculates up to 4 meal times per day
- Meal times are calculated by adding the interval to the first meal time
- Only reasonable eating hours (before 10 PM) are scheduled

### 3. Notification Types
- **Breakfast**: 🌅 Time for Breakfast!
- **Lunch**: ☀️ Lunch Time!
- **Afternoon Snack**: 🌤️ Afternoon Snack!
- **Dinner**: 🌙 Dinner Time!

### 4. User Controls
- Enable/disable notifications
- Toggle sound and vibration
- Reschedule notifications when settings change
- Cancel all notifications

## Technical Implementation

### Dependencies Added
```yaml
firebase_messaging: ^15.1.3
flutter_local_notifications: ^17.2.3
timezone: ^0.9.4
```

### Key Components

#### 1. NotificationService (`lib/core/services/notification_service.dart`)
- Handles local and Firebase push notifications
- Schedules notifications based on Regular Eating settings
- Manages notification channels and permissions

#### 2. NotificationProvider (`lib/providers/notification_provider.dart`)
- State management for notification settings
- Integration with Regular Eating provider

#### 3. NotificationSettingsScreen (`lib/screens/profile/notification_settings_screen.dart`)
- User interface for managing notification preferences
- Accessible from Profile → Notification Settings

### Android Configuration

The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Firebase Messaging Service

The Firebase Messaging service has been configured in the Android manifest to handle background notifications.

## Usage

### For Users

1. **Set up Regular Eating**: Go to Profile → Regular Eating and configure your meal times
2. **Manage Notifications**: Go to Profile → Notification Settings to:
   - Enable/disable notifications
   - Toggle sound and vibration
   - Reschedule notifications
   - Cancel all notifications

### For Developers

#### Scheduling Notifications
```dart
// Get user's Regular Eating settings
final regularEating = await regularEatingService.getUserRegularEatingSettings(userId);

// Schedule notifications
await notificationService.scheduleRegularEatingNotifications(regularEating);
```

#### Canceling Notifications
```dart
// Cancel all regular eating notifications
await notificationService.cancelRegularEatingNotifications();
```

#### Rescheduling Notifications
```dart
// Reschedule when settings change
await regularEatingService.rescheduleNotifications(userId);
```

## Notification Schedule Example

If a user sets:
- First meal: 8:00 AM
- Meal interval: 3 hours

The system will schedule notifications for:
- 8:00 AM - Breakfast
- 11:00 AM - Lunch  
- 2:00 PM - Afternoon Snack
- 5:00 PM - Dinner

## Testing

To test the notification system:

1. Set up Regular Eating settings with a first meal time in the near future
2. Check that notifications are scheduled
3. Wait for the scheduled time to verify notifications appear
4. Test notification settings (sound, vibration, etc.)

## Troubleshooting

### Notifications Not Appearing
1. Check notification permissions in device settings
2. Verify Regular Eating settings are saved
3. Check if notifications are enabled in the app
4. Try rescheduling notifications from the settings screen

### Permission Issues
1. Ensure all required permissions are granted
2. Check Android manifest configuration
3. Verify Firebase configuration

## Future Enhancements

- Custom notification sounds
- Notification templates
- Advanced scheduling options
- Integration with meal logging
- Analytics for notification effectiveness
