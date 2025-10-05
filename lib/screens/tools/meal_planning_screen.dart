import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../models/meal_plan.dart';
import 'meal_plan_survey_screen.dart';
import 'meal_plan_history_screen.dart';
import 'meal_plan_detail_screen.dart';

class MealPlanningScreen extends ConsumerWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final allPlans = ref.watch(allUserMealPlansProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planning'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(allUserMealPlansProvider(user.id).notifier).refreshPlans();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: allPlans.when(
        data: (plans) {
          if (plans.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildPlansList(context, plans);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Error loading meal plans: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(allUserMealPlansProvider(user.id).notifier).refreshPlans();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToMealPlanSurvey(context),
        backgroundColor: Colors.green[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Meal Plan'),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<MealPlan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: plans.length,
      itemBuilder: (context, index) => _buildPlanCard(context, plans[index]),
    );
  }

  Widget _buildPlanCard(BuildContext context, MealPlan plan) {
    String subtitle = _summarizeMeals(plan);
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
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToPlanDetail(context, plan),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meal Plan',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.formattedPlanDate,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
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

  String _summarizeMeals(MealPlan plan) {
    final parts = <String>[];
    if (plan.breakfast.isNotEmpty) parts.add('Breakfast: ${plan.breakfast}');
    if (plan.lunch.isNotEmpty) parts.add('Lunch: ${plan.lunch}');
    if (plan.dinner.isNotEmpty) parts.add('Dinner: ${plan.dinner}');
    if (plan.snacks.isNotEmpty) parts.add('Snacks: ${plan.snacks}');
    return parts.isEmpty ? 'No meals added yet' : parts.join(' • ');
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Meal Plans Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first daily meal plan using the button above.',
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

  Widget _buildLatestPlanDetails(BuildContext context, MealPlan plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latest Meal Plan',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'For ${plan.formattedPlanDate} • Created ${_formatDateTime(plan.createdAt)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (plan.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'Complete',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatChip(context, Icons.restaurant, '${plan.plannedMealsCount}/4 meals'),
                      const SizedBox(width: 8),
                      _buildStatChip(context, Icons.location_on, plan.displayLocation),
                      const SizedBox(width: 8),
                      _buildStatChip(context, Icons.build, '${plan.preparationMethods.length} methods'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Meals Section
          _buildSectionCard(
            context,
            'Planned Meals',
            Icons.restaurant_menu,
            Colors.green,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMealRow(context, 'Breakfast', Icons.wb_sunny, plan.breakfast),
                const SizedBox(height: 12),
                _buildMealRow(context, 'Lunch', Icons.lunch_dining, plan.lunch),
                const SizedBox(height: 12),
                _buildMealRow(context, 'Dinner', Icons.dinner_dining, plan.dinner),
                if (plan.snacks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildMealRow(context, 'Snacks', Icons.local_cafe, plan.snacks),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Preparation Details
          _buildSectionCard(
            context,
            'Preparation Plan',
            Icons.kitchen,
            Colors.blue,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Location: ${plan.displayLocation}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.build, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Methods:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: plan.preparationMethods.map((method) => 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  method,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Goals Section
          _buildSectionCard(
            context,
            'Goals & Strategies',
            Icons.flag,
            Colors.orange,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalRow(context, 'Portion Goals', Icons.straighten, plan.portionGoals),
                const SizedBox(height: 16),
                _buildGoalRow(context, 'Nutrition Goals', Icons.health_and_safety, plan.nutritionGoals),
                const SizedBox(height: 16),
                _buildGoalRow(context, 'Anticipated Challenges', Icons.warning, plan.challenges),
                const SizedBox(height: 16),
                _buildGoalRow(context, 'Success Strategies', Icons.psychology, plan.strategies),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMealRow(BuildContext context, String mealType, IconData icon, String meal) {
    if (meal.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(BuildContext context, String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange[600], size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, MaterialColor color, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'today at ${_formatTime(dateTime)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'yesterday at ${_formatTime(dateTime)}';
    } else {
      final daysAgo = today.difference(entryDate).inDays;
      if (daysAgo < 7) {
        return '$daysAgo days ago at ${_formatTime(dateTime)}';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${_formatTime(dateTime)}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToMealPlanSurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealPlanSurveyScreen(),
      ),
    );
  }

  void _navigateToAllPlans(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealPlanHistoryScreen(userId: userId),
      ),
    );
  }

  void _navigateToPlanDetail(BuildContext context, MealPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealPlanDetailScreen(plan: plan),
      ),
    );
  }
}

