import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/regular_eating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/regular_eating.dart';

class RegularEatingScreen extends ConsumerStatefulWidget {
  const RegularEatingScreen({super.key});

  @override
  ConsumerState<RegularEatingScreen> createState() => _RegularEatingScreenState();
}

class _RegularEatingScreenState extends ConsumerState<RegularEatingScreen> {
  double _mealIntervalHours = RegularEating.defaultMealIntervalHours;
  int _firstMealHour = RegularEating.defaultFirstMealHour;
  int _firstMealMinute = RegularEating.defaultFirstMealMinute;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load existing settings when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingSettings();
    });
  }

  void _loadExistingSettings() {
    final authState = ref.read(authNotifierProvider);
    authState.whenData((user) {
      if (user != null) {
        final settingsAsync = ref.read(regularEatingSettingsProvider(user.id));
        settingsAsync.whenData((settings) {
          if (settings != null && mounted) {
            setState(() {
              _mealIntervalHours = settings.mealIntervalHours;
              _firstMealHour = settings.firstMealHour;
              _firstMealMinute = settings.firstMealMinute;
            });
          }
        });
      }
    });
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectFirstMealTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _firstMealHour, minute: _firstMealMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              dayPeriodBorderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _firstMealHour = picked.hour;
        _firstMealMinute = picked.minute;
        _markAsChanged();
      });
    }
  }

  Future<void> _saveSettings() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.value;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save settings'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(userRegularEatingProvider(user.id).notifier);
      final savedSettings = await notifier.saveSettings(
        mealIntervalHours: _mealIntervalHours,
        firstMealHour: _firstMealHour,
        firstMealMinute: _firstMealMinute,
      );

      if (savedSettings != null && mounted) {
        setState(() {
          _hasChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Regular eating settings saved successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'View Schedule',
              textColor: Colors.white,
              onPressed: () {
                _showMealSchedulePreview(savedSettings);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMealSchedulePreview(RegularEating settings) {
    final today = DateTime.now();
    final mealTimes = settings.getMealTimesForDate(today);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Today\'s Meal Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your settings:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...mealTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              final mealNames = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
              final mealName = index < mealNames.length ? mealNames[index] : 'Meal ${index + 1}';
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$mealName: ${TimeOfDay.fromDateTime(time).format(context)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatFirstMealTime() {
    final time = TimeOfDay(hour: _firstMealHour, minute: _firstMealMinute);
    return time.format(context);
  }

  String _formatMealInterval() {
    if (_mealIntervalHours == _mealIntervalHours.round()) {
      final hours = _mealIntervalHours.round();
      return '$hours hour${hours == 1 ? '' : 's'}';
    } else {
      return '${_mealIntervalHours.toStringAsFixed(1)} hours';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regular Eating'),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            IconButton(
              onPressed: _isLoading ? null : _saveSettings,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              tooltip: 'Save settings',
            ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please log in to access regular eating settings'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Regular Eating Schedule',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Set up your preferred meal timing to help establish a regular eating pattern. This can support your recovery by creating structure around meals.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Meal interval settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Between Meals',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose how many hours you want between each meal (2-6 hours recommended)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Current value display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current: ${_formatMealInterval()}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Slider
                        Slider(
                          value: _mealIntervalHours,
                          min: RegularEating.minMealIntervalHours,
                          max: RegularEating.maxMealIntervalHours,
                          divisions: 16, // 0.25 hour increments
                          label: _formatMealInterval(),
                          onChanged: (value) {
                            setState(() {
                              _mealIntervalHours = value;
                              _markAsChanged();
                            });
                          },
                        ),
                        
                        // Hour markers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '2 hours',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '6 hours',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // First meal time settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Meal Time',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'What time would you like to have your first meal of the day?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Time display and picker
                        InkWell(
                          onTap: _selectFirstMealTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'First meal at: ${_formatFirstMealTime()}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                if (_hasChanges)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveSettings,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Info card
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Regular Eating',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Regular eating involves having structured meal times throughout the day. This can help:\n'
                          '• Reduce urges to binge\n'
                          '• Stabilize blood sugar levels\n'
                          '• Create healthy eating patterns\n'
                          '• Improve overall relationship with food',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading regular eating settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
