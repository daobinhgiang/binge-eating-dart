# Account Deletion & Data Cleanup Fix

## Problem
After deleting an account and recreating it, the app was showing:
1. Previous completed daily quests from the old account
2. New daily quests being generated alongside the old ones

This indicated that quest data was persisting after account deletion.

## Root Causes

### 1. **In-Memory Service Caches Not Cleared**
   - `TodoService` maintains an in-memory cache (`_cache`, `_cacheTimestamps`) to avoid repeated database queries
   - Cache timeout is 5 minutes, so stale data could persist
   - When account was deleted, the singleton services weren't clearing their caches
   - Result: App would use cached quest data even though Firestore was cleared

### 2. **Task Regeneration Cache Not Cleared**
   - `TaskRegenerationService` maintains a cache of last regeneration logs (`_lastRegenerationCache`)
   - This cache was not being cleared, so the service would think it had already regenerated today's tasks
   - Result: New quests weren't being properly generated for the new account

## Solution

### Changes Made:

#### 1. **TodoService** (`lib/core/services/todo_service.dart`)
- Added `clearAllCaches()` method to clear all in-memory caches
- This ensures no stale quest data is used after account deletion

```dart
void clearAllCaches() {
  _cache.clear();
  _cacheTimestamps.clear();
}
```

#### 2. **TaskRegenerationService** (`lib/core/services/task_regeneration_service.dart`)
- Added `clearCache()` method to clear the regeneration log cache
- This ensures the service will properly regenerate tasks for the new account

```dart
void clearCache() {
  _lastRegenerationCache.clear();
  print('In-memory regeneration cache cleared.');
}
```

#### 3. **AuthProvider** (`lib/providers/auth_provider.dart`)
- Updated `deleteAccount()` method to clear both service caches before deleting the account
- Added import for `TodoService`

```dart
Future<void> deleteAccount() async {
  state = const AsyncValue.loading();
  try {
    final currentUser = state.value;
    if (currentUser != null) {
      AppInitializationService().clearUserInitialization(currentUser.id);
      // Clear all service caches to prevent stale data after account deletion
      TodoService().clearAllCaches();
      TaskRegenerationService().clearCache();
    }
    
    await _authService.deleteAccount();
    state = const AsyncValue.data(null);
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
  }
}
```

#### 4. **AuthService** (`lib/core/services/auth_service.dart`)
- No changes needed - already properly deletes all Firestore data via `_deleteAllUserData()`
- Firestore cleanup ensures no old documents remain

## How It Works

### Account Deletion Flow:

1. User initiates account deletion
2. `AuthProvider.deleteAccount()` is called
3. **Service caches are cleared** (prevents stale data)
4. `AppInitializationService.clearUserInitialization()` is called (clears init state)
5. `AuthService.deleteAccount()` is called, which:
   - Cleans up FCM tokens
   - Deletes all Firestore subcollections (todos, assessments, exercises, weeks, etc.)
   - Deletes the main user document
   - Disconnects from Google Sign-In
   - Deletes Firebase Auth user

6. User signs out and app navigates to login

### Account Recreation Flow:

1. User signs up with same email or different account
2. New user document is created in Firestore (completely fresh)
3. **All service caches are empty** (because we cleared them)
4. `TaskRegenerationService.checkAndRegenerateTasks()` is called:
   - No regeneration log found (cache was cleared)
   - Seeds are regenerated fresh
   - Growth tasks are regenerated fresh
   - No old quests appear

## Benefits

- ✅ No stale quest data after account deletion
- ✅ Fresh tasks generated properly for new account
- ✅ Accounts can be deleted and recreated multiple times without issues
- ✅ Singleton services properly cleaned up
- ✅ Minimal performance impact (only clears caches on deletion)
- ✅ Works across app restart/relaunches

## Testing

To verify the fix works:

1. Create account, complete some quests
2. Delete account (Settings → Delete Account)
3. Create new account (same or different email)
4. Verify:
   - No old quests appear
   - Only 3-4 new daily quests show
   - No duplicate/mixed quests
   - App displays correct quest count

## Files Modified

1. `lib/core/services/todo_service.dart` - Added cache clearing method
2. `lib/core/services/task_regeneration_service.dart` - Added cache clearing method  
3. `lib/providers/auth_provider.dart` - Call cache clearing on account deletion
4. `lib/core/services/auth_service.dart` - (Already had proper cleanup, no changes needed)

---

**Date Fixed**: October 22, 2025
**Related Issues**: Account deletion leaving stale quest data
