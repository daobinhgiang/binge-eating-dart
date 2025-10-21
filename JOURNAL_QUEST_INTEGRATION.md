# Journal Quest Integration - Implementation Summary

## Overview

All journal submission screens now check for quest completion after the user successfully submits an entry. This ensures that quests like "Complete Today's Food Diary" are automatically detected and marked complete when the user submits their journal entries.

## Changes Made

### 1. Food Diary Survey Screen
**File**: `lib/screens/journal/food_diary_survey_screen.dart`
- **Activity ID**: `food_diary`
- **Quest Type**: `TodoType.journal`
- **Integration Point**: After successful entry creation in `_submitSurvey()`

### 2. Body Image Diary Survey Screen
**File**: `lib/screens/journal/body_image_diary_survey_screen.dart`
- **Activity ID**: `body_image_diary`
- **Quest Type**: `TodoType.journal`
- **Integration Point**: After successful entry creation in `_submitSurvey()`

### 3. Weight Diary Survey Screen
**File**: `lib/screens/journal/weight_diary_survey_screen.dart`
- **Activity ID**: `weight_diary`
- **Quest Type**: `TodoType.journal`
- **Integration Point**: After successful entry creation in `_submit()`

### 4. Money Diary Survey Screen
**File**: `lib/screens/journal/money_diary_survey_screen.dart`
- **Activity ID**: `money_diary`
- **Quest Type**: `TodoType.journal`
- **Integration Point**: After successful entry creation in `_submitEntry()`

## Implementation Pattern

Each screen now includes:

### 1. Required Imports
```dart
import '../../providers/todo_provider.dart';
import '../../models/todo_item.dart';
import '../../widgets/quest_completion_dialog.dart';
```

### 2. Quest Completion Handler
```dart
/// Handle quest completion for [activity] activity
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;
    
    final questCompletionService = ref.read(questCompletionServiceProvider);
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: '[activity_id]',  // e.g., 'food_diary'
      type: TodoType.journal,
    );
    
    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error checking quest completion: $e');
  }
}
```

### 3. Call After Successful Submission
```dart
if (entry != null && mounted) {
  // Check for quest completion
  await _handleActivityCompletion();
  
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(...);
  
  // Navigate back
  Navigator.of(context).pop();
}
```

## How It Works

1. **User Submits Journal Entry**: User fills out and submits a journal entry (e.g., food diary)
2. **Entry Created**: The entry is successfully saved to Firestore
3. **Quest Check Triggered**: `_handleActivityCompletion()` is called
4. **Quest Service Checks**: `QuestCompletionService` searches for pending quests matching the activity ID
5. **Quest Completed**: If a matching quest is found:
   - Quest is marked as completed in Firestore
   - EXP is awarded to the user
   - Streak is updated if applicable (for daily seeds)
   - UI updates automatically via stream providers
6. **Celebration Dialog**: If a quest was completed, a beautiful celebration dialog is shown with:
   - Animated star icon
   - EXP earned counter
   - Current streak (if applicable)
   - Quest title and details

## Matching Quests

The following quest templates in `task_templates.dart` can now be automatically completed:

### Daily Seeds
- **"Complete Today's Food Diary"** - `food_diary` (50 EXP)
- **"Reflect on Body Image"** - `body_image_diary` (50 EXP)
- **"Log Your Weight"** - `weight_diary` (30 EXP)

### Future Quests
The system is ready for any future quests related to:
- Money diary (`money_diary`)
- Journal streaks
- Multiple entries per day

## Testing

To test the implementation:

1. **Generate Daily Quests**: Ensure you have a fresh set of daily seeds
2. **Submit Journal Entry**: Complete and submit a journal entry (e.g., food diary)
3. **Verify Quest Completion**:
   - Quest should be marked complete in the Quests tab
   - Celebration dialog should appear
   - EXP should be awarded
   - Streak should update if all daily tasks are complete

## Benefits

✅ **Automatic Detection**: No manual quest marking needed
✅ **Real-time Updates**: UI reflects changes immediately
✅ **User Engagement**: Celebration dialog provides positive feedback
✅ **Streak Tracking**: Daily seeds contribute to streak maintenance
✅ **Consistent Pattern**: Same implementation across all journal types
✅ **Error Handling**: Graceful failure if no matching quest exists

## Notes

- Quest checking happens **after** successful entry creation
- If no matching quest exists, the function returns silently (no error)
- The celebration dialog only appears if a quest was actually completed
- Multiple entries can be submitted, but quest only completes once per day for daily seeds
- The weight diary integration preserves existing tutorial flow logic

## Related Files

- **Quest Completion Service**: `lib/core/services/quest_completion_service.dart`
- **Quest Completion Dialog**: `lib/widgets/quest_completion_dialog.dart`
- **Todo Provider**: `lib/providers/todo_provider.dart`
- **Task Templates**: `lib/data/task_templates.dart`

## Future Enhancements

Potential improvements for the future:

1. Add quest checking to exercise/tool screens (problem solving, meal planning, etc.)
2. Create progress-based quests (e.g., "Log weight 7 days in a row")
3. Add multi-step quests (e.g., "Complete food diary AND body image diary")
4. Create achievement milestones (e.g., "100 food diary entries")

---

**Implementation Date**: October 21, 2025
**Status**: ✅ Complete
**Tested**: Ready for testing

