import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';

class TodoService {
  static final TodoService _instance = TodoService._internal();
  factory TodoService() => _instance;
  TodoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollectionName = 'users';
  static const String _todosSubcollectionName = 'todos';
  
  // Simple cache to avoid repeated queries
  final Map<String, List<TodoItem>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Get the todos subcollection reference for a user
  CollectionReference _getTodosCollection(String userId) {
    return _firestore
        .collection(_usersCollectionName)
        .doc(userId)
        .collection(_todosSubcollectionName);
  }

  // Create a new todo item
  Future<TodoItem> createTodo({
    required String userId,
    required String title,
    required String description,
    required TodoType type,
    required String activityId,
    Map<String, dynamic>? activityData,
    required DateTime dueDate,
  }) async {
    try {
      final now = DateTime.now();
      
      final todoData = {
        'title': title,
        'description': description,
        'type': type.toString().split('.').last,
        'activityId': activityId,
        'activityData': activityData,
        'dueDate': Timestamp.fromDate(dueDate),
        'isCompleted': false,
        'completedAt': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _getTodosCollection(userId).add(todoData);
      
      // Clear cache since we added a new todo
      _clearCache(userId);
      
      return TodoItem(
        id: docRef.id,
        userId: userId,
        title: title,
        description: description,
        type: type,
        activityId: activityId,
        activityData: activityData,
        dueDate: dueDate,
        isCompleted: false,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw 'Failed to create todo: $e';
    }
  }

  // Get all todos for a specific user
  Future<List<TodoItem>> getUserTodos(String userId) async {
    try {
      // Check cache first
      final cacheTimestamp = _cacheTimestamps[userId];
      if (cacheTimestamp != null && 
          DateTime.now().difference(cacheTimestamp) < _cacheTimeout &&
          _cache.containsKey(userId)) {
        return List.from(_cache[userId]!);
      }
      
      final querySnapshot = await _getTodosCollection(userId).get();

      final todos = querySnapshot.docs
          .map((doc) => TodoItem.fromFirestore(doc, userId: userId))
          .toList();
      
      // Sort by due date in the app
      todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      // Update cache
      _cache[userId] = todos;
      _cacheTimestamps[userId] = DateTime.now();
      
      return todos;
    } catch (e) {
      throw 'Failed to fetch todos: $e';
    }
  }
  
  // Clear cache for a user
  void _clearCache(String userId) {
    _cache.remove(userId);
    _cacheTimestamps.remove(userId);
  }

  // Get todos for a specific user with real-time updates
  Stream<List<TodoItem>> getUserTodosStream(String userId) {
    return _getTodosCollection(userId)
        .snapshots()
        .map((snapshot) {
          final todos = snapshot.docs
              .map((doc) => TodoItem.fromFirestore(doc, userId: userId))
              .toList();
          
          // Sort by due date in the app
          todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          
          return todos;
        });
  }

  // Get pending todos for a user (not completed)
  Future<List<TodoItem>> getPendingTodos(String userId) async {
    try {
      // Use cached data from getUserTodos
      final allTodos = await getUserTodos(userId);
      
      final todos = allTodos
          .where((todo) => !todo.isCompleted)
          .toList();
      
      // Already sorted by getUserTodos
      return todos;
    } catch (e) {
      throw 'Failed to fetch pending todos: $e';
    }
  }

  // Get completed todos for a user
  Future<List<TodoItem>> getCompletedTodos(String userId) async {
    try {
      // Use cached data from getUserTodos
      final allTodos = await getUserTodos(userId);
      
      final todos = allTodos
          .where((todo) => todo.isCompleted)
          .toList();
      
      // Sort by completion date in the app (most recent first)
      todos.sort((a, b) {
        if (a.completedAt == null && b.completedAt == null) return 0;
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
      
      return todos;
    } catch (e) {
      throw 'Failed to fetch completed todos: $e';
    }
  }

  // Get todos due today for a user
  Future<List<TodoItem>> getTodosDueToday(String userId) async {
    try {
      // Use cached data from getUserTodos
      final allTodos = await getUserTodos(userId);

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todos = allTodos
          .where((todo) => 
              !todo.isCompleted &&
              todo.dueDate.isAfter(startOfDay) &&
              todo.dueDate.isBefore(endOfDay))
          .toList();
      
      // Already sorted by getUserTodos
      return todos;
    } catch (e) {
      throw 'Failed to fetch today\'s todos: $e';
    }
  }

  // Get overdue todos for a user
  Future<List<TodoItem>> getOverdueTodos(String userId) async {
    try {
      // Use cached data from getUserTodos
      final allTodos = await getUserTodos(userId);

      final now = DateTime.now();

      final todos = allTodos
          .where((todo) => 
              !todo.isCompleted &&
              todo.dueDate.isBefore(now))
          .toList();
      
      // Already sorted by getUserTodos
      return todos;
    } catch (e) {
      throw 'Failed to fetch overdue todos: $e';
    }
  }

  // Update a todo item
  Future<TodoItem> updateTodo(TodoItem todo) async {
    try {
      final updatedTodo = todo.copyWith(
        updatedAt: DateTime.now(),
      );

      await _getTodosCollection(todo.userId)
          .doc(todo.id)
          .update(updatedTodo.toFirestore());

      // Clear cache since we updated a todo
      _clearCache(todo.userId);

      return updatedTodo;
    } catch (e) {
      throw 'Failed to update todo: $e';
    }
  }

  // Mark todo as completed
  Future<TodoItem> markTodoCompleted(String todoId) async {
    throw 'markTodoCompleted is deprecated. Use markTodoCompletedForUser(userId, todoId) instead.';
  }

  // Mark todo as completed for a specific user
  Future<TodoItem> markTodoCompletedForUser(String userId, String todoId) async {
    try {
      final doc = await _getTodosCollection(userId).doc(todoId).get();
      
      if (!doc.exists) {
        throw 'Todo not found';
      }

      final todo = TodoItem.fromFirestore(doc, userId: userId);
      final now = DateTime.now();
      
      final updatedTodo = todo.copyWith(
        isCompleted: true,
        completedAt: now,
        updatedAt: now,
      );

      await _getTodosCollection(userId)
          .doc(todoId)
          .update({
            'isCompleted': true,
            'completedAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
          });

      // Clear cache since we updated a todo
      _clearCache(userId);

      return updatedTodo;
    } catch (e) {
      throw 'Failed to mark todo as completed: $e';
    }
  }

  // Mark todo as incomplete
  Future<TodoItem> markTodoIncomplete(String todoId) async {
    throw 'markTodoIncomplete is deprecated. Use markTodoIncompleteForUser(userId, todoId) instead.';
  }

  // Mark todo as incomplete for a specific user
  Future<TodoItem> markTodoIncompleteForUser(String userId, String todoId) async {
    try {
      final doc = await _getTodosCollection(userId).doc(todoId).get();
      
      if (!doc.exists) {
        throw 'Todo not found';
      }

      final todo = TodoItem.fromFirestore(doc, userId: userId);
      
      final now = DateTime.now();
      
      final updatedTodo = todo.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: now,
      );

      await _getTodosCollection(userId)
          .doc(todoId)
          .update({
            'isCompleted': false,
            'completedAt': null,
            'updatedAt': Timestamp.fromDate(now),
          });

      // Clear cache since we updated a todo
      _clearCache(userId);

      return updatedTodo;
    } catch (e) {
      throw 'Failed to mark todo as incomplete: $e';
    }
  }

  // Delete a todo item
  Future<void> deleteTodo(String todoId) async {
    throw 'deleteTodo is deprecated. Use deleteTodoForUser(userId, todoId) instead.';
  }

  // Delete a todo item for a specific user
  Future<void> deleteTodoForUser(String userId, String todoId) async {
    try {
      await _getTodosCollection(userId).doc(todoId).delete();
      // Clear cache since we deleted a todo
      _clearCache(userId);
    } catch (e) {
      throw 'Failed to delete todo: $e';
    }
  }

  // Get a specific todo by ID
  Future<TodoItem?> getTodoById(String todoId) async {
    throw 'getTodoById is deprecated. Use getTodoByIdForUser(userId, todoId) instead.';
  }

  // Get a specific todo by ID for a specific user
  Future<TodoItem?> getTodoByIdForUser(String userId, String todoId) async {
    try {
      final doc = await _getTodosCollection(userId).doc(todoId).get();
      
      if (doc.exists) {
        return TodoItem.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch todo: $e';
    }
  }

  // Check if user has todo for specific activity
  Future<bool> hasActivityTodo(String userId, String activityId, TodoType type) async {
    try {
      // Use cached data from getUserTodos
      final allTodos = await getUserTodos(userId);

      // Filter in the app to avoid complex index requirements
      final hasActivity = allTodos.any((todo) {
        return todo.activityId == activityId && 
               todo.type == type && 
               !todo.isCompleted;
      });

      return hasActivity;
    } catch (e) {
      throw 'Failed to check activity todo: $e';
    }
  }

  // Get todo count for user
  Future<Map<String, int>> getTodoCount(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      
      int completed = 0;
      int pending = 0;
      int overdue = 0;
      int dueToday = 0;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final todo in allTodos) {
        if (todo.isCompleted) {
          completed++;
        } else {
          pending++;
          
          final dueDate = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
          
          if (dueDate.isBefore(today)) {
            overdue++;
          } else if (dueDate.isAtSameMomentAs(today)) {
            dueToday++;
          }
        }
      }
      
      return {
        'total': allTodos.length,
        'completed': completed,
        'pending': pending,
        'overdue': overdue,
        'dueToday': dueToday,
      };
    } catch (e) {
      throw 'Failed to get todo count: $e';
    }
  }

  // Mark todo as completed by activity ID and type (for auto-completion when user accesses activity)
  Future<TodoItem?> markTodoCompletedByActivity(String userId, String activityId, TodoType type) async {
    try {
      // Use cached data from getUserTodos to find the matching todo
      final allTodos = await getUserTodos(userId);
      
      // Find the first pending todo with matching activityId and type
      final matchingTodo = allTodos.firstWhere(
        (todo) => todo.activityId == activityId && 
                  todo.type == type && 
                  !todo.isCompleted,
        orElse: () => throw 'No matching pending todo found',
      );
      
      // Mark it as completed
      return await markTodoCompletedForUser(userId, matchingTodo.id);
    } catch (e) {
      // If no matching todo is found, return null instead of throwing
      if (e.toString().contains('No matching pending todo found')) {
        return null;
      }
      throw 'Failed to mark todo as completed by activity: $e';
    }
  }
}
