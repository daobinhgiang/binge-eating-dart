import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo_item.dart';

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
    _tabController = TabController(length: 2, vsync: this); // Reduced from 3 to 2 (removed lessons)
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tools', icon: Icon(Icons.build)),
            Tab(text: 'Journal', icon: Icon(Icons.edit_note)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildToolsTab(),
                _buildJournalTab(),
              ],
            ),
          ),
          if (_selectedType != null) _buildSelectedActivityCard(),
          _buildSubmitSection(),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolCard(
          'Urge Surfing',
          'Practice riding out urges without acting on them',
          'urge_surfing',
          Icons.waves,
        ),
        _buildToolCard(
          'Problem Solving',
          'Work through challenges with structured problem-solving',
          'problem_solving',
          Icons.psychology,
        ),
        _buildToolCard(
          'Addressing Setbacks',
          'Learn how to handle and recover from setbacks',
          'addressing_setbacks',
          Icons.trending_up,
        ),
        _buildToolCard(
          'Addressing Overconcern',
          'Manage excessive worry about body image and eating',
          'addressing_overconcern',
          Icons.self_improvement,
        ),
        _buildToolCard(
          'Meal Planning',
          'Plan balanced and satisfying meals',
          'meal_planning',
          Icons.restaurant_menu,
        ),
      ],
    );
  }

  Widget _buildJournalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildJournalCard(
          'Food Diary',
          'Track your meals and eating patterns',
          'food_diary',
          Icons.restaurant,
        ),
        _buildJournalCard(
          'Body Image Diary',
          'Reflect on body image thoughts and feelings',
          'body_image_diary',
          Icons.favorite,
        ),
        _buildJournalCard(
          'Weight Diary',
          'Monitor weight changes mindfully',
          'weight_diary',
          Icons.monitor_weight,
        ),
      ],
    );
  }

  Widget _buildToolCard(String title, String description, String activityId, IconData icon) {
    final isSelected = _selectedActivityId == activityId && _selectedType == TodoType.tool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: () {
          setState(() {
            _selectedType = TodoType.tool;
            _selectedActivityId = activityId;
            _selectedActivityData = {'toolType': activityId};
            _titleController.text = title;
            _descriptionController.text = description;
          });
        },
      ),
    );
  }

  Widget _buildJournalCard(String title, String description, String activityId, IconData icon) {
    final isSelected = _selectedActivityId == activityId && _selectedType == TodoType.journal;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: () {
          setState(() {
            _selectedType = TodoType.journal;
            _selectedActivityId = activityId;
            _selectedActivityData = {'journalType': activityId};
            _titleController.text = title;
            _descriptionController.text = description;
          });
        },
      ),
    );
  }

  Widget _buildSelectedActivityCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text('Due: ${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}'),
              const Spacer(),
              TextButton(
                onPressed: _selectDueDate,
                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedType != null && !_isSubmitting ? _submitTodo : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Add Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _submitTodo() async {
    if (_selectedType == null || _selectedActivityId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) throw Exception('User not found');

      await ref.read(userTodosProvider(user.id).notifier).createTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType!,
        activityId: _selectedActivityId!,
        activityData: _selectedActivityData,
        dueDate: _selectedDueDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
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
}