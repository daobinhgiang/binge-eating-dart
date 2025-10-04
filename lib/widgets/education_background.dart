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
        // Main background with a calm, subtle white gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFF5F5F5), // Light gray
                Color(0xFFFFFFFF), // Pure white
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

    // Subtle geometric shapes for a calm learning environment
    // Soft rectangles with gentle animation
    for (int i = 0; i < 2; i++) {
      final angle = animationValue + (i * math.pi / 2);
      final offsetX = math.sin(angle * 0.3) * 8;
      final offsetY = math.cos(angle * 0.3) * 5;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * (0.15 + i * 0.4) + offsetX,
          size.height * (0.25 + i * 0.2) + offsetY,
          size.width * 0.12,
          size.height * 0.06,
        ),
        const Radius.circular(6),
      );
      
      paint.color = Colors.white.withOpacity(0.3 - i * 0.05);
      canvas.drawRRect(rect, paint);
      
      // Add a very subtle border
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF7fb781).withOpacity(0.15);
      paint.strokeWidth = 1;
      canvas.drawRRect(rect, paint);
      paint.style = PaintingStyle.fill;
    }

    // Subtle circular shapes (representing learning/ideas)
    for (int i = 0; i < 3; i++) {
      final angle = animationValue + (i * math.pi / 1.5);
      final radius = 12.0 + i * 2.0;
      final centerX = size.width * (0.2 + i * 0.25) + math.sin(angle * 0.2) * 15;
      final centerY = size.height * (0.4 + i * 0.15) + math.cos(angle * 0.2) * 10;
      
      // Soft circular shapes
      paint.color = const Color(0xFF7fb781).withOpacity(0.2 - i * 0.05);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Simple triangular shapes (representing education)
    for (int i = 0; i < 2; i++) {
      final angle = animationValue + (i * math.pi);
      final centerX = size.width * (0.75 + i * 0.15) + math.sin(angle * 0.3) * 20;
      final centerY = size.height * (0.3 + i * 0.25) + math.cos(angle * 0.3) * 10;
      
      // Simple triangle
      paint.color = const Color(0xFF7fb781).withOpacity(0.25 - i * 0.1);
      final trianglePath = Path();
      trianglePath.moveTo(centerX, centerY - 12);
      trianglePath.lineTo(centerX - 10, centerY + 8);
      trianglePath.lineTo(centerX + 10, centerY + 8);
      trianglePath.close();
      canvas.drawPath(trianglePath, paint);
    }

    // Very subtle line elements
    paint.color = const Color(0xFF7ea66f).withOpacity(0.2);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 2; i++) {
      final angle = animationValue * 0.1 + (i * math.pi);
      final startX = size.width * (0.1 + i * 0.8);
      final startY = size.height * 0.85;
      final endX = startX + math.sin(angle) * 25;
      final endY = startY - 40 + math.cos(angle) * 15;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Very subtle gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFF5F5F5).withOpacity(0.05),
          const Color(0xFFF0F0F0).withOpacity(0.1),
        ],
        stops: const [0.0, 0.7, 1.0],
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
