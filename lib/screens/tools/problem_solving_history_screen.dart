import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/problem_solving.dart';
import '../../providers/problem_solving_provider.dart';
import 'problem_solving_detail_screen.dart';
import 'problem_solving_survey_screen.dart';

class ProblemSolvingHistoryScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProblemSolvingHistoryScreen({super.key, required this.userId});

  @override
  ConsumerState<ProblemSolvingHistoryScreen> createState() => _ProblemSolvingHistoryScreenState();
}

class _ProblemSolvingHistoryScreenState extends ConsumerState<ProblemSolvingHistoryScreen> {
  String _searchQuery = '';
  List<ProblemSolving> _filteredExercises = [];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(userProblemSolvingExercisesProvider(widget.userId));
    final statisticsAsync = ref.watch(problemSolvingStatisticsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Solving History'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToNewExercise(context),
            icon: const Icon(Icons.add),
            tooltip: 'New Exercise',
          ),
          IconButton(
            onPressed: () {
              ref.read(userProblemSolvingExercisesProvider(widget.userId).notifier).refreshExercises();
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
                hintText: 'Search exercises...',
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
                _filterExercises();
              },
            ),
          ),
          
          // Exercises List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                _filteredExercises = _searchQuery.isEmpty 
                    ? exercises 
                    : exercises.where((exercise) =>
                        exercise.problemDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        exercise.specificProblems.any((problem) => 
                            problem.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                        exercise.potentialSolutions.any((solution) =>
                            solution.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            solution.implications.toLowerCase().contains(_searchQuery.toLowerCase()))
                      ).toList();
                
                if (_filteredExercises.isEmpty) {
                  return _buildNoSearchResults(context);
                }
                
                return _buildExercisesList(context, _filteredExercises);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Error loading exercises: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(userProblemSolvingExercisesProvider(widget.userId).notifier).refreshExercises();
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
        onPressed: () => _navigateToNewExercise(context),
        backgroundColor: Colors.deepOrange[600],
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
          colors: [Colors.deepOrange[600]!, Colors.deepOrange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Your Progress',
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
                'Total\nExercises',
                '${stats['totalExercises'] ?? 0}',
                Icons.psychology,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                context,
                'Completed\nExercises',
                '${stats['completedExercises'] ?? 0}',
                Icons.check_circle,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                context,
                'Completion\nRate',
                '${((stats['completionRate'] ?? 0.0) * 100).round()}%',
                Icons.trending_up,
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
              Icons.psychology_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Problem Solving Exercises Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start your first problem solving exercise to begin developing structured thinking skills.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToNewExercise(context),
              icon: const Icon(Icons.add),
              label: const Text('Start First Exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange[600],
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
              'No exercises found',
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

  Widget _buildExercisesList(BuildContext context, List<ProblemSolving> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) => _buildExerciseCard(context, exercises[index]),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ProblemSolving exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToExerciseDetail(context, exercise),
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
                      color: exercise.isComplete ? Colors.green[100] : Colors.deepOrange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      exercise.isComplete ? Icons.check_circle : Icons.psychology,
                      color: exercise.isComplete ? Colors.green[600] : Colors.deepOrange[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.problemDescription,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(exercise.createdAt),
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
                  _buildStatChip(context, Icons.list_alt, '${exercise.specificProblems.length} problems'),
                  const SizedBox(width: 8),
                  _buildStatChip(context, Icons.lightbulb_outline, '${exercise.potentialSolutions.length} solutions'),
                  const SizedBox(width: 8),
                  _buildStatChip(context, Icons.check_circle_outline, '${exercise.chosenSolutionIds.length} chosen'),
                ],
              ),
              if (exercise.isComplete) ...[
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
                        'Exercise Complete',
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

  void _navigateToExerciseDetail(BuildContext context, ProblemSolving exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemSolvingDetailScreen(exercise: exercise),
      ),
    );
  }

  void _navigateToNewExercise(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProblemSolvingSurveyScreen(),
      ),
    );
  }

  void _filterExercises() {
    // Trigger rebuild to apply search filter
    setState(() {});
  }
}
