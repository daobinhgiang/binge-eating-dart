import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../models/task_template.dart';
import '../core/services/todo_service.dart';
import '../core/services/firebase_analytics_service.dart';
import '../core/services/task_regeneration_service.dart';

// Services providers
final todoServiceProvider = Provider<TodoService>((ref) => TodoService());
final taskRegenerationServiceProvider = Provider<TaskRegenerationService>((ref) => TaskRegenerationService());

// All user todos provider
final userTodosProvider = StateNotifierProvider.family<TodoNotifier, AsyncValue<List<TodoItem>>, String>((ref, userId) {
  return TodoNotifier(ref.read(todoServiceProvider), userId);
});

// Pending todos provider
final pendingTodosProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getPendingTodos(userId);
});

// Completed todos provider
final completedTodosProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getCompletedTodos(userId);
});

// Today's todos provider
final todayTodosProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getTodosDueToday(userId);
});

// Overdue todos provider
final overdueTodosProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getOverdueTodos(userId);
});

// Todo count provider
final todoCountProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getTodoCount(userId);
});

// Individual todo provider
final todoByIdProvider = FutureProvider.family<TodoItem?, ({String userId, String todoId})>((ref, params) async {
  final service = ref.read(todoServiceProvider);
  return await service.getTodoByIdForUser(params.userId, params.todoId);
});

// Check if activity has todo provider
final hasActivityTodoProvider = FutureProvider.family<bool, ({String userId, String activityId, TodoType type})>((ref, params) async {
  final service = ref.read(todoServiceProvider);
  return await service.hasActivityTodo(params.userId, params.activityId, params.type);
});

// User todos stream provider for real-time updates
final userTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId);
});

// Seeds stream provider (daily tasks) - real-time updates
final seedsStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) =>
    todos.where((todo) => todo.tier == TaskTier.seeds).toList()
  );
});

// Growth tasks stream provider (weekly tasks) - real-time updates
final growthTasksStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) =>
    todos.where((todo) => todo.tier == TaskTier.growthTasks).toList()
  );
});

// Mastery quests stream provider (persistent tasks) - real-time updates
final masteryQuestsStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) =>
    todos.where((todo) => todo.tier == TaskTier.masteryQuests).toList()
  );
});

// Today's todos stream provider - real-time updates
final todayTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return todos.where((todo) {
      final due = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return today.isAtSameMomentAs(due);
    }).toList();
  });
});

// Pending todos stream provider - real-time updates
final pendingTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) =>
    todos.where((todo) => !todo.isCompleted).toList()
  );
});

// Completed todos stream provider - real-time updates
final completedTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) {
    final completed = todos.where((todo) => todo.isCompleted).toList();
    // Sort by completion date (most recent first)
    completed.sort((a, b) {
      if (a.completedAt == null && b.completedAt == null) return 0;
      if (a.completedAt == null) return 1;
      if (b.completedAt == null) return -1;
      return b.completedAt!.compareTo(a.completedAt!);
    });
    return completed;
  });
});

// Overdue todos stream provider - real-time updates
final overdueTodosStreamProvider = StreamProvider.family<List<TodoItem>, String>((ref, userId) {
  final service = ref.read(todoServiceProvider);
  return service.getUserTodosStream(userId).map((todos) {
    final now = DateTime.now();
    return todos.where((todo) => 
      !todo.isCompleted &&
      todo.dueDate.isBefore(now)
    ).toList();
  });
});

// Tier-based providers

// Seeds provider (daily tasks)
final seedsProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getSeeds(userId);
});

// Growth tasks provider (weekly tasks)
final growthTasksProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getGrowthTasks(userId);
});

// Mastery quests provider (persistent tasks)
final masteryQuestsProvider = FutureProvider.family<List<TodoItem>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getMasteryQuests(userId);
});

// Grouped todos by tier provider
final todosGroupedByTierProvider = FutureProvider.family<Map<String, List<TodoItem>>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getTodosGroupedByTier(userId);
});

// Tier statistics provider
final tierStatsProvider = FutureProvider.family<Map<String, Map<String, int>>, String>((ref, userId) async {
  final service = ref.read(todoServiceProvider);
  return await service.getTierStats(userId);
});

class TodoNotifier extends StateNotifier<AsyncValue<List<TodoItem>>> {
  final TodoService _todoService;
  final String _userId;
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();

  TodoNotifier(this._todoService, this._userId) : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      state = const AsyncValue.loading();
      final todos = await _todoService.getUserTodos(_userId);
      state = AsyncValue.data(todos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<TodoItem?> createTodo({
    required String title,
    required String description,
    required TodoType type,
    required String activityId,
    Map<String, dynamic>? activityData,
    required DateTime dueDate,
  }) async {
    try {
      final todo = await _todoService.createTodo(
        userId: _userId,
        title: title,
        description: description,
        type: type,
        activityId: activityId,
        activityData: activityData,
        dueDate: dueDate,
      );

      // Refresh current state
      await loadTodos();
      
      return todo;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> updateTodo(TodoItem todo) async {
    try {
      await _todoService.updateTodo(todo);
      
      // Refresh current state
      await loadTodos();
      
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> markCompleted(String todoId) async {
    try {
      await _todoService.markTodoCompletedForUser(_userId, todoId);
      
      // Track todo completion
      await _analytics.trackTodoCompletion();
      
      // Refresh current state
      await loadTodos();
      
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> markIncomplete(String todoId) async {
    try {
      await _todoService.markTodoIncompleteForUser(_userId, todoId);
      
      // Refresh current state
      await loadTodos();
      
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteTodo(String todoId) async {
    try {
      await _todoService.deleteTodoForUser(_userId, todoId);
      
      // Refresh current state
      await loadTodos();
      
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> refreshTodos() async {
    await loadTodos();
  }

  // Toggle completion status
  Future<bool> toggleCompletion(String todoId) async {
    try {
      final currentTodos = state.value ?? [];
      final todo = currentTodos.firstWhere((t) => t.id == todoId);
      
      if (todo.isCompleted) {
        return await markIncomplete(todoId);
      } else {
        return await markCompleted(todoId);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Check if user has todo for specific activity
  Future<bool> hasActivityTodo(String activityId, TodoType type) async {
    try {
      return await _todoService.hasActivityTodo(_userId, activityId, type);
    } catch (e) {
      return false;
    }
  }

  // Get todo statistics
  Future<Map<String, int>> getTodoStats() async {
    try {
      return await _todoService.getTodoCount(_userId);
    } catch (e) {
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'overdue': 0,
        'dueToday': 0,
      };
    }
  }

  // Filter todos by type
  List<TodoItem> getTodosByType(TodoType type) {
    final todos = state.value ?? [];
    return todos.where((todo) => todo.type == type).toList();
  }

  // Filter todos by completion status
  List<TodoItem> getTodosByStatus(bool isCompleted) {
    final todos = state.value ?? [];
    return todos.where((todo) => todo.isCompleted == isCompleted).toList();
  }

  // Get upcoming todos (due within next 7 days)
  List<TodoItem> getUpcomingTodos() {
    final todos = state.value ?? [];
    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));
    
    return todos.where((todo) => 
      !todo.isCompleted && 
      todo.dueDate.isAfter(now) && 
      todo.dueDate.isBefore(oneWeekFromNow)
    ).toList();
  }

  // Get today's todos
  List<TodoItem> getTodayTodos() {
    final todos = state.value ?? [];
    return todos.where((todo) => todo.isDueToday && !todo.isCompleted).toList();
  }

  // Get overdue todos
  List<TodoItem> getOverdueTodos() {
    final todos = state.value ?? [];
    return todos.where((todo) => todo.isOverdue).toList();
  }

  // Mark todo as completed by activity ID and type (for auto-completion)
  Future<TodoItem?> markCompletedByActivity(String activityId, TodoType type) async {
    try {
      final completedTodo = await _todoService.markTodoCompletedByActivity(_userId, activityId, type);
      
      if (completedTodo != null) {
        // Refresh current state
        await loadTodos();
      }
      
      return completedTodo;
    } catch (e) {
      // Don't update state with error for this operation since it's background
      return null;
    }
  }

  // Tier-based methods
  
  /// Get tasks by tier
  List<TodoItem> getTodosByTier(TaskTier tier) {
    final todos = state.value ?? [];
    return todos.where((todo) => todo.tier == tier).toList();
  }

  /// Get Seeds (daily tasks)
  List<TodoItem> getSeeds() {
    return getTodosByTier(TaskTier.seeds);
  }

  /// Get Growth Tasks (weekly tasks)
  List<TodoItem> getGrowthTasks() {
    return getTodosByTier(TaskTier.growthTasks);
  }

  /// Get Mastery Quests (persistent tasks)
  List<TodoItem> getMasteryQuests() {
    return getTodosByTier(TaskTier.masteryQuests);
  }

  /// Get tasks grouped by tier
  Map<String, List<TodoItem>> getTodosGroupedByTier() {
    final todos = state.value ?? [];
    return {
      'seeds': todos.where((todo) => todo.tier == TaskTier.seeds).toList(),
      'growthTasks': todos.where((todo) => todo.tier == TaskTier.growthTasks).toList(),
      'masteryQuests': todos.where((todo) => todo.tier == TaskTier.masteryQuests).toList(),
      'other': todos.where((todo) => todo.tier == null).toList(),
    };
  }

  /// Get tier statistics
  Map<String, Map<String, int>> getTierStats() {
    final todos = state.value ?? [];
    final stats = <String, Map<String, int>>{
      'seeds': {'total': 0, 'completed': 0, 'pending': 0},
      'growthTasks': {'total': 0, 'completed': 0, 'pending': 0},
      'masteryQuests': {'total': 0, 'completed': 0, 'pending': 0},
      'other': {'total': 0, 'completed': 0, 'pending': 0},
    };
    
    for (final todo in todos) {
      String tierKey;
      if (todo.tier == TaskTier.seeds) {
        tierKey = 'seeds';
      } else if (todo.tier == TaskTier.growthTasks) {
        tierKey = 'growthTasks';
      } else if (todo.tier == TaskTier.masteryQuests) {
        tierKey = 'masteryQuests';
      } else {
        tierKey = 'other';
      }
      
      stats[tierKey]!['total'] = (stats[tierKey]!['total'] ?? 0) + 1;
      if (todo.isCompleted) {
        stats[tierKey]!['completed'] = (stats[tierKey]!['completed'] ?? 0) + 1;
      } else {
        stats[tierKey]!['pending'] = (stats[tierKey]!['pending'] ?? 0) + 1;
      }
    }
    
    return stats;
  }
}
