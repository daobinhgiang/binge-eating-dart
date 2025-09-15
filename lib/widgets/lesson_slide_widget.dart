import 'package:flutter/material.dart';
import '../models/lesson_slide.dart';

class LessonSlideWidget extends StatelessWidget {
  final LessonSlide slide;
  final bool isFirstSlide;
  final bool isLastSlide;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;

  const LessonSlideWidget({
    super.key,
    required this.slide,
    this.isFirstSlide = false,
    this.isLastSlide = false,
    this.onPrevious,
    this.onNext,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(slide.title),
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Text(
              slide.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bullet points if any
            if (slide.bulletPoints.isNotEmpty) ...[
              ...slide.bulletPoints.map((point) => _BulletPoint(text: point)),
              const SizedBox(height: 20),
            ],
            
            // Additional info if any
            if (slide.additionalInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        slide.additionalInfo!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Image if any
            if (slide.imageUrl != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(slide.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Previous button
            if (!isFirstSlide)
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            
            if (!isFirstSlide) const SizedBox(width: 12),
            
            // Next/Finish button
            Expanded(
              flex: isFirstSlide ? 1 : 1,
              child: ElevatedButton(
                onPressed: isLastSlide ? onFinish : onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(isLastSlide ? 'Finish Chapter' : 'Next'),
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

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
