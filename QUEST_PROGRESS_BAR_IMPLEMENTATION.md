# Quest Progress Bar Implementation

## Overview
The Daily Quests section on the home screen now displays progress bars for each quest. The progress indicator adapts based on the quest type, showing either a percentage completion or a counter format (e.g., "0/3", "1/3").

## Visual Design
Each quest now displays:
1. **Checkbox** - for marking quests complete
2. **Quest Title** - the name of the quest
3. **Progress Bar** - a visual indicator with:
   - A color-coded bar (blue for %, green for counter)
   - Text displayed in the center showing progress (e.g., "0%", "1/3 min")
   - A descriptive label below the bar

## Progress Tracking by Quest Type

### Lessons
- **Display Format**: `0/15 min` (current/total minutes)
- **Logic**: Reads `duration` from `activityData`
- **Assumption**: Standard lessons are 15 minutes long
- **Progress Bar Color**: Green (counter format)

### Journals
- **Display Format**: `Logged` or `0%` (not started)
- **Logic**: Reads `entries` from `activityData`
- **Assumption**: A single journal entry marks the quest as completed
- **Progress Bar Color**: Green (counter format) or Blue (not started)

### Tools/Exercises
- **Display Format**: `0/1`, `1/3`, etc. (current/target reps)
- **Logic**: Reads `reps` and `targetReps` from `activityData`
- **Assumption**: Target reps default to 1 if not specified
- **Progress Bar Color**: Green (counter format)

## Data Structure

The progress system reads from the `TodoItem` class:

```dart
class TodoItem {
  final String id;
  final String title;
  final TodoType type;  // lesson, tool, journal
  final Map<String, dynamic>? activityData;  // Contains progress info
  final bool isCompleted;
  // ... other fields
}
```

### Activity Data Format

Each quest type should populate `activityData` with relevant fields:

**Lesson:**
```dart
activityData: {
  'duration': 0,  // minutes watched/completed
}
```

**Journal:**
```dart
activityData: {
  'entries': 0,  // number of entries recorded
}
```

**Tool:**
```dart
activityData: {
  'reps': 0,           // repetitions completed
  'targetReps': 3,     // target number of reps
}
```

## Implementation Details

### Classes

#### `ProgressType` (enum)
```dart
enum ProgressType { percentage, counter }
```
Determines whether to show percentage or counter format.

#### `QuestProgressInfo` (data class)
```dart
class QuestProgressInfo {
  final double progress;           // 0.0 to 1.0
  final String displayText;        // Text to show on bar
  final String description;        // Label below bar
  final ProgressType type;         // Display format type
}
```

### Key Methods

#### `_buildQuestProgressBar(BuildContext context, TodoItem todo)`
Renders the progress bar widget with:
- Stack layout with `LinearProgressIndicator` and centered text
- Color-coded based on progress type
- Shadow effects for text visibility

#### `_getQuestProgressInfo(TodoItem todo)`
Calculates progress information based on:
1. If quest is completed → Shows "100% Completed"
2. Otherwise, checks quest type and reads from `activityData`
3. Returns appropriate `QuestProgressInfo` object

#### `_getProgressBarColor(ProgressType type)`
Returns the bar color:
- `percentage`: Blue (#2196F3)
- `counter`: Green (#4CAF50)
- `completed`: Green (#4CAF50)

## Customization

To modify progress tracking logic:

1. **Change default lesson duration**: Edit `const totalMinutes = 15;` in `_getQuestProgressInfo()`

2. **Add new quest type**: Add a new case in the switch statement in `_getQuestProgressInfo()`

3. **Customize colors**: Modify `_getProgressBarColor()` method

4. **Adjust bar appearance**: Edit `_buildQuestProgressBar()` - adjust height, border radius, shadows, etc.

## Usage Example

When creating a quest with progress tracking:

```dart
// Lesson quest
TodoItem(
  id: 'quest_123',
  title: 'Complete Lesson 5',
  type: TodoType.lesson,
  activityData: {
    'duration': 5,  // 5 out of 15 minutes
  },
  // ... other fields
);

// Tool quest
TodoItem(
  id: 'quest_456',
  title: 'Practice Breathing',
  type: TodoType.tool,
  activityData: {
    'reps': 2,
    'targetReps': 3,
  },
  // ... other fields
);

// Journal quest
TodoItem(
  id: 'quest_789',
  title: 'Complete Food Diary',
  type: TodoType.journal,
  activityData: {
    'entries': 1,  // At least 1 entry
  },
  // ... other fields
);
```

## Future Enhancements

1. **Dynamic target durations**: Store lesson duration in `activityData` instead of hardcoding 15 minutes
2. **Custom progress calculation**: Add a `progressCalculator` field to `TaskTemplate`
3. **Multi-step lessons**: Track chapter/section completion as well as duration
4. **Animations**: Add progress bar fill animation when progress updates
5. **Progress persistence**: Track progress history for analytics
