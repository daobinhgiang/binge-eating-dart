import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../data/stage_1_data.dart';
import '../../widgets/exercise_prep_slide_widget.dart';

class Lesson121Screen extends ConsumerStatefulWidget {
  const Lesson121Screen({super.key});

  @override
  ConsumerState<Lesson121Screen> createState() => _Lesson121ScreenState();
}

class _Lesson121ScreenState extends ConsumerState<Lesson121Screen> {
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
      final stage1 = Stage1Data.getStage1();
      final lesson = stage1.chapters
          .firstWhere((chapter) => chapter.chapterNumber == 1)
          .lessons
          .firstWhere((lesson) => lesson.id == 'lesson_1_2_1');
      
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

  void _navigateToJournal() {
    // Mark lesson as completed
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    
    // Navigate to the Journal tab
    context.go('/journal');
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
          title: const Text('Journal Practice Exercise'),
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
      onStartExercise: isLastSlide ? _navigateToJournal : null,
      totalSlides: _lesson!.slides.length,
      exerciseButtonText: 'Start Journaling',
      exerciseIcon: Icons.edit_note_rounded,
      accentColor: const Color(0xFF66BB6A),
    );
  }
}
