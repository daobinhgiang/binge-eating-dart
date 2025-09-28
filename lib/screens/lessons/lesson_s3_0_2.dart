import 'package:flutter/material.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_3_data.dart';

class LessonS302Screen extends StatefulWidget {
  const LessonS302Screen({super.key});

  @override
  State<LessonS302Screen> createState() => _LessonS302ScreenState();
}

class _LessonS302ScreenState extends State<LessonS302Screen> {
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
      final stage3 = Stage3Data.getStage3();
      final lesson = stage3.chapters[0].lessons[1];
      
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
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lesson == null || _lesson!.slides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson 0.2')),
        body: const Center(child: Text('Lesson not found')),
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
