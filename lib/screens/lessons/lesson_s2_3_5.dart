import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/stage_2_data.dart';
import '../../models/lesson.dart';
import '../../screens/tools/urge_surfing_screen.dart';
import '../../core/services/lesson_service.dart';

class LessonS235Screen extends ConsumerStatefulWidget {
  const LessonS235Screen({super.key});

  @override
  ConsumerState<LessonS235Screen> createState() => _LessonS235ScreenState();
}

class _LessonS235ScreenState extends ConsumerState<LessonS235Screen> {
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
      final lesson35 = stage2.chapters[3].lessons[4]; // Chapter 3 (index 3), Lesson 5 (index 4)
      
      setState(() {
        _lesson = lesson35;
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
    
    // Navigate to Urge Surfing tool instead of going back
    _navigateToUrgeSurfingTool();
  }

  void _navigateToUrgeSurfingTool() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const UrgeSurfingScreen(),
      ),
    );
  }

  void _startUrgeSurfingExercise() {
    // Mark lesson as completed and navigate to urge surfing tool
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    _navigateToUrgeSurfingTool();
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
        appBar: AppBar(title: const Text('Lesson 3.5')),
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
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.waves,
                      size: 48,
                      color: Colors.purple[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Surf the Urge?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Practice riding out urges and cravings using our interactive urge surfing tool without acting on them.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _startUrgeSurfingExercise,
                      icon: const Icon(Icons.waves),
                      label: const Text('Start Urge Surfing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
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
