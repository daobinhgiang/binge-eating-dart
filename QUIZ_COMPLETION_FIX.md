# Quiz Completion Fix

## Problem
End-of-chapter quizzes were not turning green after completion on the lessons tab, unlike regular lessons which turn green after being completed.

## Root Cause
- **Regular lessons** call `LessonService.markLessonCompleted(lessonId)` when finished, which saves completion to `user_progress/{userId}/completed_lessons/{lessonId}` in Firestore
- **End-of-chapter quizzes** only submitted to `quiz_submissions` collection for EXP validation but never logged completion to the same `user_progress/{userId}/completed_lessons` collection
- **The lessons screen** determines button color by checking if the lesson ID exists in `user_progress/{userId}/completed_lessons` - since quizzes never wrote there, they stayed grey

## Solution Implemented

### Changes Made to `/lib/widgets/assessment_widget.dart`:

1. **Added import** for `LessonService`:
   ```dart
   import '../core/services/lesson_service.dart';
   ```

2. **Added LessonService instance** to the widget state:
   ```dart
   final LessonService _lessonService = LessonService();
   ```

3. **Added lesson completion logging** after successful quiz validation (line 646-647):
   ```dart
   // Mark quiz as completed in user_progress (same as regular lessons)
   await _lessonService.markLessonCompleted(widget.assessment.lessonId);
   ```

## How It Works Now

1. User completes a quiz
2. Quiz is submitted to `quiz_submissions` collection
3. Firebase Function validates quiz and awards EXP
4. On successful validation, the frontend now also calls `markLessonCompleted()`
5. This writes to `user_progress/{userId}/completed_lessons/{quizId}` (same location as regular lessons)
6. The lessons screen reads from this collection and turns the button green

## Quiz Lesson IDs
All quiz lessons use consistent IDs that match between stage data and assessment data:
- `quiz_1_chapter_1` - Chapter 1 Quiz (Stage 1)
- `quiz_3_chapter_3` - Chapter 3 Quiz (Stage 1)
- `quiz_0_chapter_0` - Chapter 0 Quiz (Stage 2)
- `quiz_1_stage_2` - Chapter 1 Quiz (Stage 2)
- `quiz_2_stage_2` - Chapter 2 Quiz (Stage 2)
- `quiz_3_stage_2` - Chapter 3 Quiz (Stage 2)
- `quiz_4_stage_2` - Chapter 4 Quiz (Stage 2)
- `quiz_5_stage_2` - Chapter 5 Quiz (Stage 2)
- `quiz_6_stage_2` - Chapter 6 Quiz (Stage 2)
- `quiz_7_stage_2` - Chapter 7 Quiz (Stage 2)

## Testing
After completing any end-of-chapter quiz:
1. Quiz validation should complete successfully
2. EXP should be awarded (as before)
3. **NEW**: The quiz lesson button on the lessons tab should turn green
4. The completion should persist across app restarts (stored in Firestore)

## Files Modified
- `/lib/widgets/assessment_widget.dart` - Added quiz completion logging

