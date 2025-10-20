# Real-Time Quest/Todo Updates

## Overview
The app now automatically updates all UI related to todos/daily quests in real-time without requiring users to manually refresh the app. This is achieved by using **Firestore streams** and **Riverpod's StreamProvider** instead of Future-based providers.

## What Changed

### 1. **Core Architecture**
Instead of using cached Future calls that require manual refresh, the app now uses:
- **Firebase Firestore Snapshots**: Real-time listeners that push updates whenever data changes
- **Riverpod StreamProvider**: Reactive provider that automatically rebuilds widgets when data updates

### 2. **Updated Files**

#### `lib/providers/todo_provider.dart`
Added new stream providers for real-time updates:

```dart
// Main real-time provider - all todos
final userTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId);
});

// Tier-based real-time providers
final seedsStreamProvider              // Daily tasks
final growthTasksStreamProvider        // Weekly tasks
final masteryQuestsStreamProvider      // Persistent tasks
final todayTodosStreamProvider         // Today's todos only
final pendingTodosStreamProvider       // Incomplete todos
final completedTodosStreamProvider     // Completed todos
final overdueTodosStreamProvider       // Overdue todos
```

#### `lib/screens/home_screen.dart`
Changed line 798 from:
```dart
final userTodosAsync = ref.watch(userTodosProvider(user.id));
```
To:
```dart
final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));
```

#### `lib/screens/todos/todos_screen.dart`
Changed line 61 from:
```dart
final userTodosAsync = ref.watch(userTodosProvider(user.id));
```
To:
```dart
final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));
```

#### `lib/screens/home/todo_section.dart`
Changed line 19 from:
```dart
final userTodosAsync = ref.watch(userTodosProvider(user.id));
```
To:
```dart
final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));
```

## How It Works

### Before (Old - Still Available)
```
User Action → API Call → Future (one-time) → UI Update
         ↓
    Cached for 5 minutes → Manual refresh needed for updates
```

### After (New - Real-Time)
```
Firebase Firestore → Stream (continuous) → StreamProvider (watches) → UI Auto-Updates
         ↓
    Real-time listener → Any change in DB → Instant UI refresh
```

## Benefits

1. **Automatic Updates**: UI updates immediately when todos change, no refresh needed
2. **Real-Time Sync**: If another device/browser updates a todo, this app sees it instantly
3. **Better Performance**: Efficient Firestore listeners avoid unnecessary calls
4. **Seamless Experience**: Users see changes as they happen

## Available Stream Providers

You can now use these providers for real-time updates throughout the app:

| Provider | Purpose |
|----------|---------|
| `userTodosStreamProvider` | All todos for a user |
| `seedsStreamProvider` | Daily task seeds |
| `growthTasksStreamProvider` | Weekly growth tasks |
| `masteryQuestsStreamProvider` | Persistent mastery quests |
| `todayTodosStreamProvider` | Todos due today only |
| `pendingTodosStreamProvider` | Incomplete todos |
| `completedTodosStreamProvider` | Completed todos |
| `overdueTodosStreamProvider` | Overdue todos |

### Usage Example
```dart
// In any ConsumerWidget or ConsumerStatefulWidget
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(currentUserDataProvider);
  
  // Watch real-time todos
  final todosAsync = ref.watch(userTodosStreamProvider(user.id));
  
  return todosAsync.when(
    data: (todos) => TodoListWidget(todos: todos),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(error: error),
  );
}
```

## Old Providers Still Available

The following Future-based providers are still available but are NOT using real-time updates:

```dart
final userTodosProvider                // StateNotifier (cached)
final pendingTodosProvider             // Future (cached)
final completedTodosProvider           // Future (cached)
final todayTodosProvider               // Future (cached)
final overdueTodosProvider             // Future (cached)
final seedsProvider                    // Future (cached)
final growthTasksProvider              // Future (cached)
final masteryQuestsProvider            // Future (cached)
```

These should be gradually replaced with their stream equivalents (suffixed with `Stream`).

## Firestore Service Layer

The underlying service already had stream support (line 114-127 in `todo_service.dart`):

```dart
Stream<List<TodoItem>> getUserTodosStream(String userId) {
  return _getTodosCollection(userId)
      .snapshots()
      .map((snapshot) {
        final todos = snapshot.docs
            .map((doc) => TodoItem.fromFirestore(doc, userId: userId))
            .toList();
        todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return todos;
      });
}
```

This stream automatically connects to Firestore and receives updates whenever any document in the user's todos collection changes.

## Testing Real-Time Updates

To verify the real-time functionality:

1. **Same Device Test**:
   - Open the app on one screen
   - Open the Todos screen on another screen (or split view)
   - Add/complete/edit a quest in one screen
   - Observe the other screen update immediately without refresh

2. **Multi-Device Test**:
   - Log in the same user on two devices
   - Make changes on Device A
   - Changes appear instantly on Device B

3. **Firestore Console Test**:
   - Open [Firebase Console](https://console.firebase.google.com)
   - Navigate to Firestore → Collection → users → [userId] → todos
   - Manually edit a document
   - App updates instantly

## Performance Considerations

- **Network**: Streams maintain a constant connection; ensure good network conditions
- **Battery**: Active listeners use more battery; consider this for mobile devices
- **Data**: Real-time syncing reduces data freshness issues but increases connection overhead
- **Limits**: Be mindful of Firestore's [pricing limits](https://firebase.google.com/docs/firestore/quotas) for real-time listeners

## Future Improvements

1. **Add offline support**: Use `@DocumentReference` with local caching
2. **Pagination**: For users with many todos, add cursor-based pagination to streams
3. **Filtering**: Create specialized stream providers for complex filtering (e.g., by date range)
4. **Error Recovery**: Implement automatic reconnection with exponential backoff
5. **Analytics**: Track how many real-time listeners are active

## Troubleshooting

### UI not updating in real-time?
1. Check Firestore security rules allow reads for the user
2. Verify network connection is stable
3. Check Firebase console for any errors
4. Ensure you're watching the stream provider (not the Future provider)

### Too many updates?
1. Consider debouncing with `.distinct()`
2. Add filtering at the Firestore level (e.g., `where()` queries)
3. Use `.throttle()` if updates are too frequent

### Memory leaks?
1. Streams dispose automatically when providers are no longer watched
2. Ensure ConsumerWidget/ConsumerStatefulWidget properly dispose
3. Check that multiple listeners aren't created for the same user
