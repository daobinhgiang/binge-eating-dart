# Lesson and Activity Integration Guide ✅

## System Overview

### Lesson Completion System (New!)
- **Centralized tracking**: All lessons tracked globally, not per-screen
- **Daily counters**: Resets at midnight like quest generation  
- **Weekly counters**: Resets Monday (ISO week numbering)
- **Automatic resets**: Similar to daily quest regeneration
- **Progress-based quests**: "Complete 2 lessons" shows 1/2, 2/2 progress

### Activity Completion System
- **Automatic detection**: When activity finished, call handler
- **Quest matching**: Checks if activity ID matches quest activityId
- **Progress tracking**: Some quests track progress (lessons, etc.)
- **Celebration dialog**: Shows when any quest is completed

---

## Part 1: Lesson Integration

### For Lesson Screens ONLY:

### Step 1: Convert to ConsumerStatefulWidget
```dart
class Lesson12Screen extends ConsumerStatefulWidget {
  @override
  ConsumerState<Lesson12Screen> createState() => _Lesson12ScreenState();
}

class _Lesson12ScreenState extends ConsumerState<Lesson12Screen> {
```

### Step 2: Add Imports
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
```

### Step 3: Add Handler (Copy This Exactly)
```dart
Future<void> _handleLessonCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    // Track lesson completion and check for quests
    final result = await questCompletionService.handleLessonCompletion(
      userId: user.id,
      lessonId: 'lesson_1_2',  // ← Change to actual lesson ID
    );

    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Step 4: Call in _finishLesson()
```dart
void _finishLesson() async {
  if (_lesson != null) {
    await _lessonService.markLessonCompleted(_lesson!.id);
    
    // NEW: Handle lesson completion with quest tracking
    await _handleLessonCompletion();
  }
  
  Navigator.of(context).pop();
}
```

### That's it for lessons!
No need to update 30+ lesson files - just use the centralized `handleLessonCompletion()` method.

---

## Part 2: Activity Integration (Food Diary, Problem Solving, etc.)

### For Food Diary Survey Screen
**File**: `lib/screens/journal/food_diary_survey_screen.dart`
**Activity ID**: `food_diary`
**Type**: `TodoType.journal`

```dart
// Step 1: Make ConsumerStatefulWidget
class FoodDiarySurveyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FoodDiarySurveyScreen> createState() => _FoodDiarySurveyScreenState();
}

// Step 2: Add imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';

// Step 3: Add handler
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: 'food_diary',
      type: TodoType.journal,
    );

    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Step 4: Call in _submitSurvey()
Future<void> _submitSurvey() async {
  if (!_validateCurrentPage()) return;

  setState(() => _isSubmitting = true);

  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) throw 'User not found';

    final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
      // ... existing parameters ...
    );

    if (entry != null && mounted) {
      // NEW: Handle activity completion
      await _handleActivityCompletion();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food diary entry saved successfully!')),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    // ... error handling ...
  }
}
```

### For Weight Diary Survey Screen
**File**: `lib/screens/journal/weight_diary_survey_screen.dart`
**Activity ID**: `weight_diary`
**Type**: `TodoType.journal`

Use the same template as Food Diary, just change the activity ID and file name.

### For Body Image Diary Survey Screen
**File**: `lib/screens/journal/body_image_diary_survey_screen.dart`
**Activity ID**: `body_image_diary`
**Type**: `TodoType.journal`

Use the same template, just change the activity ID.

### For Problem Solving Survey Screen
**File**: `lib/screens/exercises/problem_solving_survey_screen.dart`
**Activity ID**: `problem_solving`
**Type**: `TodoType.tool`

```dart
// Use same handler pattern
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: 'problem_solving',  // ← Tool ID
      type: TodoType.tool,
    );

    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Call after problem solving is submitted
```

### For Meal Planning Survey Screen
**File**: `lib/screens/exercises/meal_plan_survey_screen.dart`
**Activity ID**: `meal_planning`
**Type**: `TodoType.tool`

### For Urge Surfing Survey Screen
**File**: `lib/screens/exercises/urge_surfing_survey_screen.dart`
**Activity ID**: `urge_surfing`
**Type**: `TodoType.tool`

---

## Activity ID Reference

### Lessons
- All lesson files have IDs like: `lesson_1_1`, `lesson_1_2`, `lesson_3_10`, `lesson_s2_0_1`, etc.
- Use the lesson's ID from its file name

### Journals (TodoType.journal)
- `food_diary` - Food Diary Survey
- `weight_diary` - Weight Diary Survey
- `body_image_diary` - Body Image Diary Survey
- `money_diary` - Money/Spending Diary Survey

### Tools/Exercises (TodoType.tool)
- `problem_solving` - Problem Solving Survey
- `meal_planning` - Meal Planning Survey
- `urge_surfing` - Urge Surfing Survey
- `addressing_overconcern` - Addressing Overconcern
- `addressing_setbacks` - Addressing Setbacks Survey

---

## Lesson-Specific Quests

### How They Work

Quests can be created with `tierMetadata` that tracks progress:

```dart
// Example quest: "Complete 2 lessons today"
tierMetadata: {
  'requiredCount': 2,
  'trackBy': 'daily',  // or 'weekly'
  'expReward': 100,
}
```

When user completes a lesson:
1. `handleLessonCompletion()` records it
2. Updates: `lessonsCompletedToday` and `lessonsCompletedThisWeek`
3. Checks all "complete lessons" quests
4. If count >= required count → marks quest complete + shows dialog

### Example Quest Progress Display

In TodosScreen, quests can show progress like:
- "Complete 2 lessons" → Shows "1/2" or "2/2" after each lesson
- Quest completes when reaching requirement
- Celebrations show after reaching the goal

---

## Testing Checklist

For each screen you integrate:

- [ ] Screen extends `ConsumerStatefulWidget`
- [ ] Required imports added
- [ ] `_handleActivityCompletion()` method added
- [ ] Handler called at completion point
- [ ] Correct activity ID used
- [ ] Correct TodoType used
- [ ] No linting errors
- [ ] **Test Flow 1**: Click quest → navigate to activity → DON'T complete → go back → quest still pending ✅
- [ ] **Test Flow 2**: Click quest → navigate to activity → COMPLETE activity → see celebration dialog 🎉
- [ ] **Test Flow 3**: Return to TodosScreen → quest shows as completed ✅

---

## Implementation Checklist

### Lessons (Priority: 🔴 HIGH)
- [ ] Any lesson screen (just add `_handleLessonCompletion()` call)

### Journals (Priority: 🔴 HIGH & 🟡 MEDIUM)
- [ ] Food Diary - `food_diary_survey_screen.dart` (🔴 HIGH)
- [ ] Weight Diary - `weight_diary_survey_screen.dart` (🟡 MEDIUM)
- [ ] Body Image Diary - `body_image_diary_survey_screen.dart` (🟡 MEDIUM)
- [ ] Money Diary - `money_diary_survey_screen.dart` (🟢 LOW)

### Tools (Priority: 🔴 HIGH & 🟡 MEDIUM)
- [ ] Problem Solving - `problem_solving_survey_screen.dart` (🔴 HIGH)
- [ ] Meal Planning - `meal_plan_survey_screen.dart` (🟡 MEDIUM)
- [ ] Urge Surfing - `urge_surfing_survey_screen.dart` (🟡 MEDIUM)
- [ ] Addressing Overconcern - `addressing_overconcern_screen.dart` (🟢 LOW)
- [ ] Addressing Setbacks - `addressing_setbacks_survey_screen.dart` (🟢 LOW)

---

## Common Issues

| Issue | Solution |
|-------|----------|
| "Dialog doesn't show" | Check activity ID matches quest exactly |
| "ConsumerState not available" | Make sure screen extends `ConsumerStatefulWidget` |
| "Lesson progress not tracking" | Verify user doc exists in Firestore |
| "Can't see progress in quest" | Update quest template with tierMetadata |
| "No celebration after completing quest" | Check that handleActivityCompletion() is called AFTER successful submission |

---

## Services Available

### LessonProgressService
```dart
final lessonProgressService = LessonProgressService();

// Record lesson completion
final progress = await lessonProgressService.recordLessonCompletion(userId);
// Returns: { lessonsCompletedToday, lessonsCompletedThisWeek }

// Get current progress
final progress = await lessonProgressService.getLessonProgress(userId);
// Returns: { lessonsCompletedToday, lessonsCompletedThisWeek }
```

### QuestCompletionService
```dart
final questCompletionService = ref.read(questCompletionServiceProvider);

// For lessons
await questCompletionService.handleLessonCompletion(
  userId: userId,
  lessonId: 'lesson_1_2',
);

// For other activities
await questCompletionService.handleActivityCompletion(
  userId: userId,
  activityId: 'food_diary',
  type: TodoType.journal,
);
```

---

## Summary

**Lessons**: All handled by `handleLessonCompletion()` - no per-file changes needed!

**Other Activities**: Follow the template pattern - 3 steps per file:
1. Make ConsumerStatefulWidget
2. Add handler method
3. Call in completion point

Once complete, all quests will detect completions properly! 🎉
