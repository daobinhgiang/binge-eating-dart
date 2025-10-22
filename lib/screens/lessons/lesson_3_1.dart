import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_1_data.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../providers/todo_provider.dart';
import '../../providers/auth_provider.dart';

class Lesson31Screen extends ConsumerStatefulWidget {
  const Lesson31Screen({super.key});

  @override
  ConsumerState<Lesson31Screen> createState() => _Lesson31ScreenState();
}

class _Lesson31ScreenState extends ConsumerState<Lesson31Screen> {
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
      print('\n📚 [Lesson31Screen] Calling quest completion handler...');
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        print('❌ [Lesson31Screen] User not found');
        return;
      }
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleLessonCompletion(
        userId: user.id,
        lessonId: 'lesson_3_1',
      );
      
      if (result.questCompleted && mounted) {
        print('🎉 [Lesson31Screen] Quest completed! Showing dialog...');
        showQuestCompletionDialog(context, result);
      } else {
        print('ℹ️  [Lesson31Screen] No quest completed yet');
      }
    } catch (e) {
      print('❌ [Lesson31Screen] Error in quest completion: $e');
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
