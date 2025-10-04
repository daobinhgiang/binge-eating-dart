import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/lesson.dart';
import '../../data/stage_1_data.dart';
import '../../widgets/forest_background.dart';

class Lesson121Screen extends ConsumerStatefulWidget {
  const Lesson121Screen({super.key});

  @override
  ConsumerState<Lesson121Screen> createState() => _Lesson121ScreenState();
}

class _Lesson121ScreenState extends ConsumerState<Lesson121Screen> {
  int _currentSlideIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlideIndex < _getLesson().slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Lesson _getLesson() {
    final stage1 = Stage1Data.getStage1();
    return stage1.chapters
        .firstWhere((chapter) => chapter.chapterNumber == 1)
        .lessons
        .firstWhere((lesson) => lesson.id == 'lesson_1_2_1');
  }

  void _navigateToJournal() {
    // Navigate to the Journal tab
    context.go('/journal');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    final lesson = _getLesson();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'LESSON',
                                  style: TextStyle(
                                    color: Colors.orange.shade300,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.school_outlined,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.slideshow_outlined,
                                color: Colors.white.withOpacity(0.7),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Slide ${_currentSlideIndex + 1} of ${lesson.slides.length}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_stories_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Enhanced Progress Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((_currentSlideIndex + 1) / lesson.slides.length * 100).round()}%',
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            height: 8,
                            width: MediaQuery.of(context).size.width * 
                                   ((_currentSlideIndex + 1) / lesson.slides.length) * 0.8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Slide ${_currentSlideIndex + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'of ${lesson.slides.length}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlideIndex = index;
                    });
                  },
                  itemCount: lesson.slides.length,
                  itemBuilder: (context, index) {
                    final slide = lesson.slides[index];
                    final isCurrentSlide = index == _currentSlideIndex;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isCurrentSlide ? 8 : 16,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.98),
                            Colors.white.withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrentSlide 
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          width: isCurrentSlide ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrentSlide 
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                            blurRadius: isCurrentSlide ? 20 : 15,
                            offset: const Offset(0, 8),
                            spreadRadius: isCurrentSlide ? 2 : 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Slide header with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade100,
                                      Colors.orange.shade200,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  slide.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Main content
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              slide.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Enhanced bullet points
                          if (slide.bulletPoints.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.indigo.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.key_outlined,
                                        color: Colors.blue.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Key Points',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...slide.bulletPoints.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final point = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${idx + 1}',
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              point,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey.shade700,
                                                height: 1.5,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Enhanced Navigation Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    if (_currentSlideIndex > 0)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _previousSlide,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 100),
                    
                    // Next/Finish button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _currentSlideIndex == lesson.slides.length - 1
                            ? [Colors.green.shade500, Colors.green.shade600]
                            : [Colors.orange.shade500, Colors.orange.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_currentSlideIndex == lesson.slides.length - 1
                              ? Colors.green
                              : Colors.orange).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _currentSlideIndex == lesson.slides.length - 1
                            ? _navigateToJournal
                            : _nextSlide,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentSlideIndex == lesson.slides.length - 1
                                    ? 'Start Exercise'
                                    : 'Next',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentSlideIndex == lesson.slides.length - 1
                                    ? Icons.play_arrow
                                    : Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

