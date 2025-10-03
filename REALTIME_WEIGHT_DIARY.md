# Real-time Weight Diary Implementation

## Overview
The weight diary graph now fetches data from Firestore in real-time using Firestore streams. When you log a weight change, the graph automatically updates without requiring a manual refresh.

## Implementation Details

### Real-time Provider
- **Provider**: `allWeightEntriesStreamProvider`
- **Type**: `StreamProvider.family<List<WeightDiary>, String>`
- **Location**: `lib/providers/weight_diary_provider.dart`

### How it Works
1. Uses Firestore's `collectionGroup` query to fetch all weight diary entries for a user
2. Orders entries by `createdAt` in ascending order (oldest first)
3. Listens to real-time updates via Firestore's `snapshots()` method
4. Automatically rebuilds the graph when new data is available

### Key Features
- **Real-time Updates**: Graph updates automatically when new weight entries are added
- **Efficient Queries**: Uses collection group queries to avoid complex nested queries
- **Sorted Data**: Entries are automatically sorted by creation time
- **Error Handling**: Built-in error handling for network issues

### Usage
The weight diary survey screen (`lib/screens/journal/weight_diary_survey_screen.dart`) now uses:
```dart
final allAsync = ref.watch(allWeightEntriesStreamProvider(user.id));
```

Instead of the previous:
```dart
final allAsync = ref.watch(allWeightEntriesProvider(user.id));
```

### Benefits
1. **Automatic Updates**: No need to manually refresh the screen
2. **Better UX**: Users see changes immediately after logging weight
3. **Real-time Collaboration**: Multiple devices show the same data instantly
4. **Reduced Network Calls**: Only fetches data when changes occur

### Technical Notes
- Uses Firestore's real-time listeners
- Automatically handles connection state changes
- Optimized for mobile networks with efficient data transfer
- Compatible with offline functionality

