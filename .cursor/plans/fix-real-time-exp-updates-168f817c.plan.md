<!-- 168f817c-974b-4f27-b956-af5d9251c52a 41ec8dfb-4873-4fe0-9dcc-0bf957847f44 -->
# Fix Real-time EXP UI Updates

## Problem 1: Profile "My Progress" Section Not Updating

The profile page uses `userExpProvider` which depends on `currentUserDataProvider` → `authNotifierProvider` (StateNotifier). The StateNotifier doesn't automatically listen to the Firestore stream, so EXP changes aren't reflected.

**Solution**: Update `userExpProvider` in `lib/providers/exp_provider.dart` to use `currentUserProvider` (which uses the stream) instead of `currentUserDataProvider`.

**Change in `exp_provider.dart` (lines 12-18)**:

Current:

```dart
final userExpProvider = Provider<({int exp, int level})?>((ref) {
  final user = ref.watch(currentUserDataProvider);
  if (user == null) return null;
  
  return (exp: user.exp, level: user.level);
});
```

New:

```dart
final userExpProvider = Provider<({int exp, int level})?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return null;
      return (exp: user.exp, level: user.level);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
```

## Problem 2: Home Page Header Needs Level + EXP Display

The current home page header shows:

- Logo (left)
- Greeting + Date (middle)
- Level badge only (right)

**Solution**: Replace the greeting + date section with a compact level and EXP display.

**Changes in `lib/screens/home_screen.dart`**:

1. **Remove greeting/date section** (lines 400-421)
2. **Replace with level + EXP widget** showing:

   - Level badge with number
   - EXP progress bar below
   - Current EXP / Next level EXP

This will make the header more focused on progress tracking rather than just greeting.

## Impact

After these fixes:

- Profile "My Progress" section updates immediately when EXP changes
- Home page prominently displays user's level and EXP progress
- All UI components react to Firestore changes in real-time