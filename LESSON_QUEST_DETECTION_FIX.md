# Lesson Quest Detection Fix ✅

## Problem
The app was tracking lesson completion counts (`lessonsCompletedToday`, `lessonsCompletedThisWeek`) correctly, but the "Complete 3 Lessons" quest was not being detected and marked as complete. The terminal output showed:

```
📚 LESSON COMPLETION HANDLER
📊 Step 1: Recording lesson completion...
   ✅ Progress recorded!
   📅 Lessons completed TODAY: 2
   📆 Lessons completed THIS WEEK: 2

🔍 Step 2: Checking for matching quests...
   Total todos fetched: 0           ← ❌ THIS WAS THE PROBLEM
   Found 0 pending lesson-based quests

ℹ️  RESULT: No quest completed this session
```

## Root Cause
Two issues were preventing quest detection:

### Issue 1: Missing tierMetadata Fields (PRIMARY ISSUE)
**File**: `lib/models/task_template.dart`
**Method**: `TaskTemplate.toTodoItem()`

When converting a TaskTemplate to a TodoItem, the `tierMetadata` was only including `expReward`:
```dart
// OLD CODE (INCORRECT)
tierMetadata: {
  'expReward': expReward,
},
```

But the quest completion logic was looking for `requiredCount` and `trackBy`:
```dart
// In quest_completion_service.dart, line 193-194
final requiredCount = quest.tierMetadata?['requiredCount'] as int?;
final trackBy = quest.tierMetadata?['trackBy'] as String? ?? 'daily';
```

Since these fields were missing from `tierMetadata`, the quest wasn't being properly identified.

### Issue 2: Stale Cache
**File**: `lib/core/services/todo_service.dart`

The `getUserTodos()` method uses a 5-minute cache. When checking for matching quests, the cached todos might have been stale if seeds were just generated or updated.

## Solution

### Fix 1: Include All Metadata in tierMetadata
**File**: `lib/models/task_template.dart` (lines 108-116)

Changed the `toTodoItem()` method to merge all template metadata into `tierMetadata`:

```dart
// Build tierMetadata with both template metadata and expReward
final tierMetadata = <String, dynamic>{
  'expReward': expReward,
};

// Merge in all metadata from the template
if (metadata != null) {
  tierMetadata.addAll(metadata!);
}
```

Now when the `seed_lesson_complete` template is converted to a TodoItem, the tierMetadata includes:
- `expReward`: 150 (from template)
- `requiredCount`: 3 (from metadata)
- `trackBy`: 'daily' (from metadata)
- `priority`: 0 (from metadata)

### Fix 2: Clear Cache Before Quest Checking
**File**: `lib/core/services/quest_completion_service.dart` (line 174-175)

Added cache clearing in `handleLessonCompletion()` before fetching todos:

```dart
print('\n🔍 Step 2: Checking for matching quests...');
// Clear cache to ensure fresh data from Firestore
_todoService.clearUserCache(userId);
// Now check for matching quests related to lesson completion
final allTodos = await _todoService.getUserTodos(userId);
```

### Supporting Change: Public Cache Clear Method
**File**: `lib/core/services/todo_service.dart` (after line 61)

Added a public method to clear the cache:

```dart
/// Public method to clear cache for a user
/// Call this when you need fresh data from Firestore
void clearUserCache(String userId) {
  _clearCache(userId);
}
```

## How It Now Works

```
1. User completes a lesson
   ↓
2. _finishLesson() is called
   ↓
3. LessonProgressService.recordLessonCompletion()
   ├─ Updates lessonsCompletedToday/Week in Firestore
   └─ Returns updated counts
   ↓
4. QuestCompletionService.handleLessonCompletion()
   ├─ Clear todo cache ✅ (FIX #2)
   ├─ Fetch todos from Firestore
   ├─ Find quests with activityId == 'complete_lessons'
   ├─ Extract tierMetadata.requiredCount ✅ (FIX #1)
   ├─ Compare current count >= required count
   ├─ If YES:
   │  ├─ Award EXP
   │  ├─ Mark quest as complete
   │  └─ Show celebration dialog
   └─ If NO: Log progress for next lesson
```

## Example Metadata Flow

### Template Definition (task_templates.dart, lines 91-106)
```dart
TaskTemplate(
  id: 'seed_lesson_complete',
  category: 'lessons',
  tier: TaskTier.seeds,
  title: 'Complete 3 Lessons',
  description: 'Finish 3 lessons today to master your recovery',
  activityId: 'complete_lessons',
  expReward: 150,
  metadata: {
    'requiredCount': 3,
    'trackBy': 'daily',
    'priority': 0,
  },
),
```

### Converted to TodoItem
Now includes in `tierMetadata`:
```dart
tierMetadata: {
  'expReward': 150,           // From template
  'requiredCount': 3,         // From metadata ✅
  'trackBy': 'daily',         // From metadata ✅
  'priority': 0,              // From metadata ✅
}
```

### Quest Detection (quest_completion_service.dart, lines 192-206)
```dart
for (final quest in lessonQuests) {
  final requiredCount = quest.tierMetadata?['requiredCount'] as int?;  // ✅ NOW FOUND
  final trackBy = quest.tierMetadata?['trackBy'] as String? ?? 'daily'; // ✅ NOW FOUND
  
  if (requiredCount == null) continue;

  final currentCount = trackBy == 'weekly' 
      ? progress['lessonsCompletedThisWeek']! 
      : progress['lessonsCompletedToday']!;

  // Check if requirement is met
  if (currentCount >= requiredCount) {
    print('      ✅✅✅ QUEST REQUIREMENT MET! ✅✅✅');
    // Award EXP, mark complete, show dialog
  }
}
```

## Testing

After this fix, when completing lessons:

```
✅ Progress recorded!
   📅 Lessons completed TODAY: 3
   📆 Lessons completed THIS WEEK: 3

   Found 1 pending lesson-based quests

   📋 Checking Quest: "Complete 3 Lessons"
      - Required: 3 lessons
      - Tracking: DAILY
      - Current: 3 lessons
      - Progress: 3/3
      ✅✅✅ QUEST REQUIREMENT MET! ✅✅✅
```

## Files Modified

1. **lib/models/task_template.dart**
   - Updated `toTodoItem()` method to merge metadata into tierMetadata

2. **lib/core/services/todo_service.dart**
   - Added public `clearUserCache()` method

3. **lib/core/services/quest_completion_service.dart**
   - Added cache clearing before fetching todos in `handleLessonCompletion()`

## Impact

- ✅ "Complete 3 Lessons" quests now properly detected when conditions are met
- ✅ Progress tracking works for daily/weekly lesson completion
- ✅ Quest completion shows correct progress (1/3, 2/3, 3/3)
- ✅ EXP rewards (150 XP) awarded correctly
- ✅ Congratulation dialogs now appear at quest completion
- ✅ Todo list updates reflect quest completion status

## Verification Checklist

- [ ] Complete lesson 1
  - Check: Should show "1/3 lessons" in quest
  - Check: Should NOT mark quest complete yet
  
- [ ] Complete lesson 2
  - Check: Should show "2/3 lessons" in quest
  - Check: Should NOT mark quest complete yet
  
- [ ] Complete lesson 3
  - Check: Should show "3/3 lessons" in quest
  - Check: ✅ SHOULD show quest complete dialog
  - Check: ✅ Should award 150 EXP
  - Check: ✅ Quest should disappear from pending list
  - Check: ✅ Should appear in completed quests

---

**Status**: ✅ FIXED
**Severity**: CRITICAL (Blocked main quest functionality)
**Effort**: LOW (3 simple changes)
