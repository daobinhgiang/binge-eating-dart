<!-- d1bdc1fd-8250-42e1-aed1-d3c9c1279c43 1856e372-c0a8-4f46-8f37-e7c471e9813c -->
# Streak System Implementation Plan

## High-Level Approach

The streak system will be integrated into the existing task regeneration and completion workflows:

- **Streak Storage**: Add `streak` (int) and `lastStreakDate` (DateTime) fields to `UserModel`
- **Streak Logic**: Create a `StreakService` to manage streak operations
- **Regeneration Integration**: Modify `TaskRegenerationService.checkAndRegenerateTasks()` to check if yesterday's Seeds tasks were completed and reset streak if not
- **Completion Integration**: When a user completes a task, check if ALL Seeds tasks for today are done, then increment streak and show animation
- **UI Components**: Create `StreakDisplay` widget and `StreakAnimationPopup` widget
- **Home Screen**: Add streak display to top-right, redesign exp bar to be more compact and animated

## Implementation Phases

### Phase 1: Data Model & Database (File: `lib/models/user_model.dart`)

- Add `streak` field (default: 0)
- Add `lastStreakDate` field (DateTime, nullable)
- Update `fromFirestore()` and `toFirestore()` methods
- Update `copyWith()` method

### Phase 2: Streak Service (New file: `lib/core/services/streak_service.dart`)

Create a singleton service with methods:

- `getCurrentStreak(userId)` - Get current streak value
- `incrementStreak(userId)` - Increment streak by 1
- `resetStreak(userId)` - Reset streak to 0
- `getAllDailyTasksCompleted(userId)` - Check if all Seeds tasks for today are done
- `checkAndResetStreakIfNeeded(userId)` - Called during task regeneration to reset streak if yesterday's tasks weren't completed

### Phase 3: Task Regeneration Integration (File: `lib/core/services/task_regeneration_service.dart`)

Modify `checkAndRegenerateTasks()` method:

- Before regenerating today's Seeds, check if it's a new day
- If new day AND yesterday had Seeds tasks, call `StreakService.checkAndResetStreakIfNeeded()`
- This will reset streak to 0 if yesterday's Seeds tasks weren't all completed

### Phase 4: Task Completion Integration (File: `lib/providers/todo_provider.dart`)

Modify `markCompleted()` method:

- After marking task complete, call `StreakService.getAllDailyTasksCompleted(userId)`
- If all Seeds tasks are complete for today AND today hasn't been registered yet, increment streak
- Trigger the streak animation popup if streak increased or reset occurred

### Phase 5: UI Components

**New file: `lib/widgets/streak_display.dart`**

- Create `StreakDisplay` widget showing:
- Sun icon (custom or from `flutter_svg` + icon)
- Streak number centered on the sun
- Compact design suitable for top-right corner

**New file: `lib/widgets/streak_animation_popup.dart`**

- Show overlay popup with animation:
- Old streak number slides down and fades out
- New streak number slides from top and settles in middle
- Duration: ~800ms
- Support for both increases and resets

### Phase 6: Providers (File: `lib/providers/exp_provider.dart` or new file `lib/providers/streak_provider.dart`)

- Create `streakServiceProvider` 
- Create `userStreakProvider` to watch current user's streak
- Create `streakAnimationTriggerProvider` (StateNotifier) to trigger animations

### Phase 7: Home Screen Integration (File: `lib/screens/home_screen.dart`)

- Modify header layout to place streak display at top-right
- Make exp bar more compact (reduce height, remove some padding)
- Add streak animation popup trigger
- Position streak next to level badge or in separate top-right corner

## Key Implementation Details

**Streak Check Logic**:

- Only check Seeds (daily) tasks, ignore Growth (weekly) tasks
- Check happens automatically when app detects new day during task regeneration
- Streak date tracking: Store `lastStreakDate` to know which day the streak was last updated/checked

**Popup Animation Behavior**:

- Show on both increments AND resets
- Position: Center of screen or near top
- Include visual feedback (haptic, sound optional)

**Integration Points**:

1. `TaskRegenerationService.checkAndRegenerateTasks()` - Streak reset check
2. `TodoProvider.markCompleted()` - Streak increment check
3. `AuthProvider` - Provide user model with streak data
4. `HomeScreen` - Display and animate streak

## Files to Create/Modify

**Create**:

- `/lib/core/services/streak_service.dart`
- `/lib/widgets/streak_display.dart`
- `/lib/widgets/streak_animation_popup.dart`

**Modify**:

- `/lib/models/user_model.dart` - Add streak fields
- `/lib/core/services/task_regeneration_service.dart` - Add streak reset check
- `/lib/providers/todo_provider.dart` - Add streak increment on task completion
- `/lib/screens/home_screen.dart` - Add streak display and animation UI
- `/lib/providers/exp_provider.dart` - Add streak provider (or create new provider file)

### To-dos

- [ ] Add streak and lastStreakDate fields to UserModel with proper serialization
- [ ] Create StreakService with methods for increment, reset, completion check, and daily reset logic
- [ ] Integrate streak reset check into TaskRegenerationService.checkAndRegenerateTasks()
- [ ] Integrate streak increment check into TodoProvider.markCompleted()
- [ ] Create StreakDisplay widget with sun icon and centered streak number
- [ ] Create StreakAnimationPopup widget with sliding animation for old/new streak numbers
- [ ] Create streak provider in exp_provider.dart to expose streak data and animation trigger
- [ ] Update HomeScreen to display streak at top-right and integrate streak animation
- [ ] Make exp bar more compact and add subtle animations
- [ ] Add printing throughout the implementation so I can see what is going on