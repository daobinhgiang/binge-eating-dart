import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../widgets/lesson_slide_widget.dart';
import '../../data/stage_2_data.dart';
import '../../core/services/quest_completion_service.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../providers/todo_provider.dart';
import '../../providers/auth_provider.dart';

class LessonS242Screen extends ConsumerStatefulWidget {
  const LessonS242Screen({super.key});

  @override
  ConsumerState<LessonS242Screen> createState() => _LessonS242ScreenState();
}

class _LessonS242ScreenState extends ConsumerState<LessonS242Screen> {
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
      final stage2 = Stage2Data.getStage2();
      final lesson = stage2.chapters
          .firstWhere((chapter) => chapter.chapterNumber == 4)
          .lessons
          .firstWhere((lesson) => lesson.id == 'lesson_s2_4_2');
      
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
      print('\n📚 [LessonS242Screen] Calling quest completion handler...');
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        print('❌ [LessonS242Screen] User not found');
        return;
      }
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleLessonCompletion(
        userId: user.id,
        lessonId: 'lesson_s2_4_2',
      );
      
      if (result.questCompleted && mounted) {
        print('🎉 [LessonS242Screen] Quest completed! Showing dialog...');
        showQuestCompletionDialog(context, result);
      } else {
        print('ℹ️  [LessonS242Screen] No quest completed yet');
      }
    } catch (e) {
      print('❌ [LessonS242Screen] Error in quest completion: $e');
    }
  }


  void _finishLesson() async {
    if (_lesson != null) {
      await _lessonService.markLessonCompleted(_lesson!.id);
      await _handleLessonCompletion();
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
        appBar: AppBar(title: const Text('Lesson 4.2')),
        body: const Center(child: Text('Lesson not found')),
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
