import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/meal_plan.dart';
import '../../models/todo_item.dart';
import '../../widgets/quest_completion_dialog.dart';

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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      'Daily Meal Plan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button width
              ],
            ),
          ),
          
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentPage + 1} of 8',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        '${((_currentPage + 1) / 8 * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green[600]!,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          // Survey questions
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.green[600]!),
                        foregroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_currentPage < 7 ? _nextPage : _submitPlan),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentPage < 7 ? 'Next' : 'Save Meal Plan',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPlanDateQuestion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.lightGreen[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 28,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Date',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Step 1 of 8',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'When are you planning?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the date you want to plan your meals for.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(color: Colors.green[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.green[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatSelectedDate(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDateDescription(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green[600],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.lightGreen[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 28,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Your Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step 2 of 8',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What will you eat?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to eat for each meal? Be as specific or general as you prefer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _buildMealField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.green[600], size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: controller,
              maxLines: 2,
              style: const TextStyle(fontSize: 15, height: 1.4),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Meal Location',
          Icons.location_on,
          'Step 3 of 8',
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where will you prepare?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the primary location for meal preparation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...MealPlan.locationOptions.map((location) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedLocation == location ? Colors.green[50] : Colors.white,
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(
                      color: _selectedLocation == location ? Colors.green[300]! : Colors.grey[200]!,
                      width: _selectedLocation == location ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      location,
                      style: TextStyle(
                        fontWeight: _selectedLocation == location ? FontWeight.w600 : FontWeight.normal,
                        color: _selectedLocation == location ? Colors.green[800] : Colors.grey[800],
                      ),
                    ),
                    value: location,
                    groupValue: _selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                    activeColor: Colors.green[600],
                  ),
                );
              }),
              if (_selectedLocation == 'Other') ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _customLocationController,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                    decoration: InputDecoration(
                      labelText: 'Please specify',
                      labelStyle: TextStyle(color: Colors.green[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationMethodsQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Preparation Methods',
          Icons.kitchen,
          'Step 4 of 8',
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you prepare?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all preparation methods you plan to use (you can choose multiple).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: MealPlan.preparationMethodOptions.map((method) {
              final isSelected = _selectedMethods.contains(method);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green[50] : Colors.white,
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: isSelected ? Colors.green[300]! : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    method,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.green[800] : Colors.grey[800],
                    ),
                  ),
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
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortionGoalsQuestion() {
    return _buildTextFieldStep(
      title: 'Portion Goals',
      icon: Icons.straighten,
      step: 'Step 5 of 8',
      subtitle: 'Set your portion goals',
      description: 'Describe your goals for portion sizes and eating patterns.',
      controller: _portionGoalsController,
      hint: 'e.g., Eat moderate portions, listen to hunger cues, include protein at each meal...',
    );
  }

  Widget _buildNutritionGoalsQuestion() {
    return _buildTextFieldStep(
      title: 'Nutrition Goals',
      icon: Icons.health_and_safety,
      step: 'Step 6 of 8',
      subtitle: 'Focus on nutrition',
      description: 'Describe what you want to focus on nutritionally for this meal plan.',
      controller: _nutritionGoalsController,
      hint: 'e.g., Include more vegetables, get enough protein, stay hydrated, eat balanced meals...',
    );
  }

  Widget _buildChallengesQuestion() {
    return _buildTextFieldStep(
      title: 'Anticipated Challenges',
      icon: Icons.warning_amber,
      step: 'Step 7 of 8',
      subtitle: 'Identify challenges',
      description: 'Think about potential obstacles or difficulties you might face with this meal plan.',
      controller: _challengesController,
      hint: 'e.g., Busy schedule, limited time for prep, cravings for unhealthy foods, eating out...',
    );
  }

  Widget _buildStrategiesQuestion() {
    return _buildTextFieldStep(
      title: 'Success Strategies',
      icon: Icons.psychology,
      step: 'Step 8 of 8',
      subtitle: 'Plan for success',
      description: 'Describe specific strategies and coping skills to help you stick to your meal plan.',
      controller: _strategiesController,
      hint: 'e.g., Meal prep on Sunday, pack healthy snacks, set reminders to eat, practice mindful eating...',
    );
  }

  Widget _buildStepHeader(String title, IconData icon, String step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.lightGreen[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
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

  Widget _buildTextFieldStep({
    required String title,
    required IconData icon,
    required String step,
    required String subtitle,
    required String description,
    required TextEditingController controller,
    required String hint,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(title, icon, step),
          const SizedBox(height: 24),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
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
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Handle quest completion for meal planning exercise
  Future<void> _handleActivityCompletion() async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleActivityCompletion(
        userId: user.id,
        activityId: 'meal_planning',
        type: TodoType.tool,
        ref: ref,
      );
      
      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(context, result);
      }
    } catch (e) {
      print('Error checking quest completion: $e');
    }
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
        // Check for quest completion
        await _handleActivityCompletion();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Meal plan saved successfully!')),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            margin: const EdgeInsets.all(16),
          ),
        );
        // Navigate back to exercises tab
        context.go('/exercises');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error saving meal plan: $e')),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            margin: const EdgeInsets.all(16),
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

