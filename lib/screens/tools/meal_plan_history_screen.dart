import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import 'meal_plan_detail_screen.dart';
import 'meal_plan_survey_screen.dart';

class MealPlanHistoryScreen extends ConsumerStatefulWidget {
  final String userId;

  const MealPlanHistoryScreen({super.key, required this.userId});

  @override
  ConsumerState<MealPlanHistoryScreen> createState() => _MealPlanHistoryScreenState();
}

class _MealPlanHistoryScreenState extends ConsumerState<MealPlanHistoryScreen> {
  String _searchQuery = '';
  List<MealPlan> _filteredPlans = [];

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(allUserMealPlansProvider(widget.userId));
    final statisticsAsync = ref.watch(mealPlanStatisticsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan History'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToNewPlan(context),
            icon: const Icon(Icons.add),
            tooltip: 'New Meal Plan',
          ),
          IconButton(
            onPressed: () {
              ref.read(allUserMealPlansProvider(widget.userId).notifier).refreshPlans();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Header
          statisticsAsync.when(
            data: (stats) => _buildStatisticsHeader(context, stats),
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search meal plans...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _filterPlans();
              },
            ),
          ),
          
          // Plans List
          Expanded(
            child: plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                _filteredPlans = _searchQuery.isEmpty 
                    ? plans 
                    : plans.where((plan) =>
                        plan.breakfast.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        plan.lunch.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        plan.dinner.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        plan.snacks.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        plan.nutritionGoals.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        plan.portionGoals.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                
                if (_filteredPlans.isEmpty) {
                  return _buildNoSearchResults(context);
                }
                
                return _buildPlansList(context, _filteredPlans);
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
                        ref.read(allUserMealPlansProvider(widget.userId).notifier).refreshPlans();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewPlan(context),
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatisticsHeader(BuildContext context, Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Your Meal Planning Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Total\nPlans',
                '${stats['totalPlans'] ?? 0}',
                Icons.restaurant_menu,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                context,
                'Complete\nPlans',
                '${stats['completePlans'] ?? 0}',
                Icons.check_circle,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                context,
                'Avg Meals\nPer Plan',
                '${(stats['averageMealsPerPlan'] ?? 0.0).toStringAsFixed(1)}',
                Icons.restaurant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              'Start creating daily meal plans to organize your nutrition goals.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToNewPlan(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No meal plans found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<MealPlan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: plans.length,
      itemBuilder: (context, index) => _buildPlanCard(context, plans[index]),
    );
  }

  Widget _buildPlanCard(BuildContext context, MealPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToPlanDetail(context, plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: plan.isComplete ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      plan.isComplete ? Icons.check_circle : Icons.restaurant_menu,
                      color: plan.isComplete ? Colors.green[600] : Colors.orange[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meal Plan for ${plan.formattedPlanDate}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created ${_formatDateTime(plan.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
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
              if (plan.isComplete) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Complete Plan',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
          Icon(icon, size: 12, color: Colors.grey[600]),
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
      return 'Today at ${_formatTime(dateTime)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else {
      final daysAgo = today.difference(entryDate).inDays;
      if (daysAgo < 7) {
        return '$daysAgo days ago';
      } else if (daysAgo < 30) {
        final weeksAgo = (daysAgo / 7).floor();
        return '$weeksAgo week${weeksAgo == 1 ? '' : 's'} ago';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToPlanDetail(BuildContext context, MealPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealPlanDetailScreen(plan: plan),
      ),
    );
  }

  void _navigateToNewPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealPlanSurveyScreen(),
      ),
    );
  }

  void _filterPlans() {
    // Trigger rebuild to apply search filter
    setState(() {});
  }
}
