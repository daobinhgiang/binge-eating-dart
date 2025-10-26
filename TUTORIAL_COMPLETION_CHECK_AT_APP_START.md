# Tutorial Completion Check at App Start

## Overview
The app now checks if users have completed ALL tutorial steps when the app starts. If any tutorial step is incomplete, the app automatically resets all tutorial flags and redirects the user to redo the tutorial from the very beginning.

## Key Features

✅ **App Start Check Only** - The check only runs once when the app starts, NOT on every navigation  
✅ **Complete Reset** - All tutorial flags are reset if any step is incomplete  
✅ **Automatic Redirection** - User is automatically redirected to start the tutorial flow  
✅ **Premium User Skip** - Premium users skip this check entirely  
✅ **Detailed Logging** - Comprehensive logging for debugging and monitoring  

## Implementation Details

### 1. App Start Check (`lib/main.dart`)

The `_BEDAppState` class now includes a dedicated method that checks tutorial completion status:

```dart
/// Check if user has completed ALL tutorials at app start
/// If not all completed, reset all tutorial flags to force complete redo
Future<void> _checkAndResetTutorialsIfIncomplete(UserModel user) async {
  // Skip if already checked or user is premium
  if (_tutorialCheckComplete || user.isPremium) return;

  // Only check if user has completed onboarding
  if (!user.onboardingCompleted) {
    _tutorialCheckComplete = true;
    return;
  }

  // Check if ALL tutorial flags are completed
  final bool allTutorialsCompleted = user.hasSeenAppTutorial &&
      user.hasCompletedFirstLesson &&
      user.hasSeenExercisesTutorial &&
      user.hasSeenJournalTutorial &&
      user.hasLoggedWeightDuringTutorial &&
      user.hasSeenWeightDiaryTutorial &&
      user.hasVisitedWeightDiary &&
      user.hasSeenStreakTutorial &&
      user.hasSeenPlantGrowthTutorial &&
      user.hasSeenTimerClosingSlides;

  if (!allTutorialsCompleted) {
    // Reset ALL tutorial flags and redirect user
    await ref.read(authNotifierProvider.notifier).resetAllTutorialFlags();
  }

  _tutorialCheckComplete = true;
}
```

**Key Points:**
- Runs only ONCE per app session (tracked by `_tutorialCheckComplete` flag)
- Checks ALL 10 tutorial flags for completion
- Logs detailed status of each tutorial flag for debugging
- Resets all flags if ANY are incomplete

### 2. Reset Method (`lib/providers/auth_provider.dart`)

Added `resetAllTutorialFlags()` method to the `AuthNotifier` class:

```dart
/// Reset ALL tutorial flags to force user to redo tutorials from beginning
Future<void> resetAllTutorialFlags() async {
  try {
    await _authService.resetAllTutorialFlags();
    
    // Refresh current user state
    final user = await _authService.currentUser;
    state = AsyncValue.data(user);
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
  }
}
```

This method calls the auth service to update Firestore and refreshes the user state.

### 3. AuthGuard Fix (`lib/main.dart`)

Fixed the AuthGuard to properly check for closing slides completion:

```dart
// Check if user has completed tutorial closing slides
if (!user.isPremium && 
    user.onboardingCompleted && 
    user.hasSeenAppTutorial && 
    user.hasCompletedFirstLesson && 
    user.hasSeenExercisesTutorial && 
    user.hasSeenJournalTutorial && 
    user.hasLoggedWeightDuringTutorial && 
    user.hasSeenWeightDiaryTutorial && 
    user.hasVisitedWeightDiary && 
    user.hasSeenStreakTutorial && 
    user.hasSeenPlantGrowthTutorial &&
    !user.hasSeenTimerClosingSlides) {
  // Redirect to closing slides
  context.go('/tutorial-closing-slides');
}
```

Added the missing `!user.hasSeenTimerClosingSlides` check to ensure proper redirection.

## Tutorial Flags Checked

The system checks ALL 10 tutorial flags:

1. ✅ `hasSeenAppTutorial` - Education tab tutorial
2. ✅ `hasCompletedFirstLesson` - First lesson completion
3. ✅ `hasSeenExercisesTutorial` - Exercises tab tutorial
4. ✅ `hasSeenJournalTutorial` - Journal tab tutorial
5. ✅ `hasLoggedWeightDuringTutorial` - Weight logging during tutorial
6. ✅ `hasSeenWeightDiaryTutorial` - Weight diary tutorial
7. ✅ `hasVisitedWeightDiary` - Weight diary visit flag
8. ✅ `hasSeenStreakTutorial` - Streak system tutorial
9. ✅ `hasSeenPlantGrowthTutorial` - Plant growth tutorial
10. ✅ `hasSeenTimerClosingSlides` - Tutorial closing slides

## User Flow After Reset

When tutorial flags are reset at app start:

1. **App Starts** → Auth initializes and loads user data
2. **Check Runs** → `_checkAndResetTutorialsIfIncomplete` detects incomplete tutorials
3. **Flags Reset** → All 10 tutorial flags set to `false` in Firestore
4. **State Updates** → User data stream updates with new values
5. **AuthGuard Check** → User passes through (onboarding completed, but tutorials reset)
6. **Navigate to Home** → User lands on `MainNavigation` (home screen)
7. **Tutorial Triggers** → `MainNavigation._checkAndShowTutorial()` detects `!hasSeenPlantGrowthTutorial`
8. **Tutorial Starts** → Plant growth tutorial begins automatically
9. **Flow Continues** → User proceeds through entire tutorial sequence

## Tutorial Flow Sequence

The complete tutorial flow after reset:

```
Plant Growth Tutorial
  ↓
Timer Button Tutorial
  ↓
Education Tab Tutorial
  ↓
First Lesson (Chapter 1: Lesson 1)
  ↓
Exercises Tab Tutorial
  ↓
Journal Tab Tutorial
  ↓
Weight Diary Tutorial
  ↓
Weight Logging
  ↓
Streak System Tutorial
  ↓
Tutorial Closing Slides
  ↓
Main App Access
```

## Session Behavior

**Important:** The check only runs ONCE per app session:

- ✅ **First app start** → Check runs, resets if needed
- ❌ **Tab navigation** → Check does NOT run
- ❌ **Screen navigation** → Check does NOT run
- ❌ **AuthGuard checks** → Does NOT trigger the reset
- ✅ **App restart** → Check runs again (new session)
- ✅ **Re-login** → Check runs again (new session)

This is controlled by the `_tutorialCheckComplete` flag in `_BEDAppState`.

## Premium User Handling

Premium users are excluded from tutorial checks:

```dart
if (_tutorialCheckComplete || user.isPremium) {
  return;
}
```

Premium users can access the app immediately without tutorials.

## Logging Output

When incomplete tutorials are detected:

```
⚠️ APP START: Incomplete tutorials detected - resetting all tutorial flags
   Tutorial completion status:
   - hasSeenAppTutorial: true
   - hasCompletedFirstLesson: true
   - hasSeenExercisesTutorial: false  ← Incomplete!
   - hasSeenJournalTutorial: false
   - hasLoggedWeightDuringTutorial: false
   - hasSeenWeightDiaryTutorial: false
   - hasVisitedWeightDiary: false
   - hasSeenStreakTutorial: false
   - hasSeenPlantGrowthTutorial: true
   - hasSeenTimerClosingSlides: false
✅ APP START: All tutorial flags reset - user will redo tutorials from beginning
   User will be redirected to home screen to start tutorial flow
```

When all tutorials are complete:

```
✅ APP START: All tutorials completed - no reset needed
```

## Testing

To test this feature:

1. **Manual Testing:**
   - Complete part of the tutorial (e.g., stop after exercises)
   - Close and restart the app
   - Check console logs for reset message
   - Verify user is redirected to start tutorial from beginning

2. **Edge Cases:**
   - Premium users → Should skip check
   - New users → Should pass through (onboarding not completed)
   - Users mid-tutorial → Should reset and restart
   - Users who completed all → Should pass through without reset

## Benefits

✅ **Data Integrity** - Ensures users complete the full tutorial experience  
✅ **Better UX** - Prevents users from getting stuck in incomplete tutorial states  
✅ **Clean Flow** - Forces complete redo rather than partial completion  
✅ **Easy Debugging** - Comprehensive logging makes issues easy to diagnose  
✅ **Performance** - Only runs once at app start, not on every navigation  

## Related Files

- `lib/main.dart` - App start check and AuthGuard logic
- `lib/providers/auth_provider.dart` - Reset method implementation
- `lib/core/services/auth_service.dart` - Firestore update logic
- `lib/models/user_model.dart` - Tutorial flag definitions
- `lib/screens/main_navigation.dart` - Tutorial trigger logic
- `lib/core/services/app_tutorial_service.dart` - Tutorial display service

## Summary

This implementation ensures that:
1. ✅ Tutorial completion is verified at app start ONLY
2. ✅ Incomplete tutorials trigger a complete reset
3. ✅ Users are automatically redirected to redo tutorials
4. ✅ The check does NOT interfere with normal navigation
5. ✅ Premium users are excluded from the check
6. ✅ Comprehensive logging aids debugging

The user experience is seamless - if they close the app mid-tutorial, they'll automatically restart from the beginning on the next launch, ensuring they get the complete tutorial experience.

