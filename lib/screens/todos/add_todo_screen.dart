import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../models/todo_item.dart';
import '../../models/lesson.dart';
import '../../core/services/lesson_service.dart';
import '../../screens/tools/tools_screen.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TodoType? _selectedType;
  String? _selectedActivityId;
  Map<String, dynamic>? _selectedActivityData;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canSubmit() ? _submitTodo : null,
            child: _isSubmitting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Activity Selection Tabs
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _selectedType = TodoType.values[index];
                  _selectedActivityId = null;
                  _selectedActivityData = null;
                  _titleController.clear();
                  _descriptionController.clear();
                });
              },
              tabs: const [
                Tab(icon: Icon(Icons.school), text: 'Lessons'),
                Tab(icon: Icon(Icons.build), text: 'Tools'),
                Tab(icon: Icon(Icons.edit_note), text: 'Journal'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsTab(),
                _buildToolsTab(),
                _buildJournalTab(),
              ],
            ),
          ),
          
          // Task Details Section
          if (_selectedActivityId != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: _buildTaskDetailsSection(),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    final lessonsAsync = ref.watch(allLessonsProvider);
    
    return lessonsAsync.when(
      data: (lessons) {
        if (lessons.isEmpty) {
          return _buildEmptyState(
            icon: Icons.school,
            title: 'No lessons available',
            subtitle: 'Lessons will appear here when they are available.',
          );
        }

        // Group lessons by chapter
        final groupedLessons = <int, List<Lesson>>{};
        for (final lesson in lessons) {
          groupedLessons.putIfAbsent(lesson.chapterNumber, () => []).add(lesson);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedLessons.keys.length,
          itemBuilder: (context, index) {
            final chapterNumber = groupedLessons.keys.elementAt(index);
            final chapterLessons = groupedLessons[chapterNumber]!;
            
            return _buildChapterSection(chapterNumber, chapterLessons);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Failed to load lessons: $error'),
    );
  }

  Widget _buildChapterSection(int chapterNumber, List<Lesson> lessons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Chapter $chapterNumber: ${LessonService.getChapterTitle(chapterNumber)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...lessons.map((lesson) => _buildLessonCard(lesson)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    final isSelected = _selectedActivityId == lesson.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: isSelected,
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.play_lesson,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(lesson.title),
        subtitle: Text(
          lesson.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: () => _selectActivity(
          type: TodoType.lesson,
          activityId: lesson.id,
          title: lesson.title,
          description: lesson.description,
          activityData: {
            'chapterNumber': lesson.chapterNumber,
            'lessonNumber': lesson.lessonNumber,
          },
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ToolsScreen.exercises.length,
      itemBuilder: (context, index) {
        final exercise = ToolsScreen.exercises[index];
        final isSelected = _selectedActivityId == exercise.title;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            selected: isSelected,
            leading: CircleAvatar(
              backgroundColor: isSelected 
                  ? exercise.color
                  : exercise.color.withValues(alpha: 0.1),
              child: Icon(
                exercise.icon,
                color: isSelected ? Colors.white : exercise.color,
              ),
            ),
            title: Text(exercise.title),
            subtitle: Text(exercise.description),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () => _selectActivity(
              type: TodoType.tool,
              activityId: exercise.title,
              title: exercise.title,
              description: exercise.description,
              activityData: {
                'toolType': exercise.title,
                'icon': exercise.icon.codePoint,
                'color': exercise.color.toARGB32(),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildJournalTab() {
    final journalActivities = [
      {
        'id': 'food_diary',
        'title': 'Food Diary Entry',
        'description': 'Track your meals and eating patterns',
        'icon': Icons.restaurant,
        'color': Colors.orange,
      },
      {
        'id': 'weight_diary',
        'title': 'Weight Diary Entry',
        'description': 'Record your weight and body measurements',
        'icon': Icons.monitor_weight,
        'color': Colors.blue,
      },
      {
        'id': 'body_image_diary',
        'title': 'Body Image Diary Entry',
        'description': 'Reflect on your body image and feelings',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: journalActivities.length,
      itemBuilder: (context, index) {
        final activity = journalActivities[index];
        final isSelected = _selectedActivityId == activity['id'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            selected: isSelected,
            leading: CircleAvatar(
              backgroundColor: isSelected 
                  ? activity['color'] as Color
                  : (activity['color'] as Color).withValues(alpha: 0.1),
              child: Icon(
                activity['icon'] as IconData,
                color: isSelected ? Colors.white : activity['color'] as Color,
              ),
            ),
            title: Text(activity['title'] as String),
            subtitle: Text(activity['description'] as String),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () => _selectActivity(
              type: TodoType.journal,
              activityId: activity['id'] as String,
              title: activity['title'] as String,
              description: activity['description'] as String,
              activityData: {
                'journalType': activity['id'],
                'icon': (activity['icon'] as IconData).codePoint,
                'color': (activity['color'] as Color).toARGB32(),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Task Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title Field
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter a custom title or use the default',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          
          // Description Field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add any additional notes or details',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Due Date Picker
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due Date: ${_formatDate(_selectedDueDate)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              TextButton.icon(
                onPressed: _selectDueDate,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitTodo : null,
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Creating...'),
                      ],
                    )
                  : const Text('Create Task'),
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
            'Error',
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
        ],
      ),
    );
  }

  void _selectActivity({
    required TodoType type,
    required String activityId,
    required String title,
    required String description,
    Map<String, dynamic>? activityData,
  }) {
    setState(() {
      _selectedType = type;
      _selectedActivityId = activityId;
      _selectedActivityData = activityData;
      
      // Set default title if empty
      if (_titleController.text.isEmpty) {
        _titleController.text = title;
      }
      
      // Set default description if empty
      if (_descriptionController.text.isEmpty) {
        _descriptionController.text = description;
      }
    });
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  bool _canSubmit() {
    return _selectedActivityId != null && 
           _titleController.text.trim().isNotEmpty &&
           !_isSubmitting;
  }

  Future<void> _submitTodo() async {
    if (!_canSubmit()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) throw 'User not authenticated';

      final todo = await ref.read(userTodosProvider(user.id).notifier).createTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType!,
        activityId: _selectedActivityId!,
        activityData: _selectedActivityData,
        dueDate: _selectedDueDate,
      );

      if (todo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/todos');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (selectedDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
