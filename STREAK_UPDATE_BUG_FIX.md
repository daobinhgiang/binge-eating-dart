# Streak Update Bug Fix ✅

## Problem
When users completed all daily Seeds (quests), the streak was not being incremented. The congratulation dialog appeared with EXP rewards, but streak remained at 0.

## Root Cause
The `StreakService.getAllDailyTasksCompleted()` method was querying the **wrong field** in Firestore:

```dart
// ❌ WRONG - This was checking the activity type
.where('type', isEqualTo: 'seed')
```

But in the data model:
- `type`: Determines the **activity type** (lesson, tool, journal)
- `tier`: Determines the **task tier** (seeds, growthTasks, masteryQuests)

Daily Seeds are identified by **`tier == 'seeds'`**, not `type == 'seed'`.

### The Query Was Returning 0 Results
Since the query found no matching documents, `getAllDailyTasksCompleted()` returned `false`, preventing streak increment.

## Solution
Changed two queries in `StreakService` to use the correct field:

### Fix 1: `getAllDailyTasksCompleted()` (Line 87)
```dart
// ✅ CORRECT - Now checks the task tier
.where('tier', isEqualTo: 'seeds')
```

### Fix 2: `checkAndResetStreakIfNeeded()` (Line 159)
```dart
// ✅ CORRECT - Now checks the task tier
.where('tier', isEqualTo: 'seeds')
```

## Impact

### Before Fix
- User completes last daily seed
- Service checks for tasks with `type == 'seed'` ❌
- Query returns 0 results
- `getAllDailyTasksCompleted()` returns `false`
- Streak NOT incremented ❌

### After Fix
- User completes last daily seed
- Service checks for tasks with `tier == 'seeds'` ✅
- Query finds all 3 seeds for today
- `getAllDailyTasksCompleted()` returns `true` (all are completed)
- Streak incremented ✅
- Congratulation dialog shows new streak count 🔥

## Testing

To verify the fix works:

1. **Generate daily seeds**
   - Open TodosScreen
   - Seeds should generate automatically

2. **Complete all 3 seeds**
   - Go through each seed's activity
   - Complete one by one

3. **When completing the last seed:**
   - Congratulation dialog appears
   - Should show streak count (e.g., "1 day streak!" 🔥)
   - User document updated with new streak value

4. **Verify in Firestore:**
   ```
   users/{userId}
   ├─ streak: 1 (or higher if continuing streak)
   └─ lastStreakDate: today's date
   ```

## Files Modified
- `lib/core/services/streak_service.dart` (2 lines changed)

## Deployment Notes
- No database migrations needed
- No user data loss
- Existing streaks unaffected
- Fix takes effect immediately on next seed completion

## Future Prevention
- Add integration tests for streak increment
- Add Firestore query validation tests
- Consider renaming to avoid field confusion (e.g., `taskCategory` vs `taskType`)
