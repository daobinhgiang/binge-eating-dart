# Level-Up Navigation and Tree Animation Feature

## Summary

Implemented automatic navigation to home screen with smooth animations and visual tree growth when users level up.

## Changes Made

### 1. TreeGrowthWidget Enhancement (`lib/widgets/tree_growth_widget.dart`)

**New Features:**
- Added listener for `treeAnimationProvider` to detect when to trigger growth animations
- Implemented `_startGrowthAnimation()` method that:
  - Shows old tree stage initially
  - Plays dramatic growth animation (scale + cross-fade)
  - Transitions to new tree stage at animation midpoint
  - Duration: 2500ms for full visual impact
- Added `_buildTreeImageWithCrossFade()` for smooth tree image transitions
- Tracks animation state with `_isAnimating` and `_displayLevel` flags
- Uses growth animation when explicitly triggered, falls back to simple scale animation for passive updates

**Animation Specs:**
- **Growth Scale Animation**: 
  - Phase 1 (30%): Scale 1.0 → 0.85 (shrink in)
  - Phase 2 (50%): Scale 0.85 → 1.25 (burst out)
  - Phase 3 (20%): Scale 1.25 → 1.0 (settle)
- **Cross-Fade Animation**: Fades new tree in at midpoint (interval 0.3-0.7)

### 2. LevelUpDialog Update (`lib/widgets/level_up_dialog.dart`)

**New Features:**
- Added `shouldNavigateToHome` parameter (default: false)
- Modified "Continue" button to return level info in a map:
  ```dart
  {
    'shouldNavigate': true/false,
    'oldLevel': int,
    'newLevel': int,
  }
  ```
- Allows callers to know when to trigger navigation and animation

### 3. AssessmentWidget Enhancement (`lib/widgets/assessment_widget.dart`)

**New Features:**
- Added import for `tree_animation_provider`
- Updated `LevelUpDialog` call to set `shouldNavigateToHome: true`
- Enhanced dialog result handling to check for level data
- Updated `_navigateToHomeWithAnimation()` to:
  - Navigate to home with slow, smooth 1200ms fade transition
  - Wait for navigation to complete (1400ms)
  - Trigger tree growth animation via provider

**Navigation Flow:**
```
Quiz Complete → Level Up Detected
    ↓
Show LevelUpDialog (celebration)
    ↓
User taps "Continue"
    ↓
Smooth fade navigation to home (1200ms)
    ↓
Wait 1400ms for navigation to settle
    ↓
Trigger tree growth animation (2500ms)
    ↓
User sees their tree visually evolve!
```

## User Experience Flow

1. **User completes quiz** that causes level-up
2. **Level-up dialog appears** with trophy, confetti, and celebration
3. **User taps "Continue"**
4. **Screen smoothly fades** back to home (slower than normal navigation)
5. **Tree begins dramatic growth animation**:
   - Shrinks slightly (anticipation)
   - Bursts into new, larger form
   - Settles to final size
   - Image cross-fades to new tree stage
6. **User clearly sees** their progress reflected in the tree

## Technical Details

### Navigation Transition
- Uses `PageRouteBuilder` with custom `transitionsBuilder`
- Duration: 1200ms (vs typical 300ms)
- Curve: `Curves.easeInOutCubic` for extra smoothness
- Removes all previous routes to reset navigation stack

### Animation Coordination
- Navigation completes before tree animation starts (1400ms delay)
- Prevents jarring simultaneous animations
- Ensures user has arrived at home before visual spectacle begins

### State Management
- Uses Riverpod providers for state coordination
- `treeAnimationProvider` triggers animations across widget tree
- `userExpProvider` provides level data
- Clean separation between navigation logic and animation logic

## Files Modified

1. ✅ `lib/widgets/tree_growth_widget.dart` - Added animation listening and growth sequences
2. ✅ `lib/widgets/level_up_dialog.dart` - Added navigation flag and level data return
3. ✅ `lib/widgets/assessment_widget.dart` - Integrated navigation + animation triggering

## Testing Checklist

- [ ] Complete a quiz that causes level-up
- [ ] Verify level-up dialog appears
- [ ] Tap "Continue" and verify smooth navigation to home
- [ ] Verify tree growth animation plays after arriving at home
- [ ] Verify animation is smooth and dramatic (2.5 seconds)
- [ ] Verify tree image changes from old level to new level during animation
- [ ] Test with multiple level-ups (level 1→2, 2→3, etc.)
- [ ] Verify no animation issues if user is already on home screen

## Notes

- Animation only triggers when level-up happens via quiz completion
- Tree still updates silently for direct level changes (e.g., manual database edits)
- Animation is non-blocking; user can interact with app if needed
- All animations use proper disposal to prevent memory leaks

