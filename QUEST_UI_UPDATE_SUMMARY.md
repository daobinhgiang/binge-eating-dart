# Quest Progress Bar UI Update

## What Changed

The Daily Quests section on the home screen now includes visual progress bars for each quest.

### Before
```
☐ Complete Today's Food Diary
☐ Practice a Coping Strategy
☐ Mindfulness Exercise
```

### After
```
☐ Complete Today's Food Diary
  ▰▰▰▰▰▰░░░░░░░░░░ 1/3 entries
  Journal entry recorded
  
☐ Practice a Coping Strategy  
  ▰▰▰▰░░░░░░░░░░░░ 2/3 reps
  Exercise progress
  
☐ Mindfulness Exercise
  ░░░░░░░░░░░░░░░░░░ 0%
  Not started
```

## Key Features

### 1. Progress Bar with Centered Text
- **Height**: 28px
- **Border Radius**: 8px
- **Text**: Displayed in the center with white color and shadow
- **Placement**: Below the quest title

### 2. Adaptive Progress Display
The text shown on the progress bar adapts based on quest type:

| Quest Type | Completed | Partial | Not Started |
|-----------|-----------|---------|-------------|
| **Lesson** | 100% Completed | 5/15 min | 0% |
| **Journal** | Logged | Logged | 0% |
| **Tool** | 100% Completed | 2/3 | 0% |

### 3. Color Coding
- **Green (#4CAF50)**: Counter format (e.g., "1/3") or completed
- **Blue (#2196F3)**: Percentage format
- **Gray (#E0E0E0)**: Inactive background

### 4. Progress Labels
Each bar includes a descriptive label:
- "Lesson progress"
- "Journal entry recorded"
- "Exercise progress"
- "Completed"
- "Not started"

## Visual Layout

```
┌─────────────────────────────────────┐
│                                     │
│  ☐  Quest Title                     │
│     ▰▰▰▰▰▰▰░░░░░░░░ 50%            │
│     Progress label                  │
│                                     │
└─────────────────────────────────────┘
```

## How It Works

1. **Rendering**: Each quest item calls `_buildQuestProgressBar()`
2. **Calculation**: `_getQuestProgressInfo()` determines the progress value
3. **Display**: 
   - Reads from `activityData` in the TodoItem
   - Calculates progress based on quest type
   - Generates appropriate display text
4. **Color Selection**: `_getProgressBarColor()` determines bar color

## Implementation Code

### Main Widget: `_buildQuestProgressBar()`
```dart
Widget _buildQuestProgressBar(BuildContext context, TodoItem todo) {
  final progressInfo = _getQuestProgressInfo(todo);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          // LinearProgressIndicator (the bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressInfo.progress,
              minHeight: 28,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressBarColor(progressInfo.type),
              ),
            ),
          ),
          // Centered text
          Positioned.fill(
            child: Center(
              child: Text(progressInfo.displayText, ...),
            ),
          ),
        ],
      ),
      // Description label
      Text(progressInfo.description, ...),
    ],
  );
}
```

### Progress Calculator: `_getQuestProgressInfo()`
Reads `activityData` from the quest and determines:
- `progress`: 0.0 to 1.0 for the bar fill
- `displayText`: What to show on the bar
- `description`: Label below the bar
- `type`: ProgressType.percentage or .counter

## Data Integration

For this feature to work, quests must populate `activityData`:

```dart
// When creating a lesson quest
activityData: {
  'duration': 5,  // minutes completed
}

// When creating a tool quest
activityData: {
  'reps': 1,
  'targetReps': 3,
}

// When creating a journal quest
activityData: {
  'entries': 0,  // number of entries
}
```

## Styling Details

- **Progress Bar Height**: 28px (clickable area)
- **Border Radius**: 8px (rounded corners)
- **Text Shadow**: Offset(0,1), blur 2, for readability
- **Font Size**: 12px (bodySmall)
- **Weight**: w600 (semi-bold)
- **Label Font Size**: 11px
- **Spacing**: 12px above bar, 4px below bar

## Responsive Behavior

- **Portrait**: Full width within quest card
- **Landscape**: Same, full width
- **Text Overflow**: Not applicable (always fits)
- **Touch Target**: Entire row (checkbox and text) for completion
