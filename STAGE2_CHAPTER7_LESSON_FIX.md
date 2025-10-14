# Stage 2 Chapter 7 Lesson Order Fix

## Problem
When completing **Lesson 7.4** ("Breaking the Comparison Trap"), the button for **Lesson 7.3** ("A New Way of Seeing Yourself") was turning blue instead. This indicated that lesson 7.4 was actually marking lesson 7.3 as complete.

## Root Cause
**Missing lesson in data structure**: The lesson `lesson_s2_7_2_1` (Addressing Overconcern Exercise) existed as a screen file but was **completely missing from the Stage 2 data structure**.

### What Was Happening:

#### Expected Lesson Order:
```
Index 0: lesson_s2_7_1   (7.1)
Index 1: lesson_s2_7_1_1 (7.1.1 - pre-exercise)
Index 2: lesson_s2_7_2   (7.2)
Index 3: lesson_s2_7_2_1 (7.2.1 - pre-exercise) ← MISSING!
Index 4: lesson_s2_7_3   (7.3)
Index 5: lesson_s2_7_4   (7.4)
Index 6: lesson_s2_7_5   (7.5)
Index 7: lesson_s2_7_6   (7.6)
Index 8: lesson_s2_7_7   (7.7)
Index 9: lesson_s2_7_8   (7.8)
```

#### Actual Lesson Order (Before Fix):
```
Index 0: lesson_s2_7_1   (7.1)
Index 1: lesson_s2_7_1_1 (7.1.1 - pre-exercise)
Index 2: lesson_s2_7_2   (7.2)
Index 3: lesson_s2_7_3   (7.3) ← Off by one!
Index 4: lesson_s2_7_4   (7.4) ← Off by one!
Index 5: lesson_s2_7_5   (7.5) ← Off by one!
Index 6: lesson_s2_7_6   (7.6) ← Off by one!
Index 7: lesson_s2_7_7   (7.7) ← Off by one!
Index 8: lesson_s2_7_8   (7.8) ← Off by one!
```

### The Impact:
1. **Lesson 7.2.1 screen file existed** (`lesson_s2_7_2_1.dart`)
2. **Lesson 7.2.1 was imported** in `lessons_screen.dart`
3. **Lesson 7.2.1 data was MISSING** from `stage_2_data.dart`
4. **All lessons from 7.3 onward** were shifted by one index
5. **When completing lesson 7.4**, it loaded lesson 7.3's data (index 3 instead of 4)
6. **Completion was saved** with lesson 7.3's ID
7. **Lesson 7.3 button turned blue** instead of lesson 7.4

## Solution Implemented

### 1. Added Missing Lesson to Data Structure

**File: `/lib/data/stage_2_data.dart`**

Added `lesson_s2_7_2_1` between lesson 7.2 and lesson 7.3:

```dart
// Lesson 7.2.1: Addressing Overconcern Exercise
Lesson(
  id: 'lesson_s2_7_2_1',
  title: '7.2.1: Addressing Overconcern Exercise',
  description: 'Practice your skills for addressing overconcern about shape and weight with structured exercises',
  chapterNumber: 7,
  lessonNumber: 21, // Using 21 to represent 2.1
  slides: [
    // 4 slides with exercise instructions
  ],
  createdAt: now,
  updatedAt: now,
),
```

### 2. Fixed Variable Name Typo

**File: `/lib/screens/lessons/lesson_s2_7_2_1.dart`**

Fixed typo where `lesson721` was used instead of `lesson`:

**Before:**
```dart
setState(() {
  _lesson = lesson721; // ❌ Typo!
  _isLoading = false;
});
```

**After:**
```dart
setState(() {
  _lesson = lesson; // ✅ Correct!
  _isLoading = false;
});
```

## Lesson 7.2.1 Content

The added lesson is a **pre-exercise lesson** that introduces the Addressing Overconcern Exercise:

- **Purpose**: Guide users to the Addressing Overconcern tool in the Tools section
- **Type**: Pre-exercise lesson (similar to 7.1.1)
- **Slides**: 4 informational slides explaining the exercise
- **Action**: Navigates to the Addressing Overconcern tool when completed

## How It Works Now

### Correct Lesson Order:
```
Index 0: lesson_s2_7_1   (7.1) - How Important is Shape and Weight to You?
Index 1: lesson_s2_7_1_1 (7.1.1) - Addressing Overconcern Exercise (first intro)
Index 2: lesson_s2_7_2   (7.2) - Rebalancing Your Pie Chart
Index 3: lesson_s2_7_2_1 (7.2.1) - Addressing Overconcern Exercise (second intro) ✅
Index 4: lesson_s2_7_3   (7.3) - A New Way of Seeing Yourself ✅
Index 5: lesson_s2_7_4   (7.4) - Breaking the Comparison Trap ✅
Index 6: lesson_s2_7_5   (7.5) - Reconnecting With Your Body
Index 7: lesson_s2_7_6   (7.6) - Understanding the Feeling of "Feeling Fat"
Index 8: lesson_s2_7_7   (7.7) - Checking In on Your Body Image
Index 9: lesson_s2_7_8   (7.8) - When to Move On from the Body Image Module
```

### Completion Flow:
1. **User completes lesson 7.4**
2. **Lesson 7.4 screen loads** `lesson_s2_7_4` data (index 5)
3. **Completion is saved** with ID `lesson_s2_7_4`
4. **Lesson 7.4 button turns blue** ✅
5. **All other lessons** complete correctly

## Testing
- ✅ Lesson 7.2.1 now appears in the education tab
- ✅ Lesson 7.2.1 loads correct content
- ✅ Lesson 7.3 completes correctly (marks 7.3, not 7.2)
- ✅ Lesson 7.4 completes correctly (marks 7.4, not 7.3)
- ✅ All subsequent lessons (7.5-7.8) complete correctly
- ✅ No linting errors introduced

## Why This Happened

This is a **data-screen mismatch** issue:
1. **Screen file was created** for lesson 7.2.1
2. **Screen was imported** in lessons_screen.dart
3. **Data was never added** to stage_2_data.dart
4. **Testing may have missed it** because:
   - Lesson 7.2.1 screen existed (no compile error)
   - Lesson 7.3 would complete when testing 7.4 (appeared to work)
   - The bug only became obvious when tracking which specific lesson turned blue

## Prevention

To prevent similar issues in the future:
1. **Always add lesson data first** before creating screen files
2. **Verify lesson order** by checking the data structure
3. **Test completion tracking** by verifying the correct lesson ID turns blue
4. **Use ID-based loading** instead of index-based (already implemented)
5. **Document pre-exercise lessons** clearly in the data structure

## Related Fixes
- **LESSON_COMPLETION_FIX.md**: Fixed async/await for 50 lessons
- **LESSON_ID_MISMATCH_FIX.md**: Fixed lesson 1.3 loading wrong data
- **ASSESSMENT_COMPLETION_FIX.md**: Fixed assessment completion tracking
- **PRE_EXERCISE_LESSON_FIX.md**: Fixed pre-exercise lesson completion

## Impact
- ✅ All Chapter 7 lessons now complete correctly
- ✅ Lesson order matches expected structure
- ✅ No more index-off-by-one errors in Chapter 7
- ✅ Lesson 7.2.1 is now accessible to users
- ✅ Consistent lesson structure across all chapters
