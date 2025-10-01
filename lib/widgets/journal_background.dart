import 'package:flutter/material.dart';
import 'dart:math' as math;

class JournalBackground extends StatefulWidget {
  final Widget child;

  const JournalBackground({
    super.key,
    required this.child,
  });

  @override
  State<JournalBackground> createState() => _JournalBackgroundState();
}

class _JournalBackgroundState extends State<JournalBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 35),
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
        // Main background with a more reflective/journal-focused gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E8), // Light mint green
                Color(0xFFF0F8F0), // Very light green
                Color(0xFFE0F2E0), // Slightly more green
                Color(0xFFD4E6D4), // Mint green
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        
        // Animated journal-themed shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: JournalShapesPainter(_animation.value),
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

class JournalShapesPainter extends CustomPainter {
  final double animationValue;

  JournalShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Writing and reflection themed shapes
    // Floating paper/journal pages
    for (int i = 0; i < 4; i++) {
      final angle = animationValue + (i * math.pi / 2);
      final centerX = size.width * (0.15 + i * 0.2) + math.sin(angle * 0.2) * 25;
      final centerY = size.height * (0.2 + i * 0.15) + math.cos(angle * 0.2) * 20;
      
      // Paper page
      paint.color = Colors.white.withOpacity(0.7 - i * 0.1);
      final pageRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - 30,
          centerY - 40,
          60,
          80,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(pageRect, paint);
      
      // Page border
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF7fb781).withOpacity(0.4);
      paint.strokeWidth = 1.5;
      canvas.drawRRect(pageRect, paint);
      paint.style = PaintingStyle.fill;
      
      // Writing lines on the page
      paint.color = const Color(0xFF7fb781).withOpacity(0.2);
      paint.strokeWidth = 1;
      paint.style = PaintingStyle.stroke;
      for (int j = 0; j < 5; j++) {
        final lineY = centerY - 30 + j * 8;
        canvas.drawLine(
          Offset(centerX - 20, lineY),
          Offset(centerX + 20, lineY),
          paint,
        );
      }
      paint.style = PaintingStyle.fill;
    }

    // Floating pen/quill shapes
    for (int i = 0; i < 3; i++) {
      final angle = animationValue * 0.3 + (i * math.pi / 1.5);
      final centerX = size.width * (0.7 + i * 0.1) + math.sin(angle) * 30;
      final centerY = size.height * (0.3 + i * 0.2) + math.cos(angle) * 25;
      
      // Pen body
      paint.color = const Color(0xFF4CAF50).withOpacity(0.6 - i * 0.15);
      final penRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - 2,
          centerY - 20,
          4,
          40,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(penRect, paint);
      
      // Pen tip
      paint.color = const Color(0xFF2E7D32).withOpacity(0.7 - i * 0.15);
      canvas.drawCircle(
        Offset(centerX, centerY + 20),
        3,
        paint,
      );
      
      // Feather (for quill effect)
      paint.color = const Color(0xFF7fb781).withOpacity(0.5 - i * 0.1);
      final featherPath = Path();
      featherPath.moveTo(centerX - 2, centerY - 20);
      featherPath.quadraticBezierTo(
        centerX - 8, centerY - 25,
        centerX - 6, centerY - 30,
      );
      featherPath.quadraticBezierTo(
        centerX - 4, centerY - 28,
        centerX - 2, centerY - 20,
      );
      canvas.drawPath(featherPath, paint);
    }

    // Floating thought bubbles representing reflection
    for (int i = 0; i < 5; i++) {
      final angle = animationValue + (i * math.pi / 2.5);
      final radius = 15.0 + i * 3.0;
      final centerX = size.width * (0.1 + i * 0.2) + math.sin(angle * 0.3) * 35;
      final centerY = size.height * (0.5 + i * 0.08) + math.cos(angle * 0.3) * 30;
      
      // Main bubble
      paint.color = Colors.white.withOpacity(0.6 - i * 0.08);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
      
      // Bubble border
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF7fb781).withOpacity(0.4);
      paint.strokeWidth = 1.5;
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
      paint.style = PaintingStyle.fill;
      
      // Small connecting bubble
      if (i % 2 == 0) {
        paint.color = Colors.white.withOpacity(0.4);
        canvas.drawCircle(
          Offset(centerX + radius * 0.7, centerY + radius * 0.7),
          radius * 0.3,
          paint,
        );
      }
    }

    // Gentle ink drops representing writing
    paint.color = const Color(0xFF4CAF50).withOpacity(0.3);
    for (int i = 0; i < 6; i++) {
      final angle = animationValue * 0.4 + (i * math.pi / 3);
      final centerX = size.width * (0.2 + i * 0.12) + math.sin(angle) * 20;
      final centerY = size.height * (0.7 + i * 0.05) + math.cos(angle) * 15;
      
      // Ink drop shape
      final inkPath = Path();
      inkPath.moveTo(centerX, centerY);
      inkPath.quadraticBezierTo(
        centerX - 3, centerY + 8,
        centerX, centerY + 12,
      );
      inkPath.quadraticBezierTo(
        centerX + 3, centerY + 8,
        centerX, centerY,
      );
      canvas.drawPath(inkPath, paint);
    }

    // Floating bookmarks
    for (int i = 0; i < 3; i++) {
      final angle = animationValue * 0.2 + (i * math.pi / 1.5);
      final centerX = size.width * (0.8 + i * 0.05) + math.sin(angle) * 25;
      final centerY = size.height * (0.2 + i * 0.25) + math.cos(angle) * 20;
      
      paint.color = const Color(0xFFFF9800).withOpacity(0.6 - i * 0.15);
      final bookmarkPath = Path();
      bookmarkPath.moveTo(centerX - 8, centerY - 15);
      bookmarkPath.lineTo(centerX + 8, centerY - 15);
      bookmarkPath.lineTo(centerX + 8, centerY + 15);
      bookmarkPath.lineTo(centerX, centerY + 10);
      bookmarkPath.lineTo(centerX - 8, centerY + 15);
      bookmarkPath.close();
      canvas.drawPath(bookmarkPath, paint);
    }

    // Soft gradient overlay for depth and warmth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFE8F5E8).withOpacity(0.15),
          const Color(0xFFD4E6D4).withOpacity(0.25),
        ],
        stops: const [0.0, 0.5, 1.0],
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

