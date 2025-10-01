import 'package:flutter/material.dart';
import 'dart:math' as math;

class EducationBackground extends StatefulWidget {
  final Widget child;

  const EducationBackground({
    super.key,
    required this.child,
  });

  @override
  State<EducationBackground> createState() => _EducationBackgroundState();
}

class _EducationBackgroundState extends State<EducationBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main background with a more academic/learning-focused gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E8), // Light mint green
                Color(0xFFF0F8F0), // Very light green
                Color(0xFFE0F2E0), // Slightly more green
                Color(0xFFD4E6D4), // Back to mint green
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        
        // Animated learning-themed shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: EducationShapesPainter(_animation.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class EducationShapesPainter extends CustomPainter {
  final double animationValue;

  EducationShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Learning-themed geometric shapes instead of organic ones
    // Book-like rectangles with subtle animation
    for (int i = 0; i < 3; i++) {
      final angle = animationValue + (i * math.pi / 3);
      final offsetX = math.sin(angle * 0.5) * 15;
      final offsetY = math.cos(angle * 0.5) * 10;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * (0.1 + i * 0.3) + offsetX,
          size.height * (0.2 + i * 0.15) + offsetY,
          size.width * 0.15,
          size.height * 0.08,
        ),
        const Radius.circular(8),
      );
      
      paint.color = Colors.white.withOpacity(0.6 - i * 0.1);
      canvas.drawRRect(rect, paint);
      
      // Add a subtle border
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF7fb781).withOpacity(0.3);
      paint.strokeWidth = 1.5;
      canvas.drawRRect(rect, paint);
      paint.style = PaintingStyle.fill;
    }

    // Floating lightbulb shapes (representing learning/ideas)
    for (int i = 0; i < 4; i++) {
      final angle = animationValue + (i * math.pi / 2);
      final radius = 18.0 + i * 3.0;
      final centerX = size.width * (0.15 + i * 0.2) + math.sin(angle * 0.3) * 25;
      final centerY = size.height * (0.4 + i * 0.12) + math.cos(angle * 0.3) * 20;
      
      // Lightbulb body
      paint.color = const Color(0xFFFFF59D).withOpacity(0.7 - i * 0.1);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * 0.7,
        paint,
      );
      
      // Lightbulb base
      final baseRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - radius * 0.3,
          centerY + radius * 0.5,
          radius * 0.6,
          radius * 0.3,
        ),
        const Radius.circular(4),
      );
      paint.color = const Color(0xFFE0E0E0).withOpacity(0.6 - i * 0.1);
      canvas.drawRRect(baseRect, paint);
    }

    // Graduation cap shapes (representing education)
    for (int i = 0; i < 2; i++) {
      final angle = animationValue + (i * math.pi);
      final centerX = size.width * (0.7 + i * 0.2) + math.sin(angle * 0.4) * 30;
      final centerY = size.height * (0.3 + i * 0.2) + math.cos(angle * 0.4) * 15;
      
      // Cap top
      paint.color = const Color(0xFF7fb781).withOpacity(0.6 - i * 0.2);
      final capPath = Path();
      capPath.moveTo(centerX - 20, centerY);
      capPath.lineTo(centerX + 20, centerY);
      capPath.lineTo(centerX + 15, centerY - 15);
      capPath.lineTo(centerX - 15, centerY - 15);
      capPath.close();
      canvas.drawPath(capPath, paint);
      
      // Cap tassel
      paint.color = const Color(0xFF4CAF50).withOpacity(0.7 - i * 0.2);
      canvas.drawCircle(
        Offset(centerX + 15, centerY - 15),
        3,
        paint,
      );
    }

    // Subtle knowledge tree branches
    paint.color = const Color(0xFF7ea66f).withOpacity(0.4);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 2; i++) {
      final angle = animationValue * 0.2 + (i * math.pi);
      final startX = size.width * (0.05 + i * 0.9);
      final startY = size.height * 0.8;
      final endX = startX + math.sin(angle) * 40;
      final endY = startY - 60 + math.cos(angle) * 20;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      // Add small leaves
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF4CAF50).withOpacity(0.5);
      for (int j = 0; j < 3; j++) {
        final leafX = startX + (endX - startX) * (j + 1) / 4;
        final leafY = startY + (endY - startY) * (j + 1) / 4;
        canvas.drawCircle(
          Offset(leafX, leafY),
          4,
          paint,
        );
      }
      paint.style = PaintingStyle.stroke;
    }

    // Soft gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFE8F5E8).withOpacity(0.1),
          const Color(0xFFD4E6D4).withOpacity(0.2),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
