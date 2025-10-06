import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/education_provider.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../providers/firebase_analytics_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../core/services/openai_service.dart';
import '../models/todo_item.dart';
import '../core/services/user_learning_service.dart';
import '../models/lesson.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _scrollController;
  PageController? _lessonCarouselController;
  
  // Insights section state
  bool _isGeneratingInsights = false;
  List<Map<String, dynamic>> _insightsRecommendations = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Start at a large number to enable infinite scrolling in both directions
    _lessonCarouselController = PageController(
      viewportFraction: 0.6,
      initialPage: 10000,
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _lessonCarouselController?.dispose();
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
          'logo.png',
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


  Widget _buildProfileSection(AsyncValue authState, {bool onGreenBackground = false}) {
    // Notification bell removed - return empty space
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Combined header and Continue Learning Section with green background
            SliverToBoxAdapter(
              child: _buildCombinedHeaderAndLearningSection(authState),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -90),
                  child: Column(
                    children: [
                          // Resources title
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Resources',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                          
                          // Main buttons layout - left column with two buttons, right side with larger button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Column with Urge Help and AI Chat buttons
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    // Urge Help button
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE57373).withOpacity(0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity( 0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
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
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                            child: Center(
                                              child: Text(
                                                'Urge Help',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFFE57373),
                                                  fontSize: 20,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // AI Chat button
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF64B5F6).withOpacity( 0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity( 0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => context.go('/chat'),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                            child: Center(
                                              child: Text(
                                                'AI Chat',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF64B5F6),
                                                  fontSize: 20,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Right side - Larger Personalized Insights button
                              Expanded(
                                flex: 1,
                                child: _buildInsightsButton(),
                              ),
                            ],
                          ),
                  
                          // Recommendations display (if any)
                          if (_insightsRecommendations.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              constraints: const BoxConstraints(
                                minHeight: 80,
                                maxHeight: 200,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recommended for you',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ..._insightsRecommendations.asMap().entries.map((entry) => 
                                        _buildInsightRecommendationCard(entry.value, key: ValueKey('insight_${entry.key}'))
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                  
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
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 40),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Green background that extends from top
              if (shouldShowLearningSection)
                SizedBox(
                  height: 480, // Increased to overlay bottom 2% of lesson tiles
                  child: ClipPath(
                    clipper: CurvedHeaderClipper(depth: 60),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4CAF50), // Green
                            Color(0xFF66BB6A), // Light green
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Content overlay - NOT clipped so lesson cards extend beyond curve
              if (shouldShowLearningSection)
                Column(
                  children: [
                    // Header section with transparent background
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Row(
                          children: [
                            // App Logo
                            _buildAppLogo(),
                            const SizedBox(width: 16),
                            // Greeting and user info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTimeBasedGreeting(authState.valueOrNull?.displayName.split(' ').first),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: shouldShowLearningSection ? Colors.white : Colors.black87,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getCurrentDate(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: shouldShowLearningSection ? Colors.white.withOpacity(0.95) : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Profile section
                            _buildProfileSection(authState, onGreenBackground: shouldShowLearningSection),
                          ],
                        ),
                      ),
                    ),
                    
                    // Continue Learning content (if logged in) - extends beyond the curve
                    _buildContinueLearningContentOnly(ref),
                  ],
                )
              else
                // When not logged in, show header without clipping
                Column(
                  children: [
                    // Header section with transparent background
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Row(
                          children: [
                            // App Logo
                            _buildAppLogo(),
                            const SizedBox(width: 16),
                            // Greeting and user info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTimeBasedGreeting(authState.valueOrNull?.displayName.split(' ').first),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getCurrentDate(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Profile section
                            _buildProfileSection(authState, onGreenBackground: false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
    
    final nextLessonsAsync = ref.watch(nextUncompletedLessonsProvider(user.id));
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Lesson cards carousel
          nextLessonsAsync.when(
            data: (lessons) {
              print('DEBUG UI: Got ${lessons.length} lessons');
              if (lessons.isEmpty) {
                return _buildAllLessonsCompletedCard();
              } else {
                return _buildLessonCarousel(lessons);
              }
            },
            loading: () {
              print('DEBUG UI: Loading lessons...');
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
            error: (error, stack) {
              print('DEBUG UI: Error loading lessons: $error');
              print('Stack: $stack');
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unable to load lessons',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToInsightLesson(lesson.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
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


  Widget _buildLessonCarousel(List<Lesson> lessons) {
    // Ensure we have at least one lesson
    if (lessons.isEmpty) {
      print('DEBUG: No lessons available for carousel');
      return const SizedBox.shrink();
    }

    // Check if controller is initialized
    if (_lessonCarouselController == null) {
      print('DEBUG: PageController not initialized');
      return const SizedBox.shrink();
    }

    print('DEBUG: Building carousel with ${lessons.length} lessons');

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _lessonCarouselController,
        itemBuilder: (context, index) {
          // Use modulo to create infinite loop with the available lessons
          final lessonIndex = index % lessons.length;
          final lesson = lessons[lessonIndex];
          
          return AnimatedBuilder(
            animation: _lessonCarouselController!,
            builder: (context, child) {
              double value = 1.0;
              if (_lessonCarouselController!.position.haveDimensions) {
                value = (_lessonCarouselController!.page ?? 0) - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
              }
              
              // Calculate blur amount based on distance from center
              final blurAmount = (1.0 - value) * 10; // 0 to 10 blur
              
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 200,
                  child: _buildLessonVideoCard(
                    lesson,
                    blurAmount: blurAmount,
                    isFirstLesson: lessonIndex == 0,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonVideoCard(
    Lesson lesson, {
    double blurAmount = 0.0,
    bool isFirstLesson = false,
  }) {
    final cardContent = Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson icon and label row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              if (isFirstLesson)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Next Lesson',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Lesson title
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 10),
          
          // Start button/arrow
          Row(
            children: [
              Text(
                'Start',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                color: Colors.white.withOpacity(0.9),
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );

    // Apply blur if needed
    if (blurAmount > 0.5) {
      return ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: blurAmount,
          sigmaY: blurAmount,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToLesson(lesson),
            borderRadius: BorderRadius.circular(12),
            child: cardContent,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToLesson(lesson),
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      ),
    );
  }

  Widget _buildAllLessonsCompletedCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'All lessons completed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Great job!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
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
                const SizedBox(height: 16),
                userTodosAsync.when(
                  data: (todos) => _buildRefinedTodoLayout(context, todos),
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

  Widget _buildRefinedTodoLayout(BuildContext context, List<TodoItem> todos) {
    if (todos.isEmpty) {
      return _buildEmptyTodoLayout(context);
    }

    // Get today's todos in the same order as the main todo list
    final todayTodos = todos.where((todo) => todo.isDueToday && !todo.isCompleted).toList();
    final completedToday = todos.where((todo) => todo.isDueToday && todo.isCompleted).toList();
    final totalToday = todayTodos.length + completedToday.length;

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
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side - Date card
              Expanded(
                flex: 1,
                child: _buildDateCard(context, totalToday, completedToday.length),
              ),
              const SizedBox(width: 16),
              // Right side - Todo list
              Expanded(
                flex: 2,
                child: _buildCompactTodoListCard(context, todayTodos),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTodoLayout(BuildContext context) {
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
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side - Date card
              Expanded(
                flex: 1,
                child: _buildDateCard(context, 0, 0),
              ),
              const SizedBox(width: 16),
              // Right side - Empty state
              Expanded(
                flex: 2,
                child: _buildCompactEmptyTodoCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, int totalTasks, int completedTasks) {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final day = now.day;
    final month = _getMonthName(now.month);

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81C784), // Light green
            Color(0xFF4CAF50), // Green
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity( 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekday,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$month $day',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (totalTasks > 0)
              Text(
                '$completedTasks/$totalTasks Tasks Done',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTodoListCard(BuildContext context, List<TodoItem> todayTodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To-Do List',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (todayTodos.isEmpty)
          _buildEmptyTodoState(context)
        else
          ...todayTodos.take(2).toList().asMap().entries.map((entry) => 
            _buildCompactTodoItem(context, entry.value, key: ValueKey('todo_${entry.value.id}_${entry.key}'))
          ),
      ],
    );
  }

  Widget _buildCompactEmptyTodoCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'To-Do List',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 28,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 6),
            Text(
              'No tasks for today',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Add lessons, tools, or journal activities',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildEmptyTodoState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No tasks scheduled for today',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildCompactTodoItem(BuildContext context, TodoItem todo, {Key? key}) {
    final timeText = _formatTodoTime(todo.dueDate);
    
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Type icon
          _buildTodoTypeIcon(todo.type),
          const SizedBox(width: 8),
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _getWeekdayName(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildTodoTypeIcon(TodoType type) {
    IconData iconData;
    
    switch (type) {
      case TodoType.journal:
        iconData = Icons.edit_note;
        break;
      case TodoType.lesson:
        iconData = Icons.school;
        break;
      case TodoType.tool:
        iconData = Icons.build;
        break;
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF4CAF50), // Green outline
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        color: const Color(0xFF4CAF50), // Green icon
        size: 14,
      ),
    );
  }

  String _formatTodoTime(DateTime dueDate) {
    final hour = dueDate.hour;
    final minute = dueDate.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    
    return '$displayHour:$displayMinute $period';
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
            onPressed: () {
              // Track dialog close
              final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
              trackDialog('dialog_closed');
              Navigator.of(context).pop();
            },
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
    // Track urge surfing navigation from help dialog
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('urge_surfing_navigation');
    context.push('/tools/urge-surfing');
  }
  
  Widget _buildInsightsButton() {
    return Container(
      height: 177, // Height to match the combined height of the two left buttons (120 + 16 + 120)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity( 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGeneratingInsights ? null : _generateInsights,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon and Title stacked vertically
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity( 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personalized',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Insights',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGeneratingInsights ? null : _generateInsights,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isGeneratingInsights 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Generating...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Generate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _generateInsights() async {
    setState(() {
      _isGeneratingInsights = true;
    });
    
    try {
      // Get the current user ID
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      
      if (user == null) {
        return;
      }
      
      final openaiService = OpenAIService();
      final response = await openaiService.generateInsights(user.id);
      
      setState(() {
        _insightsRecommendations = List<Map<String, dynamic>>.from(response['recommendations'] ?? []);
      });
    } catch (e) {
      // Handle error silently or show a snackbar if needed
    } finally {
      setState(() {
        _isGeneratingInsights = false;
      });
    }
  }
  
  Widget _buildInsightRecommendationCard(Map<String, dynamic> recommendation, {Key? key}) {
    final type = recommendation['type'] as String? ?? '';
    final title = recommendation['title'] as String? ?? '';
    final description = recommendation['description'] as String? ?? '';

    IconData typeIcon;
    Color typeColor;
    
    switch (type) {
      case 'lesson':
        typeIcon = Icons.school_outlined;
        typeColor = const Color(0xFF4CAF50);
        break;
      case 'tool':
        typeIcon = Icons.build_outlined;
        typeColor = const Color(0xFF2196F3);
        break;
      case 'journal':
        typeIcon = Icons.edit_note_outlined;
        typeColor = const Color(0xFF9C27B0);
        break;
      case 'assessment':
        typeIcon = Icons.quiz_outlined;
        typeColor = const Color(0xFFFF9800);
        break;
      default:
        typeIcon = Icons.help_outline;
        typeColor = Colors.grey;
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToInsightRecommendation(recommendation),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    typeIcon, 
                    color: typeColor, 
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToInsightRecommendation(Map<String, dynamic> recommendation) {
    final type = recommendation['type'] ?? '';
    final id = recommendation['id'] ?? '';
    
    switch (type) {
      case 'lesson':
        _navigateToInsightLesson(id);
        break;
      case 'tool':
        _navigateToInsightTool(id);
        break;
      case 'journal':
        _navigateToInsightJournal(id);
        break;
      case 'assessment':
        _navigateToInsightAssessment(id);
        break;
      default:
        // Fallback to home
        break;
    }
  }
  
  void _navigateToInsightLesson(String lessonId) {
    // Save last clicked lesson so Home can update the next lesson in realtime
    UserLearningService().saveLastLesson(lessonId);
    // Navigate to specific lesson based on lesson ID (same logic as chatbot)
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1':
        context.push('/lesson/1_1');
        break;
      case 'lesson_1_2':
        context.push('/lesson/1_2');
        break;
      case 'lesson_1_2_1':
        context.push('/lesson/1_2_1');
        break;
      case 'lesson_1_3':
        context.push('/lesson/1_3');
        break;
      case 'lesson_2_1':
        context.push('/lesson/2_1');
        break;
      case 'lesson_2_2':
        context.push('/lesson/2_2');
        break;
      case 'lesson_2_3':
        context.push('/lesson/2_3');
        break;
      case 'lesson_3_1':
        context.push('/lesson/3_1');
        break;
      case 'lesson_3_2':
        context.push('/lesson/3_2');
        break;
      case 'lesson_3_3':
        context.push('/lesson/3_3');
        break;
      case 'lesson_3_4':
        context.push('/lesson/3_4');
        break;
      case 'lesson_3_5':
        context.push('/lesson/3_5');
        break;
      case 'lesson_3_6':
        context.push('/lesson/3_6');
        break;
      case 'lesson_3_7':
        context.push('/lesson/3_7');
        break;
      case 'lesson_3_8':
        context.push('/lesson/3_8');
        break;
      case 'lesson_3_9':
        context.push('/lesson/3_9');
        break;
      case 'lesson_3_10':
        context.push('/lesson/3_10');
        break;
      
      // Stage 2 lessons
      case 'lesson_s2_0_1':
        context.push('/lesson/s2_0_1');
        break;
      case 'lesson_s2_0_2':
        context.push('/lesson/s2_0_2');
        break;
      case 'lesson_s2_0_3':
        context.push('/lesson/s2_0_3');
        break;
      case 'lesson_s2_0_4':
        context.push('/lesson/s2_0_4');
        break;
      case 'lesson_s2_0_5':
        context.push('/lesson/s2_0_5');
        break;
      case 'lesson_s2_0_6':
        context.push('/lesson/s2_0_6');
        break;
      case 'lesson_s2_1_1':
        context.push('/lesson/s2_1_1');
        break;
      case 'lesson_s2_1_2':
        context.push('/lesson/s2_1_2');
        break;
      case 'lesson_s2_1_3':
        context.push('/lesson/s2_1_3');
        break;
      case 'lesson_s2_2_1':
        context.push('/lesson/s2_2_1');
        break;
      case 'lesson_s2_2_2':
        context.push('/lesson/s2_2_2');
        break;
      case 'lesson_s2_2_3':
        context.push('/lesson/s2_2_3');
        break;
      case 'lesson_s2_2_4':
        context.push('/lesson/s2_2_4');
        break;
      case 'lesson_s2_2_5':
        context.push('/lesson/s2_2_5');
        break;
      case 'lesson_s2_2_5_1':
        context.push('/lesson/s2_2_5_1');
        break;
      case 'lesson_s2_2_7':
        context.push('/lesson/s2_2_7');
        break;
      case 'lesson_s2_3_1':
        context.push('/lesson/s2_3_1');
        break;
      case 'lesson_s2_3_2':
        context.push('/lesson/s2_3_2');
        break;
      case 'lesson_s2_3_2_1':
        context.push('/lesson/s2_3_2_1');
        break;
      case 'lesson_s2_3_3':
        context.push('/lesson/s2_3_3');
        break;
      case 'lesson_s2_3_4':
        context.push('/lesson/s2_3_4');
        break;
      case 'lesson_s2_3_5':
        context.push('/lesson/s2_3_5');
        break;
      case 'lesson_s2_4_1':
        context.push('/lesson/s2_4_1');
        break;
      case 'lesson_s2_4_2':
        context.push('/lesson/s2_4_2');
        break;
      case 'lesson_s2_4_2_1':
        context.push('/lesson/s2_4_2_1');
        break;
      case 'lesson_s2_4_3':
        context.push('/lesson/s2_4_3');
        break;
      case 'lesson_s2_5_1':
        context.push('/lesson/s2_5_1');
        break;
      case 'lesson_s2_5_2':
        context.push('/lesson/s2_5_2');
        break;
      case 'lesson_s2_6_1':
        context.push('/lesson/s2_6_1');
        break;
      case 'lesson_s2_6_2':
        context.push('/lesson/s2_6_2');
        break;
      case 'lesson_s2_6_3':
        context.push('/lesson/s2_6_3');
        break;
      case 'lesson_s2_7_1':
        context.push('/lesson/s2_7_1');
        break;
      case 'lesson_s2_7_1_1':
        context.push('/lesson/s2_7_1_1');
        break;
      case 'lesson_s2_7_2':
        context.push('/lesson/s2_7_2');
        break;
      case 'lesson_s2_7_3':
        context.push('/lesson/s2_7_3');
        break;
      case 'lesson_s2_7_4':
        context.push('/lesson/s2_7_4');
        break;
      case 'lesson_s2_7_5':
        context.push('/lesson/s2_7_5');
        break;
      case 'lesson_s2_7_6':
        context.push('/lesson/s2_7_6');
        break;
      case 'lesson_s2_7_7':
        context.push('/lesson/s2_7_7');
        break;
      case 'lesson_s2_7_8':
        context.push('/lesson/s2_7_8');
        break;
      case 'lesson_s2_7_2_1':
        context.push('/lesson/s2_7_2_1');
        break;
      
      // Stage 3 lessons
      case 'lesson_s3_0_1':
        context.push('/lesson/s3_0_1');
        break;
      case 'lesson_s3_0_2':
        context.push('/lesson/s3_0_2');
        break;
      case 'lesson_s3_0_2_1':
        context.push('/lesson/s3_0_2_1');
        break;
      default:
        _showInsightLessonNotAvailable(lessonId);
    }
  }
  
  void _navigateToInsightTool(String toolName) {
    // Use the same logic as the chatbot for tool navigation
    // Handle different formats: "Problem Solving", "problem solving", "problem_solving", etc.
    final normalizedName = toolName.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedName) {
      case 'problem solving':
        context.push('/tools/problem-solving');
        break;
      case 'meal planning':
        context.push('/tools/meal-planning');
        break;
      case 'urge surfing activities':
        context.push('/tools/urge-surfing');
        break;
      case 'addressing overconcern':
        context.push('/tools/addressing-overconcern');
        break;
      case 'addressing setbacks':
        context.push('/tools/addressing-setbacks');
        break;
      default:
        // Try to match partial names for better compatibility
        if (normalizedName.contains('problem') && normalizedName.contains('solving')) {
          context.push('/tools/problem-solving');
        } else if (normalizedName.contains('meal') && normalizedName.contains('planning')) {
          context.push('/tools/meal-planning');
        } else if (normalizedName.contains('urge') && (normalizedName.contains('surfing') || normalizedName.contains('activities'))) {
          context.push('/tools/urge-surfing');
        } else if (normalizedName.contains('overconcern')) {
          context.push('/tools/addressing-overconcern');
        } else if (normalizedName.contains('setbacks')) {
          context.push('/tools/addressing-setbacks');
        } else {
          _showInsightToolNotAvailable(toolName);
        }
    }
  }
  
  void _navigateToInsightJournal(String journalType) {
    // Use the same logic as the chatbot for journal navigation
    // Handle different formats: "Food Diary", "food diary", "food_diary", etc.
    final normalizedType = journalType.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedType) {
      case 'food diary':
        context.push('/journal/food-diary');
        break;
      case 'weight diary':
        context.push('/journal/weight-diary');
        break;
      case 'body image diary':
        context.push('/journal/body-image-diary');
        break;
      default:
        // Try to match partial names
        if (normalizedType.contains('food')) {
          context.push('/journal/food-diary');
        } else if (normalizedType.contains('weight')) {
          context.push('/journal/weight-diary');
        } else if (normalizedType.contains('body') || normalizedType.contains('image')) {
          context.push('/journal/body-image-diary');
        } else {
          context.push('/journal');
        }
    }
  }
  
  void _navigateToInsightAssessment(String assessmentName) {
    switch (assessmentName.toLowerCase()) {
      case 'ede-q':
        context.push('/lesson/2_1'); // EDE-Q assessment
        break;
      case 'cia':
        context.push('/lesson/2_2'); // CIA assessment
        break;
      case 'general psychiatric':
        context.push('/lesson/2_3'); // General psychiatric assessment
        break;
      default:
        _showInsightAssessmentNotAvailable(assessmentName);
    }
  }
  
  void _showInsightLessonNotAvailable(String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson "$lessonId" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightToolNotAvailable(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool "$toolName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightAssessmentNotAvailable(String assessmentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assessment "$assessmentName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
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

