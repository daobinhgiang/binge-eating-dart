# Quest Progress Tracking - UI Integration Guide

## Overview

The quest system now automatically tracks and updates progress for quests like "Complete 3 Lessons". This guide shows how to display this progress in the UI.

## What Changed

### 1. Quest Metadata Now Includes Progress

When a lesson is completed, the quest's `tierMetadata` is automatically updated with:
- `currentCount`: Number of lessons completed so far (e.g., 2)
- `requiredCount`: Total lessons needed (e.g., 3)
- `trackBy`: Either 'daily' or 'weekly'

### 2. New Helper Methods on TodoItem

The `TodoItem` model now has convenient getters to access progress:

```dart
// Check if quest tracks progress
bool hasProgress = quest.hasProgress;

// Get current progress (e.g., 2)
int current = quest.currentCount;

// Get required count (e.g., 3)
int required = quest.requiredCount;

// Get progress as percentage (0.0 to 1.0)
double percentage = quest.progressPercentage;

// Get progress as string (e.g., "2/3")
String progressText = quest.progressString;

// Check if almost complete
bool almostDone = quest.isAlmostComplete;
```

## UI Examples

### Example 1: Simple Progress Text

```dart
Widget buildQuestCard(TodoItem quest) {
  return Card(
    child: ListTile(
      title: Text(quest.title),
      subtitle: quest.hasProgress 
          ? Text('Progress: ${quest.progressString}')
          : Text(quest.description),
      trailing: quest.isCompleted 
          ? Icon(Icons.check_circle, color: Colors.green)
          : null,
    ),
  );
}
```

### Example 2: Progress Bar

```dart
Widget buildQuestWithProgressBar(TodoItem quest) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quest.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          
          // Show progress bar if quest tracks progress
          if (quest.hasProgress) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: quest.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      quest.isAlmostComplete ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  quest.progressString,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${quest.requiredCount - quest.currentCount} more to go!',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ] else
            Text(quest.description),
          
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quest.expReward} EXP',
                style: TextStyle(color: Colors.amber[700]),
              ),
              if (quest.tier != null)
                Chip(
                  label: Text(quest.tierDisplayName),
                  backgroundColor: _getTierColor(quest.tier!),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

Color _getTierColor(TaskTier tier) {
  switch (tier) {
    case TaskTier.seeds:
      return Colors.green[100]!;
    case TaskTier.growthTasks:
      return Colors.blue[100]!;
    case TaskTier.masteryQuests:
      return Colors.purple[100]!;
  }
}
```

### Example 3: Circular Progress Indicator

```dart
Widget buildCompactQuestCard(TodoItem quest) {
  return Card(
    child: ListTile(
      leading: quest.hasProgress
          ? Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: quest.progressPercentage,
                  backgroundColor: Colors.grey[300],
                ),
                Text(
                  '${quest.currentCount}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : Icon(Icons.task_alt),
      title: Text(quest.title),
      subtitle: quest.hasProgress
          ? Text('${quest.requiredCount - quest.currentCount} more needed')
          : Text(quest.description),
      trailing: Text('${quest.expReward} EXP'),
    ),
  );
}
```

## Automatic Progress Updates

### When Does Progress Update?

Progress is automatically updated in the following scenarios:

1. **When a lesson is completed**: The `handleLessonCompletion` method in `QuestCompletionService` automatically updates all matching lesson quests.

2. **When seeds are regenerated**: New quests are automatically synced with current lesson progress to show accurate counts from the start.

3. **Manual sync (optional)**: You can manually trigger a sync if needed:

```dart
final questService = QuestCompletionService();
await questService.syncLessonQuestProgress(userId);
```

### Real-time Updates in UI

If you're using Riverpod with stream providers, the UI will automatically update when quest progress changes:

```dart
final seeds = ref.watch(seedsStreamProvider(userId));

return seeds.when(
  data: (quests) {
    return ListView.builder(
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        return buildQuestWithProgressBar(quest);
      },
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## Testing Progress Tracking

To verify progress tracking is working:

1. Check the Firestore console for a quest document
2. Look at the `tierMetadata` field
3. It should contain:
   ```json
   {
     "expReward": 150,
     "requiredCount": 3,
     "currentCount": 2,
     "trackBy": "daily",
     "priority": 0
   }
   ```

4. Complete a lesson and verify `currentCount` increments
5. The quest should auto-complete when `currentCount >= requiredCount`

## Troubleshooting

### Quest shows 0/3 even after completing lessons

**Solution**: Call `syncLessonQuestProgress` to sync existing quests:
```dart
await QuestCompletionService().syncLessonQuestProgress(userId);
```

### Progress doesn't update in real-time

**Solution**: Use stream providers instead of future providers:
```dart
// Use this:
final seeds = ref.watch(seedsStreamProvider(userId));

// Instead of:
final seeds = ref.watch(seedsProvider(userId));
```

### Quest was completed but still shows as pending

**Solution**: The quest should auto-complete when the count reaches the requirement. Check the console logs for the completion handler. If it's not completing, ensure:
- The quest's `activityId` is exactly 'complete_lessons'
- The `tierMetadata` contains 'requiredCount'
- The lesson completion handler is being called

## Summary

The quest progress system is now fully automated:
- ✅ Quests automatically update their progress when lessons are completed
- ✅ Progress is persisted in Firestore in the quest's `tierMetadata`
- ✅ UI can easily display progress using the helper methods
- ✅ Quests auto-complete when the requirement is met
- ✅ Real-time updates work with stream providers

