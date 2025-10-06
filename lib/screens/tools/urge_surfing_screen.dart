import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/urge_surfing_provider.dart';
import '../../models/urge_surfing.dart';

class UrgeSurfingScreen extends ConsumerStatefulWidget {
  const UrgeSurfingScreen({super.key});

  @override
  ConsumerState<UrgeSurfingScreen> createState() => _UrgeSurfingScreenState();
}

class _UrgeSurfingScreenState extends ConsumerState<UrgeSurfingScreen> {
  final bool _isLoading = false;

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

    final activitiesAsync = ref.watch(userActivitiesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Urge Surfing Activities'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(userActivitiesProvider(user.id).notifier).refreshActivities();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildActivitiesList(context, activities);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Error loading activities: $e'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(context),
        backgroundColor: Colors.teal[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Activity'),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.waves_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Activities Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add alternative activities you can do when an urge strikes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddActivityDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildGuideSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<AlternativeActivity> activities) {
    return Column(
      children: [
        // Guide section at the top
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildGuideSection(context),
        ),
        // Activities list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            itemCount: activities.length,
            itemBuilder: (context, index) => _buildActivityCard(context, activities[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, AlternativeActivity activity, int index) {
    final criteriaCount = activity.criteriaCount;
    final isIdeal = activity.meetsAllCriteria;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isIdeal ? Colors.green[50] : Colors.teal[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isIdeal ? Colors.green[300]! : Colors.teal.withValues(alpha: 0.2),
                  width: isIdeal ? 2 : 1,
                ),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: (isIdeal ? Colors.green : Colors.teal).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: (isIdeal ? Colors.green : Colors.teal).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : [
                  BoxShadow(
                    color: (isIdeal ? Colors.green : Colors.teal).withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _editActivity(context, activity, index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isIdeal ? Colors.green[600] : Colors.teal[600],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: isIdeal
                                    ? const Icon(Icons.star, color: Colors.white, size: 18)
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (activity.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      activity.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
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
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                  onTap: () => _editActivity(context, activity, index),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red[600]),
                                      const SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red[600])),
                                    ],
                                  ),
                                  onTap: () => _deleteActivity(context, activity),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _buildGuideSection(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      elevation: 2,
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


  void _showAddActivityDialog(BuildContext context) {
    _showActivityDialog(context);
  }

  void _editActivity(BuildContext context, AlternativeActivity activity, int index) {
    _showActivityDialog(context, existingActivity: activity);
  }

  void _deleteActivity(BuildContext context, AlternativeActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = ref.read(currentUserDataProvider);
                if (user != null) {
                  await ref.read(userActivitiesProvider(user.id).notifier).deleteActivity(activity.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting activity: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showActivityDialog(BuildContext context, {AlternativeActivity? existingActivity}) {
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
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an activity name')),
                  );
                  return;
                }

                try {
                  final user = ref.read(currentUserDataProvider);
                  if (user != null) {
                    if (existingActivity != null) {
                      // Update existing activity
                      await ref.read(userActivitiesProvider(user.id).notifier).updateActivity(
                        activityId: existingActivity.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        isActive: isActive,
                        isEnjoyable: isEnjoyable,
                        isRealistic: isRealistic,
                      );
                    } else {
                      // Add new activity
                      await ref.read(userActivitiesProvider(user.id).notifier).addActivity(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        isActive: isActive,
                        isEnjoyable: isEnjoyable,
                        isRealistic: isRealistic,
                      );
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Activity ${existingActivity != null ? 'updated' : 'added'} successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving activity: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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
}

