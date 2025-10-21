# Quest Completion System - Quick Start Guide

## 30-Second Overview

**What**: Your to-do quests now detect when users complete activities and reward them with EXP, celebrate with a dialog, and update the UI in real-time.

**Where**: 
- Service: `lib/core/services/quest_completion_service.dart`
- Dialog: `lib/widgets/quest_completion_dialog.dart`
- Provider: `lib/providers/todo_provider.dart`

**How**: Call one method in each activity screen at completion

## 3-Step Integration

### Step 1: Import Dependencies
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
```

### Step 2: Change Widget Base Class
```dart
// BEFORE
class MyActivityScreen extends StatefulWidget { ... }

// AFTER
class MyActivityScreen extends ConsumerStatefulWidget { ... }
```

### Step 3: Add Handler Method
```dart
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: 'your_activity_id',  // e.g., 'lesson_1_2' or 'food_diary'
      type: TodoType.lesson,            // or .journal, or .tool
    );

    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Step 4: Call Handler at Completion Point
```dart
// For lessons:
void _finishLesson() async {
  if (_lesson != null) {
    await _lessonService.markLessonCompleted(_lesson!.id);
    await _handleActivityCompletion();  // ADD THIS LINE
  }
  Navigator.of(context).pop();
}

// For journals:
Future<void> _submitSurvey() async {
  // ... submission code ...
  await _handleActivityCompletion();    // ADD THIS LINE
  Navigator.of(context).pop();
}

// For tools:
Future<void> _completeTool() async {
  // ... tool code ...
  await _handleActivityCompletion();    // ADD THIS LINE
  Navigator.of(context).pop();
}
```

## Activity ID Quick Reference

### Lessons
- Stage 1: `lesson_1_1`, `lesson_1_2`, `lesson_1_3`, ...
- Stage 2: `lesson_s2_0_1`, `lesson_s2_4_3`, ...
- Stage 3: `lesson_s3_0_2_1`, ...

### Journals
- `food_diary`
- `weight_diary`
- `body_image_diary`
- `money_diary`

### Tools
- `problem_solving`
- `meal_planning`
- `urge_surfing`
- `addressing_overconcern`
- `addressing_setbacks`

## What Happens Automatically

1. ✅ Quest found and marked complete in Firestore
2. ✅ EXP awarded to user
3. ✅ Streak incremented (if all daily tasks done)
4. ✅ Congratulation dialog shown with animation
5. ✅ TodosScreen updates in real-time

## Testing

1. Open TodosScreen → daily seeds generated
2. Complete matching activity (e.g., finish lesson that matches a seed)
3. See congratulation dialog
4. Return to TodosScreen → quest shows completed

## Troubleshooting

| Problem | Fix |
|---------|-----|
| No dialog appears | Check activity ID matches quest `activityId` exactly |
| ConsumerState error | Make sure screen extends `ConsumerStatefulWidget` |
| EXP not awarded | Verify user doc exists in Firestore |
| Streak not updating | Make sure all daily seeds are completed |

## Documentation

- **Full guide**: `QUEST_INTEGRATION_GUIDE.md`
- **Architecture**: `QUEST_COMPLETION_SYSTEM_SUMMARY.md`
- **Technical specs**: `QUEST_COMPLETION_IMPLEMENTATION.md`
- **Status**: `QUEST_SYSTEM_IMPLEMENTATION_COMPLETE.md`

## That's It! 🎯

Your quests are now live and interactive. Every activity completion triggers rewards, streaks, and beautiful celebrations!
