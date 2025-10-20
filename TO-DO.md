# Binge Eating Recovery App - Quest Management System Implementation Plan

## Executive Summary

This document outlines the comprehensive implementation plan for the app's quest management system. It includes the current state analysis, architectural recommendations, and specific adjustments tailored to the existing codebase.

---

## Part 1: Current State Analysis

### 1.1 What Currently Exists

The app already has a **solid foundation** for quest management:

#### Implemented Components
- **TodoItem Model** (`lib/models/todo_item.dart`)
  - Complete data model with all necessary fields
  - Support for three quest types: Lesson, Tool (Exercises), Journal
  - Timestamps for creation, updates, and completion
  - Activity ID tracking for linking quests to actual content
  - Proper serialization/deserialization with Firestore

- **TodoService** (`lib/core/services/todo_service.dart`)
  - Full CRUD operations for todos
  - Caching mechanism (5-minute timeout) for performance
  - User-specific todo management
  - Stream support for real-time updates
  - Filtering capabilities (pending, completed, overdue, due today)

- **TodoProvider & State Management** (`lib/providers/todo_provider.dart`)
  - Riverpod-based state management
  - Multiple providers for different queries
  - AsyncValue handling for loading/error states
  - Methods for quest completion, filtering, and statistics

- **UI Components**
  - **TodosScreen** - Full quest list view with tabs for pending/completed
  - **AddTodoScreen** - Manual quest creation with activity selection
  - **TodoSection** - Home screen widget showing today's quests
  - Summary cards showing quest statistics
  - Quest filtering by type and completion status

#### Recent Changes
- **Auto-Todo System Removed** (see TODO_AUTO_CREATION_REMOVAL_SUMMARY.md)
  - Automatic quest generation has been removed
  - App now relies on manual quest creation
  - This is actually beneficial for the new architecture

### 1.2 Current Limitations

1. **No Automatic Quest Generation**
   - Users must manually create all quests
   - No seeds (daily quests), growth quests (weekly), or mastery quests
   - No regeneration logic
   - No template system

2. **No Tier System**
   - Cannot distinguish between different quest categories/priorities
   - All quests treated equally

3. **No Template Infrastructure**
   - Quest templates not stored or managed
   - Hard to maintain consistency across users
   - Difficult to scale quest types

4. **Limited Quest Metadata**
   - No tier type (Seeds, Growth Quests, Mastery Quests)
   - No regeneration timestamps
   - No priority levels

5. **No Timezone Handling**
   - All dates stored as absolute timestamps
   - No consideration for user's local timezone

---

## Part 2: Recommended Architecture

### 2.1 Enhanced Core Data Model

#### New Models to Create

**TaskTemplate Model** (`lib/models/task_template.dart`)
```dart
enum TaskTier {
  seeds,           // Daily tasks
  growthTasks,     // Weekly tasks
  masteryQuests,   // Persistent tasks
}

class TaskTemplate {
  final String id;
  final String category;      // 'journaling', 'exercises', 'lessons'
  final TaskTier tier;
  final String title;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Methods for task instantiation
  TodoItem toTodoItem(String userId, DateTime dueDate);
}
```

**ActiveTask Model** (`lib/models/active_task.dart`)
```dart
class ActiveTask {
  final String id;
  final String userId;
  final String templateId;      // Reference to task template
  final TodoItem taskInstance;  // The actual todo item
  final DateTime assignedDate;
  final DateTime? autoDeleteDate; // For Seeds and Growth Tasks
  final bool isSeed;            // Easier filtering
  final bool isGrowthTask;
  final bool isMasteryQuest;
  
  // Regeneration tracking
  final String regenerationBatchId; // Group tasks from same regeneration
}
```

**RegenerationLog Model** (`lib/models/regeneration_log.dart`)
```dart
class RegenerationLog {
  final String id;
  final String userId;
  final DateTime regeneratedAt;
  final String? seedsDate;      // Date string (YYYY-MM-DD) for Seeds
  final int? growthWeek;        // ISO week number for Growth Tasks
  final List<String> generatedTaskIds;
}
```

#### Update Existing TodoItem Model

Add these fields to `TodoItem`:
```dart
final TaskTier? tier;                    // Seeds, GrowthTasks, MasteryQuests
final String? templateId;                // Reference to template
final String? regenerationBatchId;       // Track regeneration batches
final DateTime? autoDeleteDate;          // Auto-clear date for Seeds/Growth Tasks
final Map<String, dynamic>? tierMetadata; // Tier-specific data
```

---

### 2.2 Firestore Structure

```
users/{userId}/
├── taskTemplates/
│   ├── {templateId}
│   │   ├── id
│   │   ├── category (journaling, exercises, lessons)
│   │   ├── tier (seeds, growthTasks, masteryQuests)
│   │   ├── title
│   │   ├── description
│   │   ├── metadata (category-specific data)
│   │   ├── createdAt
│   │   └── updatedAt
│   └── ...
├── activeTasks/ (renamed from todos)
│   ├── {taskId}
│   │   ├── todoItemData (the actual TodoItem)
│   │   ├── templateId
│   │   ├── tier
│   │   ├── assignedDate
│   │   ├── autoDeleteDate
│   │   ├── regenerationBatchId
│   │   └── ... (all TodoItem fields)
│   └── ...
├── taskHistory/ (optional, for analytics)
│   ├── {historyId}
│   │   ├── taskId
│   │   ├── templateId
│   │   ├── completedAt
│   │   ├── tier
│   │   └── durationMinutes
│   └── ...
└── regenerationLog/
    ├── {logId}
    │   ├── regeneratedAt
    │   ├── seedsDate
    │   ├── growthWeek
    │   └── generatedTaskIds
    └── ...
```

**Why this structure:**
- ✅ Maintains backward compatibility with current `todos` usage
- ✅ Clear separation of concerns
- ✅ Efficient querying for different task types
- ✅ Audit trail for regenerations
- ✅ Optional history for future analytics/streaks

---

### 2.3 Task Tier Definitions

#### Tier 1: Seeds (Daily Tasks)
- **Purpose**: Daily recovery activities
- **Regeneration**: Every 24 hours (midnight local timezone)
- **Examples**:
  - Today's journal tasks (food diary, body image diary, weight diary)
  - One recommended lesson section
  - Daily 2 (recovery) exercises
  - Daily Weight logging
- **Behavior**:
  - Regenerated if date changed since last generation
  - Previous day's incomplete seeds are deleted (cleared)
  - Auto-deleted at end of day or start of new day
  

#### Tier 2: Growth Tasks (Weekly Tasks)
- **Purpose**: Deeper learning and skill-building
- **Regeneration**: Every 7 days (e.g., Mondays at midnight)
- **Examples**:
  - Complete 2 quiz
  - Major recovery exercise (e.g., Problem Solving, Meal Planning)
  - Weekly reflection exercise
- **Behavior**:
  - Regenerated if week number changed
  - Incomplete growth tasks auto-deleted when week changes
  - Can be manually pinned to carry over (future feature)
  - Will award 

#### Tier 3: Mastery Quests (Persistent Tasks)
- **Purpose**: Long-term milestones and achievements
- **Regeneration**: Never
- **Examples**:
  - Complete all lessons stage 1
  - Earn 3,000 EXP this month
  - Maintain 7-day journal streak
- **Behavior**:
  - Created once and stay until completed
  - Manually managed or server-calculated
  - Can be reset or extended

---

## Part 3: Implementation Architecture

### 3.1 Task Template Management

#### Template Bootstrap Strategy

Instead of fetching templates from Firebase every time, use a **bundled + cached approach**:

1. **Bundled Templates** (`lib/data/task_templates.dart`)
   ```dart
   class TaskTemplatesData {
     static List<TaskTemplate> getDefaultSeeds() { ... }
     static List<TaskTemplate> getDefaultGrowthTasks() { ... }
     static List<TaskTemplate> getDefaultMasteryQuests() { ... }
   }
   ```

2. **Local Cache** (Use existing `TodoService` caching mechanism)
   - Cache templates for 24 hours
   - Update on app startup if needed
   - Reduces Firestore reads

3. **Optional Firebase Sync** (Future Phase)
   - Sync custom user templates periodically
   - Allow admin to update global templates
   - Not required for initial implementation

---

### 3.2 Client-Side Regeneration Logic

#### New Service: TaskRegenerationService

```dart
class TaskRegenerationService {
  /// Check and regenerate tasks if needed
  /// Returns: List of newly generated tasks
  Future<List<TodoItem>> checkAndRegenerateTasks(
    String userId, 
    List<TaskTemplate> templates,
  ) async {
    // 1. Check if Seeds need regeneration (daily)
    // 2. Check if Growth Tasks need regeneration (weekly)
    // 3. Mastery Quests: no regeneration needed
    // 4. Return newly generated tasks
  }
  
  /// Generate Seeds for today
  Future<List<TodoItem>> generateSeeds(
    String userId,
    List<TaskTemplate> seedTemplates,
  ) async { ... }
  
  /// Generate Growth Tasks for this week
  Future<List<TodoItem>> generateGrowthTasks(
    String userId,
    List<TaskTemplate> growthTemplates,
  ) async { ... }
  
  /// Clean up expired tasks
  Future<void> cleanupExpiredTasks(String userId) async { ... }
  
  /// Get regeneration status
  Future<RegenerationLog?> getLastRegeneration(String userId) async { ... }
}
```

#### Key Regeneration Logic

**Check if Seeds need regeneration:**
```dart
bool _seedsNeedRegeneration(RegenerationLog? lastLog) {
  if (lastLog == null) return true;
  
  final lastDate = DateTime.parse(lastLog.seedsDate ?? '');
  final today = DateTime.now();
  final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  
  return !lastDateOnly.isAtSameMomentAs(todayOnly);
}
```

**Check if Growth Tasks need regeneration:**
```dart
bool _growthTasksNeedRegeneration(RegenerationLog? lastLog) {
  if (lastLog == null) return true;
  
  final lastWeek = lastLog.growthWeek ?? 0;
  final currentWeek = _getISOWeekNumber(DateTime.now());
  
  return lastWeek != currentWeek;
}

int _getISOWeekNumber(DateTime date) {
  // ISO week numbering logic
  final jan4 = DateTime(date.year, 1, 4);
  final startOfYear = jan4.subtract(Duration(days: jan4.weekday - 1));
  final diffDays = date.difference(startOfYear).inDays;
  return (diffDays / 7).floor() + 1;
}
```

---

### 3.3 Timezone Handling

#### Timezone Service

```dart
class TimezoneService {
  /// Get user's local midnight in UTC
  DateTime getLocalMidnightUTC(String userId) {
    final userTimezone = _getUserTimezone(userId); // Store in user preferences
    final now = DateTime.now();
    final local = TZDateTime.from(now, getLocation(userTimezone));
    final midnight = DateTime(local.year, local.month, local.day);
    return TZDateTime.from(midnight, getLocation(userTimezone)).toUtc();
  }
  
  /// Check if it's a new day for the user
  bool isNewDayForUser(String userId, DateTime lastCheck) {
    final timezone = _getUserTimezone(userId);
    final now = DateTime.now().toLocal();
    final lastCheckLocal = lastCheck.toLocal();
    
    return DateTime(now.year, now.month, now.day) !=
           DateTime(lastCheckLocal.year, lastCheckLocal.month, lastCheckLocal.day);
  }
}
```

**Use package:** `timezone: ^0.9.0` (already available in Flutter ecosystem)

---

### 3.4 Task Generation Strategy

#### Daily Seeds Generation

**Timing**: On app startup if date changed
**Strategy**: Based on user's current progress

```dart
Future<List<TodoItem>> generateDailySeeds(String userId) async {
  // 1. Get user's current stage/chapter from lesson progress
  // 2. Select appropriate seed templates for that stage
  // 3. Randomize or rotate if multiple options
  // 4. Create TodoItems with today's due date + evening time (7 PM)
  // 5. Return generated seeds
}
```

**Example Seeds for Stage 1:**
- Daily Journal: "Complete today's food diary"
- Daily Journal: "Reflect on body image"
- Daily Journal: "Check your weight"
- Daily Exercise: "Practice your coping strategy"
- Daily Lesson: "Review lesson 1.1"

#### Weekly Growth Tasks Generation

**Timing**: On app startup if week changed
**Strategy**: Based on lesson progression

```dart
Future<List<TodoItem>> generateWeeklyGrowthTasks(String userId) async {
  // 1. Get user's current and next chapters
  // 2. Select key lessons from this week's focus
  // 3. Select one major exercise from this week
  // 4. Create TodoItems with due dates spread across the week
  // 5. Return generated growth tasks
}
```

**Example Growth Tasks for Stage 1:**
- Monday: "Complete Lesson 1.2 - Building Awareness"
- Wednesday: "Practice Problem-Solving Exercise"
- Friday: "Complete Assessment Quiz 1.1"

#### Mastery Quests (Persistent)

**Creation**: 
- When stage starts
- When achievements unlocked
- Manually by admin

**Examples:**
- "Complete all lessons in Stage 1" (auto-calculated)
- "Maintain 30-day journal streak" (progress-tracked)
- "Earn 10,000 EXP" (milestone-based)

---

## Part 4: Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
- [ ] Create new models: `TaskTemplate`, `ActiveTask`, `RegenerationLog`
- [ ] Update `TodoItem` with tier fields
- [ ] Create `TaskRegenerationService`
- [ ] Update Firestore security rules for new collections
- [ ] Add timezone package to `pubspec.yaml`
- [ ] Write comprehensive tests for regeneration logic

### Phase 2: Task Generation (Weeks 3-4)
- [ ] Implement `generateSeeds()` logic
- [ ] Implement `generateGrowthTasks()` logic
- [ ] Implement cleanup logic
- [ ] Update `TodoService` to handle tier-based queries
- [ ] Create `TimezoneService`
- [ ] Add regeneration call to app initialization

### Phase 3: UI & UX (Weeks 5-6)
- [ ] Update `TodosScreen` to show tasks organized by tier
- [ ] Add visual indicators for Seeds, Growth Tasks, Mastery Quests
- [ ] Show regeneration timestamp and next regeneration time
- [ ] Add "Quick Add" for manual tasks
- [ ] Implement tier-based filtering/sorting
- [ ] Update home screen todo widget

### Phase 4: Testing & Polish (Weeks 7-8)
- [ ] End-to-end testing with multiple users
- [ ] Edge case testing (timezone changes, day boundaries, etc.)
- [ ] Performance testing (large task lists)
- [ ] User feedback and refinement
- [ ] Documentation and deployment

---

## Part 5: Multi-Device Synchronization Strategy

### 5.1 Conflict Resolution

**Problem**: User opens app on phone (Seeds regenerated) then opens on tablet

**Solution**: Use regeneration batch IDs and timestamps

```dart
Future<void> ensureConsistentState(String userId) async {
  // 1. Fetch last regeneration log from server
  // 2. Compare with local last regeneration
  // 3. If different:
  //    - Remove locally-regenerated tasks not in server version
  //    - Add any missing server-generated tasks
  //    - Update regeneration log
}
```

### 5.2 Conflict Detection

```dart
bool _hasRegenerationConflict(
  DateTime lastLocalRegen,
  DateTime lastServerRegen,
) {
  final diff = lastServerRegen.difference(lastLocalRegen).inMinutes;
  return diff.abs() > 5; // More than 5 minutes apart
}
```

---

## Part 6: Edge Cases & Handling

### 6.1 Timezone Changes
- **Issue**: User travels to different timezone
- **Solution**: Regeneration check uses local timezone, not stored timezone
- **Implementation**: Always compare dates in user's current local timezone

### 6.2 Offline Usage
- **Issue**: No Firestore connectivity during regeneration
- **Solution**: Regenerate locally, queue sync
- **Implementation**: Mark tasks with `pendingSync` flag, retry on connectivity

### 6.3 User Skips Days
- **Issue**: User doesn't open app for 3 days
- **Solution**: Only regenerate up to today, delete all overdue incomplete tasks
- **Implementation**: Batch cleanup on app startup

### 6.4 Task Completion Before Regeneration
- **Issue**: User completes yesterday's seed before today's regeneration
- **Solution**: Move to history, don't auto-delete
- **Implementation**: Check `completedAt` timestamp during cleanup

---

## Part 7: Integration Points

### 7.1 With Lesson System
- Link Seeds/Growth Tasks to specific lessons
- Auto-complete task when lesson completed (existing functionality)
- Track lesson progress to inform task generation

### 7.2 With Exercise System
- Weekly growth tasks recommend exercises
- Track exercise completion in task history
- Use for analytics

### 7.3 With Journal System
- Daily Seeds automatically create journal prompts
- Journal completion marks task complete
- Track journaling consistency

### 7.4 With EXP System
- Award XP for task completion
- Different tiers award different amounts:
  - Seeds: 50 XP each
  - Growth Tasks: 200 XP each
  - Mastery Quests: 500+ XP each
- Milestone tracking for streaks

---

## Part 8: Database Considerations

### 8.1 Cost Optimization

**Current Usage** (TodoItem only):
- ~1 read per user on startup
- ~1 write per task creation/completion
- ~0.5 reads per app session for filtering

**With Proposed System**:
- +1 read for regeneration log (startup only)
- +N reads for template fetching (cached, minimal)
- Same writes (~1 per task)
- Result: ~15-20% increase in Firestore cost, manageable

**Optimization Strategies**:
- Cache templates locally (key savings)
- Use bundles for initial data loads
- Batch writes for regeneration
- Archive old completed tasks to history

### 8.2 Firestore Indexes

Create indexes for:
```
users/{userId}/activeTasks:
- [userId, tier, createdAt]
- [userId, tier, isDueToday, isCompleted]
- [userId, regenerationBatchId, createdAt]
```

---

## Part 9: Future Enhancements (Not in Phase 1)

1. **Streaks System** (mentioned in current TO-DO.md)
   - Track consecutive days of task completion
   - Different multipliers for different task types
   - Visual badges and notifications

2. **Smart Task Recommendations**
   - AI-based task suggestions based on user behavior
   - Adaptive difficulty based on completion rates
   - Personalized exercise recommendations

3. **Admin Dashboard**
   - Create/edit task templates
   - View template performance metrics
   - A/B test different task sets

4. **Custom Task Templates**
   - Allow therapists to create custom tasks for clients
   - Assign custom tasks to specific users
   - Track custom task completion separately

5. **Task Notifications**
   - Push notifications for Seeds at specific times
   - Weekly Growth Task reminders
   - Mastery Quest progress updates

6. **Analytics & Reporting**
   - Task completion rates by tier
   - Most/least completed task types
   - User engagement trends
   - Therapist reporting dashboard

---

## Part 10: Key Differences from Current TO-DO.md

### What We Kept ✅
- Core three-tier system (Seeds, Growth Tasks, Mastery Quests)
- Client-side regeneration logic
- Hybrid sync approach (local-first with Firestore sync)
- Multi-device synchronization considerations
- Timezone handling
- Edge case management

### What We Adjusted ✅
1. **Simplified Template Storage**
   - Use bundled templates, not Firebase fetches initially
   - Reduces Firestore reads and complexity
   - Easier to maintain and version-control

2. **ActiveTask Model**
   - Introduced to avoid confusion with raw TodoItem
   - Clearer separation of concerns
   - Better for regeneration tracking

3. **Regeneration Log**
   - Explicit tracking instead of implicit timestamps
   - Easier conflict detection
   - Better audit trail

4. **Implementation Phases**
   - Broken down into manageable 2-week phases
   - Clear dependencies and milestones
   - Easier to review and adjust

5. **Integration Focus**
   - Explicit connections to existing systems
   - Clear mapping to lesson, exercise, journal systems
   - Better EXP integration planning

### What We Added 🆕
- Concrete code examples for key functions
- Firestore structure with specific collection paths
- Timezone service implementation details
- Cost analysis and optimization strategies
- Clear phase breakdown with estimated timelines
- Future enhancements section
- Edge case handling strategies
- Database index recommendations
- Integration points with existing systems

---

## Part 11: Migration Strategy from Current System

Since the auto-todo system was recently removed, here's how to migrate:

### Current State
- Manual TodoItems only
- No tier system
- No templates
- No regeneration

### Migration Path

1. **Data Preservation** ✅
   - Existing todos remain in `todos` collection
   - No data loss
   - Users can continue manually creating tasks

2. **Collection Expansion**
   - Add `activeTasks` (copy and enhance existing todos)
   - Add `taskTemplates` for new functionality
   - Add `regenerationLog` for tracking

3. **Backwards Compatibility**
   - Keep TodoService working with both `todos` and `activeTasks`
   - Phase 1: Run in parallel
   - Phase 2: Gradually migrate users to `activeTasks`
   - Phase 3: Archive old `todos` collection

4. **User Onboarding**
   - Show opt-in message for new task system
   - Migrate existing tasks if user opts in
   - Create initial Seeds, Growth Tasks, Mastery Quests
   - Option to revert if needed

---

## Conclusion

This implementation plan provides a **clear, phased approach** to building a sophisticated task management system while leveraging the existing infrastructure. The system is designed to be:

- **Scalable**: Can handle thousands of users and tasks
- **Efficient**: Minimizes Firestore reads through caching
- **Reliable**: Handles edge cases and multi-device scenarios
- **User-Centric**: Personalizes tasks based on user progress
- **Maintainable**: Clear separation of concerns and modular design

**Recommended Start Date**: Week [X]
**Estimated Total Time**: 8 weeks
**Resource Requirements**: 1-2 developers, 1 QA

---