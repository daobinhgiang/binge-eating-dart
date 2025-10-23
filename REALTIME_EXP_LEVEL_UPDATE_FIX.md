# Real-Time EXP and Level Update Fix ✅

## Problem
The app was not updating EXP and level immediately when users completed activities. Users had to refresh the app to see their updated EXP and level values.

## Root Cause
When quest completion awarded EXP on the client side, it only updated the `exp` field in the user document but **did not calculate and update the `level` field**. 

### The Inconsistency
1. **Backend Cloud Functions** (for lessons, exercises, journal entries, etc.):
   - ✅ Update both `exp` AND `level`
   - ✅ Use `calculateLevel()` function to determine new level based on total EXP
   
2. **Client-Side Quest Completion** (before fix):
   - ❌ Only updated `exp`
   - ❌ Did not calculate or update `level`

This created a mismatch where the user's `exp` would increase, but their `level` would remain outdated until a backend function ran or the app was restarted.

### Real-Time Updates Were Working
The real-time Firestore listener was actually working correctly:
- `AuthService.currentUserStream` uses `.snapshots()` to listen to user document changes
- `AuthNotifier` subscribes to this stream
- `userExpProvider` derives exp/level from the auth state

The issue was that the client-side code was writing **incomplete** data to Firestore (exp without level).

## Solution

### 1. Added Level Calculation to ExpService (`lib/core/services/exp_service.dart`)

Added a `calculateLevel()` method that matches the backend logic:

```dart
/// Calculate what level a user should be at given their total EXP
/// This matches the backend logic in functions/src/config/exp-config.ts
int calculateLevel(int totalExp) {
  if (totalExp < _levelThresholds[2]!) return 1;  // < 50
  if (totalExp < _levelThresholds[3]!) return 2;  // < 150
  if (totalExp < _levelThresholds[4]!) return 3;  // < 350
  if (totalExp < _levelThresholds[5]!) return 4;  // < 750
  return 5; // Max level
}
```

**Level Thresholds:**
- Level 1: 0-49 EXP
- Level 2: 50-149 EXP
- Level 3: 150-349 EXP
- Level 4: 350-749 EXP
- Level 5: 750+ EXP (max level)

### 2. Updated Quest Completion Service (`lib/core/services/quest_completion_service.dart`)

Modified `_awardQuestEXP()` to calculate and update both exp AND level:

**Before:**
```dart
Future<int> _awardQuestEXP(String userId, TodoItem quest) async {
  final currentExp = (userDoc.get('exp') ?? 0) as int;
  final newExp = currentExp + expAmount;

  // ❌ Only update exp
  await _firestore.collection('users').doc(userId).update({
    'exp': newExp,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

**After:**
```dart
Future<int> _awardQuestEXP(String userId, TodoItem quest) async {
  final currentExp = (userDoc.get('exp') ?? 0) as int;
  final currentLevel = (userDoc.get('level') ?? 1) as int;
  final newExp = currentExp + expAmount;

  // ✅ Calculate new level based on new EXP
  final expService = ExpService();
  final newLevel = expService.calculateLevel(newExp);

  // ✅ Update both exp and level
  await _firestore.collection('users').doc(userId).update({
    'exp': newExp,
    'level': newLevel,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('   Updated user exp: $currentExp → $newExp');
  print('   Updated user level: $currentLevel → $newLevel');
}
```

## Files Modified

1. **`lib/core/services/exp_service.dart`**
   - Added `calculateLevel(int totalExp)` method

2. **`lib/core/services/quest_completion_service.dart`**
   - Added import for `exp_service.dart`
   - Updated `_awardQuestEXP()` to calculate and update level
   - Added logging for level changes

## How It Works Now

### Quest Completion Flow
```
User completes activity (e.g., lesson)
    ↓
QuestCompletionService.handleActivityCompletion() called
    ↓
_awardQuestEXP() executes:
  1. Get current exp and level from Firestore
  2. Calculate new exp (current + reward)
  3. Calculate new level using ExpService.calculateLevel()
  4. Update Firestore with both new exp and level ✅
    ↓
Firestore update triggers AuthService.currentUserStream
    ↓
AuthNotifier receives updated user data
    ↓
UI rebuilds with new exp and level immediately ✨
```

## Testing

### Verification Steps
1. Complete a quest (e.g., complete a daily lesson)
2. Observe the EXP counter in the top header
3. Observe the Level badge in the top header
4. Both should update **immediately** without needing to refresh

### Level Up Scenario
If the quest EXP pushes you to a new level:
- Both exp AND level update together
- Level badge changes immediately
- Progress bar updates correctly

## Impact

- ✅ **Immediate feedback:** Users see their progress update in real-time
- ✅ **Consistent behavior:** Client-side and server-side updates now work the same way
- ✅ **No breaking changes:** Existing functionality remains unchanged
- ✅ **Better UX:** More engaging and responsive experience

## Related Documentation

- Backend level calculation: `functions/src/config/exp-config.ts`
- Real-time auth stream: `lib/core/services/auth_service.dart`
- EXP provider: `lib/providers/exp_provider.dart`
- Quest completion: `QUEST_COMPLETION_IMPLEMENTATION.md`

