# Quest Completion Implementation Strategy

## Overview
This document outlines how the todo/quest system connects to actual user activities (lessons, tools, journals) to detect completion and update both backend and UI in real-time.

## Current Architecture

### 1. Quest Generation System
- **Seeds (Daily Tasks)**: Generated daily at 12:00 AM UTC, 3 random tasks from templates
- **Growth Tasks (Weekly)**: Generated weekly (Monday), 2 tasks spread across Mon/Wed/Fri
- **Mastery Quests**: Long-term persistent tasks
- Tasks auto-regenerate to clear incomplete quests each day/week

### 2. Quest Models
- **TodoItem**: Represents a quest with:
  - `activityId`: Links to actual lesson/tool/journal ID
  - `type`: TodoType.lesson, .tool, or .journal
  - `isCompleted`: Whether quest is marked complete
  - `tier`: Seeds, GrowthTasks, MasteryQuests

### 3. Current Quest Completion Flow
When user clicks a quest card:
1. `TodosScreen` calls `NavigationService.navigateToTodoActivity(todo, ref)`
2. NavigationService automatically marks todo as completed via `markCompletedByActivity(activityId, type)`
3. This calls `TodoService.markTodoCompletedByActivity()` which:
   - Finds matching pending todo by activityId + type
   - Marks it as completed in Firestore
   - Updates UI via stream provider

**PROBLEM**: Completion happens when user navigates TO the activity, not when they actually COMPLETE it.

## New Implementation

### Key Changes Needed

#### 1. Keep Auto-Completion on Navigation
- When user clicks quest → navigate and mark todo as "started"
- This prevents quest from being triggered multiple times

#### 2. Add Activity Completion Detection
- Each activity screen (lesson, tool, journal) has a completion point
- When activity completes, check if there's a matching pending todo
- If yes, mark todo fully completed + trigger congratulation

#### 3. Real-Time UI Updates
- Use Firestore stream providers for real-time updates
- TodosScreen listens to userTodosStreamProvider
- When todo completion changes, UI updates automatically

### Implementation Steps

#### Phase 1: Quest Completion Callback
Create a service to handle quest completion events:
```dart
// lib/core/services/quest_completion_service.dart
class QuestCompletionService {
  // Called when user completes any activity (lesson, tool, journal)
  Future<QuestCompletionResult> handleActivityCompletion({
    required String userId,
    required String activityId,
    required TodoType type,
  })
  
  // Returns: completed quest + EXP awarded + streak updates
}
```

#### Phase 2: Congratulation System
Create a widget that shows congratulation on quest completion:
```dart
// lib/widgets/quest_completion_dialog.dart
- Shows quest title and EXP awarded
- Plays celebration animation
- Updates streak if applicable
- Dismissible with "Continue" button
```

#### Phase 3: Integration Points
Update all activity completion points:
- **Lessons**: After `_finishLesson()` 
- **Tools**: After completing tool exercises
- **Journal**: After submitting journal entries

#### Phase 4: Real-Time Updates
- Ensure TodosScreen listens to real-time updates
- When quest completion changes in Firestore, UI updates immediately
- Show completed badge/animation

## Expected User Experience

1. User opens TodosScreen → sees pending quests
2. User clicks quest card → navigates to activity (quest marked as "started")
3. User completes activity (finishes lesson, submits journal, etc)
4. Congratulation dialog appears with:
   - "Quest Completed!" message
   - EXP awarded
   - Streak count (if applicable)
5. Dialog closes → todo shows as completed in list
6. TodosScreen updates in real-time via Firestore stream

## Data Flow Diagram

```
User Clicks Quest
    ↓
NavigationService marks todo as "started" (auto-complete on nav)
    ↓
User navigates to activity screen (lesson/tool/journal)
    ↓
User completes activity (submits form, finishes lesson, etc)
    ↓
Activity screen calls QuestCompletionService.handleActivityCompletion()
    ↓
Service marks todo as "completed" in Firestore
    ↓
Service awards EXP to user
    ↓
Service updates streak if needed
    ↓
Congratulation dialog shown with results
    ↓
TodosScreen listens to stream and updates UI
    ↓
Quest shows as completed in list
```

## Files to Create
1. `lib/core/services/quest_completion_service.dart` - Main completion handler
2. `lib/widgets/quest_completion_dialog.dart` - Congratulation UI
3. `lib/models/quest_completion_result.dart` - Data class for completion result

## Files to Modify
1. `lib/core/services/navigation_service.dart` - Track quest starting
2. Activity screens (lessons, tools, journals) - Call completion handler
3. `lib/providers/todo_provider.dart` - Add completion result handler (optional)
4. `lib/screens/todos/todos_screen.dart` - Ensure real-time updates visible
