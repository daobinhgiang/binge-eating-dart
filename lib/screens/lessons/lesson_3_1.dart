import 'package:flutter/material.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_1_data.dart';

class Lesson31Screen extends StatefulWidget {
  const Lesson31Screen({super.key});

  @override
  State<Lesson31Screen> createState() => _Lesson31ScreenState();
}

class _Lesson31ScreenState extends State<Lesson31Screen> {
  final LessonService _lessonService = LessonService();
  Lesson? _lesson;
  int _currentSlideIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      // Load from the new Stage 1 data structure
      final stage1 = Stage1Data.getStage1();
      final lesson31 = stage1.chapters[2].lessons[0]; // Chapter 3 (index 2), Lesson 1 (index 0)
      
      setState(() {
        _lesson = lesson31;
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
          title: const Text('Lesson 3.1'),
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
    );
  }
}
