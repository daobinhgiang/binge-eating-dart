import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(userTodosProvider(user.id).notifier).refreshTodos(),
            icon: const Icon(Icons.refresh),
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
        label: const Text('Add Task'),
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
            subtitle: 'All caught up! Add new tasks or complete existing ones.',
            actionText: 'Add Task',
            onAction: () => context.go('/todos/add'),
          );
        }

        // Group todos by status
        final overdueTodos = pendingTodos.where((todo) => todo.isOverdue).toList();
        final dueTodayTodos = pendingTodos.where((todo) => todo.isDueToday).toList();
        final upcomingTodos = pendingTodos.where((todo) => !todo.isOverdue && !todo.isDueToday).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overdueTodos.isNotEmpty) ...[
                _buildSectionHeader(context, 'Overdue', overdueTodos.length, Colors.red),
                const SizedBox(height: 8),
                ...overdueTodos.map((todo) => _buildTodoCard(context, todo, userId)),
                const SizedBox(height: 24),
              ],
              
              if (dueTodayTodos.isNotEmpty) ...[
                _buildSectionHeader(context, 'Due Today', dueTodayTodos.length, Colors.orange),
                const SizedBox(height: 8),
                ...dueTodayTodos.map((todo) => _buildTodoCard(context, todo, userId)),
                const SizedBox(height: 24),
              ],
              
              if (upcomingTodos.isNotEmpty) ...[
                _buildSectionHeader(context, 'Upcoming', upcomingTodos.length, Colors.blue),
                const SizedBox(height: 8),
                ...upcomingTodos.map((todo) => _buildTodoCard(context, todo, userId)),
              ],
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

  Widget _buildTodoCard(BuildContext context, TodoItem todo, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
                Text(
                  'Due ${_formatDueDate(todo.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDueDateColor(todo),
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        onTap: () => NavigationService().navigateToTodoActivity(context, todo, ref),
      ),
    );
  }

  Widget _buildTypeChip(TodoType type) {
    Color color;
    IconData icon;
    
    switch (type) {
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
    // Lessons are no longer available
    final toolTodos = todos.where((todo) => todo.type == TodoType.tool).toList();
    final journalTodos = todos.where((todo) => todo.type == TodoType.journal).toList();

    return Column(
      children: [
        // Lessons are no longer available
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

  Color _getDueDateColor(TodoItem todo) {
    if (todo.isCompleted) return Colors.grey;
    if (todo.isOverdue) return Colors.red;
    if (todo.isDueToday) return Colors.orange;
    return Colors.grey[600]!;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    
    if (dueDate.isBefore(today)) {
      final daysAgo = today.difference(dueDate).inDays;
      return '$daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else if (dueDate.isAtSameMomentAs(today)) {
      return 'today';
    } else {
      final daysFromNow = dueDate.difference(today).inDays;
      if (daysFromNow == 1) {
        return 'tomorrow';
      } else {
        return 'in $daysFromNow days';
      }
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
