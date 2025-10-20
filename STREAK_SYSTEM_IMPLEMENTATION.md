# Streak System Implementation

## Overview

A complete daily streak system has been implemented that tracks user consistency in completing all daily tasks. Users build streaks by completing all Seeds (daily) tasks each day, and streaks reset to 0 if tasks aren't completed on a new day.

## Key Features

### 1. Automatic Streak Tracking
- **Increments by 1** when user completes all daily Seeds tasks in a day
- **Resets to 0** when a new day arrives and yesterday's tasks weren't completed
- **Tracks last update** with `lastStreakDate` to prevent duplicate increments

### 2. Beautiful UI Components
- **Streak Display Widget**: Sun icon (☀️) with streak number centered inside
- **Location**: Top-right corner of home screen, next to level badge
- **Animation Popup**: Smooth transition when streak changes
  - Old number slides down and fades out
  - New number slides from top and settles in place
  - Different colors for increments (amber/gold) vs resets (red/orange)

### 3. Compact EXP Bar
- Made more compact (reduced from 20px to 4px height)
- Reduced spacing and padding
- **Smooth animated transitions** with `TweenAnimationBuilder`
- Color gradient animation: amber → green as progress increases
- Animated text changes with `AnimatedDefaultTextStyle`

### 4. Automatic Reset Logic
Triggered during daily task regeneration:
```
1. App detects new day in TaskRegenerationService.checkAndRegenerateTasks()
2. Calls StreakService.checkAndResetStreakIfNeeded()
3. Checks if yesterday had any Seeds tasks
4. If yes, checks if ALL were completed
5. If not all completed → resets streak to 0 with animation
6. If all completed or no tasks existed → maintains streak
```

## Implementation Details

### Files Created

#### 1. `lib/core/services/streak_service.dart`
Singleton service managing all streak operations:

**Methods:**
- `getCurrentStreak(userId)` - Fetch current streak value
- `incrementStreak(userId)` - Increment by 1 and update lastStreakDate
- `resetStreak(userId)` - Set to 0 and update lastStreakDate
- `getAllDailyTasksCompleted(userId)` - Check if all today's Seeds tasks are done
- `checkAndResetStreakIfNeeded(userId)` - Check yesterday's completion and reset if needed

**Key Logic:**
- Uses Firestore queries to check task completion
- Filters by task type `'seed'` and due date
- Only operates on Timestamps (daily granularity)
- Comprehensive logging with emojis for debugging

#### 2. `lib/widgets/streak_display.dart`
Displays user's current streak:
- Circle container with sun icon background
- Streak number overlaid on center
- Amber color scheme with subtle shadow
- Tap-able for future enhancements

#### 3. `lib/widgets/streak_animation_popup.dart`
Modal dialog with beautiful animations:
- Shows old→new streak transitions
- Different styling for resets vs increments
- 800ms animation duration
- Auto-closes after animation completes
- Helper function: `showStreakAnimation(context, oldStreak, newStreak, isReset)`

### Files Modified

#### 1. `lib/models/user_model.dart`
Added two fields:
```dart
final int streak;              // Current streak count (default: 0)
final DateTime? lastStreakDate; // Date of last streak update
```

Updated `fromFirestore()`, `toFirestore()`, and `copyWith()` methods.

#### 2. `lib/core/services/task_regeneration_service.dart`
Added streak check at start of `checkAndRegenerateTasks()`:
```dart
// Check streak if it's a new day
final streakService = StreakService();
final streakWasReset = await streakService.checkAndResetStreakIfNeeded(userId);
```

#### 3. `lib/providers/todo_provider.dart`
Enhanced `markCompleted()` method:
1. After marking task complete, checks if ALL daily tasks are done
2. Gets current streak and lastStreakDate
3. Only increments if today hasn't been updated yet
4. Logs detailed progress with emojis

```dart
final allDailyTasksCompleted = await streakService.getAllDailyTasksCompleted(_userId);
if (allDailyTasksCompleted) {
  // Get current streak to track for animation
  final currentStreak = await streakService.getCurrentStreak(_userId);
  // Check if streak was already updated today
  // If not, increment: await streakService.incrementStreak(_userId);
}
```

#### 4. `lib/providers/exp_provider.dart`
Added streak-related providers:
```dart
final streakServiceProvider = Provider<StreakService>((ref) => StreakService());
final userStreakProvider = Provider<int?>((ref) {
  final userAsync = ref.watch(authNotifierProvider);
  return userAsync.when(
    data: (user) => user?.streak,
    loading: () => null,
    error: (_, __) => null,
  );
});
```

#### 5. `lib/screens/home_screen.dart`
**Header Integration:**
- Added streak display widget next to level badge
- Integrated `ref.listen(userStreakProvider)` to detect changes
- Automatically triggers `showStreakAnimation()` when streak changes

**EXP Bar Improvements:**
- Reduced from 20px to 4px height
- Reduced font sizes (20→16, 12→11)
- Reduced spacing (16→12, 6→4, 4→2)
- Added `AnimatedDefaultTextStyle` for EXP text
- Added `TweenAnimationBuilder` for progress bar with color lerp
- Changed max level text from "Max Level!" to "Max Level! 🎉"

## Data Flow

### Streak Increment Flow
```
User marks last daily task complete
         ↓
TodoProvider.markCompleted() triggered
         ↓
Check if ALL daily Seeds tasks completed
         ↓
YES: Get currentStreak and lastStreakDate
         ↓
If lastStreakDate != today:
  • Increment streak in Firebase
  • Update lastStreakDate to today
  • Refresh auth provider (triggers userStreakProvider update)
         ↓
HomeScreen detects streak change via ref.listen()
         ↓
Shows StreakAnimationPopup with old→new transition
```

### Streak Reset Flow
```
App starts or user opens app
         ↓
TaskRegenerationService.checkAndRegenerateTasks() called
         ↓
StreakService.checkAndResetStreakIfNeeded() called
         ↓
Check if today == lastStreakDate (already checked today)
         ↓
NO: Get yesterday's Seeds tasks
         ↓
If yesterday had tasks:
  • Check if ALL were completed
  • If NOT all completed: Reset streak to 0
         ↓
Refresh auth provider (triggers userStreakProvider update)
         ↓
HomeScreen detects streak change via ref.listen()
         ↓
Shows StreakAnimationPopup with reset styling
```

## Logging & Debugging

All operations include detailed emoji-based logging:

**Task Completion Check:**
```
🔍 Checking if all daily tasks are completed for today...
   📋 Found 3 Seeds tasks for today
      - Task 1: ✅
      - Task 2: ❌
      - Task 3: ✅
   Result: Not all completed ❌
```

**Streak Increment:**
```
🔥 Incrementing streak for user: abc123
   Current streak: 5
   New streak: 6
   Update date: 2025-10-20
✅ Streak incremented successfully
```

**Streak Reset Check:**
```
🔍 STREAK CHECK: Checking if yesterday's tasks were completed...
   Last streak date: 2025-10-19
   Today date: 2025-10-20
   Checking yesterday's tasks: 2025-10-19
   📋 Found 3 Seeds tasks from yesterday
   ❌ Not all yesterday's tasks were completed
   🔄 Resetting streak to 0
✅ Streak reset to 0 successfully
```

## Integration Points

### 1. Database Schema
```
users/{userId}/
├── streak: integer (default: 0)
└── lastStreakDate: timestamp (nullable)
```

### 2. Task Types
- `'seed'` = Daily repeating tasks (checked for streaks)
- `'growth'` = Weekly tasks (ignored for streaks)

### 3. Firestore Queries
Uses compound queries filtering by:
- Task type: `'seed'`
- Due date range: today (or yesterday during reset check)
- Completion status: `isCompleted` field

## Testing Considerations

1. **Streak Increment**: Complete all daily tasks and verify popup shows
2. **Streak Maintenance**: Complete all tasks day 1, verify streak doesn't reset day 2
3. **Streak Reset**: Don't complete all tasks day 1, open app day 2 - should reset with animation
4. **Consistency**: Multiple streak increments should show animation each time
5. **Edge Cases**:
   - No daily tasks exist (should not increment/reset)
   - First time ever (should increment from 0→1)
   - Partial completion (should not increment, will reset on new day)

## Future Enhancements

1. **Streak History**: Show streak achievements/milestones (7-day, 30-day badges)
2. **Streak Statistics**: Weekly/monthly streak data on profile
3. **Notifications**: Alert users before midnight about incomplete tasks
4. **Customization**: Celebrate streaks with sound/haptic feedback
5. **Streaks Per Category**: Separate streaks for different task types
6. **Recovery Mode**: Option to "restore" streak if accidentally missed one day

## Notes

- All streak operations are idempotent (safe to run multiple times)
- `lastStreakDate` prevents duplicate increments within same day
- Reset check only runs once per day (checked on app start)
- Animations use `Curves.easeInCubic` for down motion, `Curves.easeOutCubic` for up motion
- Color scheme: Amber (#FFC107) for positive, Red (#F44336) for negative

