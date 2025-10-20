# To-Do List System Documentation

## Overview

The to-do list system in this Flutter app is a comprehensive task management system that automatically creates, manages, and tracks user tasks based on their progress through the binge eating recovery program. The system combines manual task creation with intelligent auto-assignment based on user progress.

## Architecture

### Core Components

1. **TodoItem Model** (`lib/models/todo_item.dart`)
2. **TodoService** (`lib/core/services/todo_service.dart`)
3. **AutoTodoService** (`lib/core/services/auto_todo_service.dart`)
4. **TodoProvider** (`lib/providers/todo_provider.dart`)
5. **AutoTodoProvider** (`lib/providers/auto_todo_provider.dart`)
6. **UI Screens** (`lib/screens/todos/`)

## Data Model

### TodoItem Class

```dart
class TodoItem {
  final String id;                    // Unique identifier
  final String userId;                // User who owns the todo
  final String title;                 // Task title
  final String description;           // Task description
  final TodoType type;                // Type: lesson, tool, or journal
  final String activityId;            // ID of the specific activity
  final Map<String, dynamic>? activityData; // Additional activity metadata
  final DateTime dueDate;             // When the task is due
  final bool isCompleted;             // Completion status
  final DateTime? completedAt;        // When it was completed
  final DateTime createdAt;           // Creation timestamp
  final DateTime updatedAt;           // Last update timestamp
}
```

### TodoType Enum

```dart
enum TodoType {
  lesson,    // Educational lessons
  tool,      // Recovery tools/exercises
  journal,   // Journaling activities
}
```

## Database Structure

### Firestore Collections

```
users/{userId}/todos/{todoId}
```

Each todo document contains:
- `title`: String
- `description`: String
- `type`: String (enum as string)
- `activityId`: String
- `activityData`: Map<String, dynamic>
- `dueDate`: Timestamp
- `isCompleted`: Boolean
- `completedAt`: Timestamp (nullable)
- `createdAt`: Timestamp
- `updatedAt`: Timestamp

## Service Layer

### TodoService

**Purpose**: Handles all CRUD operations for todos

**Key Methods**:
- `createTodo()` - Creates a new todo
- `getUserTodos()` - Gets all todos for a user
- `updateTodo()` - Updates an existing todo
- `markTodoCompletedForUser()` - Marks todo as completed
- `markTodoIncompleteForUser()` - Marks todo as incomplete
- `deleteTodoForUser()` - Deletes a todo
- `markTodoCompletedByActivity()` - Auto-completes todo when activity is accessed

**Features**:
- 5-minute caching system to reduce Firestore reads
- Automatic cache invalidation on updates
- Error handling with descriptive messages

### AutoTodoService

**Purpose**: Automatically creates and manages todos based on user progress

**Key Methods**:
- `initializeUserTodos()` - Main initialization method
- `markLessonCompleted()` - Handles lesson completion
- `_assignChapterTodos()` - Creates todos for lessons
- `_assignDailyJournalTodos()` - Creates daily journal tasks
- `_assignFutureChapters()` - Pre-plans future tasks
- `_rescaleOverdueTodos()` - Moves overdue tasks to today

**Auto-Assignment Logic**:

1. **Lesson Todos**: Created based on user's current stage/chapter progress
2. **Journal Todos**: 3 daily tasks (food diary, body image diary, weight diary)
3. **Future Planning**: Pre-assigns tasks for next 14 days
4. **Overdue Management**: Automatically moves overdue tasks to today

## State Management

### TodoProvider

Uses Riverpod for state management with multiple providers:

- `todoServiceProvider` - Service instance
- `userTodosProvider` - All user todos with StateNotifier
- `pendingTodosProvider` - Pending todos only
- `completedTodosProvider` - Completed todos only
- `todayTodosProvider` - Today's todos
- `overdueTodosProvider` - Overdue todos
- `todoCountProvider` - Todo statistics
- `userTodosStreamProvider` - Real-time updates

### AutoTodoProvider

Manages auto-todo initialization state:
- `autoTodoServiceProvider` - Service instance
- `autoTodoInitializationProvider` - Initialization state

## UI Components

### AddTodoScreen

**Purpose**: Manual todo creation interface

**Features**:
- Tabbed interface for different todo types
- Activity selection from available lessons/tools/journal
- Custom title and description editing
- Due date picker
- Form validation

**Todo Type Tabs**:
1. **Lessons**: Shows available lessons from Stage 1 data
2. **Tools**: Shows available recovery tools/exercises
3. **Journal**: Shows journal activity types

### TodosScreen

**Purpose**: Main todo management interface

**Features**:
- Summary statistics cards
- Tabbed view (Pending/Completed)
- Todo item cards with completion checkboxes
- Context menus for actions
- Auto-navigation to activities
- Delete confirmation dialogs

### TodoSection (Home Screen)

**Purpose**: Compact todo overview on home screen

**Features**:
- Today's date display
- Task completion progress
- Compact todo list (shows first 2 tasks)
- Quick navigation to full todo screen

## Auto-Assignment System

### Initialization Process

1. **App Startup**: `AppInitializationService` calls `AutoTodoService.initializeUserTodos()`
2. **Progress Calculation**: Determines user's current stage/chapter based on completed lessons
3. **Overdue Management**: Moves any overdue todos to today
4. **Todo Assignment**: Creates appropriate todos for current progress
5. **Future Planning**: Pre-assigns tasks for next 2 weeks

### Assignment Rules

#### Lesson Todos
- Created for lessons in current chapter
- Skipped if already completed
- Due date set to today for current chapter
- Future chapters assigned with appropriate due dates

#### Journal Todos
- 3 daily tasks: food diary, body image diary, weight diary
- Unique activity IDs include date (e.g., `food_diary_20241201`)
- Due date set to specific day
- Recreated daily

#### Future Planning
- Plans 14 days ahead
- Maintains proper chapter progression
- Includes both lessons and journal tasks

### Auto-Completion

When users access activities through todos:
1. `NavigationService.navigateToTodoActivity()` is called
2. Todo is automatically marked as completed
3. For lessons, progress is updated in `user_progress` collection
4. Auto-todo system refreshes to create next tasks

## Caching Strategy

### TodoService Caching
- **Duration**: 5 minutes
- **Scope**: Per-user
- **Invalidation**: On any write operation
- **Benefits**: Reduces Firestore reads, improves performance

### AutoTodoService Caching
- **Stages Data**: Cached in memory to avoid repeated instantiation
- **User Progress**: Calculated fresh each time for accuracy

## Error Handling

### Service Level
- All service methods include try-catch blocks
- Errors are logged but don't interrupt user experience
- Graceful degradation when services fail

### UI Level
- Loading states for async operations
- Error states with retry options
- User-friendly error messages

## Integration Points

### App Initialization
- Called during app startup via `AppInitializationService`
- Runs in background to avoid blocking UI
- Only initializes once per user session

### Lesson Completion
- Integrated with lesson completion flow
- Automatically updates todos when lessons are completed
- Triggers progression to next chapter

### Navigation
- `NavigationService` handles todo-to-activity navigation
- Auto-completion on activity access
- Seamless user experience

## Performance Considerations

### Database Optimization
- Efficient Firestore queries with proper indexing
- Caching to reduce read operations
- Batch operations where possible

### UI Optimization
- RepaintBoundary for todo lists
- Efficient list rendering with proper keys
- Lazy loading for large todo lists

### Memory Management
- Proper disposal of controllers and listeners
- Cache cleanup on user logout
- Efficient data structures

## Future Enhancements

### Potential Improvements
1. **Smart Scheduling**: AI-based due date suggestions
2. **Priority System**: User-defined task priorities
3. **Recurring Tasks**: Daily/weekly recurring todos
4. **Notifications**: Push notifications for due tasks
5. **Analytics**: Task completion analytics and insights
6. **Custom Categories**: User-defined todo categories
7. **Bulk Operations**: Select multiple todos for actions
8. **Export/Import**: Todo data backup and restore

### Technical Debt
1. **Deprecated Methods**: Some methods marked as deprecated need removal
2. **Error Handling**: Could be more granular in some areas
3. **Testing**: More comprehensive unit and integration tests needed
4. **Documentation**: Some complex logic could use more inline documentation

## Usage Examples

### Creating a Manual Todo
```dart
final todo = await ref.read(userTodosProvider(userId).notifier).createTodo(
  title: 'Custom Task',
  description: 'User-defined task',
  type: TodoType.tool,
  activityId: 'custom_tool',
  activityData: {'custom': true},
  dueDate: DateTime.now().add(Duration(days: 1)),
);
```

### Auto-Initializing Todos
```dart
await ref.read(autoTodoInitializationProvider(userId).notifier).initializeTodos();
```

### Marking Todo as Completed
```dart
await ref.read(userTodosProvider(userId).notifier).toggleCompletion(todoId);
```

### Accessing Activity from Todo
```dart
NavigationService().navigateToTodoActivity(context, todo, ref);
```

## Conclusion

The to-do list system provides a comprehensive task management solution that balances automation with user control. The auto-assignment feature ensures users always have relevant tasks based on their progress, while manual creation allows for customization. The system is designed to be performant, user-friendly, and maintainable.
