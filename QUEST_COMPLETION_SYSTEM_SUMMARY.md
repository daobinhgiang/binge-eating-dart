# Quest Completion System - Implementation Summary

## Overview

A complete quest completion detection and tracking system has been implemented. When users complete activities (lessons, tools, journals), the system automatically:

1. **Detects quest completion** - Matches the activity to pending quests
2. **Marks quests as complete** - Updates Firestore in real-time
3. **Awards EXP** - Adds EXP to user's total
4. **Updates streak** - Increments daily streak when all daily tasks completed
5. **Shows congratulations** - Beautiful celebration dialog with animations
6. **Updates UI in real-time** - TodosScreen reflects changes immediately

## Architecture

### Core Components

#### 1. QuestCompletionService (`lib/core/services/quest_completion_service.dart`)
**Singleton service** that coordinates the entire quest completion flow.

**Main Method:**
```dart
Future<QuestCompletionResult> handleActivityCompletion({
  required String userId,
  required String activityId,
  required TodoType type,
})
```

**Responsibilities:**
- Finds matching pending quest for an activity
- Marks quest as completed in Firestore
- Awards EXP points to user
- Updates daily streak if applicable
- Returns completion result with details

**Data Class:**
```dart
class QuestCompletionResult {
  final bool questCompleted;           // Was quest found & completed?
  final TodoItem? completedQuest;      // The quest that was completed
  final int expAwarded;                // EXP given
  final bool streakUpdated;            // Was streak incremented?
  final int? currentStreak;            // New streak count
}
```

#### 2. QuestCompletionDialog (`lib/widgets/quest_completion_dialog.dart`)
**Beautiful celebration dialog** shown when user completes a quest.

**Features:**
- Elastic pop-in animation with scale transition
- Slide-in content animation
- Animated star icon with pulsing effect
- Animated EXP counter (counts from 0 to final amount)
- Optional streak display with fire icon
- White "Continue" button for dismissal
- Purple gradient background with shadow effects

**Usage:**
```dart
showQuestCompletionDialog(context, result);
```

#### 3. Provider Integration
Added to `lib/providers/todo_provider.dart`:
```dart
final questCompletionServiceProvider = 
  Provider<QuestCompletionService>((ref) => QuestCompletionService());
```

### Data Flow

```
User completes activity
    ↓
Activity screen calls _handleActivityCompletion()
    ↓
QuestCompletionService.handleActivityCompletion() executes
    ├─→ Step 1: Find matching quest by activityId + type
    ├─→ Step 2: Award EXP (add to user.exp in Firestore)
    └─→ Step 3: Update streak if seed quest
         (only if ALL daily tasks now completed)
    ↓
QuestCompletionResult returned
    ↓
If questCompleted == true:
  Show congratulation dialog
    ↓
User dismisses dialog
    ↓
TodosStream updates automatically
    ↓
TodosScreen reflects completed quest
```

## Integration Guide

### For Lessons

1. **Make screen ConsumerStatefulWidget**:
   ```dart
   class MyLessonScreen extends ConsumerStatefulWidget {
     @override
     ConsumerState<MyLessonScreen> createState() => _MyLessonScreenState();
   }
   ```

2. **Add imports**:
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../core/services/quest_completion_service.dart';
   import '../widgets/quest_completion_dialog.dart';
   import '../providers/auth_provider.dart';
   import '../providers/todo_provider.dart';
   import '../models/todo_item.dart';
   ```

3. **Add handler method**:
   ```dart
   Future<void> _handleActivityCompletion() async {
     try {
       final user = ref.read(currentUserDataProvider);
       if (user == null) return;

       final questCompletionService = ref.read(questCompletionServiceProvider);
       
       final result = await questCompletionService.handleActivityCompletion(
         userId: user.id,
         activityId: 'lesson_1_2',  // Your lesson ID
         type: TodoType.lesson,
       );

       if (result.questCompleted && mounted) {
         showQuestCompletionDialog(context, result);
       }
     } catch (e) {
       print('Error handling activity completion: $e');
     }
   }
   ```

4. **Call in completion method**:
   ```dart
   void _finishLesson() async {
     if (_lesson != null) {
       await _lessonService.markLessonCompleted(_lesson!.id);
       await _handleActivityCompletion();  // NEW LINE
     }
     
     Navigator.of(context).pop();
   }
   ```

### For Journals

Same process, but in submission method:

```dart
Future<void> _submitSurvey() async {
  // ... validation & submission code ...
  
  final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
    // ... parameters ...
  );

  if (entry != null && mounted) {
    await _handleActivityCompletion();  // NEW LINE
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved successfully!')),
    );
    Navigator.of(context).pop();
  }
}
```

**Activity IDs**:
- `'food_diary'` - Food Diary
- `'weight_diary'` - Weight Diary  
- `'body_image_diary'` - Body Image Diary
- `'money_diary'` - Money/Spending Diary

### For Tools/Exercises

Same pattern, in tool completion handler:

```dart
Future<void> _completeTool() async {
  // ... tool completion logic ...
  
  await _handleActivityCompletion();  // NEW LINE
  
  Navigator.of(context).pop();
}
```

**Activity IDs**:
- `'problem_solving'`
- `'meal_planning'`
- `'urge_surfing'`
- `'addressing_overconcern'`
- `'addressing_setbacks'`

## Real-Time Updates

The TodosScreen automatically updates when quests are completed because it listens to the real-time stream:

```dart
final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));
```

When a quest is marked as completed in Firestore:
1. Firestore stream updates
2. Provider rebuilds with new data
3. TodosScreen re-renders
4. Completed quest shows as completed in UI

## EXP System

### How EXP is Awarded

When quest completion service awards EXP:

```dart
// Get current EXP
final userDoc = await _firestore.collection('users').doc(userId).get();
final currentExp = (userDoc.get('exp') ?? 0) as int;
final newExp = currentExp + expAmount;

// Update user document
await _firestore.collection('users').doc(userId).update({
  'exp': newExp,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

### EXP Rewards by Quest Type

Configured in TodoItem model via `expReward` getter:

```dart
int get expReward {
  if (tierMetadata != null && tierMetadata!.containsKey('expReward')) {
    return tierMetadata!['expReward'] as int;
  }
  // Default rewards by tier
  switch (tier!) {
    case TaskTier.seeds:
      return 50;           // Daily seeds
    case TaskTier.growthTasks:
      return 200;          // Weekly growth tasks
    case TaskTier.masteryQuests:
      return 500;          // Long-term mastery quests
  }
}
```

## Streak System

### How Streak is Updated

Streak only increments when **ALL daily (Seed) tasks are completed**:

1. User completes a seed quest
2. Quest completion service checks if all seeds for today are done
3. If yes: increment streak + show in congratulation dialog
4. If no: don't update streak

**Streak Conditions:**
- ✅ Increments daily when all Seeds completed
- ✅ Resets on task regeneration if yesterday's seeds weren't all completed
- ✅ Displayed in congratulation dialog with fire icon
- ✅ Used in StreakDisplay widget on home screen

## Files Created

1. **lib/core/services/quest_completion_service.dart**
   - QuestCompletionService class
   - QuestCompletionResult data class
   - Main completion logic

2. **lib/widgets/quest_completion_dialog.dart**
   - QuestCompletionDialog widget
   - showQuestCompletionDialog() helper function
   - Beautiful animations and UI

3. **QUEST_COMPLETION_IMPLEMENTATION.md**
   - Detailed technical documentation
   - Architecture overview

4. **QUEST_INTEGRATION_GUIDE.md**
   - Step-by-step integration instructions
   - Activity ID reference
   - Code examples

5. **QUEST_COMPLETION_SYSTEM_SUMMARY.md** (this file)
   - High-level overview
   - Architecture summary

## Files Modified

1. **lib/providers/todo_provider.dart**
   - Added questCompletionServiceProvider

## Testing

To test the system:

1. **Generate daily seeds**
   ```
   - Manually clear yesterday's tasks
   - Open TodosScreen → tasks regenerate
   ```

2. **Match activity to quest**
   ```
   - Verify seed's activityId (e.g., 'lesson_1_2')
   - Complete that activity
   - Should match and trigger completion
   ```

3. **Verify completion flow**
   ```
   - Congratulation dialog appears
   - Shows quest name + EXP awarded
   - Shows streak if applicable
   - User dismisses → returns to screen
   - Quest marked as completed in list
   ```

4. **Check Firestore updates**
   ```
   - Quest isCompleted = true
   - User exp increased by quest.expReward
   - Streak updated (if applicable)
   - TodosStream reflects changes
   ```

## Important Notes

1. **Activity ID Matching**: The activity ID passed to `handleActivityCompletion()` MUST match exactly with the quest's `activityId` in Firestore, or no matching quest will be found.

2. **Error Handling**: The handler has try-catch that silently fails if no quest is found. This is intentional - users can complete activities without having a quest for them.

3. **Async/Await**: Always `await` the completion handler to ensure it completes before navigation.

4. **Mounted Check**: Always check `if (mounted)` before showing dialogs after async operations.

5. **ConsumerStatefulWidget**: Activity screens must be ConsumerStatefulWidget to access `ref`.

6. **Daily Seeds**: The system prioritizes daily seeds when updating streaks. Non-seed quests don't contribute to streaks.

## Next Steps

To fully integrate this system into your app:

1. Update each activity screen (lessons, tools, journals) with the integration pattern
2. Test quest completion end-to-end
3. Verify Firestore updates are working
4. Monitor console logs for any issues
5. Fine-tune EXP amounts if needed
6. Add tracking/analytics for quest completion rates

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Dialog not showing | Quest not found | Check activity ID matches quest.activityId |
| EXP not awarded | Firestore write failed | Check user doc exists in Firestore |
| Streak not updating | Not all seeds completed | Verify all daily tasks are actually complete |
| UI not updating | Stream not refreshing | Ensure TodosScreen watches userTodosStreamProvider |
| ConsumerState error | Wrong widget base class | Change to ConsumerStatefulWidget |
