import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/task_template.dart';

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

  /// Public method to clear cache for a user
  /// Call this when you need fresh data from Firestore
  void clearUserCache(String userId) {
    _clearCache(userId);
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


  Future<TodoItem> _markTodoCompletedForUser(String userId, String todoId) async {
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

  // Public method for external services to mark todo as completed
  Future<void> markTodoCompleted(String userId, String todoId) async {
    await _markTodoCompletedForUser(userId, todoId);
  }
  // Delete a todo item


  // Delete a todo item for a specific user (internal use for system operations)
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
      // This now supports both exact matches and "acceptsAny" quests
      final matchingTodo = allTodos.firstWhere(
        (todo) {
          if (todo.isCompleted || todo.type != type) return false;
          
          // Check for exact activityId match
          if (todo.activityId == activityId) return true;
          
          // Check if this is an "acceptsAny" quest that includes this activity
          final metadata = todo.tierMetadata;
          if (metadata != null && metadata['acceptsAny'] == true) {
            final validActivities = metadata['validActivities'];
            if (validActivities is List && validActivities.contains(activityId)) {
              return true;
            }
          }
          
          return false;
        },
        orElse: () => throw 'No matching pending todo found',
      );
      
      // Mark it as completed
      return await _markTodoCompletedForUser(userId, matchingTodo.id);
    } catch (e) {
      // If no matching todo is found, return null instead of throwing
      if (e.toString().contains('No matching pending todo found')) {
        return null;
      }
      throw 'Failed to mark todo as completed by activity: $e';
    }
  }

  // Tier-based query methods
  
  /// Get todos by tier
  Future<List<TodoItem>> getTodosByTier(String userId, TaskTier tier) async {
    try {
      final allTodos = await getUserTodos(userId);
      return allTodos.where((todo) => todo.tier == tier).toList();
    } catch (e) {
      throw 'Failed to fetch todos by tier: $e';
    }
  }

  /// Get Seeds (daily tasks)
  Future<List<TodoItem>> getSeeds(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      return allTodos.where((todo) => todo.tier == TaskTier.seeds).toList();
    } catch (e) {
      throw 'Failed to fetch seeds: $e';
    }
  }

  /// Get Growth Tasks (weekly tasks)
  Future<List<TodoItem>> getGrowthTasks(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      return allTodos.where((todo) => todo.tier == TaskTier.growthTasks).toList();
    } catch (e) {
      throw 'Failed to fetch growth tasks: $e';
    }
  }

  /// Get Mastery Quests (persistent tasks)
  Future<List<TodoItem>> getMasteryQuests(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      return allTodos.where((todo) => todo.tier == TaskTier.masteryQuests).toList();
    } catch (e) {
      throw 'Failed to fetch mastery quests: $e';
    }
  }

  /// Get tasks grouped by tier
  Future<Map<String, List<TodoItem>>> getTodosGroupedByTier(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      
      return {
        'seeds': allTodos.where((todo) => todo.tier == TaskTier.seeds).toList(),
        'growthTasks': allTodos.where((todo) => todo.tier == TaskTier.growthTasks).toList(),
        'masteryQuests': allTodos.where((todo) => todo.tier == TaskTier.masteryQuests).toList(),
        'other': allTodos.where((todo) => todo.tier == null).toList(),
      };
    } catch (e) {
      throw 'Failed to group todos by tier: $e';
    }
  }

  /// Get tier statistics
  Future<Map<String, Map<String, int>>> getTierStats(String userId) async {
    try {
      final allTodos = await getUserTodos(userId);
      
      final stats = <String, Map<String, int>>{
        'seeds': {'total': 0, 'completed': 0, 'pending': 0},
        'growthTasks': {'total': 0, 'completed': 0, 'pending': 0},
        'masteryQuests': {'total': 0, 'completed': 0, 'pending': 0},
        'other': {'total': 0, 'completed': 0, 'pending': 0},
      };
      
      for (final todo in allTodos) {
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
    } catch (e) {
      throw 'Failed to get tier stats: $e';
    }
  }
}
