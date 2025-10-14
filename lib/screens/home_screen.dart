import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/education_provider.dart';
import '../providers/exp_provider.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../../models/stage.dart';
import '../../models/lesson.dart';
import '../providers/firebase_analytics_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../core/services/exp_service.dart';
import '../models/todo_item.dart';
import '../core/services/user_learning_service.dart';
import '../core/services/reset_timer_service.dart';
import '../widgets/level_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _scrollController;
  
  
  // Timer state
  DateTime? _lastResetTime;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadLastResetTime();
    _startTimer();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastResetTime() async {
    final lastReset = await ResetTimerService().getLastResetTime();
    if (mounted) {
      setState(() {
        _lastResetTime = lastReset;
      });
    }
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild every second to update the timer display
        });
      }
    });
  }

  // Helper methods for enhanced header
  String _getTimeBasedGreeting(String? firstName) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    if (firstName != null && firstName.isNotEmpty) {
      return '$timeGreeting, $firstName!';
    } else {
      return '$timeGreeting!';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final day = now.day;
    final month = _getMonthName(now.month);
    final year = now.year;
    
    return '$weekday, $month $day, $year';
  }

  

  Widget _buildAppLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple icon if image fails to load
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF64B5F6), // Light blue
                    Color(0xFF4CAF50), // Green
                    Color(0xFFFFB74D), // Light orange
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildProfileSection(AsyncValue authState) {
    // Show level badge for logged in users
    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        return Consumer(
          builder: (context, ref, child) {
            final userExp = ref.watch(userExpProvider);
            if (userExp == null) return const SizedBox.shrink();
            
            return LevelBadge(
              level: userExp.level,
              size: 48,
              showLabel: false,
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLevelExpDisplay(bool onGreenBackground) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        final user = authState.valueOrNull;
        
        if (user == null) {
          return const SizedBox.shrink();
        }
        
        final userExp = ref.watch(userExpProvider);
        if (userExp == null) {
          return const SizedBox.shrink();
        }
        
        final service = ExpService();
        final progress = service.getCurrentLevelProgress(userExp.exp, userExp.level);
        final expRemaining = service.getExpRemainingForNextLevel(userExp.exp, userExp.level);
        final isMaxLevel = userExp.level >= 5;
        
        final textColor = Colors.black87;  // Always use dark text for better visibility
        final subtextColor = Colors.grey[700]!;  // Slightly darker grey for better contrast
        
        return Row(
          children: [
            // Level badge
            LevelBadge(
              level: userExp.level,
              size: 56,
              showLabel: true,
            ),
            const SizedBox(width: 16),
            // EXP info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${userExp.exp} EXP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!isMaxLevel) ...[
                    Text(
                      '$expRemaining to Level ${userExp.level + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],  // Light grey background
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF4CAF50),  // Always use green for progress
                        ),
                      ),
                    ),
                  ] else
                    Text(
                      'Max Level!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          clipBehavior: Clip.none,
          slivers: [
            // Combined header and Continue Learning Section with green background
            SliverToBoxAdapter(
              child: _buildCombinedHeaderAndLearningSection(authState),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                        // Recovery Tools section with header inside container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recovery Tools header
                        Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                              child: Text(
                                  'Recovery Tools',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                              // Recovery Tools list
                              Column(
                            children: [
                                  _buildToolItem(
                                    icon: Icons.psychology_outlined,
                                    title: 'Recovery Guide',
                                    description: 'Your personalized guide',
                                    onTap: () => context.push('/chat'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildToolItem(
                                    icon: Icons.edit_note_outlined,
                                    title: 'Journaling Partner',
                                    description: 'Track your progress',
                                    onTap: () => context.push('/realtime-journaling'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildToolItem(
                                    icon: Icons.people_outline,
                                    title: 'Accountability Partner',
                                    description: 'Connect with support',
                                    onTap: () => context.push('/accountability-partner'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildToolItem(
                                    icon: Icons.insights_outlined,
                                    title: 'Insights',
                                    description: 'Understand your patterns',
                                    onTap: () => context.push('/insights'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                ],
                                    ),
                                  ],
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
            ),
          ],
        ),
      );
  }


  Widget _buildAuthenticatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodoSection(),
      ],
    );
  }

  Widget _buildCombinedHeaderAndLearningSection(AsyncValue authState) {
    return Consumer(
      builder: (context, ref, child) {
        final user = authState.valueOrNull;
        final shouldShowLearningSection = user != null;
        
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              // Header section
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Row(
                          children: [
                            // Level and EXP display
                            Expanded(
                              child: _buildLevelExpDisplay(shouldShowLearningSection),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
              // Continue Learning content (if logged in)
              if (shouldShowLearningSection)
                    _buildContinueLearningContentOnly(ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueLearningContentOnly(WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Binge-Free Timer
          _buildBingeFreeTimer(),
          
          const SizedBox(height: 16),
          
          // Urge Help and Motivation buttons in same row
          Row(
            children: [
              Expanded(
                child: _buildUrgeHelpButton(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMotivationButton(),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Lesson? _firstLesson(List<Stage> stages) {
    for (final stage in stages) {
      for (final chapter in stage.chapters) {
        if (chapter.lessons.isNotEmpty) return chapter.lessons.first;
      }
    }
    return null;
  }

  Lesson? _findNextLesson(List<Stage> stages, String currentLessonId) {
    final flat = <Lesson>[];
    for (final stage in stages) {
      for (final chapter in stage.chapters) {
        flat.addAll(chapter.lessons);
      }
    }
    for (int i = 0; i < flat.length; i++) {
      if (flat[i].id == currentLessonId) {
        if (i + 1 < flat.length) return flat[i + 1];
        return null; // No next lesson
      }
    }
    return null; // Not found
  }

  Widget _buildNextLessonCard(Lesson lesson) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToLesson(lesson),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_lesson,
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
                        'Up Next',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF4CAF50)),
              ],
            ),
          ),
        ),
      ),
    );
  }





  void _navigateToLesson(Lesson lesson) {
    // Navigate to the specific lesson based on lesson ID
    final lessonId = lesson.id;
    
    // Convert lesson ID to route path
    String routePath;
    if (lessonId.startsWith('lesson_1_') || lessonId.startsWith('lesson_2_') || lessonId.startsWith('lesson_3_')) {
      routePath = '/lesson/${lessonId.replaceFirst('lesson_', '')}';
    } else if (lessonId.startsWith('lesson_s2_')) {
      routePath = '/lesson/${lessonId.replaceFirst('lesson_s2_', 's2_')}';
    } else if (lessonId.startsWith('lesson_s3_')) {
      routePath = '/lesson/${lessonId.replaceFirst('lesson_s3_', 's3_')}';
    } else {
      routePath = '/lesson/${lessonId.replaceFirst('lesson_', '')}';
    }
    
    context.push(routePath);
  }




  Widget _buildGuestContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Content',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Understanding BED card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F8F0), // Very light green tint
                Color(0xFFE8F5E8), // Light green tint
                Color(0xFFE0F2E0), // Slightly more green
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF4CAF50)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Understanding Binge Eating Disorder',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Learn about the causes, symptoms, and impact of BED',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Self-Care Strategies card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F9F5), // Very light green tint
                Color(0xFFEDF5ED), // Light green tint
                Color(0xFFE5F0E5), // Slightly more green
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Self-Care Strategies',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Practical techniques for managing difficult moments',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
            
            return userTodosAsync.when(
              data: (todos) => _buildDailyTasksWidget(context, todos, ref),
                  loading: () => _buildTodoLoadingCard(context),
                  error: (error, stack) => _buildTodoErrorCard(context),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDailyTasksWidget(BuildContext context, List<TodoItem> todos, WidgetRef ref) {
    // Get all today's todos (both completed and incomplete)
    final todayTodos = todos.where((todo) => todo.isDueToday).toList();
    
    if (todayTodos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and "See All" button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Tasks',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 24,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/todos'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See all tasks',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
          ),
          // Tasks list
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: todayTodos.map((todo) => _buildDailyTaskItem(context, todo, ref)).toList(),
            ),
            ),
          ],
        ),
    );
  }

  Widget _buildDailyTaskItem(BuildContext context, TodoItem todo, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToTodoItem(todo),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => _toggleTodoCompletion(todo, ref),
                child: Container(
                  width: 32,
                  height: 32,
      decoration: BoxDecoration(
                    color: todo.isCompleted ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
        border: Border.all(
                      color: todo.isCompleted ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: todo.isCompleted
                      ? const Icon(
                          Icons.check,
                    color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Task text
          Expanded(
                child: Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    fontSize: 16,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey[400],
                    decorationThickness: 2,
                  ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Future<void> _toggleTodoCompletion(TodoItem todo, WidgetRef ref) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    if (user == null) return;
    
    final todoNotifier = ref.read(userTodosProvider(user.id).notifier);
    await todoNotifier.toggleCompletion(todo.id);
  }

  void _navigateToTodoItem(TodoItem todo) {
    // Navigate based on the todo type and activity ID
    switch (todo.type) {
      case TodoType.lesson:
        if (todo.activityId.isNotEmpty) {
          _navigateToLessonById(todo.activityId);
        }
        break;
      case TodoType.journal:
        if (todo.activityId.isNotEmpty) {
          _navigateToJournalById(todo.activityId);
        }
        break;
      case TodoType.tool:
        if (todo.activityId.isNotEmpty) {
          _navigateToToolById(todo.activityId);
        }
        break;
    }
  }

  void _navigateToLessonById(String lessonId) {
    // Same logic as existing lesson navigation
    if (lessonId.startsWith('lesson_1_') || lessonId.startsWith('lesson_2_') || lessonId.startsWith('lesson_3_')) {
      context.push('/lesson/${lessonId.replaceFirst('lesson_', '')}');
    } else if (lessonId.startsWith('lesson_s2_')) {
      context.push('/lesson/${lessonId.replaceFirst('lesson_s2_', 's2_')}');
    } else if (lessonId.startsWith('lesson_s3_')) {
      context.push('/lesson/${lessonId.replaceFirst('lesson_s3_', 's3_')}');
    } else {
      context.push('/lesson/${lessonId.replaceFirst('lesson_', '')}');
    }
  }

  void _navigateToJournalById(String journalType) {
    // Normalize the journal type string
    final normalized = journalType.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    
    switch (normalized) {
      case 'food_diary':
      case 'food':
        context.push('/journal/food-diary');
        break;
      case 'weight_diary':
      case 'weight':
        context.push('/journal/weight-diary');
        break;
      case 'body_image_diary':
      case 'body_image':
        context.push('/journal/body-image-diary');
        break;
      default:
        // Try to construct the route from the journalType
        if (normalized.contains('food')) {
          context.push('/journal/food-diary');
        } else if (normalized.contains('weight')) {
          context.push('/journal/weight-diary');
        } else if (normalized.contains('body') || normalized.contains('image')) {
          context.push('/journal/body-image-diary');
        } else {
          // Fallback to generic journal page if we can't determine the type
          context.push('/journal');
        }
    }
  }

  void _navigateToToolById(String toolName) {
    final normalized = toolName.toLowerCase().replaceAll(' ', '-');
    context.push('/tools/$normalized');
  }


  String _getWeekdayName(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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

  
  void _showUrgeHelpDialog() {
    // Track dialog opening
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('dialog_opened');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
            ),
          ],
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE57373).withOpacity(0.15),
                      const Color(0xFFEF5350).withOpacity(0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE57373).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Color(0xFFE57373),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                            'Coping with Urges',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE57373),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take control with these tools',
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
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When you experience urges, these resources can help you stay on track:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
              _buildHelpOptionCard(
                context,
                'Urge Surfing Activity',
                'Practical exercises to manage urges as they arise',
                Icons.waves,
                      const Color(0xFFE57373),
                () => _navigateToUrgeSurfing(),
              ),
            ],
          ),
        ),
              // Actions
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
            onPressed: () {
              // Track dialog close
              final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
              trackDialog('dialog_closed');
              Navigator.of(context).pop();
            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHelpOptionCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Close dialog first
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
                    children: [
                      Container(
                  padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: color,
                                ),
                              ),
                            ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Old lesson navigation methods removed
  
  void _navigateToUrgeSurfing() {
    // Track urge surfing navigation from help dialog
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('urge_surfing_navigation');
    context.push('/tools/urge-surfing');
  }
  
  Widget _buildToolItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? onTap,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.all(16),
            child: Row(
              children: [
              // Icon with circular background
                Container(
                width: 48,
                height: 48,
                  decoration: BoxDecoration(
                  color: iconBgColor,
                          shape: BoxShape.circle,
                  ),
                  child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        fontSize: 16,
                        ),
                      ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                        fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              // Navigation arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                size: 16,
                ),
              ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[200],
    );
  }
  

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleResetButton,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.refresh,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Reset',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgeHelpButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Track analytics for urge-relapse button usage
            final trackUrgeButton = ref.read(urgeRelapseButtonTrackingProvider);
            trackUrgeButton();
            _showUrgeHelpDialog();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Urge Help',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/motivation'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Motivation',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetButton() async {
    try {
      final isFirstTime = _lastResetTime == null;
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isFirstTime ? Icons.play_arrow : Icons.refresh, 
                color: isFirstTime ? const Color(0xFF4CAF50) : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(isFirstTime ? 'Start Timer' : 'Reset Timer'),
            ],
          ),
          content: Text(
            isFirstTime 
              ? 'Ready to start tracking your binge-free progress?'
              : 'Are you sure you want to reset your timer? This will log a new reset time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFirstTime ? const Color(0xFF4CAF50) : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(isFirstTime ? 'Start' : 'Reset'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Log the reset time
        await ResetTimerService().logResetTime();

        // Reload the last reset time
        await _loadLastResetTime();

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFirstTime ? 'Timer started! Good luck on your journey!' : 'Reset time logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log reset time: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBingeFreeTimer() {
    if (_lastResetTime == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Start tracking your binge-free progress',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleResetButton,
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text(
                'Start Timer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    final duration = DateTime.now().difference(_lastResetTime!);
    
    // Calculate time units
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    // Build list of all non-zero time units to display
    List<Map<String, dynamic>> timeUnits = [];
    
    // Determine font size based on how many units we'll show
    double fontSize;
    if (days > 0) {
      fontSize = 36.0; // 4 units: days, hours, minutes, seconds
    } else if (hours > 0) {
      fontSize = 42.0; // 3 units: hours, minutes, seconds
    } else if (minutes > 0) {
      fontSize = 48.0; // 2 units: minutes, seconds
    } else {
      fontSize = 72.0; // 1 unit: seconds only
    }
    
    if (days > 0) {
      timeUnits.add({
        'value': days.toString().padLeft(2, '0'),
        'label': days == 1 ? 'day' : 'days',
        'size': fontSize,
      });
    }
    if (hours > 0 || days > 0) {
      timeUnits.add({
        'value': hours.toString().padLeft(2, '0'),
        'label': 'hrs',
        'size': fontSize,
      });
    }
    if (minutes > 0 || hours > 0 || days > 0) {
      timeUnits.add({
        'value': minutes.toString().padLeft(2, '0'),
        'label': 'min',
        'size': fontSize,
      });
    }
    // Always show seconds
    timeUnits.add({
      'value': seconds.toString().padLeft(2, '0'),
      'label': 'sec',
      'size': fontSize,
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Title
          const Text(
            'Binge-Free For',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Circular progress indicator
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
            ? _buildIOSTimerLayout(timeUnits, days, hours, minutes, seconds)
            : SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular progress rings
                    CustomPaint(
                      size: const Size(320, 320),
                      painter: CircularTimerPainter(
                        days: days,
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                      ),
                    ),
                    
                    // Center text - display all non-zero time units
                    Column(
          mainAxisAlignment: MainAxisAlignment.center,
                      children: timeUnits.asMap().entries.map((entry) {
                        final unit = entry.value;
                        final index = entry.key;
                        final fontSize = unit['size'] as double;
                        final labelSize = fontSize * 0.35;
                        
                        return Column(
          children: [
                          if (index > 0) const SizedBox(height: 4),
                          Row(
              mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                                unit['value'] as String,
                  style: TextStyle(
                                  fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5B9FED),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                unit['label'] as String,
                                style: TextStyle(
                                  fontSize: labelSize,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                ],
              );
            }).toList(),
                    ),
          ],
        ),
              ),

          const SizedBox(height: 16),
    
          // Legend
          Column(
            children: [
              // First row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Days', const Color(0xFF4CAF50)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Hours', const Color(0xFF9C27B0)),
                ],
              ),
              const SizedBox(height: 8),
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Minutes', const Color(0xFFFF9800)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Seconds', const Color(0xFF2196F3)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Reset Timer button
          ElevatedButton.icon(
            onPressed: _handleResetButton,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Reset Timer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildIOSTimerLayout(List<Map<String, dynamic>> timeUnits, int days, int hours, int minutes, int seconds) {
    return Column(
      children: [
        // Circular progress rings
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            size: const Size(280, 280),
            painter: CircularTimerPainter(
              days: days,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Time units displayed in a row below the circle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: timeUnits.map((unit) {
            final fontSize = 24.0;
            final labelSize = 12.0;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    unit['value'] as String,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5B9FED),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit['label'] as String,
                    style: TextStyle(
                      fontSize: labelSize,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  
}

// Custom painter for circular timer rings
class CircularTimerPainter extends CustomPainter {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  CircularTimerPainter({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 16.0;
    
    // Calculate progress values (normalized to 0-1)
    // Seconds: Progress through current minute (resets every 60 seconds)
    final secondsProgress = (seconds / 60).clamp(0.0, 1.0);
    
    // Minutes: Progress through current hour (resets every 60 minutes)
    final minutesProgress = (minutes / 60).clamp(0.0, 1.0);
    
    // Hours: Progress through current day (resets every 24 hours)
    final hoursProgress = (hours / 24).clamp(0.0, 1.0);
    
    // Days: Progress through current month (resets every 30 days)
    final daysProgress = (days % 30 / 30).clamp(0.0, 1.0);
    
    // Define ring radii (from outer to inner)
    final daysRadius = size.width / 2 - strokeWidth / 2;
    final hoursRadius = daysRadius - strokeWidth - 8;
    final minutesRadius = hoursRadius - strokeWidth - 8;
    final secondsRadius = minutesRadius - strokeWidth - 8;
    
    // App-themed colors for better visual variety
    final daysColor = const Color(0xFF4CAF50); // Light Green (matches app theme)
    final hoursColor = const Color(0xFF9C27B0); // Purple
    final minutesColor = const Color(0xFFFF9800); // Orange
    final secondsColor = const Color(0xFF2196F3); // Blue
    
    // Background rings (light gray)
    _drawRing(canvas, center, daysRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, hoursRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, minutesRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    _drawRing(canvas, center, secondsRadius, strokeWidth, Colors.grey[200]!, 1.0, false);
    
    // Progress rings with glow
    _drawRing(canvas, center, daysRadius, strokeWidth, daysColor, daysProgress, true);
    _drawRing(canvas, center, hoursRadius, strokeWidth, hoursColor, hoursProgress, true);
    _drawRing(canvas, center, minutesRadius, strokeWidth, minutesColor, minutesProgress, true);
    _drawRing(canvas, center, secondsRadius, strokeWidth, secondsColor, secondsProgress, true);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeWidth, Color color, double progress, bool addGlow) {
    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw effects for progress rings
    if (addGlow && progress > 0) {
      // Outer shadow (drop shadow)
      final outerShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(rect, startAngle, sweepAngle, false, outerShadowPaint);

      // Outer glow (reduced by 2/3)
      final glowPaint1 = Paint()
        ..color = color.withOpacity(0.13) // 0.4 * 1/3 ≈ 0.13
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2 // 6 * 1/3 = 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.7); // 5 * 1/3 ≈ 1.7

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint1);

      // Inner glow (reduced by 2/3)
      final glowPaint2 = Paint()
        ..color = color.withOpacity(0.2) // 0.6 * 1/3 = 0.2
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 1 // 3 * 1/3 = 1
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7); // 2 * 1/3 ≈ 0.7

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint2);

      // Outer stroke (border)
      final outerStrokePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, outerStrokePaint);
    }

    // Main ring
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.hours != hours ||
        oldDelegate.minutes != minutes ||
        oldDelegate.seconds != seconds;
  }
}

// Custom painter for dashed lines
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom clipper for curved header with inward curve
class CurvedHeaderClipper extends CustomClipper<Path> {
  final double depth;
  
  CurvedHeaderClipper({this.depth = 80});
  
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left corner
    path.moveTo(0, 0);
    
    // Go to top-right corner
    path.lineTo(size.width, 0);
    
    // Go down the right side
    path.lineTo(size.width, size.height - depth);
    
    // Create a smooth inward curve (concave) at the bottom
    // Using quadraticBezierTo for a cleaner arch shape
    path.quadraticBezierTo(
      size.width / 2,              // Control point X (center)
      size.height - depth * 2,      // Control point Y (pulls curve upward for inward effect)
      0,                           // End point X (left side)
      size.height - depth,          // End point Y (same height as right side)
    );
    
    // Go up the left side
    path.lineTo(0, 0);
    
    // Close the path
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for comforting background with subtle nature elements
class ComfortingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw subtle circles for a calming effect
    paint.color = const Color(0xFF4CAF50).withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.width * 0.15,
      paint,
    );
    
    paint.color = const Color(0xFF66BB6A).withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.2,
      paint,
    );
    
    paint.color = const Color(0xFF43A047).withOpacity(0.025);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      size.width * 0.12,
      paint,
    );
    
    paint.color = const Color(0xFF388E3C).withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      size.width * 0.18,
      paint,
    );
    
    // Draw subtle organic shapes for a nature-inspired feel
    paint.color = const Color(0xFF4CAF50).withOpacity(0.015);
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.05,
      size.width * 0.7, size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.15,
      size.width * 0.6, size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.18,
      size.width * 0.3, size.height * 0.1,
    );
    canvas.drawPath(path, paint);
    
    // Draw gentle hills at the bottom
    paint.color = const Color(0xFF66BB6A).withOpacity(0.02);
    final hillsPath = Path();
    hillsPath.moveTo(0, size.height);
    hillsPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.95,
      size.width * 0.4, size.height,
    );
    hillsPath.quadraticBezierTo(
      size.width * 0.6, size.height * 0.98,
      size.width * 0.8, size.height,
    );
    hillsPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.97,
      size.width, size.height,
    );
    canvas.drawPath(hillsPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
