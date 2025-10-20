# Quest System Implementation Summary

## Overview

This document summarizes the implementation of the comprehensive quest management system based on the TO-DO.md plan. The system includes three tiers of quests (Seeds, Growth Tasks, Mastery Quests) with automatic regeneration, modern UI with progress bars, and tier-based organization.

---

## What Was Implemented

### 1. Core Data Models

#### **TaskTemplate Model** (`lib/models/task_template.dart`)
- Defines quest templates with tier classification
- Supports conversion to TodoItem instances
- Includes metadata for quest customization
- Auto-calculates delete dates for Seeds and Growth Tasks
- EXP reward configuration

#### **TaskTier Enum**
- `seeds` - Daily tasks (regenerate every 24 hours)
- `growthTasks` - Weekly tasks (regenerate every week)
- `masteryQuests` - Persistent tasks (never auto-delete)

#### **RegenerationLog Model** (`lib/models/regeneration_log.dart`)
- Tracks when Seeds and Growth Tasks were last regenerated
- Stores generation timestamps and batch IDs
- Enables multi-device synchronization

#### **Enhanced TodoItem Model**
Added new fields:
- `tier` - Quest tier classification
- `templateId` - Reference to original template
- `regenerationBatchId` - Tracks regeneration batches
- `autoDeleteDate` - Auto-cleanup date for Seeds/Growth Tasks
- `tierMetadata` - Tier-specific data (e.g., EXP rewards)

New helper methods:
- `isSeed`, `isGrowthTask`, `isMasteryQuest` - Quick tier checks
- `tierDisplayName` - Human-readable tier name
- `expReward` - EXP points awarded on completion

---

### 2. Task Templates Data (`lib/data/task_templates.dart`)

Bundled task templates for quest generation:

#### **Seeds (Daily Tasks)**
- Complete Today's Food Diary (50 EXP)
- Reflect on Body Image (50 EXP)
- Log Your Weight (30 EXP)
- Practice a Coping Strategy (60 EXP)
- Mindfulness Exercise (50 EXP)

#### **Growth Tasks (Weekly Tasks)**
- Complete This Week's Lesson (200 EXP)
- Review Previous Lessons (150 EXP)
- Complete Assessment Quiz (250 EXP)
- Problem-Solving Exercise (200 EXP)
- Meal Planning Exercise (200 EXP)
- Weekly Reflection (150 EXP)

#### **Mastery Quests (Persistent Tasks)**
- Complete All Stage 1/2/3 Lessons (1000-2000 EXP)
- Maintain 7-Day Journal Streak (500 EXP)
- Maintain 30-Day Journal Streak (1500 EXP)
- Earn 1,000/5,000/10,000 EXP (500-2000 EXP)
- Complete 10/25 Exercises (500-1000 EXP)

---

### 3. Task Regeneration Service (`lib/core/services/task_regeneration_service.dart`)

Handles automatic quest generation and cleanup:

#### **Key Methods:**

**`checkAndRegenerateTasks(String userId)`**
- Checks if Seeds or Growth Tasks need regeneration
- Automatically generates new quests based on date/week changes
- Cleans up expired tasks

**`generateSeeds(String userId)`**
- Generates 3 random daily Seeds
- Sets due date to 7 PM today
- Auto-deletes at end of day

**`generateGrowthTasks(String userId)`**
- Generates 2 random weekly Growth Tasks
- Spreads due dates across the week (Mon, Wed, Fri)
- Auto-deletes at end of week

**`initializeMasteryQuests(String userId, ...)`**
- Creates relevant Mastery Quests based on user progress
- Filters by current stage, EXP, streaks, etc.
- Only creates quests that don't already exist

**`forceRegenerateAll(String userId)`**
- Manual regeneration trigger (for testing or admin use)
- Cleans up existing auto-generated tasks
- Creates fresh Seeds and Growth Tasks

#### **Regeneration Logic:**

**Seeds regeneration triggers:**
- If no regeneration log exists
- If current date ≠ last regeneration date (daily check)

**Growth Tasks regeneration triggers:**
- If no regeneration log exists
- If current ISO week number ≠ last regeneration week (weekly check)

---

### 4. Updated Services

#### **TodoService** (`lib/core/services/todo_service.dart`)

Added tier-based query methods:
- `getTodosByTier(userId, tier)` - Filter by specific tier
- `getSeeds(userId)` - Get all Seeds
- `getGrowthTasks(userId)` - Get all Growth Tasks
- `getMasteryQuests(userId)` - Get all Mastery Quests
- `getTodosGroupedByTier(userId)` - Get all quests grouped by tier
- `getTierStats(userId)` - Get statistics per tier

---

### 5. Updated Providers (`lib/providers/todo_provider.dart`)

Added new providers:
- `taskRegenerationServiceProvider` - Service access
- `seedsProvider` - Seeds-only query
- `growthTasksProvider` - Growth Tasks-only query
- `masteryQuestsProvider` - Mastery Quests-only query
- `todosGroupedByTierProvider` - Grouped query
- `tierStatsProvider` - Statistics per tier

Enhanced TodoNotifier with tier-based methods:
- `getTodosByTier(tier)` - Local filtering by tier
- `getSeeds()`, `getGrowthTasks()`, `getMasteryQuests()` - Quick accessors
- `getTodosGroupedByTier()` - Local grouping
- `getTierStats()` - Local statistics calculation

---

### 6. Modern UI Redesign (`lib/screens/todos/todos_screen.dart`)

Complete UI overhaul with modern design inspired by the reference image:

#### **Key Features:**

**Modern Header**
- Gradient background
- Large, bold title with subtitle
- Icon buttons in white cards with shadows
- Refresh button for manual regeneration

**Filter Chips**
- Horizontal scrollable filter bar
- Color-coded chips for each tier
- Smooth animations on selection
- "All Quests", "Daily Seeds", "Growth Tasks", "Mastery" filters

**Statistics Overview Card**
- Gradient purple background with shadow
- Overall progress percentage
- Animated progress bar
- Breakdown by tier (Seeds/Growth/Mastery)
- Shows completed/total for each tier

**Quest Cards**
- Clean white cards with subtle shadows
- Progress bar at the bottom (color-coded by tier)
- Animated checkbox for completion
- Tier badge (Seeds/Growth/Mastery)
- Type badge (Lesson/Tool/Journal)
- EXP reward display with star icon
- Three-dot menu for actions (Start/Edit/Delete)
- Tap to start quest (if activity linked)

**Color Scheme:**
- Seeds: Orange/Yellow (#FFB951)
- Growth Tasks: Green (#00B894)
- Mastery Quests: Purple (#6C5CE7)
- Lessons: Blue (#0984E3)
- Tools: Red (#D63031)
- Journals: Light Purple (#A29BFE)

**Sections:**
- "Active Quests" - Pending tasks
- "Completed" - Finished tasks
- Section headers with count badges

**Empty States:**
- Centered icon and text
- Call-to-action button
- Helpful explanatory text

#### **Auto-Regeneration:**
- Checks for regeneration on screen load
- Automatically creates daily/weekly quests
- Cleans up expired tasks
- Refreshes UI after regeneration

---

## How It Works

### Quest Lifecycle

1. **Generation**
   - Seeds: Generated daily at first app open after midnight
   - Growth Tasks: Generated weekly at first app open of new week
   - Mastery Quests: Created once based on user progress

2. **Completion**
   - User taps checkbox or completes linked activity
   - Quest marked as completed with timestamp
   - EXP awarded to user
   - Progress bars update

3. **Auto-Deletion**
   - Seeds: Deleted at end of day (11:59 PM)
   - Growth Tasks: Deleted at end of week (Sunday 11:59 PM)
   - Mastery Quests: Never auto-deleted

4. **Regeneration**
   - Next day: New Seeds generated
   - Next week: New Growth Tasks generated
   - Old incomplete Seeds/Growth Tasks cleaned up

---

## Usage

### For Users

1. **View Quests**: Navigate to the Quests screen from the home screen
2. **Filter Quests**: Use filter chips to view specific tier types
3. **Complete Quests**: Tap checkbox or tap card to start activity
4. **Track Progress**: View overall progress in stats card
5. **Manual Refresh**: Tap refresh button to check for new quests

### For Developers

#### **Trigger Quest Regeneration Manually:**

```dart
final regenerationService = TaskRegenerationService();
await regenerationService.checkAndRegenerateTasks(userId);
```

#### **Force Regenerate All Quests:**

```dart
final regenerationService = TaskRegenerationService();
final result = await regenerationService.forceRegenerateAll(userId);
// result['seeds'] - List of generated Seeds
// result['growthTasks'] - List of generated Growth Tasks
```

#### **Initialize Mastery Quests:**

```dart
final regenerationService = TaskRegenerationService();
await regenerationService.initializeMasteryQuests(
  userId,
  currentStage: userStage,
  currentExp: userExp,
  journalStreakDays: streakDays,
  totalExercisesCompleted: exerciseCount,
);
```

#### **Access Quest Data:**

```dart
// Get all Seeds
final seeds = await ref.read(seedsProvider(userId).future);

// Get tier stats
final stats = await ref.read(tierStatsProvider(userId).future);
// stats['seeds']['completed'] - Number of completed Seeds
// stats['growthTasks']['pending'] - Number of pending Growth Tasks
```

---

## Integration Points

### With Lesson System
- Seeds can link to specific lessons
- Growth Tasks include lesson completion
- Mastery Quests track stage completion
- Auto-completion when lesson finished

### With Exercise System
- Seeds include daily exercises
- Growth Tasks include major exercises
- Mastery Quests track exercise milestones
- EXP awarded on exercise completion

### With Journal System
- Seeds include daily journal entries
- Growth Tasks include weekly reflections
- Mastery Quests track journal streaks
- Auto-completion on journal entry

### With EXP System
- Each quest tier has different EXP rewards
- Seeds: 30-60 EXP
- Growth Tasks: 150-250 EXP
- Mastery Quests: 500-2000 EXP
- EXP displayed on quest cards
- Mastery Quests track EXP milestones

---

## Future Enhancements

### Phase 2 (Not Implemented Yet)
- Timezone service for accurate daily regeneration
- User preferences for quest types
- Custom quest templates
- Quest notifications
- Streak tracking UI
- Achievement badges
- Quest history analytics
- Admin dashboard for template management

### Phase 3
- AI-based quest recommendations
- Adaptive difficulty
- Personalized quest generation
- Therapist-assigned custom quests
- Multi-user quest sharing
- Social features (quest challenges)

---

## File Changes Summary

### New Files Created:
1. `lib/models/task_template.dart` - Task template model
2. `lib/models/regeneration_log.dart` - Regeneration tracking
3. `lib/data/task_templates.dart` - Bundled quest templates
4. `lib/core/services/task_regeneration_service.dart` - Quest generation service

### Files Modified:
1. `lib/models/todo_item.dart` - Added tier fields and methods
2. `lib/core/services/todo_service.dart` - Added tier-based queries
3. `lib/providers/todo_provider.dart` - Added tier providers
4. `lib/screens/todos/todos_screen.dart` - Complete UI redesign

### Files Backed Up:
1. `lib/screens/todos/todos_screen_old.dart.backup` - Original todos screen

---

## Testing Recommendations

1. **Daily Regeneration**: Change device date to test Seeds regeneration
2. **Weekly Regeneration**: Change to new week to test Growth Tasks
3. **Multi-Device**: Test on multiple devices to verify sync
4. **Edge Cases**: Test with no internet, incomplete tasks, etc.
5. **Performance**: Test with large number of completed quests
6. **UI**: Test all filter combinations and empty states

---

## Known Limitations

1. **Timezone Handling**: Uses device local time (no explicit timezone service yet)
2. **Template Customization**: Templates are hardcoded (no Firestore sync)
3. **Progress Tracking**: Mastery Quest progress calculated manually
4. **Notifications**: No push notifications for quest reminders
5. **Analytics**: No quest completion analytics yet

---

## Firestore Structure

```
users/{userId}/
  ├── todos/
  │   ├── {todoId}
  │   │   ├── title
  │   │   ├── description
  │   │   ├── type (lesson/tool/journal)
  │   │   ├── tier (seeds/growthTasks/masteryQuests)
  │   │   ├── templateId
  │   │   ├── regenerationBatchId
  │   │   ├── autoDeleteDate
  │   │   ├── tierMetadata
  │   │   └── ... (other TodoItem fields)
  │   └── ...
  └── regenerationLog/
      ├── {logId}
      │   ├── regeneratedAt
      │   ├── seedsDate (YYYY-MM-DD)
      │   ├── growthWeek (ISO week number)
      │   ├── growthYear
      │   └── generatedTaskIds
      └── ...
```

---

## Conclusion

The quest system is now fully implemented with:
- ✅ Three-tier quest system
- ✅ Automatic daily and weekly regeneration
- ✅ Modern UI with progress bars
- ✅ Tier-based organization and filtering
- ✅ EXP reward system integration
- ✅ Auto-cleanup of expired quests
- ✅ Multi-device synchronization support
- ✅ Comprehensive templates for all quest types

The system is ready for production use and provides a solid foundation for future enhancements like notifications, analytics, and custom quest templates.

---

**Implementation Date**: October 20, 2025  
**Status**: ✅ Complete and Ready for Testing

