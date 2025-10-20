import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../widgets/level_badge.dart';
import '../widgets/tree_growth_widget.dart';
import '../widgets/binge_free_timer_carousel_widget.dart';

enum ProgressType { percentage, counter }

class QuestProgressInfo {
  final double progress;
  final String displayText;
  final String description;
  final ProgressType type;

  QuestProgressInfo({
    required this.progress,
    required this.displayText,
    required this.description,
    required this.type,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  final GlobalKey? treeWidgetKey;
  
  const HomeScreen({super.key, this.treeWidgetKey});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
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
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
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
                borderRadius: BorderRadius.circular(40.0),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
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
                        // Recovery Exercises section with header inside container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recovery Exercises header
                        Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                              child: Text(
                                  'Recovery Exercises',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                              // Recovery Exercises list
                              Column(
                            children: [
                                  _buildExerciseItem(
                                    icon: Icons.psychology_outlined,
                                    title: 'Recovery Guide',
                                    description: 'Your personalized guide',
                                    onTap: () => context.push('/chat'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildExerciseItem(
                                    icon: Icons.edit_note_outlined,
                                    title: 'Journaling Partner',
                                    description: 'Track your progress',
                                    onTap: () => context.push('/realtime-journaling'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildExerciseItem(
                                    icon: Icons.people_outline,
                                    title: 'Accountability Partner',
                                    description: 'Connect with support',
                                    onTap: () => context.push('/accountability-partner'),
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E8),
                                  ),
                                  _buildDivider(),
                                  _buildExerciseItem(
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Carousel with tree and binge-free timer - full width, no horizontal padding
        BingeFreeTimerCarouselWidget(treeWidgetKey: widget.treeWidgetKey),
        
        // Add padding for the rest of the content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
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
        ),
      ],
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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(40.0),
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
            borderRadius: BorderRadius.circular(40.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(40.0),
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
            borderRadius: BorderRadius.circular(40.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(40.0),
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
            
            final userTodosAsync = ref.watch(userTodosStreamProvider(user.id));
            
            return userTodosAsync.when(
              data: (todos) => _buildDailyQuestsWidget(context, todos, ref),
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

  Widget _buildDailyQuestsWidget(BuildContext context, List<TodoItem> todos, WidgetRef ref) {
    // Get today's todos - include both completed and incomplete
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayTodos = todos.where((todo) {
      final due = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return today.isAtSameMomentAs(due);
    }).toList();
    
    if (todayTodos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  'Daily Quests',
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
                    'See All',
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
          // Quests list
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: todayTodos.map((todo) => _buildDailyQuestItem(context, todo, ref)).toList(),
            ),
            ),
          ],
        ),
    );
  }

  Widget _buildDailyQuestItem(BuildContext context, TodoItem todo, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToTodoItem(todo),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _getTodoBackgroundColor(todo.type),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTodoBorderColor(todo.type),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getTodoShadowColor(todo.type).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon spanning from title to progress bar
              _buildTodoTypeIconWithBackground(todo.type),
              const SizedBox(width: 12),
              // Title and progress bar content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[400],
                        decorationThickness: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    _buildQuestProgressBar(context, todo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoTypeIconWithBackground(TodoType type) {
    final (iconData, backgroundColor, iconColor) = _getTodoTypeIcon(type);
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }

  (IconData, Color, Color) _getTodoTypeIcon(TodoType type) {
    switch (type) {
      case TodoType.journal:
        return (Icons.auto_stories_rounded, const Color(0xFFE8D5F2), const Color(0xFFA29BFE));
      case TodoType.lesson:
        return (Icons.menu_book_rounded, const Color(0xFFD6E9F8), const Color(0xFF0984E3));
      case TodoType.tool:
        return (Icons.psychology_rounded, const Color(0xFFFFD6D6), const Color(0xFFD63031));
    }
  }

  Color _getTodoBackgroundColor(TodoType type) {
    switch (type) {
      case TodoType.journal:
        return const Color(0xFFFAF3FF);
      case TodoType.lesson:
        return const Color(0xFFF0F7FF);
      case TodoType.tool:
        return const Color(0xFFFFF4F4);
    }
  }

  Color _getTodoBorderColor(TodoType type) {
    switch (type) {
      case TodoType.journal:
        return const Color(0xFFE8D5F2);
      case TodoType.lesson:
        return const Color(0xFFD6E9F8);
      case TodoType.tool:
        return const Color(0xFFFFD6D6);
    }
  }

  Color _getTodoShadowColor(TodoType type) {
    switch (type) {
      case TodoType.journal:
        return const Color(0xFFA29BFE);
      case TodoType.lesson:
        return const Color(0xFF0984E3);
      case TodoType.tool:
        return const Color(0xFFD63031);
    }
  }

  Widget _buildQuestProgressBar(BuildContext context, TodoItem todo) {
    final progressInfo = _getQuestProgressInfo(todo);
    
    return SizedBox(
      width: double.infinity, // Span to the edge on the right
      child: Stack(
        children: [
          // Progress bar background
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressInfo.progress,
              minHeight: 22,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                todo.isCompleted ? const Color(0xFF4CAF50) : _getProgressBarColor(progressInfo.type),
              ),
            ),
          ),
          // Progress text centered on the bar
          Positioned.fill(
            child: Center(
              child: Text(
                progressInfo.displayText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  QuestProgressInfo _getQuestProgressInfo(TodoItem todo) {
    // If completed, show 100%
    if (todo.isCompleted) {
      return QuestProgressInfo(
        progress: 1.0,
        displayText: '100%',
        description: 'Completed',
        type: ProgressType.percentage,
      );
    }

    // Parse activity data for progress information
    final activityData = todo.activityData ?? {};
    
    // Determine progress based on quest type
    switch (todo.type) {
      case TodoType.lesson:
        // For lessons: show minutes if available, or generic progress
        final minutes = (activityData['duration'] as int?) ?? 0;
        if (minutes > 0) {
          // Assume lesson is 15 minutes by default, calculate progress
          const totalMinutes = 15;
          final progress = (minutes / totalMinutes).clamp(0.0, 1.0);
          return QuestProgressInfo(
            progress: progress,
            displayText: '$minutes/$totalMinutes min',
            description: 'Lesson progress',
            type: ProgressType.counter,
          );
        }
        return QuestProgressInfo(
          progress: 0.0,
          displayText: '0%',
          description: 'Not started',
          type: ProgressType.percentage,
        );
        
      case TodoType.journal:
        // For journal: show entries or simple progress
        final entries = (activityData['entries'] as int?) ?? 0;
        if (entries > 0) {
          return QuestProgressInfo(
            progress: 1.0,
            displayText: 'Logged',
            description: 'Journal entry recorded',
            type: ProgressType.counter,
          );
        }
        return QuestProgressInfo(
          progress: 0.0,
          displayText: '0%',
          description: 'Not started',
          type: ProgressType.percentage,
        );
        
      case TodoType.tool:
        // For tools/exercises: show completion or reps
        final reps = (activityData['reps'] as int?) ?? 0;
        final targetReps = (activityData['targetReps'] as int?) ?? 1;
        if (targetReps > 0) {
          final progress = (reps / targetReps).clamp(0.0, 1.0);
          return QuestProgressInfo(
            progress: progress,
            displayText: '$reps/$targetReps',
            description: 'Exercise progress',
            type: ProgressType.counter,
          );
        }
        return QuestProgressInfo(
          progress: 0.0,
          displayText: '0%',
          description: 'Not started',
          type: ProgressType.percentage,
        );
    }
  }

  Color _getProgressBarColor(ProgressType type) {
    switch (type) {
      case ProgressType.percentage:
        return const Color(0xFF2196F3); // Blue for percentage
      case ProgressType.counter:
        return const Color(0xFF4CAF50); // Green for counter
    }
  }

  Future<void> _toggleTodoCompletion(TodoItem todo, WidgetRef ref) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    if (user == null) return;
    
    final todoNotifier = ref.read(userTodosProvider(user.id).notifier);
    await todoNotifier.toggleCompletion(todo.id);
  }

  Future<void> _navigateToTodoItem(TodoItem todo) async {
    // Mark the todo as completed in the background
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    if (user != null) {
      final todoNotifier = ref.read(userTodosProvider(user.id).notifier);
      // Mark as completed asynchronously without waiting
      todoNotifier.markCompleted(todo.id);
    }
    
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
          _navigateToExerciseById(todo.activityId);
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

  void _navigateToExerciseById(String exerciseName) {
    final normalized = exerciseName.toLowerCase().replaceAll(' ', '-');
    context.push('/exercises/$normalized');
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
              'Loading your quests...',
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
        title: const Text('Unable to load quests'),
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
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
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
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
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
                            'Take control with these exercises',
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
                        borderRadius: BorderRadius.circular(40.0),
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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
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
                    borderRadius: BorderRadius.circular(40.0),
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
    context.push('/exercises/urge-surfing');
  }
  
  Widget _buildExerciseItem({
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
          borderRadius: BorderRadius.circular(40.0),
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

  Widget _buildUrgeHelpButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
          borderRadius: BorderRadius.circular(40.0),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/motivation'),
          borderRadius: BorderRadius.circular(40.0),
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
}

