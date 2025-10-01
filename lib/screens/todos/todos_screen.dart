import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/auto_todo_provider.dart';
import '../../models/todo_item.dart';
import '../../core/services/navigation_service.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to detect auto-assigned todos
  bool _isAutoAssignedTodo(TodoItem todo) {
    // Auto-assigned todos have specific patterns:
    // 1. Lessons from stage data (lesson_1_*, lesson_s2_*, lesson_s3_*)
    // 2. Daily journal tasks with timestamp in activityId
    // 3. Have activityData with 'type' field
    
    if (todo.activityData != null && todo.activityData!.containsKey('type')) {
      return true;
    }
    
    // Check for lesson patterns
    if (todo.type == TodoType.lesson && (
        todo.activityId.startsWith('lesson_1_') ||
        todo.activityId.startsWith('lesson_s2_') ||
        todo.activityId.startsWith('lesson_s3_')
    )) {
      return true;
    }
    
    // Check for journal patterns with timestamps
    if (todo.type == TodoType.journal && (
        todo.activityId.contains('food_diary_') ||
        todo.activityId.contains('body_image_diary_') ||
        todo.activityId.contains('weight_diary_')
    )) {
      return true;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userTodosAsync = ref.watch(userTodosProvider(user.id));
    final todoStatsAsync = ref.watch(todoCountProvider(user.id));
    final autoTodoState = ref.watch(autoTodoInitializationProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('To-Do List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(userTodosProvider(user.id).notifier).refreshTodos();
              await ref.read(autoTodoInitializationProvider(user.id).notifier).refreshTodos();
            },
            icon: autoTodoState.isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTodosTab(userTodosAsync, user.id),
          _buildCompletedTodosTab(userTodosAsync, user.id),
          _buildOverviewTab(todoStatsAsync, userTodosAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/todos/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Custom Task'),
      ),
    );
  }

  Widget _buildPendingTodosTab(AsyncValue<List<TodoItem>> todosAsync, String userId) {
    return todosAsync.when(
      data: (todos) {
        final pendingTodos = todos.where((todo) => !todo.isCompleted).toList();
        
        if (pendingTodos.isEmpty) {
          return _buildEmptyState(
            icon: Icons.task_alt,
            title: 'No pending tasks',
            subtitle: 'All caught up! Your lessons and journal tasks are automatically assigned based on your progress.',
            actionText: 'Add Custom Task',
            onAction: () => context.go('/todos/add'),
          );
        }

        // Group todos by status - with smart scaling, there should be no overdue todos
        // We're keeping the structure but all todos will be either due today or upcoming
        final dueTodayTodos = pendingTodos.where((todo) => todo.isDueToday).toList();
        final upcomingTodos = pendingTodos.where((todo) => !todo.isDueToday).toList();

        // Group upcoming todos by their due dates
        final upcomingTodosByDate = <DateTime, List<TodoItem>>{};
        for (final todo in upcomingTodos) {
          final dueDate = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
          upcomingTodosByDate.putIfAbsent(dueDate, () => []).add(todo);
        }

        // Sort the dates
        final sortedDates = upcomingTodosByDate.keys.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              if (dueTodayTodos.isNotEmpty) ...[
                _buildSectionHeader(context, 'Due Today', dueTodayTodos.length, Colors.orange),
                const SizedBox(height: 8),
                ..._sortTodosByPriority(dueTodayTodos).map((todo) => _buildTodoCard(context, todo, userId)),
                const SizedBox(height: 24),
              ],
              
              // Show upcoming todos grouped by date
              ...sortedDates.map((date) {
                final todosForDate = upcomingTodosByDate[date]!;
                // Sort todos within each date: Journal first, then Lessons
                final sortedTodosForDate = _sortTodosByPriority(todosForDate);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUpcomingSectionHeader(context, date, todosForDate.length),
                    const SizedBox(height: 8),
                    ...sortedTodosForDate.map((todo) => _buildTodoCard(context, todo, userId)),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildCompletedTodosTab(AsyncValue<List<TodoItem>> todosAsync, String userId) {
    return todosAsync.when(
      data: (todos) {
        final completedTodos = todos.where((todo) => todo.isCompleted).toList();
        
        if (completedTodos.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No completed tasks yet',
            subtitle: 'Complete some tasks to see them here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedTodos.length,
          itemBuilder: (context, index) {
            final todo = completedTodos[index];
            return _buildTodoCard(context, todo, userId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildOverviewTab(AsyncValue<Map<String, int>> statsAsync, AsyncValue<List<TodoItem>> todosAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          statsAsync.when(
            data: (stats) => _buildStatsCards(context, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading stats: $error'),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Tasks by Type',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          todosAsync.when(
            data: (todos) => _buildTasksByType(context, todos),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading tasks: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSectionHeader(BuildContext context, DateTime date, int count) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    Color color = Colors.blue;
    
    if (dueDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
      color = Colors.orange;
    } else {
      final daysFromNow = dueDate.difference(today).inDays;
      if (daysFromNow == 1) {
        dateText = 'Tomorrow';
      } else if (daysFromNow <= 7) {
        dateText = 'In $daysFromNow days';
      } else {
        // Format as "Oct 15" for dates further out
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dateText = '${months[date.month - 1]} ${date.day}';
      }
    }
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          dateText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoItem todo, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: _isAutoAssignedTodo(todo) && !todo.isCompleted 
            ? () => NavigationService().navigateToTodoActivity(context, todo, ref)
            : null,
        leading: GestureDetector(
          onTap: () => ref.read(userTodosProvider(userId).notifier).toggleCompletion(todo.id),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: todo.isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
              color: todo.isCompleted ? Colors.green : Colors.transparent,
            ),
            child: todo.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: todo.isCompleted ? Colors.grey : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildTypeChip(todo.type),
                const SizedBox(width: 8),
                // Due date is now shown in section headers, not individual items
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, todo, userId),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'start_activity',
              child: Row(
                children: [
                  Icon(_getActivityIcon(todo.type), size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Start ${todo.typeDisplayName}', style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 16),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: todo.isCompleted ? 'mark_incomplete' : 'mark_complete',
              child: Row(
                children: [
                  Icon(
                    todo.isCompleted ? Icons.radio_button_unchecked : Icons.check_circle,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(todo.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(TodoType type) {
    Color color;
    IconData icon;
    
    switch (type) {
      case TodoType.lesson:
        color = Colors.blue;
        icon = Icons.school;
        break;
      case TodoType.tool:
        color = Colors.green;
        icon = Icons.build;
        break;
      case TodoType.journal:
        color = Colors.purple;
        icon = Icons.edit_note;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            type.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, int> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, 'Total Tasks', stats['total'] ?? 0, Icons.task, Colors.blue),
        _buildStatCard(context, 'Completed', stats['completed'] ?? 0, Icons.check_circle, Colors.green),
        _buildStatCard(context, 'Pending', stats['pending'] ?? 0, Icons.pending_actions, Colors.orange),
        _buildStatCard(context, 'Overdue', stats['overdue'] ?? 0, Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksByType(BuildContext context, List<TodoItem> todos) {
    final lessonTodos = todos.where((todo) => todo.type == TodoType.lesson).toList();
    final toolTodos = todos.where((todo) => todo.type == TodoType.tool).toList();
    final journalTodos = todos.where((todo) => todo.type == TodoType.journal).toList();

    return Column(
      children: [
        _buildTypeStatCard(context, 'Lessons', lessonTodos.length, Icons.school, Colors.blue),
        const SizedBox(height: 12),
        _buildTypeStatCard(context, 'Tools', toolTodos.length, Icons.build, Colors.green),
        const SizedBox(height: 12),
        _buildTypeStatCard(context, 'Journal', journalTodos.length, Icons.edit_note, Colors.purple),
      ],
    );
  }

  Widget _buildTypeStatCard(BuildContext context, String type, int count, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(type),
        trailing: Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Sort todos by priority: Journal items first, then Lesson items
  List<TodoItem> _sortTodosByPriority(List<TodoItem> todos) {
    return List.from(todos)..sort((a, b) {
      // Journal items come first (priority 0)
      // Lesson items come second (priority 1)
      // Tool items come last (priority 2)
      final priorityA = _getTodoPriority(a);
      final priorityB = _getTodoPriority(b);
      
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      // If same priority, sort alphabetically by title
      return a.title.compareTo(b.title);
    });
  }

  /// Get priority for todo sorting (lower number = higher priority)
  int _getTodoPriority(TodoItem todo) {
    switch (todo.type) {
      case TodoType.journal:
        return 0; // Highest priority
      case TodoType.lesson:
        return 1; // Second priority
      case TodoType.tool:
        return 2; // Lowest priority
    }
  }

  void _handleMenuAction(String action, TodoItem todo, String userId) {
    switch (action) {
      case 'start_activity':
        NavigationService().navigateToTodoActivity(context, todo, ref);
        break;
      case 'edit':
        context.go('/todos/edit/${todo.id}');
        break;
      case 'mark_complete':
        ref.read(userTodosProvider(userId).notifier).markCompleted(todo.id);
        break;
      case 'mark_incomplete':
        ref.read(userTodosProvider(userId).notifier).markIncomplete(todo.id);
        break;
      case 'delete':
        _showDeleteConfirmation(todo, userId);
        break;
    }
  }

  IconData _getActivityIcon(TodoType type) {
    switch (type) {
      case TodoType.lesson:
        return Icons.school;
      case TodoType.tool:
        return Icons.build;
      case TodoType.journal:
        return Icons.edit_note;
    }
  }

  void _showDeleteConfirmation(TodoItem todo, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userTodosProvider(userId).notifier).deleteTodo(todo.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
