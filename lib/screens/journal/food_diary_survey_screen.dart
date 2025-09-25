import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../models/food_diary.dart';

class FoodDiarySurveyScreen extends ConsumerStatefulWidget {
  const FoodDiarySurveyScreen({super.key});

  @override
  ConsumerState<FoodDiarySurveyScreen> createState() => _FoodDiarySurveyScreenState();
}

class _FoodDiarySurveyScreenState extends ConsumerState<FoodDiarySurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers and values
  final TextEditingController _foodController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  String _selectedLocation = FoodDiary.locationOptions.first;
  final TextEditingController _customLocationController = TextEditingController();
  bool _isBinge = false;
  String _purgeMethod = FoodDiary.purgeMethodOptions.first;
  final TextEditingController _contextController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _foodController.dispose();
    _customLocationController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentPage + 1} of 6',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / 6 * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Survey questions
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildFoodAndDrinksQuestion(),
                _buildMealTimeQuestion(),
                _buildLocationQuestion(),
                _buildBingeQuestion(),
                _buildPurgeQuestion(),
                _buildContextQuestion(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_currentPage < 5 ? _nextPage : _submitSurvey),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentPage < 5 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodAndDrinksQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What food and drinks did you have?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please describe what you ate and drank during this meal or snack. Be as detailed as possible.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _foodController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'e.g., Chicken salad with lettuce, tomatoes, and ranch dressing. Glass of water.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What time did you have this meal?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the time when you started eating this meal or snack.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Selected Time',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDisplayTime(_selectedTime),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text('Change Time'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where did you have this meal?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the location where you ate this meal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...FoodDiary.locationOptions.map((location) {
            return RadioListTile<String>(
              title: Text(location),
              value: location,
              groupValue: _selectedLocation,
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value!;
                });
              },
            );
          }),
          if (_selectedLocation == 'Other') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customLocationController,
              decoration: const InputDecoration(
                labelText: 'Please specify location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBingeQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Was this a binge?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A binge is characterized by eating a large amount of food in a short period while feeling out of control.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          RadioListTile<bool>(
            title: const Text('Yes'),
            subtitle: const Text('This was a binge episode'),
            value: true,
            groupValue: _isBinge,
            onChanged: (value) {
              setState(() {
                _isBinge = value!;
              });
            },
          ),
          RadioListTile<bool>(
            title: const Text('No'),
            subtitle: const Text('This was normal eating'),
            value: false,
            groupValue: _isBinge,
            onChanged: (value) {
              setState(() {
                _isBinge = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPurgeQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did you vomit or use laxatives?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please select if you used any compensatory behaviors after this meal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          RadioListTile<String>(
            title: const Text('None'),
            subtitle: const Text('No compensatory behaviors'),
            value: 'none',
            groupValue: _purgeMethod,
            onChanged: (value) {
              setState(() {
                _purgeMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Vomiting'),
            subtitle: const Text('I vomited after this meal'),
            value: 'vomit',
            groupValue: _purgeMethod,
            onChanged: (value) {
              setState(() {
                _purgeMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Laxatives'),
            subtitle: const Text('I used laxatives after this meal'),
            value: 'laxatives',
            groupValue: _purgeMethod,
            onChanged: (value) {
              setState(() {
                _purgeMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Both'),
            subtitle: const Text('I vomited and used laxatives'),
            value: 'both',
            groupValue: _purgeMethod,
            onChanged: (value) {
              setState(() {
                _purgeMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContextQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context and comments',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please share any additional context about this meal - how you were feeling, what triggered it, or any other relevant details.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _contextController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'e.g., I was feeling stressed after work. Ate quickly while watching TV. Felt guilty afterwards.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      // Validate current page before proceeding
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Food and drinks
        if (_foodController.text.trim().isEmpty) {
          _showValidationError('Please describe what food and drinks you had.');
          return false;
        }
        break;
      case 2: // Location
        if (_selectedLocation == 'Other' && _customLocationController.text.trim().isEmpty) {
          _showValidationError('Please specify the location.');
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDisplayTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submitSurvey() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
        foodAndDrinks: _foodController.text.trim(),
        mealTime: _selectedTime,
        location: _selectedLocation,
        customLocation: _selectedLocation == 'Other' ? _customLocationController.text.trim() : null,
        isBinge: _isBinge,
        purgeMethod: _purgeMethod,
        contextAndComments: _contextController.text.trim(),
      );

      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food diary entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
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
