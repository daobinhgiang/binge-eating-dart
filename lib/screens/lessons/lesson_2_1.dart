import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_1_data.dart';
import '../../core/services/quest_completion_service.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../providers/todo_provider.dart';
import '../../providers/auth_provider.dart';

class Lesson21Screen extends ConsumerStatefulWidget {
  const Lesson21Screen({super.key});

  @override
  ConsumerState<Lesson21Screen> createState() => _Lesson21ScreenState();
}

class _Lesson21ScreenState extends ConsumerState<Lesson21Screen> {
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

  Future<void> _loadLesson() async {
    try {
      // Load from the new Stage 1 data structure
      final stage1 = Stage1Data.getStage1();
      final lesson21 = stage1.chapters[1].lessons[0]; // Chapter 2 (index 1), Lesson 1 (index 0)
      
      setState(() {
        _lesson = lesson21;
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
      // Reset scroll position to top
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
      // Reset scroll position to top
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Handle lesson completion with quest tracking
  Future<void> _handleLessonCompletion() async {
    try {
      print('\n📚 [Lesson21Screen] Calling quest completion handler...');
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        print('❌ [Lesson21Screen] User not found');
        return;
      }
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleLessonCompletion(
        userId: user.id,
        lessonId: 'lesson_2_1',
      );
      
      if (result.questCompleted && mounted) {
        print('🎉 [Lesson21Screen] Quest completed! Showing dialog...');
        showQuestCompletionDialog(context, result);
      } else {
        print('ℹ️  [Lesson21Screen] No quest completed yet');
      }
    } catch (e) {
      print('❌ [Lesson21Screen] Error in quest completion: $e');
    }
  }


  void _finishLesson() async {
    // Mark lesson as completed
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
      await _handleLessonCompletion();
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
          title: const Text('Lesson 2.1'),
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
      scrollController: _scrollController,
      isFirstSlide: isFirstSlide,
      isLastSlide: isLastSlide,
      onPrevious: isFirstSlide ? null : _goToPreviousSlide,
      onNext: isLastSlide ? null : _goToNextSlide,
      onFinish: isLastSlide ? _finishLesson : null,
      totalSlides: _lesson!.slides.length,
    );
  }
}