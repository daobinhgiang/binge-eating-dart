import 'package:flutter/material.dart';
import '../models/lesson_slide.dart';

/// A beautiful, engaging widget for lessons that prepare users for exercises
class ExercisePrepSlideWidget extends StatelessWidget {
  final LessonSlide slide;
  final bool isFirstSlide;
  final bool isLastSlide;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onStartExercise;
  final int totalSlides;
  final String exerciseButtonText;
  final IconData exerciseIcon;
  final Color? accentColor;

  const ExercisePrepSlideWidget({
    super.key,
    required this.slide,
    required this.scrollController,
    this.isFirstSlide = false,
    this.isLastSlide = false,
    this.onPrevious,
    this.onNext,
    this.onStartExercise,
    this.totalSlides = 10,
    this.exerciseButtonText = 'Start Exercise',
    this.exerciseIcon = Icons.fitness_center,
    this.accentColor,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? const Color(0xFF66BB6A);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.08),
              Colors.white,
              color.withOpacity(0.03),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Stunning header
              _buildHeader(context, color),
              
              // Content Section
              Expanded(
                child: _buildContent(context, color),
              ),
              
              // Footer Section
              _buildFooter(context, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
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
                      color: color.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: color.withOpacity(0.1),
                      highlightColor: color.withOpacity(0.05),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: color.withOpacity(0.8),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: slide.slideNumber / totalSlides,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.8),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
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

  Widget _buildContent(BuildContext context, Color color) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          children: [
            // Main content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content text
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
                  
                  if (slide.bulletPoints.isNotEmpty) const SizedBox(height: 32),
                  
                  // Bullet points with colorful cards
                  if (slide.bulletPoints.isNotEmpty) ...[
                    ...slide.bulletPoints.asMap().entries.map((entry) {
                      return _buildBulletCard(
                        text: entry.value,
                        index: entry.key,
                        color: color,
                      );
                    }),
                  ],
                ],
              ),
            ),
            
            // Call to action card for last slide
            if (isLastSlide && onStartExercise != null) ...[
              const SizedBox(height: 24),
              _buildCallToActionCard(context, color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBulletCard({
    required String text,
    required int index,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.04),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Beautiful numbered badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                height: 1.6,
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

  Widget _buildCallToActionCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with gradient background
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              exerciseIcon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            '🎯 Ready to Practice?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            'Apply what you\'ve learned with an interactive exercise designed to reinforce these concepts.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[700],
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          
          // CTA Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onStartExercise,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        exerciseIcon,
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        exerciseButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color color) {
    // Only show navigation if not on last slide (since last slide has the CTA button)
    if (isLastSlide) {
      return const SizedBox.shrink();
    }
    
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
            // Previous button
            if (!isFirstSlide)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
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
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: color,
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
            
            // Next button
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onNext,
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
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

