# Stage 3 Assessment Completion Fix

## Problem
The last two lessons (assessments) in **Stage 3, Chapter 0** were not turning purple after completion. The buttons remained grey even though users completed the assessments:
- **Lesson 0.3**: EDE-Q Assessment (`lesson_s3_0_3`)
- **Lesson 0.4**: CIA Assessment (`lesson_s3_0_4`)

## Root Cause
**Wrong lesson ID in assessment data**: The assessment screens were reusing the same assessment objects from Stage 1, which had hardcoded `lessonId` values pointing to Stage 1 lessons.

### What Was Happening:

#### Stage 1 Assessments (Working):
```
lesson_2_1 (EDE-Q) → Assessment with lessonId: 'lesson_2_1' ✅
lesson_2_2 (CIA)   → Assessment with lessonId: 'lesson_2_2' ✅
```

#### Stage 3 Assessments (Broken):
```
lesson_s3_0_3 (EDE-Q) → Assessment with lessonId: 'lesson_2_1' ❌
lesson_s3_0_4 (CIA)   → Assessment with lessonId: 'lesson_2_2' ❌
```

### The Flow:
1. **User completes Stage 3 EDE-Q assessment** (lesson_s3_0_3)
2. **Assessment screen loads** `getEDEQAssessment()`
3. **Assessment has** `lessonId: 'lesson_2_1'` (from Stage 1)
4. **Completion is saved** with ID `lesson_2_1` (wrong!)
5. **Stage 1 lesson 2.1 button turns green** (if visible)
6. **Stage 3 lesson 0.3 button stays grey** ❌

## Solution Implemented

### Strategy
Use the `copyWith()` method to override the `lessonId` when creating assessments for Stage 3, ensuring the correct lesson ID is used for completion tracking.

### Changes Made

#### 1. Fixed EDE-Q Assessment Screen
**File: `/lib/screens/assessments/assessment_s3_0_3_screen.dart`**

**Before:**
```dart
@override
void initState() {
  super.initState();
  _assessment = AssessmentData.getEDEQAssessment(); // ❌ Uses lesson_2_1
}
```

**After:**
```dart
@override
void initState() {
  super.initState();
  // Get EDE-Q assessment and override lessonId for Stage 3
  _assessment = AssessmentData.getEDEQAssessment().copyWith(
    lessonId: 'lesson_s3_0_3', // ✅ Correct Stage 3 lesson ID
  );
}
```

#### 2. Fixed CIA Assessment Screen
**File: `/lib/screens/assessments/assessment_s3_0_4_screen.dart`**

**Before:**
```dart
@override
void initState() {
  super.initState();
  _assessment = AssessmentData.getCIAAssessment(); // ❌ Uses lesson_2_2
}
```

**After:**
```dart
@override
void initState() {
  super.initState();
  // Get CIA assessment and override lessonId for Stage 3
  _assessment = AssessmentData.getCIAAssessment().copyWith(
    lessonId: 'lesson_s3_0_4', // ✅ Correct Stage 3 lesson ID
  );
}
```

## How It Works Now

### Correct Flow:
1. **User completes Stage 3 EDE-Q assessment** (lesson_s3_0_3)
2. **Assessment screen loads** `getEDEQAssessment().copyWith(lessonId: 'lesson_s3_0_3')`
3. **Assessment has** `lessonId: 'lesson_s3_0_3'` ✅
4. **Completion is saved** with ID `lesson_s3_0_3` ✅
5. **Stage 3 lesson 0.3 button turns purple** ✅

### Assessment Reuse Pattern:
The same assessment questions are used across stages, but with different lesson IDs:

**EDE-Q Assessment:**
- Stage 1: `lesson_2_1` (uses base assessment)
- Stage 3: `lesson_s3_0_3` (uses `copyWith` to override lessonId)

**CIA Assessment:**
- Stage 1: `lesson_2_2` (uses base assessment)
- Stage 3: `lesson_s3_0_4` (uses `copyWith` to override lessonId)

## Why This Approach

### Advantages:
1. **DRY Principle**: Reuses the same assessment questions (no duplication)
2. **Maintainable**: Changes to assessment questions apply everywhere
3. **Flexible**: Easy to add assessments to new stages
4. **Type-safe**: Uses the existing `copyWith` method

### Alternative Approaches (Not Used):
1. **Create separate methods** (e.g., `getEDEQAssessmentStage3()`) - More code duplication
2. **Modify `getAssessmentByLessonId`** - Would require changing all assessment screens
3. **Pass lessonId as parameter** - Would require changing assessment data methods

## Testing
- ✅ Complete lesson_s3_0_3 (EDE-Q) → Button turns purple
- ✅ Complete lesson_s3_0_4 (CIA) → Button turns purple
- ✅ Stage 1 assessments still work correctly
- ✅ Completion persists across app sessions
- ✅ No linting errors

## Stage 3 Chapter 0 Complete Lesson Order
```
Index 0: lesson_s3_0_1   (0.1) - Making Your Progress Last
Index 1: lesson_s3_0_2   (0.2) - How to Handle Setbacks
Index 2: lesson_s3_0_2_1 (0.2.1) - Practice Addressing Setbacks Exercise
Index 3: lesson_s3_0_3   (0.3) - EDE-Q Assessment ✅ Now works!
Index 4: lesson_s3_0_4   (0.4) - CIA Assessment ✅ Now works!
```

## Impact
- ✅ Stage 3 assessments now track completion correctly
- ✅ Buttons turn purple after completion
- ✅ Stage 1 assessments unaffected
- ✅ Assessment questions remain consistent across stages
- ✅ No code duplication

## Related Fixes
- **ASSESSMENT_COMPLETION_FIX.md**: Fixed Stage 1 assessment completion tracking
- **LESSON_COMPLETION_FIX.md**: Fixed async/await for 50 lessons
- **LESSON_ID_MISMATCH_FIX.md**: Fixed lesson 1.3 loading wrong data
- **STAGE2_CHAPTER7_LESSON_FIX.md**: Fixed missing lesson 7.2.1

## Prevention
To prevent similar issues when adding assessments to new stages:
1. **Always override lessonId** when reusing assessments in different stages
2. **Use `copyWith(lessonId: 'correct_id')`** pattern
3. **Test completion tracking** for each assessment in each stage
4. **Document assessment reuse** in code comments
