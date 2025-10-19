# Variable Name Typo Fixes

## Problem
Multiple lesson screen files had typos in their `_loadLesson()` methods where the variable name used in `setState()` didn't match the declared variable name, causing compilation errors.

## Error Messages
```
Error: The getter 'lesson27' isn't defined for the type '_LessonS227ScreenState'
Error: The getter 'lesson35' isn't defined for the type '_LessonS235ScreenState'
Error: The getter 'lesson43' isn't defined for the type '_LessonS243ScreenState'
Error: The getter 'lesson721' isn't defined for the type '_LessonS2721ScreenState'
```

## Root Cause
When converting lessons to use ID-based loading (instead of index-based), the variable was declared as `lesson` but the `setState()` call was using the old variable name pattern (e.g., `lesson27`, `lesson35`, etc.).

## Files Fixed

### 1. `/lib/screens/lessons/lesson_s2_2_7.dart`
**Before:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 2)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_2_7');

setState(() {
  _lesson = lesson27; // ❌ Wrong variable name
  _isLoading = false;
});
```

**After:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 2)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_2_7');

setState(() {
  _lesson = lesson; // ✅ Correct variable name
  _isLoading = false;
});
```

### 2. `/lib/screens/lessons/lesson_s2_3_5.dart`
**Before:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 3)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_3_5');

setState(() {
  _lesson = lesson35; // ❌ Wrong variable name
  _isLoading = false;
});
```

**After:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 3)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_3_5');

setState(() {
  _lesson = lesson; // ✅ Correct variable name
  _isLoading = false;
});
```

### 3. `/lib/screens/lessons/lesson_s2_4_3.dart`
**Before:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 4)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_4_3');

setState(() {
  _lesson = lesson43; // ❌ Wrong variable name
  _isLoading = false;
});
```

**After:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 4)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_4_3');

setState(() {
  _lesson = lesson; // ✅ Correct variable name
  _isLoading = false;
});
```

### 4. `/lib/screens/lessons/lesson_s2_7_2_1.dart`
**Before:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 7)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_7_2_1');

setState(() {
  _lesson = lesson721; // ❌ Wrong variable name
  _isLoading = false;
});
```

**After:**
```dart
final lesson = stage2.chapters
    .firstWhere((chapter) => chapter.chapterNumber == 7)
    .lessons
    .firstWhere((lesson) => lesson.id == 'lesson_s2_7_2_1');

setState(() {
  _lesson = lesson; // ✅ Correct variable name
  _isLoading = false;
});
```

## Why This Happened
These typos were likely introduced during a refactoring process where:
1. Lessons were converted from index-based loading to ID-based loading
2. The variable name was changed from specific names (e.g., `lesson27`) to generic `lesson`
3. The `setState()` call wasn't updated to use the new variable name
4. These specific files were missed in the refactoring

## Testing
- ✅ All 4 files now compile without errors
- ✅ No linting errors
- ✅ Lessons load correctly
- ✅ Completion tracking works properly

## Impact
- ✅ Application now compiles successfully
- ✅ All affected lessons (2.7, 3.5, 4.3, 7.2.1) work correctly
- ✅ No runtime errors

## Related Fixes
- **LESSON_COMPLETION_FIX.md**: Fixed async/await for lesson completion
- **LESSON_ID_MISMATCH_FIX.md**: Fixed lesson 1.3 loading wrong data
- **STAGE2_CHAPTER7_LESSON_FIX.md**: Fixed missing lesson 7.2.1 in data structure
