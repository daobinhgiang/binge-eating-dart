import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/urge_surfing_provider.dart';
import '../../models/urge_surfing.dart';

class UrgeSurfingSurveyScreen extends ConsumerStatefulWidget {
  final UrgeSurfing? existingExercise;

  const UrgeSurfingSurveyScreen({super.key, this.existingExercise});

  @override
  ConsumerState<UrgeSurfingSurveyScreen> createState() => _UrgeSurfingSurveyScreenState();
}

class _UrgeSurfingSurveyScreenState extends ConsumerState<UrgeSurfingSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<AlternativeActivity> _activities = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      _titleController.text = widget.existingExercise!.title;
      _notesController.text = widget.existingExercise!.notes;
      _activities = List.from(widget.existingExercise!.activities);
    } else {
      _titleController.text = 'My Urge Surfing Activities';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExercise != null ? 'Edit Activity List' : 'New Activity List'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveExercise,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'List Title',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: 'e.g., My Go-To Activities',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title for your activity list';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guide Section
                    _buildGuideSection(context),

                    const SizedBox(height: 24),

                    // Activities Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Alternative Activities (${_activities.length})',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addActivity,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Activity'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 36),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_activities.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.waves_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No activities added yet',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add activities you can do when an urge strikes',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...List.generate(_activities.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: _buildActivityCard(context, _activities[index], index),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes Field
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes (Optional)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Any additional notes about your activities...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Activity Selection Guide',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'For each activity, consider these three key properties:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildGuideItem('Active', 'Doing something rather than passive', Icons.directions_run, Colors.red),
            _buildGuideItem('Enjoyable', 'Something you enjoy, not a chore', Icons.sentiment_satisfied, Colors.orange),
            _buildGuideItem('Realistic', 'Something you can actually do when urges strike', Icons.access_time, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description, IconData icon, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color[700],
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, AlternativeActivity activity, int index) {
    final criteriaCount = activity.criteriaCount;
    final isIdeal = activity.meetsAllCriteria;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIdeal ? Colors.green[50] : Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIdeal ? Colors.green[300]! : Colors.teal[200]!,
          width: isIdeal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isIdeal ? Colors.green[600] : Colors.teal[600],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isIdeal
                      ? const Icon(Icons.star, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCriteriaColor(criteriaCount).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$criteriaCount/3',
                  style: TextStyle(
                    color: _getCriteriaColor(criteriaCount),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editActivity(index),
                    icon: const Icon(Icons.edit, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    onPressed: () => _removeActivity(index),
                    icon: const Icon(Icons.delete, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    color: Colors.red[600],
                  ),
                ],
              ),
            ],
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCriteriaChip('Active', activity.isActive),
              const SizedBox(width: 8),
              _buildCriteriaChip('Enjoyable', activity.isEnjoyable),
              const SizedBox(width: 8),
              _buildCriteriaChip('Realistic', activity.isRealistic),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaChip(String label, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            size: 12,
            color: isMet ? Colors.green[700] : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCriteriaColor(int count) {
    switch (count) {
      case 3:
        return Colors.green[600]!;
      case 2:
        return Colors.orange[600]!;
      case 1:
        return Colors.amber[600]!;
      default:
        return Colors.red[600]!;
    }
  }

  void _addActivity() {
    _showActivityDialog();
  }

  void _editActivity(int index) {
    _showActivityDialog(existingActivity: _activities[index], index: index);
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }

  void _showActivityDialog({AlternativeActivity? existingActivity, int? index}) {
    final nameController = TextEditingController(text: existingActivity?.name ?? '');
    final descriptionController = TextEditingController(text: existingActivity?.description ?? '');
    bool isActive = existingActivity?.isActive ?? false;
    bool isEnjoyable = existingActivity?.isEnjoyable ?? false;
    bool isRealistic = existingActivity?.isRealistic ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingActivity != null ? 'Edit Activity' : 'Add Activity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Name *',
                    hintText: 'e.g., Take a walk, Call a friend',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief description of the activity...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Properties:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Involves doing something rather than being passive'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: const Text('Enjoyable'),
                  subtitle: const Text('Something you enjoy, not a chore'),
                  value: isEnjoyable,
                  onChanged: (value) => setDialogState(() => isEnjoyable = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: const Text('Realistic'),
                  subtitle: const Text('Something you can actually do when urges strike'),
                  value: isRealistic,
                  onChanged: (value) => setDialogState(() => isRealistic = value ?? false),
                  dense: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an activity name')),
                  );
                  return;
                }

                final activity = AlternativeActivity(
                  id: existingActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  isActive: isActive,
                  isEnjoyable: isEnjoyable,
                  isRealistic: isRealistic,
                );

                setState(() {
                  if (index != null) {
                    _activities[index] = activity;
                  } else {
                    _activities.add(activity);
                  }
                });

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
              ),
              child: Text(existingActivity != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    if (_activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one activity'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      if (widget.existingExercise != null) {
        // Update existing exercise
        await ref.read(userUrgeSurfingExercisesProvider(user.id).notifier).updateExercise(
          exerciseId: widget.existingExercise!.id,
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          activities: _activities,
        );
      } else {
        // Create new exercise
        await ref.read(userUrgeSurfingExercisesProvider(user.id).notifier).createExercise(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          activities: _activities,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Activity list ${widget.existingExercise != null ? 'updated' : 'created'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving activity list: $e'),
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
