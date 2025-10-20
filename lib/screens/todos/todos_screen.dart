import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo_item.dart';
import '../../models/task_template.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/task_regeneration_service.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  String _selectedFilter = 'all'; // 'all', 'seeds', 'growth', 'mastery'
  
  @override
  void initState() {
    super.initState();
    // Check and regenerate tasks on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _regenerateTasksOnLoad();
    });
  }

  Future<void> _regenerateTasksOnLoad() async {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;
    
    try {
      final regenerationService = TaskRegenerationService();
      final newTasks = await regenerationService.checkAndRegenerateTasks(user.id);
      
      // Only refresh if new tasks were generated
      if (newTasks.isNotEmpty) {
        print('New quests generated, refreshing UI');
        await ref.read(userTodosProvider(user.id).notifier).refreshTodos();
      }
    } catch (e) {
      print('Error during quest regeneration: $e');
    }
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

    final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8EDF2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilterChips(),
              Expanded(
                child: userTodosAsync.when(
                  data: (todos) => _buildQuestsList(todos, user.id),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/todos/add'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Add Quest',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D3436)),
            ),
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Quests',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3436),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your recovery journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All Quests', 'all', Icons.grid_view_rounded, null),
          const SizedBox(width: 12),
          _buildFilterChip('Daily Seeds', 'seeds', Icons.wb_sunny_rounded, const Color(0xFFFFB951)),
          const SizedBox(width: 12),
          _buildFilterChip('Growth Tasks', 'growth', Icons.trending_up_rounded, const Color(0xFF00B894)),
          const SizedBox(width: 12),
          _buildFilterChip('Mastery', 'mastery', Icons.emoji_events_rounded, const Color(0xFF6C5CE7)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, Color? color) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? const Color(0xFF6C5CE7)) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (color ?? const Color(0xFF6C5CE7)).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : (color ?? const Color(0xFF636E72)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsList(List<TodoItem> todos, String userId) {
    // Filter based on selected filter
    List<TodoItem> filteredTodos = todos;
    if (_selectedFilter == 'seeds') {
      filteredTodos = todos.where((t) => t.tier == TaskTier.seeds).toList();
    } else if (_selectedFilter == 'growth') {
      filteredTodos = todos.where((t) => t.tier == TaskTier.growthTasks).toList();
    } else if (_selectedFilter == 'mastery') {
      filteredTodos = todos.where((t) => t.tier == TaskTier.masteryQuests).toList();
    }

    final pendingTodos = filteredTodos.where((t) => !t.isCompleted).toList();
    final completedTodos = filteredTodos.where((t) => t.isCompleted).toList();

    if (filteredTodos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Statistics overview
        _buildStatsOverview(todos),
        const SizedBox(height: 24),
        
        // Pending quests
        if (pendingTodos.isNotEmpty) ...[
          _buildSectionHeader('Active Quests', pendingTodos.length),
          const SizedBox(height: 12),
          ...pendingTodos.map((todo) => _buildQuestCard(context, todo, userId)),
          const SizedBox(height: 24),
        ],
        
        // Completed quests
        if (completedTodos.isNotEmpty) ...[
          _buildSectionHeader('Completed', completedTodos.length),
          const SizedBox(height: 12),
          ...completedTodos.map((todo) => _buildQuestCard(context, todo, userId)),
        ],
      ],
    );
  }

  Widget _buildStatsOverview(List<TodoItem> todos) {
    final totalQuests = todos.length;
    final completedQuests = todos.where((t) => t.isCompleted).length;
    final progressPercent = totalQuests > 0 ? (completedQuests / totalQuests * 100).round() : 0;
    
    final seeds = todos.where((t) => t.tier == TaskTier.seeds);
    final growth = todos.where((t) => t.tier == TaskTier.growthTasks);
    final mastery = todos.where((t) => t.tier == TaskTier.masteryQuests);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF9D8CF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$progressPercent%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalQuests > 0 ? completedQuests / totalQuests : 0,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${seeds.where((t) => t.isCompleted).length}/${seeds.length}',
                  'Seeds',
                  Icons.wb_sunny_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '${growth.where((t) => t.isCompleted).length}/${growth.length}',
                  'Growth',
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '${mastery.where((t) => t.isCompleted).length}/${mastery.length}',
                  'Mastery',
                  Icons.emoji_events_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C5CE7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(BuildContext context, TodoItem todo, String userId) {
    final tierColor = _getTierColor(todo.tier);
    final tierIcon = _getTierIcon(todo.tier);
    final typeColor = _getTypeColor(todo.type);
    
    // Calculate progress for the card
    final progress = todo.isCompleted ? 1.0 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: todo.isCompleted 
              ? null
              : () {
                  if (todo.activityId.isNotEmpty) {
                    NavigationService().navigateToTodoActivity(context, todo, ref);
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: () => ref.read(userTodosProvider(userId).notifier).toggleCompletion(todo.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: todo.isCompleted ? tierColor : const Color(0xFFDFE6E9),
                            width: 2,
                          ),
                          color: todo.isCompleted ? tierColor : Colors.transparent,
                        ),
                        child: todo.isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Tier badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tierColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(tierIcon, size: 12, color: tierColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      todo.tierDisplayName,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: tierColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Type badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  todo.typeDisplayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: typeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            todo.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: todo.isCompleted 
                                  ? const Color(0xFFB2BEC3) 
                                  : const Color(0xFF2D3436),
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (todo.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              todo.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF636E72),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // EXP reward
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB951).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB951)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${todo.expReward} EXP',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFB951),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey[400],
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) => _handleMenuAction(value, todo, userId),
                      itemBuilder: (context) => [
                        if (!todo.isCompleted && todo.activityId.isNotEmpty)
                          PopupMenuItem(
                            value: 'start',
                            child: Row(
                              children: [
                                Icon(_getActivityIcon(todo.type), size: 18, color: const Color(0xFF6C5CE7)),
                                const SizedBox(width: 12),
                                Text(
                                  'Start Quest',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF636E72)),
                              const SizedBox(width: 12),
                              Text(
                                'Edit',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_rounded, size: 18, color: Color(0xFFFF7675)),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFF7675),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Progress bar at bottom
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: tierColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(TaskTier? tier) {
    if (tier == null) return const Color(0xFF636E72);
    switch (tier) {
      case TaskTier.seeds:
        return const Color(0xFFFFB951);
      case TaskTier.growthTasks:
        return const Color(0xFF00B894);
      case TaskTier.masteryQuests:
        return const Color(0xFF6C5CE7);
    }
  }

  IconData _getTierIcon(TaskTier? tier) {
    if (tier == null) return Icons.task_alt_rounded;
    switch (tier) {
      case TaskTier.seeds:
        return Icons.wb_sunny_rounded;
      case TaskTier.growthTasks:
        return Icons.trending_up_rounded;
      case TaskTier.masteryQuests:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getTypeColor(TodoType type) {
    switch (type) {
      case TodoType.lesson:
        return const Color(0xFF0984E3);
      case TodoType.tool:
        return const Color(0xFFD63031);
      case TodoType.journal:
        return const Color(0xFFA29BFE);
    }
  }

  IconData _getActivityIcon(TodoType type) {
    switch (type) {
      case TodoType.lesson:
        return Icons.school_rounded;
      case TodoType.tool:
        return Icons.build_rounded;
      case TodoType.journal:
        return Icons.edit_note_rounded;
    }
  }

  void _handleMenuAction(String action, TodoItem todo, String userId) {
    switch (action) {
      case 'start':
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

  void _showDeleteConfirmation(TodoItem todo, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Quest?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${todo.title}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF636E72)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userTodosProvider(userId).notifier).deleteTodo(todo.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 64,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quests Found',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your recovery journey by adding quests or wait for daily quests to be generated automatically.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/todos/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add Your First Quest',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
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
            const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFFF7675)),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

