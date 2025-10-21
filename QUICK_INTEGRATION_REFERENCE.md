# Quick Integration Reference Card 📋

## For Lessons (Template)

```dart
// Step 1: Make ConsumerStatefulWidget
class Lesson12Screen extends ConsumerStatefulWidget {
  @override
  ConsumerState<Lesson12Screen> createState() => _Lesson12ScreenState();
}

// Step 2: Add imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';

class _Lesson12ScreenState extends ConsumerState<Lesson12Screen> {
  // Step 3: Add this method
  Future<void> _handleLessonCompletion() async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleLessonCompletion(
        userId: user.id,
        lessonId: 'lesson_1_2',  // Change this
      );
      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(context, result);
      }
    } catch (e) { print('Error: $e'); }
  }

  // Step 4: Add this line in _finishLesson()
  void _finishLesson() async {
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
      await _handleLessonCompletion();  // ← ADD THIS
    }
    Navigator.of(context).pop();
  }
}
```

---

## For Food Diary (Template)

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

class _FoodDiarySurveyScreenState extends ConsumerState<FoodDiarySurveyScreen> {
  // Step 3: Add this method
  Future<void> _handleActivityCompletion() async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleActivityCompletion(
        userId: user.id,
        activityId: 'food_diary',  // ← Match activity ID
        type: TodoType.journal,
      );
      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(context, result);
      }
    } catch (e) { print('Error: $e'); }
  }

  // Step 4: Add this line in _submitSurvey()
  Future<void> _submitSurvey() async {
    if (!_validateCurrentPage()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) throw 'User not found';
      
      final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
        // ... parameters ...
      );

      if (entry != null && mounted) {
        await _handleActivityCompletion();  // ← ADD THIS
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ... error handling ...
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
```

---

## For Other Activities

Use **Food Diary** template, just change:
- `activityId`: Use the ID below
- `type`: `TodoType.journal` or `TodoType.tool`
- `_submitSurvey()`: Adapt to your screen's method name

| Activity | ID | Type |
|----------|----|----|
| Weight Diary | `weight_diary` | .journal |
| Body Image | `body_image_diary` | .journal |
| Money Diary | `money_diary` | .journal |
| Problem Solving | `problem_solving` | .tool |
| Meal Planning | `meal_planning` | .tool |
| Urge Surfing | `urge_surfing` | .tool |
| Addressing Overconcern | `addressing_overconcern` | .tool |
| Addressing Setbacks | `addressing_setbacks` | .tool |

---

## Checklist Per File

- [ ] Convert to `ConsumerStatefulWidget`
- [ ] Add all 4 imports
- [ ] Add handler method (copy from template)
- [ ] Add call in completion method
- [ ] Update activity ID
- [ ] Update type (.journal or .tool for lessons: use handler directly!)
- [ ] No linting errors? (`flutter analyze`)
- [ ] Test: Complete activity → see dialog 🎉

---

## Testing Quick Check

1. **Click quest** → navigate to activity
2. **Don't complete** → go back → quest STILL pending ✅
3. **Complete activity** → see celebration dialog 🎉
4. **Return to list** → quest shows COMPLETED ✅

---

## For Help

- **Full Guide**: `LESSON_AND_ACTIVITY_INTEGRATION.md`
- **All Docs**: Check documentation files in root
- **Code Examples**: In integration guide with comments

---

## Priority Order

🔴 HIGH (do first):
1. Any lesson file
2. Food Diary
3. Problem Solving

🟡 MEDIUM (do next):
4. Weight Diary
5. Body Image Diary
6. Meal Planning
7. Urge Surfing

🟢 LOW (do last):
8. Money Diary
9. Addressing Setbacks
10. Addressing Overconcern

**Total time**: ~1-2 hours for all high + medium items (5-10 min per file)

---

That's it! Copy, adapt, test, move to next! 🚀
