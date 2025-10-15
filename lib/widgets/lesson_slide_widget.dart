import 'package:flutter/material.dart';
import '../models/lesson_slide.dart';
import 'audio_button_widget.dart';

String? _getAudioPathForSlide(String slideId) {
  // Map slide IDs to their corresponding audio files
  final audioMap = {
    // Lesson 1.1 slides
    'slide_1_1_1': 'audio_lessons/lesson_1_1__slide_1_1_1.wav',
    'slide_1_1_2': 'audio_lessons/lesson_1_1__slide_1_1_2.wav',
    'slide_1_1_3': 'audio_lessons/lesson_1_1__slide_1_1_3.wav',
    'slide_1_1_4': 'audio_lessons/lesson_1_1__slide_1_1_4.wav',
    
    // Lesson 1.3 slides
    'slide_1_3_1': 'audio_lessons/lesson_1_3__slide_1_3_1.wav',
    'slide_1_3_2': 'audio_lessons/lesson_1_3__slide_1_3_2.wav',
    'slide_1_3_3': 'audio_lessons/lesson_1_3__slide_1_3_3.wav',
    'slide_1_3_4': 'audio_lessons/lesson_1_3__slide_1_3_4.wav',
    
    // Lesson 3.1 slides
    'slide_3_1_1': 'audio_lessons/lesson_3_1__slide_3_1_1.wav',
    'slide_3_1_2': 'audio_lessons/lesson_3_1__slide_3_1_2.wav',
    'slide_3_1_3': 'audio_lessons/lesson_3_1__slide_3_1_3.wav',
    'slide_3_1_4': 'audio_lessons/lesson_3_1__slide_3_1_4.wav',
    
    // Lesson 3.2 slides
    'slide_3_2_1': 'audio_lessons/lesson_3_2__slide_3_2_1.wav',
    'slide_3_2_2': 'audio_lessons/lesson_3_2__slide_3_2_2.wav',
    'slide_3_2_3': 'audio_lessons/lesson_3_2__slide_3_2_3.wav',
    'slide_3_2_4': 'audio_lessons/lesson_3_2__slide_3_2_4.wav',
    'slide_3_2_5': 'audio_lessons/lesson_3_2__slide_3_2_5.wav',
    
    // Lesson 3.3 slides
    'slide_3_3_1': 'audio_lessons/lesson_3_3__slide_3_3_1.wav',
    'slide_3_3_2': 'audio_lessons/lesson_3_3__slide_3_3_2.wav',
    'slide_3_3_3': 'audio_lessons/lesson_3_3__slide_3_3_3.wav',
    'slide_3_3_4': 'audio_lessons/lesson_3_3__slide_3_3_4.wav',
    
    // Lesson 3.4 slides
    'slide_3_4_1': 'audio_lessons/lesson_3_4__slide_3_4_1.wav',
    'slide_3_4_2': 'audio_lessons/lesson_3_4__slide_3_4_2.wav',
    'slide_3_4_3': 'audio_lessons/lesson_3_4__slide_3_4_3.wav',
    'slide_3_4_4': 'audio_lessons/lesson_3_4__slide_3_4_4.wav',
    
    // Lesson 3.5 slides
    'slide_3_5_1': 'audio_lessons/lesson_3_5__slide_3_5_1.wav',
    'slide_3_5_2': 'audio_lessons/lesson_3_5__slide_3_5_2.wav',
    'slide_3_5_3': 'audio_lessons/lesson_3_5__slide_3_5_3.wav',
    'slide_3_5_4': 'audio_lessons/lesson_3_5__slide_3_5_4.wav',
    'slide_3_5_5': 'audio_lessons/lesson_3_5__slide_3_5_5.wav',
    
    // Lesson 3.6 slides
    'slide_3_6_1': 'audio_lessons/lesson_3_6__slide_3_6_1.wav',
    'slide_3_6_2': 'audio_lessons/lesson_3_6__slide_3_6_2.wav',
    'slide_3_6_3': 'audio_lessons/lesson_3_6__slide_3_6_3.wav',
    'slide_3_6_4': 'audio_lessons/lesson_3_6__slide_3_6_4.wav',
    
    // Lesson 3.7 slides
    'slide_3_7_1': 'audio_lessons/lesson_3_7__slide_3_7_1.wav',
    'slide_3_7_2': 'audio_lessons/lesson_3_7__slide_3_7_2.wav',
    'slide_3_7_3': 'audio_lessons/lesson_3_7__slide_3_7_3.wav',
    'slide_3_7_4': 'audio_lessons/lesson_3_7__slide_3_7_4.wav',
    
    // Lesson 3.8 slides
    'slide_3_8_1': 'audio_lessons/lesson_3_8__slide_3_8_1.wav',
    'slide_3_8_2': 'audio_lessons/lesson_3_8__slide_3_8_2.wav',
    'slide_3_8_3': 'audio_lessons/lesson_3_8__slide_3_8_3.wav',
    'slide_3_8_4': 'audio_lessons/lesson_3_8__slide_3_8_4.wav',
    
    // Lesson 3.9 slides
    'slide_3_9_1': 'audio_lessons/lesson_3_9__slide_3_9_1.wav',
    'slide_3_9_2': 'audio_lessons/lesson_3_9__slide_3_9_2.wav',
    'slide_3_9_3': 'audio_lessons/lesson_3_9__slide_3_9_3.wav',
    'slide_3_9_4': 'audio_lessons/lesson_3_9__slide_3_9_4.wav',
    
    // Lesson 3.10 slides
    'slide_3_10_1': 'audio_lessons/lesson_3_10__slide_3_10_1.wav',
    'slide_3_10_2': 'audio_lessons/lesson_3_10__slide_3_10_2.wav',
    'slide_3_10_3': 'audio_lessons/lesson_3_10__slide_3_10_3.wav',
    'slide_3_10_4': 'audio_lessons/lesson_3_10__slide_3_10_4.wav',
  };
  
  return audioMap[slideId];
}

class LessonSlideWidget extends StatelessWidget {
  final LessonSlide slide;
  final bool isFirstSlide;
  final bool isLastSlide;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;
  final int totalSlides;

  const LessonSlideWidget({
    super.key,
    required this.slide,
    required this.scrollController,
    this.isFirstSlide = false,
    this.isLastSlide = false,
    this.onPrevious,
    this.onNext,
    this.onFinish,
    this.totalSlides = 10,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF66BB6A).withOpacity(0.02),
              const Color(0xFFF5F7FA),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(context),
              
              // Content Section
              Expanded(
                child: _buildContent(context),
              ),
              
              // Footer Section
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button, lesson title, and audio button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                // Minimalistic back button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF66BB6A).withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: const Color(0xFF66BB6A).withOpacity(0.1),
                      highlightColor: const Color(0xFF66BB6A).withOpacity(0.05),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF66BB6A).withOpacity(0.8),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Lesson title with stunning typography
                Expanded(
                  child: Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.8,
                      height: 1.2,
                    ),
                  ),
                ),
                
                // Audio button
                if (_getAudioPathForSlide(slide.id) != null) ...[
                  const SizedBox(width: 16),
                  AudioButtonWidget(
                    audioPath: _getAudioPathForSlide(slide.id)!,
                    slideId: slide.id,
                  ),
                ],
              ],
            ),
          ),
          
          // Beautiful animated progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Progress fill with shimmer effect
                FractionallySizedBox(
                  widthFactor: slide.slideNumber / totalSlides,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF66BB6A),
                          const Color(0xFF66BB6A).withOpacity(0.8),
                          const Color(0xFF66BB6A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF66BB6A).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF66BB6A).withOpacity(0.06),
                spreadRadius: 0,
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content with beautiful typography
              Text(
                slide.content,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Color(0xFF2D3748),
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              if (slide.bulletPoints.isNotEmpty || slide.additionalInfo != null || slide.imageUrl != null)
                const SizedBox(height: 32),
              
              // Stunning bullet points design
              if (slide.bulletPoints.isNotEmpty) ...[
                ...slide.bulletPoints.asMap().entries.map((entry) {
                  return _BulletPoint(
                    text: entry.value,
                    index: entry.key,
                  );
                }),
                const SizedBox(height: 8),
              ],
              
              // Premium additional info box
              if (slide.additionalInfo != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFF8E1),
                        const Color(0xFFFFECB3).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFA726),
                              Color(0xFFFF9800),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 Key Insight',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide.additionalInfo!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Color(0xFF4A5568),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Premium image display with caption style
              if (slide.imageUrl != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF66BB6A).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      slide.imageUrl!,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button - sleek minimal design
            if (!isFirstSlide)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPrevious,
                      borderRadius: BorderRadius.circular(18),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: const Color(0xFF66BB6A),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back',
                              style: const TextStyle(
                                color: Color(0xFF66BB6A),
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            if (!isFirstSlide) const SizedBox(width: 14),
            
            // Next/Finish button - premium gradient with hover effect
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF66BB6A),
                      const Color(0xFF66BB6A).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF66BB6A).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLastSlide ? onFinish : onNext,
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastSlide ? '✨ Complete' : 'Continue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isLastSlide ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _BulletPoint extends StatelessWidget {
  final String text;
  final int index;

  const _BulletPoint({
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Beautiful color palette for bullet points
    final colors = [
      const Color(0xFF667EEA), // Purple
      const Color(0xFF34D399), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF3B82F6), // Blue
    ];
    
    final bulletColor = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bulletColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: bulletColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Beautiful gradient dot indicator
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bulletColor,
                  bulletColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bulletColor.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Text content
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                height: 1.7,
                color: Color(0xFF2D3748),
                letterSpacing: 0.1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
