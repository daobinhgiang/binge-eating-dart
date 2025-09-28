import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/stage_2_data.dart';
import '../../models/lesson.dart';
import '../../screens/tools/addressing_overconcern_screen.dart';
import '../../core/services/lesson_service.dart';

class LessonS2721Screen extends ConsumerStatefulWidget {
  const LessonS2721Screen({super.key});

  @override
  ConsumerState<LessonS2721Screen> createState() => _LessonS2721ScreenState();
}

class _LessonS2721ScreenState extends ConsumerState<LessonS2721Screen> {
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
      final lesson721 = stage2.chapters[6].lessons[2]; // Chapter 7 (index 6), Lesson 3 (index 2, which is 7.2.1)
      
      setState(() {
        _lesson = lesson721;
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
    
    // Navigate to Addressing Overconcern tool instead of going back
    _navigateToAddressingOverconcernTool();
  }

  void _navigateToAddressingOverconcernTool() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AddressingOverconcernScreen(),
      ),
    );
  }

  void _startAddressingOverconcernExercise() {
    // Mark lesson as completed and navigate to addressing overconcern tool
    if (_lesson != null) {
      _lessonService.markLessonCompleted(_lesson!.id);
    }
    _navigateToAddressingOverconcernTool();
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
        appBar: AppBar(title: const Text('Lesson 7.2.1')),
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
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.psychology_alt,
                      size: 48,
                      color: Colors.pink[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Address Overconcern?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Practice techniques for reducing excessive focus on body shape and weight using our interactive tool.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _startAddressingOverconcernExercise,
                      icon: const Icon(Icons.psychology_alt),
                      label: const Text('Start Addressing Overconcern'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[600],
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
