import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lesson_progress_provider.dart';
import '../../models/lesson.dart';
import '../../core/services/user_learning_service.dart';
import '../../providers/auth_provider.dart';

class ContinueLearningSection extends ConsumerStatefulWidget {
  const ContinueLearningSection({super.key});

  @override
  ConsumerState<ContinueLearningSection> createState() => _ContinueLearningSectionState();
}

class _ContinueLearningSectionState extends ConsumerState<ContinueLearningSection> {
  PageController? _lessonCarouselController;

  @override
  void initState() {
    super.initState();
    // Start at a large number to enable infinite scrolling in both directions
    _lessonCarouselController = PageController(
      viewportFraction: 0.6,
      initialPage: 10000,
    );
  }

  @override
  void dispose() {
    _lessonCarouselController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 12),
                Text(
                  'Continue Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Lesson cards carousel
          nextLessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) {
                return _buildAllLessonsCompletedCard();
              } else {
                return _buildLessonCarousel(lessons);
              }
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            error: (error, stack) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCarousel(List<Lesson> lessons) {
    if (lessons.isEmpty || _lessonCarouselController == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _lessonCarouselController,
        itemBuilder: (context, index) {
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
              
              final blurAmount = (1.0 - value) * 10;
              
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 200,
                  child: RepaintBoundary(
                    child: _buildLessonVideoCard(
                      lesson,
                      blurAmount: blurAmount,
                      isFirstLesson: lessonIndex == 0,
                    ),
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

    if (blurAmount > 0.5) {
      return RepaintBoundary(
        child: ImageFiltered(
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
    UserLearningService().saveLastLesson(lesson.id);
    final lessonId = lesson.id;
    
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
}

