import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/stage_1_data.dart';
import '../../models/lesson.dart';
import '../../core/services/lesson_service.dart';
import '../../core/services/quest_completion_service.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';

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

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
          .firstWhere((lesson) => lesson.id == 'lesson_1_1');
      
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
      print('\n📚 [Lesson 1.1] Calling quest completion handler...');
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        print('❌ [Lesson 1.1] User not found');
        return;
      }
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleLessonCompletion(
        userId: user.id,
        lessonId: 'lesson_1_1',
      );
      
      if (result.questCompleted && mounted) {
        print('🎉 [Lesson 1.1] Quest completed! Showing dialog...');
        showQuestCompletionDialog(context, result);
      } else {
        print('ℹ️  [Lesson 1.1] No quest completed yet');
      }
    } catch (e) {
      print('❌ [Lesson 1.1] Error in quest completion: $e');
    }
  }

  void _finishLesson() async {
    // Mark lesson as completed
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
      await _handleLessonCompletion();
    }
    
    // Mark user as having completed first lesson for tutorial tracking
    try {
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasCompletedFirstLesson: true,
      );
    } catch (e) {
      // Silently fail - this is not critical to lesson completion
      debugPrint('Error updating tutorial status: $e');
    }
    
    // Navigate back to education screen
    if (mounted) {
      Navigator.of(context).pop();
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