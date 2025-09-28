import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/stage_2_data.dart';
import '../../models/lesson.dart';
import '../../screens/tools/problem_solving_main_screen.dart';
import '../../core/services/lesson_service.dart';

class LessonS243Screen extends ConsumerStatefulWidget {
  const LessonS243Screen({super.key});

  @override
  ConsumerState<LessonS243Screen> createState() => _LessonS243ScreenState();
}

class _LessonS243ScreenState extends ConsumerState<LessonS243Screen> {
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
      // Load from the Stage 2 data structure
      final stage2 = Stage2Data.getStage2();
      final lesson43 = stage2.chapters[4].lessons[2]; // Chapter 4 (index 4), Lesson 3 (index 2)
      
      setState(() {
        _lesson = lesson43;
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
    
    // Navigate to Problem Solving tool instead of going back
    _navigateToProblemSolvingTool();
  }

  void _navigateToProblemSolvingTool() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProblemSolvingMainScreen(),
      ),
    );
  }

  void _startProblemSolvingExercise() {
    // Mark lesson as completed and navigate to problem solving tool
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    _navigateToProblemSolvingTool();
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
        appBar: AppBar(title: const Text('Lesson 4.3')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final currentSlide = _lesson!.slides[_currentSlideIndex];
    final isFirstSlide = _currentSlideIndex == 0;
    final isLastSlide = _currentSlideIndex == _lesson!.slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSlide.title),
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide content
            Text(
              currentSlide.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bullet points if any
            if (currentSlide.bulletPoints.isNotEmpty) ...[
              ...currentSlide.bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
            ],
            
            // Special action button for last slide
            if (isLastSlide) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 48,
                      color: Colors.deepOrange[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Practice?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete an interactive problem-solving exercise to practice the techniques you\'ve learned.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _startProblemSolvingExercise,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Start Problem-Solving Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!isFirstSlide)
              Expanded(
                child: OutlinedButton(
                  onPressed: _goToPreviousSlide,
                  child: const Text('Previous'),
                ),
              ),
            if (!isFirstSlide) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLastSlide ? null : _goToNextSlide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: Text(isLastSlide ? 'Complete' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}