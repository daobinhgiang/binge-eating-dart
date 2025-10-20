<!-- d824da7a-3b50-4087-b2bc-a7438e6d0aec 66d240c3-3daf-40e8-8e07-331610720f8a -->
# Move Binge-Free Countdown to Home Screen Carousel

## Overview

Replace the tree placeholder on the Home screen with a carousel that shows:

1. **Default view**: TreeGrowthWidget 
2. **Swipe view**: Binge-free countdown timer (moved from Journal screen)
3. **Indicators**: Dot indicators showing active page

The logic will show the timer by default if already counting down, otherwise show the tree.

## Key Changes

### 1. Create New Carousel Widget

Create `lib/widgets/binge_free_timer_carousel_widget.dart` to encapsulate:

- PageView with 2 pages (tree + timer)
- Dot indicators at bottom
- PageController for page tracking
- Timer state management via ResetTimerService
- Logic: Show timer page if countdown active, else show tree

### 2. Update Home Screen

In `lib/screens/home_screen.dart`:

- Replace `_buildTimerPlaceholder()` widget call (around line 1506) with the new carousel widget
- Remove the placeholder widget method entirely since carousel will replace it

### 3. Extract Timer Logic

Move timer-related code from `lib/screens/journal/journal_screen.dart`:

- `_buildBingeFreeTimer()` method (lines 754-906)
- `_buildIOSTimerLayout()` method (lines 908-990)
- `CircularTimerPainter` class (lines 994-1114)
- `_handleResetButton()` method (lines 665-752)

These will be refactored into the new carousel widget.

### 4. Clean Up Journal Screen

In `lib/screens/journal/journal_screen.dart`:

- Remove `_buildBingeFreeTimer()` method
- Remove `_buildIOSTimerLayout()` method
- Remove `CircularTimerPainter` class
- Remove `_handleResetButton()` method
- Remove timer state variables (`_lastResetTime`, `_updateTimer`) from `_JournalScreenState`
- Remove timer initialization logic from `initState()` and `dispose()`
- Remove the timer widget call from the journal layout (line 106)
- Clean up imports if needed

## Implementation Details

**Carousel Behavior:**

- Default page is determined by: if `lastResetTime` exists, start on timer page; else start on tree page
- Dot indicators show current page (typically 2 dots)
- Update timer every second via existing Timer mechanism
- Maintain same UI/UX as current timer implementation

**Files Modified:**

- `lib/widgets/binge_free_timer_carousel_widget.dart` (NEW)
- `lib/screens/home_screen.dart` (modify `_buildContinueLearningContentOnly()`)
- `lib/screens/journal/journal_screen.dart` (remove timer code + state)

## Considerations

- Timer display logic (days/hours/mins/secs) remains identical
- Reset button functionality preserved
- CircularTimerPainter kept as-is for visual consistency
- All existing Firestore operations via ResetTimerService remain unchanged

### To-dos

- [ ] Create lib/widgets/binge_free_timer_carousel_widget.dart with PageView carousel showing tree + timer with dot indicators and smart default page selection
- [ ] Replace _buildTimerPlaceholder() in home_screen.dart with new carousel widget and remove the placeholder method
- [ ] Move _buildBingeFreeTimer, _buildIOSTimerLayout, CircularTimerPainter, and _handleResetButton from journal_screen.dart into the new carousel widget
- [ ] Remove timer-related code, state variables, and method calls from journal_screen.dart; update imports
- [ ] Test carousel functionality: verify tree displays by default, timer shows when active, swiping works, dot indicators update, reset button functions