import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/addressing_setbacks_provider.dart';
import '../../models/addressing_setbacks.dart';
import 'addressing_setbacks_survey_screen.dart';
import 'addressing_setbacks_history_screen.dart';
import 'addressing_setbacks_detail_screen.dart';

class AddressingSetbacksScreen extends ConsumerWidget {
  const AddressingSetbacksScreen({super.key});

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

    final allExercises = ref.watch(userAddressingSetbacksExercisesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addressing Setbacks'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(userAddressingSetbacksExercisesProvider(user.id).notifier).refreshExercises();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: allExercises.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildExercisesList(context, exercises);
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
                  ref.read(userAddressingSetbacksExercisesProvider(user.id).notifier).refreshExercises();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToSetbacksSurvey(context),
        backgroundColor: Colors.red[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Log'),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, List<AddressingSetbacks> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: exercises.length,
      itemBuilder: (context, index) => _buildExerciseCard(context, exercises[index]),
    );
  }

  Widget _buildExerciseCard(BuildContext context, AddressingSetbacks exercise) {
    final subtitle = exercise.addressPlan.isNotEmpty
        ? exercise.addressPlan
        : (exercise.trigger.isNotEmpty ? 'Trigger: ${exercise.trigger}' : 'No plan yet');

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
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToExerciseDetail(context, exercise),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.trending_down,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setback',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                exercise.problemCause.isEmpty ? 'No cause identified' : exercise.problemCause,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.red,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_down,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Setback Logs Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Log setbacks to better understand patterns and develop strategies for recovery.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGuideSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestExerciseDetails(BuildContext context, AddressingSetbacks exercise) {
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
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.trending_down,
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
                              'Latest Setback Log',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Setback on ${_formatDate(exercise.setbackDate)} • ${exercise.timeSinceSetback}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (exercise.isComplete)
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Guide Section
          _buildGuideSection(context),

          const SizedBox(height: 24),

          // Exercise Details
          _buildSectionCard(
            context,
            'Problem Cause Analysis',
            Icons.help_outline,
            Colors.red,
            Text(
              exercise.problemCause.isEmpty ? 'Not answered yet' : exercise.problemCause,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: exercise.problemCause.isEmpty ? FontStyle.italic : null,
                color: exercise.problemCause.isEmpty ? Colors.grey[500] : null,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildSectionCard(
            context,
            'Trigger & Address Plan',
            Icons.psychology,
            Colors.orange,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trigger:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.trigger.isEmpty ? 'Not identified yet' : exercise.trigger,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: exercise.trigger.isEmpty ? FontStyle.italic : null,
                    color: exercise.trigger.isEmpty ? Colors.grey[500] : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How to Address:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.addressPlan.isEmpty ? 'No plan yet' : exercise.addressPlan,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: exercise.addressPlan.isEmpty ? FontStyle.italic : null,
                    color: exercise.addressPlan.isEmpty ? Colors.grey[500] : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context) {
    return Card(
      color: Colors.red[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Setback Recovery Guide',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Understanding setbacks is key to recovery:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildGuideItem(context, 'Identify the root cause', 'What underlying problem led to the return of binge eating?', Icons.search, Colors.red),
            _buildGuideItem(context, 'Understand triggers', 'What specific event or situation triggered the setback?', Icons.warning, Colors.orange),
            _buildGuideItem(context, 'Plan your response', 'How will you address these triggers in the future?', Icons.assignment, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context, String title, String description, IconData icon, MaterialColor color) {
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateToSetbacksSurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddressingSetbacksSurveyScreen(),
      ),
    );
  }

  void _navigateToAllExercises(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressingSetbacksHistoryScreen(userId: userId),
      ),
    );
  }

  void _navigateToExerciseDetail(BuildContext context, AddressingSetbacks exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressingSetbacksDetailScreen(exercise: exercise),
      ),
    );
  }
}

