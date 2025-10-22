<!-- 19fcfd0b-1162-4e53-8c30-c1024548ab8b 3fcbffd4-940c-4f5c-95fa-0891aef2deac -->
# Streak Tutorial Flow Implementation

## Overview

Add a tutorial overlay that appears after the streak animation during the initial app tutorial to explain the streak system to first-time users.

## Changes Required

### 1. Add Streak Tutorial to AppTutorialService

**File:** `lib/core/services/app_tutorial_service.dart`

- Add `streakExplanation` to the `TutorialStep` enum
- Create new method `showStreakExplanationTutorial()` that:
- Takes a GlobalKey for the streak popup dialog
- Shows tutorial overlay with message: "Great job! When you complete all of your daily quests/seeds for the day, you extend your streak! Keep it going every day!"
- Uses a full-screen or dialog-based overlay (not targeting specific UI element since the streak popup is already visible)
- Has an "OK" button or tap-anywhere-to-dismiss functionality
- Calls `onFinish` callback when dismissed

### 2. Add User Flag for Streak Tutorial

**File:** `lib/models/user_model.dart`

- Add `hasSeenStreakTutorial` boolean field (default: false)
- Add to constructor, `fromFirestore`, `toFirestore`, and `copyWith` methods

**File:** `lib/core/services/auth_service.dart`

- Add `hasSeenStreakTutorial` parameter to `updateTutorialStatus()` method
- Include in Firestore update logic

**File:** `lib/providers/auth_provider.dart`

- Add `hasSeenStreakTutorial` parameter to `updateTutorialStatus()` method
- Pass through to auth service

### 3. Modify Quest Completion Dialog Flow

**File:** `lib/widgets/quest_completion_dialog.dart`

The current flow (lines 264-292) already shows streak animation after quest dialog dismissal. Enhance this:

- Add optional callback parameter to `showQuestCompletionDialog()` and `QuestCompletionDialog`: `onStreakAnimationShown`
- After showing streak animation (line 282-287), check if we're in tutorial flow
- If in tutorial AND user hasn't seen streak tutorial, trigger the callback
- Pass context and necessary info to allow parent to show streak tutorial

### 4. Coordinate Streak Tutorial in Weight Diary Screen

**File:** `lib/screens/journal/weight_diary_survey_screen.dart`

In `_handleActivityCompletion()` method (lines 316-346):

- When calling `showQuestCompletionDialog()` during tutorial flow (line 330-334), add `onStreakAnimationShown` callback
- This callback should:

1. Wait for streak animation to complete (~1.5-2 seconds to account for the 1.2s animation + popup display time)
2. Check if user hasn't seen streak tutorial yet
3. Show the streak tutorial overlay
4. After tutorial dismissal, mark `hasSeenStreakTutorial: true`
5. Then proceed with existing `_updateTutorialStatusAndNavigate()` logic

### 5. Ensure Proper Sequencing in Main Navigation

**File:** `lib/screens/main_navigation.dart`

The plant growth tutorial trigger (lines 399-421) already checks for `hasLoggedWeightDuringTutorial`. No changes needed here since the weight diary screen will handle the streak tutorial before navigating to home.

### 6. Update Streak Animation Popup (Optional Enhancement)

**File:** `lib/widgets/streak_animation_popup.dart`

Consider adding a GlobalKey or identifier to make it targetable by the tutorial overlay, though the tutorial can work without targeting the specific popup.

## Implementation Flow

1. User completes weight diary during tutorial
2. Quest completion dialog shows ("Quest Completed!")
3. User clicks "Continue" button
4. Dialog dismisses, streak animation popup appears automatically
5. Streak animation plays (~1.2s)
6. Tutorial overlay appears over the streak popup
7. Tutorial explains: "When you complete all daily quests, your streak extends!"
8. User taps "OK" or anywhere to dismiss tutorial
9. Mark `hasSeenStreakTutorial: true`
10. Streak popup auto-closes (existing 2.5s timeout)
11. Navigate to home tab
12. Plant growth tutorial begins (existing flow)

## Testing Checklist

- New user completes app tutorial and sees streak tutorial only once
- Streak tutorial appears AFTER streak animation completes
- Tutorial only shows during initial app tutorial flow
- Tutorial does NOT show on subsequent quest completions
- Plant growth tutorial still triggers correctly after streak tutorial
- Regular users (not in tutorial) see normal quest completion + streak animation without tutorial overlay

### To-dos

- [ ] Add showStreakExplanationTutorial() method to AppTutorialService with overlay UI
- [ ] Add hasSeenStreakTutorial flag to UserModel, AuthService, and AuthProvider
- [ ] Add onStreakAnimationShown callback to QuestCompletionDialog
- [ ] Update weight diary screen to show streak tutorial after animation completes
- [ ] Test complete tutorial flow from weight diary through plant growth