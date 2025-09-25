import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../models/meal_plan.dart';

class MealPlanSurveyScreen extends ConsumerStatefulWidget {
  const MealPlanSurveyScreen({super.key});

  @override
  ConsumerState<MealPlanSurveyScreen> createState() => _MealPlanSurveyScreenState();
}

class _MealPlanSurveyScreenState extends ConsumerState<MealPlanSurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers and values
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  final TextEditingController _snacksController = TextEditingController();
  String _selectedLocation = MealPlan.locationOptions.first;
  final TextEditingController _customLocationController = TextEditingController();
  final Set<String> _selectedMethods = {};
  final TextEditingController _portionGoalsController = TextEditingController();
  final TextEditingController _nutritionGoalsController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _strategiesController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snacksController.dispose();
    _customLocationController.dispose();
    _portionGoalsController.dispose();
    _nutritionGoalsController.dispose();
    _challengesController.dispose();
    _strategiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Meal Plan'),
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
                      'Step ${_currentPage + 1} of 8',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / 8 * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green[600]!,
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
                _buildPlanDateQuestion(),
                _buildMealsQuestion(),
                _buildLocationQuestion(),
                _buildPreparationMethodsQuestion(),
                _buildPortionGoalsQuestion(),
                _buildNutritionGoalsQuestion(),
                _buildChallengesQuestion(),
                _buildStrategiesQuestion(),
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
                    onPressed: _isSubmitting ? null : (_currentPage < 7 ? _nextPage : _submitPlan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentPage < 7 ? 'Next' : 'Save Meal Plan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDateQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What date is this meal plan for?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the date you want to plan your meals for.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.green[600]),
              title: Text(
                _formatSelectedDate(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(_getDateDescription()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan your meals for the day',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What would you like to eat for each meal? Be as specific or general as you prefer.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildMealField(
                  controller: _breakfastController,
                  label: 'Breakfast',
                  icon: Icons.wb_sunny,
                  hint: 'e.g., Oatmeal with berries and nuts',
                ),
                const SizedBox(height: 16),
                _buildMealField(
                  controller: _lunchController,
                  label: 'Lunch',
                  icon: Icons.lunch_dining,
                  hint: 'e.g., Quinoa salad with vegetables',
                ),
                const SizedBox(height: 16),
                _buildMealField(
                  controller: _dinnerController,
                  label: 'Dinner',
                  icon: Icons.dinner_dining,
                  hint: 'e.g., Grilled chicken with rice and vegetables',
                ),
                const SizedBox(height: 16),
                _buildMealField(
                  controller: _snacksController,
                  label: 'Snacks (Optional)',
                  icon: Icons.local_cafe,
                  hint: 'e.g., Apple with peanut butter, nuts',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where will you prepare/get your meals?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the primary location for meal preparation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ...MealPlan.locationOptions.map((location) {
                  return RadioListTile<String>(
                    title: Text(location),
                    value: location,
                    groupValue: _selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                    activeColor: Colors.green[600],
                  );
                }),
                if (_selectedLocation == 'Other') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationMethodsQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How will you prepare your meals?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select all preparation methods you plan to use (you can choose multiple).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: MealPlan.preparationMethodOptions.map((method) {
                final isSelected = _selectedMethods.contains(method);
                return CheckboxListTile(
                  title: Text(method),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedMethods.add(method);
                      } else {
                        _selectedMethods.remove(method);
                      }
                    });
                  },
                  activeColor: Colors.green[600],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortionGoalsQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your portion goals?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe your goals for portion sizes and eating patterns.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _portionGoalsController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g., Eat moderate portions, listen to hunger cues, include protein at each meal...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGoalsQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your nutrition goals?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe what you want to focus on nutritionally for this meal plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _nutritionGoalsController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g., Include more vegetables, get enough protein, stay hydrated, eat balanced meals...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What challenges do you anticipate?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Think about potential obstacles or difficulties you might face with this meal plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _challengesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g., Busy schedule, limited time for prep, cravings for unhealthy foods, eating out...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What strategies will help you succeed?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe specific strategies and coping skills to help you stick to your meal plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _strategiesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g., Meal prep on Sunday, pack healthy snacks, set reminders to eat, practice mindful eating...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    if (selectedDay == today) {
      return 'Today - ${_formatDate(_selectedDate)}';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow - ${_formatDate(_selectedDate)}';
    } else {
      return _formatDate(_selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDateDescription() {
    final now = DateTime.now();
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final today = DateTime(now.year, now.month, now.day);
    
    final difference = selectedDay.difference(today).inDays;
    
    if (difference == 0) {
      return 'Plan for today';
    } else if (difference == 1) {
      return 'Plan for tomorrow';
    } else if (difference > 1) {
      return 'Plan for $difference days from now';
    } else {
      return 'Plan for ${difference.abs()} day${difference.abs() == 1 ? '' : 's'} ago';
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
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
    if (_currentPage < 7) {
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
      case 0: // Plan date
        // Date is always valid since we use date picker
        return true;
      case 1: // Meals
        if (_breakfastController.text.trim().isEmpty ||
            _lunchController.text.trim().isEmpty ||
            _dinnerController.text.trim().isEmpty) {
          _showValidationError('Please plan at least breakfast, lunch, and dinner.');
          return false;
        }
        break;
      case 2: // Location
        if (_selectedLocation == 'Other' && _customLocationController.text.trim().isEmpty) {
          _showValidationError('Please specify the location.');
          return false;
        }
        break;
      case 3: // Preparation methods
        if (_selectedMethods.isEmpty) {
          _showValidationError('Please select at least one preparation method.');
          return false;
        }
        break;
      case 4: // Portion goals
        if (_portionGoalsController.text.trim().isEmpty) {
          _showValidationError('Please describe your portion goals.');
          return false;
        }
        break;
      case 5: // Nutrition goals
        if (_nutritionGoalsController.text.trim().isEmpty) {
          _showValidationError('Please describe your nutrition goals.');
          return false;
        }
        break;
      case 6: // Challenges
        if (_challengesController.text.trim().isEmpty) {
          _showValidationError('Please describe potential challenges.');
          return false;
        }
        break;
      case 7: // Strategies
        if (_strategiesController.text.trim().isEmpty) {
          _showValidationError('Please describe your strategies for success.');
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

  Future<void> _submitPlan() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final plan = await ref.read(allUserMealPlansProvider(user.id).notifier).createPlan(
        planDate: _selectedDate,
        breakfast: _breakfastController.text.trim(),
        lunch: _lunchController.text.trim(),
        dinner: _dinnerController.text.trim(),
        snacks: _snacksController.text.trim(),
        preparationLocation: _selectedLocation,
        customLocation: _selectedLocation == 'Other' ? _customLocationController.text.trim() : null,
        preparationMethods: _selectedMethods.toList(),
        portionGoals: _portionGoalsController.text.trim(),
        nutritionGoals: _nutritionGoalsController.text.trim(),
        challenges: _challengesController.text.trim(),
        strategies: _strategiesController.text.trim(),
      );

      if (plan != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal plan saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meal plan: $e'),
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
