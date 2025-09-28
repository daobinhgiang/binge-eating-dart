import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/lesson.dart';
import '../models/todo_item.dart';
import '../screens/lessons/lesson_1_1.dart';
import '../screens/lessons/lesson_1_2.dart';
import '../screens/lessons/lesson_1_3.dart';
import '../screens/lessons/lesson_2_1.dart';
import '../screens/lessons/lesson_2_2.dart';
import '../screens/lessons/lesson_2_3.dart';
import '../screens/lessons/lesson_3_1.dart';
import '../screens/lessons/lesson_3_2.dart';
import '../screens/lessons/lesson_3_3.dart';
import '../screens/lessons/lesson_3_4.dart';
import '../screens/lessons/lesson_3_5.dart';
import '../screens/lessons/lesson_3_6.dart';
import '../screens/lessons/lesson_3_7.dart';
import '../screens/lessons/lesson_3_8.dart';
import '../screens/lessons/lesson_3_9.dart';
import '../screens/lessons/lesson_3_10.dart';
import '../screens/lessons/lesson_s2_0_1.dart';
import '../screens/lessons/lesson_s2_0_2.dart';
import '../screens/lessons/lesson_s2_0_3.dart';
import '../screens/lessons/lesson_s2_0_4.dart';
import '../screens/lessons/lesson_s2_0_5.dart';
import '../screens/lessons/lesson_s2_0_6.dart';
import '../screens/lessons/lesson_s2_1_1.dart';
import '../screens/lessons/lesson_s2_1_2.dart';
import '../screens/lessons/lesson_s2_1_3.dart';
import '../screens/lessons/lesson_s3_0_1.dart';
import '../screens/lessons/lesson_s3_0_2.dart';
import '../screens/assessments/assessment_2_1_screen.dart';
import '../screens/assessments/assessment_2_2_screen.dart';
import '../screens/assessments/assessment_2_3_screen.dart';
import '../screens/assessments/assessment_s3_0_3_screen.dart';
import '../screens/assessments/assessment_s3_0_4_screen.dart';
import '../screens/lessons/lesson_s2_4_3.dart';
import '../screens/lessons/lesson_s2_2_7.dart';
import '../screens/lessons/lesson_s2_3_5.dart';
import '../screens/lessons/lesson_s2_7_2_1.dart';
import '../screens/lessons/lesson_s3_0_2_1.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BED Support App'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          authState.when(
            data: (user) => user != null
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        ref.read(authNotifierProvider.notifier).signOut();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                    child: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(user.displayName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                  )
                : TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login'),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome back message
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Urge help button
            Card(
              color: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red[200]!, width: 1),
              ),
              child: InkWell(
                onTap: _showUrgeHelpDialog,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.psychology, color: Colors.red[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'I have an urge to relapse',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get immediate help and coping strategies',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.red[700],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Inquiries button
            Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue[200]!, width: 1),
              ),
              child: InkWell(
                onTap: () => context.push('/chatbot'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.question_answer, color: Colors.blue[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inquiries',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chat with our assistant to find helpful resources',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next Lesson Recommendation
            authState.when(
              data: (user) => user != null 
                  ? _buildAuthenticatedContent()
                  : _buildGuestContentSection(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => _buildGuestContentSection(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAuthenticatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNextLessonSection(),
        const SizedBox(height: 32),
        _buildAnalyticsSection(),
        const SizedBox(height: 32),
        _buildTodoSection(),
      ],
    );
  }

  Widget _buildNextLessonSection() {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
          'Continue Learning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
        // Lesson recommendations removed with old system
      ],
    );
  }

  Widget _buildLessonRecommendationCard(BuildContext context, Lesson? nextLesson) {
    if (nextLesson == null) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            child: const Icon(Icons.celebration, color: Colors.green),
          ),
          title: const Text('All lessons completed!'),
          subtitle: const Text('Great job! Explore the education section for more content.'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => context.go('/education'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToNextLesson(nextLesson),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Lesson',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextLesson.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextLesson.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${nextLesson.slides.length} slides',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading your next lesson...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.orange),
        title: const Text('Unable to load next lesson'),
        subtitle: const Text('Tap to explore all lessons'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.go('/education'),
      ),
    );
  }

  Widget _buildGuestContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              'Featured Content',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.psychology),
                ),
                title: const Text('Understanding Binge Eating Disorder'),
                subtitle: const Text('Learn about the causes, symptoms, and impact of BED'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/education'),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.favorite),
                ),
                title: const Text('Self-Care Strategies'),
                subtitle: const Text('Practical techniques for managing difficult moments'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/education'),
              ),
            ),
          ],
    );
  }



  Future<void> _navigateToNextLesson(Lesson lesson) async {
    final lessonScreen = _getLessonScreen(lesson);
    
    if (lessonScreen != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => lessonScreen,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
      
      // Lesson completed - no additional action needed for new system
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson not available yet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget? _getLessonScreen(Lesson lesson) {
    // Use lesson ID for direct mapping (supports all stages)
    switch (lesson.id) {
      // Stage 1 lessons
      case 'lesson_1_1': return const Lesson11Screen();
      case 'lesson_1_2': return const Lesson12Screen();
      case 'lesson_1_3': return const Lesson13Screen();
      case 'lesson_2_1': return const Assessment21Screen();
      case 'lesson_2_2': return const Assessment22Screen();
      case 'lesson_2_3': return const Assessment23Screen();
      case 'lesson_3_1': return const Lesson31Screen();
      case 'lesson_3_2': return const Lesson32Screen();
      case 'lesson_3_3': return const Lesson33Screen();
      case 'lesson_3_4': return const Lesson34Screen();
      case 'lesson_3_5': return const Lesson35Screen();
      case 'lesson_3_6': return const Lesson36Screen();
      case 'lesson_3_7': return const Lesson37Screen();
      case 'lesson_3_8': return const Lesson38Screen();
      case 'lesson_3_9': return const Lesson39Screen();
      case 'lesson_3_10': return const Lesson310Screen();
      
      // Stage 2 lessons
      case 'lesson_s2_0_1': return const LessonS201Screen();
      case 'lesson_s2_0_2': return const LessonS202Screen();
      case 'lesson_s2_0_3': return const LessonS203Screen();
      case 'lesson_s2_0_4': return const LessonS204Screen();
      case 'lesson_s2_0_5': return const LessonS205Screen();
      case 'lesson_s2_0_6': return const LessonS206Screen();
      case 'lesson_s2_1_1': return const LessonS211Screen();
      case 'lesson_s2_1_2': return const LessonS212Screen();
      case 'lesson_s2_1_3': return const LessonS213Screen();
      case 'lesson_s2_2_7': return const LessonS227Screen();
      case 'lesson_s2_3_5': return const LessonS235Screen();
      case 'lesson_s2_4_3': return const LessonS243Screen();
      case 'lesson_s2_7_2_1': return const LessonS2721Screen();
      
      // Stage 3 lessons
      case 'lesson_s3_0_1': return const LessonS301Screen();
      case 'lesson_s3_0_2': return const LessonS302Screen();
      case 'lesson_s3_0_2_1': return const LessonS3021Screen();
      case 'lesson_s3_0_3': return const AssessmentS303Screen();
      case 'lesson_s3_0_4': return const AssessmentS304Screen();
    }
    
    return null;
  }

  Widget _buildAnalyticsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return authState.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            
            final analyticsAsync = ref.watch(analyticsNotifierProvider(user.id));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                analyticsAsync.when(
                  data: (analysis) => _buildAnalyticsCard(context, ref, user.id, analysis),
                  loading: () => _buildAnalyticsLoadingCard(context),
                  error: (error, stack) => _buildAnalyticsErrorCard(context, error.toString()),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, WidgetRef ref, String userId, Map<String, dynamic>? analysis) {
    if (analysis == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Analysis Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate insights from your journal entries to see patterns and recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/journal'),
                icon: const Icon(Icons.note_add),
                label: const Text('Go to Journal'),
              ),
            ],
          ),
        ),
      );
    }

    final analysisSummary = analysis['analysis'] as String? ?? 'No analysis available';
    final insights = (analysis['insights'] as List?)?.cast<String>() ?? [];
    final recommendations = (analysis['recommendations'] as List?)?.cast<String>() ?? [];
    final weekNumber = analysis['weekNumber'] as int?;
    final entriesAnalyzed = analysis['entriesAnalyzed'] as int?;
    final recommendedTodos = analysis['recommendedTodos'] as int? ?? 0;
    final todosGenerated = analysis['todosGenerated'] as bool? ?? false;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journal Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      if (weekNumber != null && entriesAnalyzed != null)
                        Text(
                          'Week $weekNumber • $entriesAnalyzed entries analyzed${todosGenerated ? " • $recommendedTodos todos added" : ""}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Analysis summary (truncated)
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analysisSummary.length > 200 
                  ? '${analysisSummary.substring(0, 200)}...'
                  : analysisSummary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...insights.take(2).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              if (insights.length > 2)
                Text(
                  '+ ${insights.length - 2} more insights',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.take(2).map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              if (recommendations.length > 2)
                Text(
                  '+ ${recommendations.length - 2} more recommendations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFullAnalysis(context, analysis),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Full'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Refresh todos and navigate to todo list if todos were generated
                      if (todosGenerated && recommendedTodos > 0) {
                        ref.read(userTodosProvider(userId).notifier).refreshTodos();
                        context.go('/todos');
                      } else {
                        context.go('/journal');
                      }
                    },
                    icon: Icon(todosGenerated && recommendedTodos > 0 ? Icons.list : Icons.note_add, size: 16),
                    label: Text(todosGenerated && recommendedTodos > 0 ? 'View Todos' : 'Add Entries'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading analytics...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsErrorCard(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Journal to generate your first analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/journal'),
              icon: const Icon(Icons.note_add),
              label: const Text('Go to Journal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullAnalysis(BuildContext context, Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Analysis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(analysis['analysis'] as String? ?? 'No analysis available'),
              
              if ((analysis['insights'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Key Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['insights'] as List).cast<String>().map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $insight'),
                  ),
                ),
              ],
              
              if ((analysis['patterns'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Patterns',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['patterns'] as List).cast<String>().map(
                  (pattern) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $pattern'),
                  ),
                ),
              ],
              
              if ((analysis['recommendations'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['recommendations'] as List).cast<String>().map(
                  (recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $recommendation'),
                  ),
                ),
              ],
            ],
          ),
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

  Widget _buildTodoSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return authState.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            
            final userTodosAsync = ref.watch(userTodosProvider(user.id));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your To-Do List',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/todos'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                userTodosAsync.when(
                  data: (todos) => _buildTodoListPreview(context, todos),
                  loading: () => _buildTodoLoadingCard(context),
                  error: (error, stack) => _buildTodoErrorCard(context),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTodoListPreview(BuildContext context, List<TodoItem> todos) {
    if (todos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.task_alt,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add lessons, tools, or journal activities to your to-do list',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/todos/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
      );
    }

    // Show summary stats and preview of tasks
    final pendingTodos = todos.where((todo) => !todo.isCompleted).toList();
    final dueTodayTodos = pendingTodos.where((todo) => todo.isDueToday).toList();
    final overdueTodos = pendingTodos.where((todo) => todo.isOverdue).toList();
    
    final previewTodos = [
      ...overdueTodos.take(2),
      ...dueTodayTodos.take(2),
      ...pendingTodos.where((todo) => !todo.isOverdue && !todo.isDueToday).take(2),
    ].take(3).toList();

    return Card(
      child: InkWell(
        onTap: () => context.go('/todos'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary row
              Row(
                children: [
                  _buildTodoStat(context, 'Total', todos.length.toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _buildTodoStat(context, 'Pending', pendingTodos.length.toString(), Colors.orange),
                  const SizedBox(width: 16),
                  if (overdueTodos.isNotEmpty)
                    _buildTodoStat(context, 'Overdue', overdueTodos.length.toString(), Colors.red),
                ],
              ),
              
              if (previewTodos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Preview todos
                ...previewTodos.map((todo) => _buildTodoPreviewItem(context, todo)),
                
                if (pendingTodos.length > 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+ ${pendingTodos.length - 3} more tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/todos/add'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Task'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/todos'),
                      icon: const Icon(Icons.list, size: 16),
                      label: const Text('View All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoStat(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoPreviewItem(BuildContext context, TodoItem todo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: todo.isOverdue ? Colors.red : (todo.isDueToday ? Colors.orange : Colors.grey),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${todo.typeDisplayName} • Due ${_formatDueDate(todo.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading your tasks...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoErrorCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.orange),
        title: const Text('Unable to load tasks'),
        subtitle: const Text('Tap to try again'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.go('/todos'),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    
    if (dueDate.isBefore(today)) {
      final daysAgo = today.difference(dueDate).inDays;
      return '$daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else if (dueDate.isAtSameMomentAs(today)) {
      return 'today';
    } else {
      final daysFromNow = dueDate.difference(today).inDays;
      if (daysFromNow == 1) {
        return 'tomorrow';
      } else {
        return 'in $daysFromNow days';
      }
    }
  }
  
  void _showUrgeHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.red[700]),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Coping with Urges'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When you experience urges to relapse, these resources can help:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Learn about urges and coping strategies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Old lesson navigation options removed
              const SizedBox(height: 16),
              const Text(
                '2. Practice practical coping skills:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHelpOptionCard(
                context,
                'Urge Surfing Activity',
                'Practical exercises to manage urges as they arise',
                Icons.waves,
                Colors.teal,
                () => _navigateToUrgeSurfing(),
              ),
            ],
          ),
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
  
  Widget _buildHelpOptionCard(BuildContext context, String title, String description, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.zero,
      color: color[50],
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(); // Close dialog first
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Old lesson navigation methods removed
  
  void _navigateToUrgeSurfing() {
    context.push('/tools/urge-surfing');
  }
}
