import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../data/stage_2_data.dart';
import '../../widgets/exercise_prep_slide_widget.dart';

class LessonS2321Screen extends ConsumerStatefulWidget {
  const LessonS2321Screen({super.key});

  @override
  ConsumerState<LessonS2321Screen> createState() => _LessonS2321ScreenState();
}

class _LessonS2321ScreenState extends ConsumerState<LessonS2321Screen> {
  final LessonService _lessonService = LessonService();
  final ScrollController _scrollController = ScrollController();
  Lesson? _lesson;
  int _currentSlideIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    try {
      final stage2 = Stage2Data.getStage2();
      final lesson = stage2.chapters
          .firstWhere((chapter) => chapter.chapterNumber == 3)
          .lessons
          .firstWhere((lesson) => lesson.id == 'lesson_s2_3_2_1');
      
      setState(() {
        _lesson = lesson;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lesson: $e')),
        );
      }
    }
  }

  void _goToNextSlide() {
    if (_lesson != null && _currentSlideIndex < _lesson!.slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _navigateToUrgeSurfing() async {
    // Mark lesson as completed
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
    }
    
    // Navigate to the Urge Surfing tool
    if (mounted) {
      context.go('/exercises/urge-surfing');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_lesson == null || _lesson!.slides.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Urge Surfing Exercise'),
        ),
        body: const Center(
          child: Text('Lesson not found'),
        ),
      );
    }

    final currentSlide = _lesson!.slides[_currentSlideIndex];
    final isFirstSlide = _currentSlideIndex == 0;
    final isLastSlide = _currentSlideIndex == _lesson!.slides.length - 1;

    return ExercisePrepSlideWidget(
      slide: currentSlide,
      scrollController: _scrollController,
      isFirstSlide: isFirstSlide,
      isLastSlide: isLastSlide,
      onPrevious: isFirstSlide ? null : _goToPreviousSlide,
      onNext: isLastSlide ? null : _goToNextSlide,
      onStartExercise: isLastSlide ? _navigateToUrgeSurfing : null,
      totalSlides: _lesson!.slides.length,
      exerciseButtonText: 'Start Urge Surfing',
      exerciseIcon: Icons.waves_rounded,
      accentColor: const Color(0xFF42A5F5), // Blue for stage 2
    );
  }
}
