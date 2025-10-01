import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../providers/weight_diary_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/food_diary.dart';
import '../../models/body_image_diary.dart';
import '../../models/weight_diary.dart';
import '../../widgets/tropical_forest_background.dart';
import 'food_diary_survey_screen.dart';
import 'body_image_diary_survey_screen.dart';
import 'weight_diary_survey_screen.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

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

    final currentWeekNumber = ref.watch(currentWeekNumberProvider(user.id));
    final currentWeekFoodDiaries = ref.watch(currentWeekFoodDiariesProvider(user.id));
    final currentWeekBodyImageDiaries = ref.watch(currentWeekBodyImageDiariesProvider(user.id));
    final currentWeekWeightDiaries = ref.watch(currentWeekWeightDiariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(currentWeekFoodDiariesProvider(user.id).notifier).refreshEntries();
              ref.read(currentWeekBodyImageDiariesProvider(user.id).notifier).refreshEntries();
              ref.read(currentWeekWeightDiariesProvider(user.id).notifier).refreshEntries();
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'generate_analysis') {
                _generateAnalysis(context, ref, user.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_analysis',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Generate Analysis'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: TropicalForestBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with current week
            currentWeekNumber.when(
              data: (weekNumber) => Container(
            width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
            child: Column(
              children: [
                Text(
                      'Week $weekNumber',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your eating patterns and behaviors',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Container(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading week: $error'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Survey Cards
            Text(
              'Surveys',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
            // Food Diary Survey Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _navigateToFoodDiarySurvey(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                              'Food Diary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log your meals and eating behaviors',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Weight Diary Survey Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _navigateToWeightDiarySurvey(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.monitor_weight,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weight Diary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log your weight and track progress',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 16),
            
            // Body Image Diary Survey Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _navigateToBodyImageDiarySurvey(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.teal[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Body Image Diary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track body checking behaviors',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Generate Analysis Section
            _buildGenerateAnalysisSection(context, ref, user.id),
            
            const SizedBox(height: 24),
            
            // Recent entries section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllEntries(context, user.id),
                  child: const Text('View All'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Combined recent entries from all diaries
            _buildCombinedRecentEntries(context, currentWeekFoodDiaries, currentWeekBodyImageDiaries, currentWeekWeightDiaries),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFoodDiaryCard(BuildContext context, FoodDiary entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(
                  _formatTime(entry.mealTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                      Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                    color: entry.isBinge ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                    entry.isBinge ? 'Binge' : 'Normal',
                    style: TextStyle(
                      color: entry.isBinge ? Colors.red[700] : Colors.green[700],
                      fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
            Text(
              entry.foodAndDrinks,
                                      style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  entry.displayLocation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildCombinedRecentEntries(
    BuildContext context,
    AsyncValue<List<FoodDiary>> foodDiaries,
    AsyncValue<List<BodyImageDiary>> bodyImageDiaries,
    AsyncValue<List<WeightDiary>> weightDiaries,
  ) {
    return foodDiaries.when(
      data: (foodEntries) {
        return bodyImageDiaries.when(
          data: (bodyImageEntries) {
            return weightDiaries.when(
              data: (weightEntries) {
                final hasAnyEntries = foodEntries.isNotEmpty || bodyImageEntries.isNotEmpty || weightEntries.isNotEmpty;

                if (!hasAnyEntries) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit_note_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries yet this week',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking with Food, Weight, or Body Image entries',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allEntries = <Widget>[];

                // Add food diary cards
                for (final entry in foodEntries.take(2)) {
                  allEntries.add(_buildFoodDiaryCard(context, entry));
                }

                // Add weight diary cards
                for (final entry in weightEntries.take(2)) {
                  allEntries.add(_buildWeightDiaryCard(context, entry));
                }

                // Add body image diary cards
                for (final entry in bodyImageEntries.take(2)) {
                  allEntries.add(_buildBodyImageDiaryCard(context, entry));
                }

                return Column(children: allEntries);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Container(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading weight entries: $error'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading body image entries: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading food entries: $error'),
      ),
    );
  }

  Widget _buildWeightDiaryCard(BuildContext context, WeightDiary entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor_weight,
                color: Colors.orange[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weight Diary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        _formatTime(entry.createdAt),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.displayWeight,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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

  void _navigateToFoodDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodDiarySurveyScreen(),
      ),
    );
  }

  Widget _buildBodyImageDiaryCard(BuildContext context, BodyImageDiary entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.visibility,
                color: Colors.teal[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Body Image Diary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[600],
                        ),
                      ),
                      Text(
                        entry.displayCheckTime,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.displayHowChecked} • ${entry.displayWhereChecked}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWeightDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeightDiarySurveyScreen(),
      ),
    );
  }

  void _navigateToBodyImageDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BodyImageDiarySurveyScreen(),
      ),
    );
  }

  Widget _buildGenerateAnalysisSection(BuildContext context, WidgetRef ref, String userId) {
    final analyticsAsync = ref.watch(analyticsNotifierProvider(userId));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get insights and patterns from your journal entries',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            analyticsAsync.when(
              data: (analysis) {
                if (analysis != null) {
                  final weekNumber = analysis['weekNumber'] as int?;
                  final entriesAnalyzed = analysis['entriesAnalyzed'] as int?;
                  final generatedAt = analysis['generatedAt'] as String?;
                  final recommendedTodos = analysis['recommendedTodos'] as int? ?? 0;
                  final todosGenerated = analysis['todosGenerated'] as bool? ?? false;
                  
                  String timeAgo = '';
                  if (generatedAt != null) {
                    try {
                      final generatedTime = DateTime.parse(generatedAt);
                      final now = DateTime.now();
                      final difference = now.difference(generatedTime).inHours;
                      
                      if (difference < 1) {
                        timeAgo = 'Just now';
                      } else if (difference < 24) {
                        timeAgo = '${difference}h ago';
                      } else {
                        timeAgo = '${difference ~/ 24}d ago';
                      }
                    } catch (e) {
                      timeAgo = 'Recently';
                    }
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Analysis complete for Week $weekNumber • $entriesAnalyzed entries • $timeAgo',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (todosGenerated && recommendedTodos > 0)
                                    Text(
                                      '✨ $recommendedTodos personalized tasks added to your to-do list',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _generateAnalysis(context, ref, userId),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Regenerate'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _viewAnalysisOnHome(context, ref, userId, todosGenerated, recommendedTodos),
                              icon: Icon(todosGenerated && recommendedTodos > 0 ? Icons.list : Icons.home, size: 16),
                              label: Text(todosGenerated && recommendedTodos > 0 ? 'View Todos' : 'View on Home'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate an AI-powered analysis of your journal entries to discover patterns, insights, and personalized recommendations for your recovery journey.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _generateAnalysis(context, ref, userId),
                          icon: const Icon(Icons.analytics),
                          label: const Text('Generate Analysis'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Analyzing your journal entries...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This may take a few moments as AI reviews your entries.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Failed to generate analysis: ${error.toString()}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generateAnalysis(context, ref, userId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
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

  void _generateAnalysis(BuildContext context, WidgetRef ref, String userId) {
    ref.read(analyticsNotifierProvider(userId).notifier).generateAnalysis();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating analysis from your journal entries...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewAnalysisOnHome(BuildContext context, WidgetRef ref, String userId, bool todosGenerated, int recommendedTodos) {
    if (todosGenerated && recommendedTodos > 0) {
      // Refresh todos and navigate to todo list
      ref.read(userTodosProvider(userId).notifier).refreshTodos();
      Navigator.of(context).pushNamedAndRemoveUntil('/todos', (route) => false);
    } else {
      // Navigate to home and show the analytics section
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _showAllEntries(BuildContext context, String userId) {
    // TODO: Navigate to a detailed view of all entries
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All entries view coming soon!')),
    );
  }
}
