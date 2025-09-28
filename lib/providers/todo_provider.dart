import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../core/services/todo_service.dart';
import '../core/services/firebase_analytics_service.dart';

// Todo service provider
final todoServiceProvider = Provider<TodoService>((ref) => TodoService());

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
}
