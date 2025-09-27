import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weight_diary_provider.dart';
import '../../models/weight_diary.dart';

class WeightDiarySurveyScreen extends ConsumerStatefulWidget {
  const WeightDiarySurveyScreen({super.key});

  @override
  ConsumerState<WeightDiarySurveyScreen> createState() => _WeightDiarySurveyScreenState();
}

class _WeightDiarySurveyScreenState extends ConsumerState<WeightDiarySurveyScreen> {
  final TextEditingController _weightController = TextEditingController();
  String _selectedUnit = WeightDiary.weightUnits.first; // Default to 'kg'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Diary'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.monitor_weight,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Track Your Weight',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log your current weight to track your progress over time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Weight input section
            Text(
              'What is your current weight?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Weight input field
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: 'Enter your weight',
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.monitor_weight_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: WeightDiary.weightUnits.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Helper text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Weigh yourself at the same time each day for more accurate tracking.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitWeight,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSubmitting ? 'Saving...' : 'Save Weight',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent entries section
            _buildRecentEntries(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries() {
    final user = ref.watch(currentUserDataProvider);
    if (user == null) return const SizedBox.shrink();
    
    final currentWeekWeightDiaries = ref.watch(currentWeekWeightDiariesProvider(user.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week\'s Entries',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        currentWeekWeightDiaries.when(
          data: (entries) {
            if (entries.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No weight entries this week',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: entries.map((entry) => _buildWeightEntryCard(entry)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading entries: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightEntryCard(WeightDiary entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor_weight,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayWeight,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    _formatDateTime(entry.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deleteEntry(entry),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    final timeString = '$hour:$minute $period';
    
    if (entryDate == today) {
      return 'Today at $timeString';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $timeString';
    } else {
      return '${dateTime.month}/${dateTime.day} at $timeString';
    }
  }

  Future<void> _submitWeight() async {
    if (_weightController.text.trim().isEmpty) {
      _showValidationError('Please enter your weight.');
      return;
    }

    final weightText = _weightController.text.trim();
    final weight = double.tryParse(weightText);
    
    if (weight == null || weight <= 0) {
      _showValidationError('Please enter a valid weight.');
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

      final entry = await ref.read(currentWeekWeightDiariesProvider(user.id).notifier).createEntry(
        weight: weight,
        unit: _selectedUnit,
      );

      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _weightController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving weight: $e'),
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

  Future<void> _deleteEntry(WeightDiary entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text('Are you sure you want to delete this weight entry (${entry.displayWeight})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = ref.read(currentUserDataProvider);
        if (user != null) {
          await ref.read(currentWeekWeightDiariesProvider(user.id).notifier)
              .deleteEntry(entry.week, entry.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Weight entry deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
