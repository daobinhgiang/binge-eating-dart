# Quest Integration Checklist ✅

## Overview
This checklist helps you identify and update ALL activity screens to support quest completion detection.

## Integration Status

### ✅ Lessons
Lessons typically use:
- `lib/screens/lessons/lesson_*.dart` files
- Usually have a `_finishLesson()` method as completion point
- Need to add: Call to `_handleActivityCompletion()` in `_finishLesson()`

**Activity ID Format**: `lesson_1_1`, `lesson_1_2`, etc.

### 📋 Journals (Submission Screens)
Quest completion must be called when entries are SUBMITTED, not created.

**Activity IDs by type**:
- `food_diary` - `lib/screens/journal/food_diary_survey_screen.dart`
- `body_image_diary` - `lib/screens/journal/body_image_diary_survey_screen.dart`
- `weight_diary` - `lib/screens/journal/weight_diary_survey_screen.dart`
- `money_diary` - `lib/screens/journal/money_diary_survey_screen.dart`

**Integration Point**: In the `_submitSurvey()`, `_submit()`, or `_submitEntry()` method, right after successful submission.

### 🛠️ Exercises/Tools
Quest completion needed for tool submissions.

**Activity IDs by tool**:
- `problem_solving` - `lib/screens/exercises/problem_solving_survey_screen.dart`
- `meal_planning` - `lib/screens/exercises/meal_plan_survey_screen.dart`
- `urge_surfing` - `lib/screens/exercises/urge_surfing_survey_screen.dart`
- `addressing_overconcern` - `lib/screens/exercises/addressing_overconcern_screen.dart`
- `addressing_setbacks` - `lib/screens/exercises/addressing_setbacks_survey_screen.dart`

**Integration Point**: After completing/submitting the exercise form.

---

## Integration Template

### Step 1: Convert to ConsumerStatefulWidget
```dart
// BEFORE
class MyActivityScreen extends StatefulWidget { }

// AFTER
class MyActivityScreen extends ConsumerStatefulWidget { }
```

### Step 2: Update initState return type
```dart
// BEFORE
State<MyActivityScreen> createState()

// AFTER
ConsumerState<MyActivityScreen> createState()
```

### Step 3: Add Imports
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
```

### Step 4: Add Handler Method
```dart
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: 'YOUR_ACTIVITY_ID_HERE',  // e.g., 'lesson_1_2' or 'food_diary'
      type: TodoType.lesson,                  // or .journal or .tool
    );

    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error handling activity completion: $e');
    // Fail silently - don't interrupt user experience
  }
}
```

### Step 5: Call Handler at Completion Point
```dart
void _finishLesson() async {
  // ... existing completion logic ...
  
  await _handleActivityCompletion();  // ADD THIS LINE
  
  Navigator.of(context).pop();
}
```

---

## Priority Integrations

### 🔴 HIGH PRIORITY (Most Common)
These are used frequently and should be integrated first:

1. **Lessons** - All `lib/screens/lessons/lesson_*.dart`
   - Very frequently completed
   - Many different activity IDs

2. **Food Diary** - `food_diary_survey_screen.dart`
   - Most frequently used journal
   
3. **Problem Solving** - `problem_solving_survey_screen.dart`
   - Primary exercise tool

### 🟡 MEDIUM PRIORITY
Integrate next:

1. **Weight Diary** - `weight_diary_survey_screen.dart`
2. **Body Image Diary** - `body_image_diary_survey_screen.dart`
3. **Meal Planning** - `meal_plan_survey_screen.dart`
4. **Urge Surfing** - `urge_surfing_survey_screen.dart`

### 🟢 LOW PRIORITY
Integrate after main ones:

1. **Money Diary** - `money_diary_survey_screen.dart`
2. **Addressing Setbacks** - `addressing_setbacks_survey_screen.dart`
3. **Addressing Overconcern** - `addressing_overconcern_screen.dart`

---

## Quick Reference: Activity IDs

### All Lesson IDs
- Stage 1: `lesson_1_1`, `lesson_1_2`, `lesson_1_3`, `lesson_2_1`, `lesson_2_2`, `lesson_2_3`, `lesson_3_1` through `lesson_3_10`
- Stage 2: `lesson_s2_0_1`, `lesson_s2_0_2`, `lesson_s2_0_3`, etc.
- Stage 3: `lesson_s3_0_2_1`, etc.

### All Journal IDs
- `food_diary`
- `weight_diary`
- `body_image_diary`
- `money_diary`

### All Tool IDs
- `problem_solving`
- `meal_planning`
- `urge_surfing`
- `addressing_overconcern`
- `addressing_setbacks`

---

## Verification Checklist

For each screen you integrate:

- [ ] Screen extends `ConsumerStatefulWidget`
- [ ] createState returns `ConsumerState<>`
- [ ] All required imports added
- [ ] `_handleActivityCompletion()` method added
- [ ] `_handleActivityCompletion()` called at completion point
- [ ] Correct activity ID used
- [ ] Correct TodoType used
- [ ] No linting errors
- [ ] Tested: Click quest → don't complete → quest still pending
- [ ] Tested: Complete activity → see congratulation dialog
- [ ] Tested: Dismiss dialog → quest shows as completed in list

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Dialog doesn't show | Check activity ID matches quest activityId exactly |
| ConsumerState error | Make sure screen extends `ConsumerStatefulWidget` |
| Quest shows as completed immediately | This shouldn't happen with new fix - check if `navigateToTodoActivity` is being called |
| No completion detected on submit | Verify `_handleActivityCompletion()` is called AFTER successful submission |
| EXP not awarded | Check user exists in Firestore |

---

## Implementation Progress

### Lessons
- [ ] lesson_1_1
- [ ] lesson_1_2
- [ ] lesson_1_3
- [ ] lesson_2_1 (assessment)
- [ ] lesson_2_2 (assessment)
- [ ] lesson_2_3 (assessment)
- [ ] lesson_3_1 through lesson_3_10
- [ ] All Stage 2 lessons
- [ ] All Stage 3 lessons

### Journals
- [ ] Food Diary (food_diary_survey_screen.dart)
- [ ] Weight Diary (weight_diary_survey_screen.dart)
- [ ] Body Image Diary (body_image_diary_survey_screen.dart)
- [ ] Money Diary (money_diary_survey_screen.dart)

### Tools
- [ ] Problem Solving (problem_solving_survey_screen.dart)
- [ ] Meal Planning (meal_plan_survey_screen.dart)
- [ ] Urge Surfing (urge_surfing_survey_screen.dart)
- [ ] Addressing Overconcern (addressing_overconcern_screen.dart)
- [ ] Addressing Setbacks (addressing_setbacks_survey_screen.dart)

---

## Need Help?

See these documents:
- **QUEST_QUICK_START.md** - 30-second overview
- **QUEST_INTEGRATION_GUIDE.md** - Step-by-step guide with examples
- **QUEST_COMPLETION_SYSTEM_SUMMARY.md** - Full architecture
- **AUTO_COMPLETION_BUG_FIX.md** - Why auto-completion was removed

---

## Next Steps

1. Start with HIGH PRIORITY items (lessons, food diary, problem solving)
2. Use the integration template above
3. Test each integration before moving to next
4. Check off boxes as you complete integrations
5. All quests will then detect completions properly!
