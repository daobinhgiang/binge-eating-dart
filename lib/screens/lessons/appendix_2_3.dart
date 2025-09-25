import 'package:flutter/material.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';

class Appendix23Screen extends StatefulWidget {
  const Appendix23Screen({super.key});

  @override
  State<Appendix23Screen> createState() => _Appendix23ScreenState();
}

class _Appendix23ScreenState extends State<Appendix23Screen> {
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
      final lesson = await _lessonService.getLessonByChapterAndNumber(102, 3);
      if (lesson != null) {
        setState(() {
          _lesson = lesson;
          _isLoading = false;
        });
        return;
      }

      try {
        await _lessonService.initializeDefaultLessons();
        final lesson = await _lessonService.getLessonByChapterAndNumber(102, 3);
        if (lesson != null) {
          setState(() {
            _lesson = lesson;
            _isLoading = false;
          });
          return;
        }
      } catch (initError) {
        print('Warning: Could not initialize lessons: $initError');
      }

      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson not found'),
            duration: Duration(seconds: 5),
          ),
        );
      }
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
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
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
          title: const Text('Appendix 2.3: Eating Out and Social Food Situations'),
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
