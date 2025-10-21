# Quest Integration Guide

This guide explains how to integrate quest completion detection into any activity screen (lessons, tools, journals, etc).

## Overview

When a user completes an activity, we need to:
1. Check if there's a pending quest for that activity
2. Mark the quest as completed in Firestore
3. Award EXP to the user
4. Update streak if applicable
5. Show a congratulation dialog

## Implementation Steps

### Step 1: Import Required Files

Add these imports to your activity screen:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/quest_completion_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
```

### Step 2: Make Screen a ConsumerStatefulWidget (if not already)

Change from `StatefulWidget` to `ConsumerStatefulWidget`:

```dart
// BEFORE
class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});
  
  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {

// AFTER
class MyActivityScreen extends ConsumerStatefulWidget {
  const MyActivityScreen({super.key});
  
  @override
  ConsumerState<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends ConsumerState<MyActivityScreen> {
```

### Step 3: Add Quest Completion Handler

Add this method to your state class:

```dart
Future<void> _handleActivityCompletion() async {
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    final questCompletionService = ref.read(questCompletionServiceProvider);
    
    // Call the completion handler with the activity details
    final result = await questCompletionService.handleActivityCompletion(
      userId: user.id,
      activityId: 'your_activity_id_here', // e.g., 'lesson_1_2'
      type: TodoType.lesson, // or .tool, or .journal
    );

    // Show congratulation dialog if quest was completed
    if (result.questCompleted && mounted) {
      showQuestCompletionDialog(context, result);
    }
  } catch (e) {
    print('Error handling activity completion: $e');
    // Fail silently - activity completion shouldn't be disrupted by quest system
  }
}
```

### Step 4: Call Handler at Completion Point

#### For Lessons

In the `_finishLesson()` method:

```dart
void _finishLesson() async {
  // Mark lesson as completed (existing code)
  if (_lesson != null) {
    await _lessonService.markLessonCompleted(_lesson!.id);
    
    // NEW: Handle quest completion
    await _handleActivityCompletion();
  }
  
  // Navigate back
  Navigator.of(context).pop();
}
```

**Activity ID for lessons**: Use the lesson ID, e.g., `'lesson_1_2'`, `'lesson_s2_4_3'`, etc.

#### For Journals

In the submission method (e.g., `_submitSurvey()`):

```dart
Future<void> _submitSurvey() async {
  // ... existing validation and submission code ...
  
  try {
    final user = ref.read(currentUserDataProvider);
    if (user == null) throw 'User not found';

    final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
      // ... entry parameters ...
    );

    if (entry != null && mounted) {
      // NEW: Handle quest completion
      await _handleActivityCompletion();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food diary entry saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    // ... error handling ...
  }
}
```

**Activity IDs for journals**:
- Food Diary: `'food_diary'`
- Weight Diary: `'weight_diary'`
- Body Image Diary: `'body_image_diary'`
- Money Diary: `'money_diary'`

#### For Tools/Exercises

In the tool completion handler (e.g., after completing problem solving steps):

```dart
Future<void> _completeTool() async {
  // ... existing tool completion code ...
  
  // NEW: Handle quest completion
  await _handleActivityCompletion();
  
  // Navigate away or show result
  Navigator.of(context).pop();
}
```

**Activity IDs for tools**:
- Problem Solving: `'problem_solving'`
- Meal Planning: `'meal_planning'`
- Urge Surfing: `'urge_surfing'`
- Addressing Overconcern: `'addressing_overconcern'`
- Addressing Setbacks: `'addressing_setbacks'`

## Data Flow

```
User completes activity (finishes lesson, submits journal, etc)
    ↓
_handleActivityCompletion() called
    ↓
QuestCompletionService.handleActivityCompletion() invoked
    ↓
Service finds matching pending quest by activityId + type
    ↓
If quest found:
  - Mark quest as completed in Firestore
  - Award EXP to user
  - Update streak if seed quest
    ↓
Return QuestCompletionResult
    ↓
Show congratulation dialog to user
    ↓
User dismisses dialog
    ↓
TodosScreen stream updates (real-time) and shows quest as completed
```

## Complete Example: Lesson Integration

Here's a complete example for integrating a lesson:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lesson_service.dart';
import '../core/services/quest_completion_service.dart';
import '../widgets/lesson_slide_widget.dart';
import '../widgets/quest_completion_dialog.dart';
import '../data/stage_1_data.dart';
import '../models/lesson.dart';
import '../models/todo_item.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';

class Lesson12Screen extends ConsumerStatefulWidget {
  const Lesson12Screen({super.key});

  @override
  ConsumerState<Lesson12Screen> createState() => _Lesson12ScreenState();
}

class _Lesson12ScreenState extends ConsumerState<Lesson12Screen> {
  final LessonService _lessonService = LessonService();
  final ScrollController _scrollController = ScrollController();
  Lesson? _lesson;
  int _currentSlideIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final stage1 = Stage1Data.getStage1();
      final lesson12 = stage1.chapters
          .firstWhere((chapter) => chapter.chapterNumber == 1)
          .lessons
          .firstWhere((lesson) => lesson.id == 'lesson_1_2');
      
      setState(() {
        _lesson = lesson12;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lesson: $e')),
        );
      }
    }
  }

  void _goToNextSlide() {
    if (_lesson != null && _currentSlideIndex < _lesson!.slides.length - 1) {
      setState(() => _currentSlideIndex++);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() => _currentSlideIndex--);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _handleActivityCompletion() async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;

      final questCompletionService = ref.read(questCompletionServiceProvider);
      
      final result = await questCompletionService.handleActivityCompletion(
        userId: user.id,
        activityId: 'lesson_1_2', // ← Specific lesson ID
        type: TodoType.lesson,
      );

      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(context, result);
      }
    } catch (e) {
      print('Error handling activity completion: $e');
    }
  }

  void _finishLesson() async {
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
      
      // NEW: Handle quest completion
      await _handleActivityCompletion();
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lesson == null || _lesson!.slides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson 1.2')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final currentSlide = _lesson!.slides[_currentSlideIndex];
    final isFirstSlide = _currentSlideIndex == 0;
    final isLastSlide = _currentSlideIndex == _lesson!.slides.length - 1;

    return LessonSlideWidget(
      slide: currentSlide,
      scrollController: _scrollController,
      isFirstSlide: isFirstSlide,
      isLastSlide: isLastSlide,
      onPrevious: isFirstSlide ? null : _goToPreviousSlide,
      onNext: isLastSlide ? null : _goToNextSlide,
      onFinish: isLastSlide ? _finishLesson : null,
      totalSlides: _lesson!.slides.length,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Activity ID Reference

### Lessons
- Stage 1 Lessons: `lesson_1_1`, `lesson_1_2`, `lesson_1_3`, etc.
- Stage 2 Lessons: `lesson_s2_0_1`, `lesson_s2_0_2`, etc.
- Stage 3 Lessons: `lesson_s3_0_2_1`, etc.

### Journals
- Food Diary: `food_diary`
- Weight Diary: `weight_diary`
- Body Image Diary: `body_image_diary`
- Money/Spending Diary: `money_diary`

### Tools/Exercises
- Problem Solving: `problem_solving`
- Meal Planning: `meal_planning`
- Urge Surfing: `urge_surfing`
- Addressing Overconcern: `addressing_overconcern`
- Addressing Setbacks: `addressing_setbacks`

## Important Notes

1. **Match Activity IDs**: The activity ID must match exactly with the quest's activityId in Firestore
2. **Error Handling**: Always wrap in try-catch - quest completion shouldn't interrupt the main activity flow
3. **Async**: Use `await` to ensure quest completion completes before navigation
4. **Mounted Check**: Always check `if (mounted)` before showing dialogs or snackbars
5. **ConsumerStatefulWidget**: Must use ConsumerStatefulWidget to access `ref`

## Testing

To test quest completion:

1. Generate daily seeds (they'll have various activity IDs)
2. Complete one of the activities (e.g., finish a lesson with ID matching a seed's activityId)
3. You should see the congratulation dialog
4. Return to TodosScreen and verify the quest is now marked as completed
