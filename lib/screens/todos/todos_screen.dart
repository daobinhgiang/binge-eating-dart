import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to detect auto-assigned todos
  bool _isAutoAssignedTodo(TodoItem todo) {
    if (todo.activityData != null && todo.activityData!.containsKey('type')) {
      return true;
    }
    
    if (todo.type == TodoType.lesson && (
        todo.activityId.startsWith('lesson_1_') ||
        todo.activityId.startsWith('lesson_s2_') ||
        todo.activityId.startsWith('lesson_s3_')
    )) {
      return true;
    }
    
    if (todo.type == TodoType.journal && (
        todo.activityId.contains('food_diary_') ||
        todo.activityId.contains('body_image_diary_') ||
        todo.activityId.contains('weight_diary_') ||
        todo.activityId.contains('money_diary_')
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
    final autoTodoState = ref.watch(autoTodoInitializationProvider(user.id));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.go('/home'),
                ),
                title: Text(
                  'Your Tasks',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
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
                        : const Icon(Icons.refresh, color: Colors.black),
                  ),
                ],
              ),
              
              SliverPadding(
                padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Summary Cards
                      userTodosAsync.when(
                        data: (todos) => _buildSummaryCards(todos),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                            ),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[600],
                          tabs: const [
                            Tab(text: 'Pending'),
                            Tab(text: 'Completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingTodosTab(userTodosAsync, user.id),
                    _buildCompletedTodosTab(userTodosAsync, user.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/todos/add'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildSummaryCards(List<TodoItem> todos) {
    final pending = todos.where((t) => !t.isCompleted).length;
    final completed = todos.where((t) => t.isCompleted).length;
    final total = todos.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pending',
            pending.toString(),
            Icons.pending_actions,
            const Color(0xFFFFA726),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completed.toString(),
            Icons.check_circle,
            const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            total.toString(),
            Icons.task,
            const Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            title: 'All caught up!',
            subtitle: 'No pending tasks. Great job!\n\nYour lessons and journal tasks are automatically assigned based on your progress.',
            actionText: 'Add Custom Task',
            onAction: () => context.go('/todos/add'),
          );
        }

        final dueTodayTodos = pendingTodos.where((todo) => todo.isDueToday).toList();
        final upcomingTodos = pendingTodos.where((todo) => !todo.isDueToday).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dueTodayTodos.isNotEmpty) ...[
                Text(
                  'Due Today',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                ..._sortTodosByPriority(dueTodayTodos).map((todo) => _buildTodoItem(context, todo, userId)),
                const SizedBox(height: 24),
              ],
              
              if (upcomingTodos.isNotEmpty) ...[
                Text(
                  'Upcoming',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                ..._sortTodosByPriority(upcomingTodos).map((todo) => _buildTodoItem(context, todo, userId)),
              ],
              
              const SizedBox(height: 80), // Space for FAB
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
            actionText: 'View Pending Tasks',
            onAction: () => _tabController.animateTo(0),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ...completedTodos.map((todo) => _buildTodoItem(context, todo, userId)),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildTodoItem(BuildContext context, TodoItem todo, String userId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAutoAssignedTodo(todo) && !todo.isCompleted 
              ? () => NavigationService().navigateToTodoActivity(context, todo, ref)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => ref.read(userTodosProvider(userId).notifier).toggleCompletion(todo.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.isCompleted ? Colors.green : Colors.grey[300]!,
                        width: 2,
                      ),
                      color: todo.isCompleted ? Colors.green : Colors.transparent,
                    ),
                    child: todo.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted ? Colors.grey[500] : Colors.black,
                        ),
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          todo.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildTypeChip(todo.type),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, todo, userId),
                  itemBuilder: (context) => [
                    if (_isAutoAssignedTodo(todo) && !todo.isCompleted)
                      PopupMenuItem(
                        value: 'start_activity',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getActivityIcon(todo.type), size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text('Start'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(TodoType type) {
    Color color;
    IconData icon;
    String label;
    
    switch (type) {
      case TodoType.lesson:
        color = Colors.blue;
        icon = Icons.school;
        label = 'Lesson';
        break;
      case TodoType.tool:
        color = Colors.green;
        icon = Icons.build;
        label = 'Tool';
        break;
      case TodoType.journal:
        color = Colors.purple;
        icon = Icons.edit_note;
        label = 'Journal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading tasks',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TodoItem> _sortTodosByPriority(List<TodoItem> todos) {
    return List.from(todos)..sort((a, b) {
      final priorityA = _getTodoPriority(a);
      final priorityB = _getTodoPriority(b);
      
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      return a.title.compareTo(b.title);
    });
  }

  int _getTodoPriority(TodoItem todo) {
    switch (todo.type) {
      case TodoType.journal:
        return 0;
      case TodoType.lesson:
        return 1;
      case TodoType.tool:
        return 2;
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
