import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../core/services/navigation_service.dart';
import '../../models/lesson.dart';
import '../../models/todo_item.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_1_data.dart';

class Lesson11Screen extends ConsumerStatefulWidget {
  const Lesson11Screen({super.key});

  @override
  ConsumerState<Lesson11Screen> createState() => _Lesson11ScreenState();
}

class _Lesson11ScreenState extends ConsumerState<Lesson11Screen> {
  final LessonService _lessonService = LessonService();
  Lesson? _lesson;
  int _currentSlideIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    
    // Mark any pending todo for this lesson as completed
    // This handles cases where users navigate directly to lessons
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.markActivityCompleted(ref, 'lesson_1_1', TodoType.lesson);
    });
  }

  Future<void> _loadLesson() async {
    try {
      // Load from the new Stage 1 data structure
      final stage1 = Stage1Data.getStage1();
      final lesson11 = stage1.chapters.first.lessons.first;
      
      setState(() {
        _lesson = lesson11;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lesson: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _goToNextSlide() {
    if (_lesson != null && _currentSlideIndex < _lesson!.slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
    }
  }

  void _finishLesson() {
    // Mark lesson as completed
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    
    // Navigate back to education screen
    Navigator.of(context).pop();
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
          title: const Text('Lesson 1.1'),
        ),
        body: const Center(
          child: Text('Lesson not found'),
        ),
      );
    }

    final currentSlide = _lesson!.slides[_currentSlideIndex];
    final isFirstSlide = _currentSlideIndex == 0;
    final isLastSlide = _currentSlideIndex == _lesson!.slides.length - 1;

    return LessonSlideWidget(
      slide: currentSlide,
      isFirstSlide: isFirstSlide,
      isLastSlide: isLastSlide,
      onPrevious: isFirstSlide ? null : _goToPreviousSlide,
      onNext: isLastSlide ? null : _goToNextSlide,
      onFinish: isLastSlide ? _finishLesson : null,
      totalSlides: _lesson!.slides.length,
    );
  }
}