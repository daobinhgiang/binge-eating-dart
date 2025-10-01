import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileBackground extends StatefulWidget {
  final Widget child;

  const ProfileBackground({
    super.key,
    required this.child,
  });

  @override
  State<ProfileBackground> createState() => _ProfileBackgroundState();
}

class _ProfileBackgroundState extends State<ProfileBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
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
        // Main background with a more personal/profile-focused gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0F8F0), // Very light green
                Color(0xFFE8F5E8), // Light mint green
                Color(0xFFE0F2E0), // Slightly more green
                Color(0xFFD4E6D4), // Mint green
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
        
        // Animated profile-themed shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ProfileShapesPainter(_animation.value),
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

class ProfileShapesPainter extends CustomPainter {
  final double animationValue;

  ProfileShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Personal growth and self-reflection themed shapes
    // Heart shapes representing self-care and personal growth
    for (int i = 0; i < 3; i++) {
      final angle = animationValue + (i * math.pi / 1.5);
      final centerX = size.width * (0.2 + i * 0.3) + math.sin(angle * 0.2) * 20;
      final centerY = size.height * (0.15 + i * 0.2) + math.cos(angle * 0.2) * 15;
      
      paint.color = const Color(0xFFFFB3BA).withOpacity(0.6 - i * 0.15);
      _drawHeart(canvas, paint, Offset(centerX, centerY), 25.0 - i * 3.0);
    }

    // Gentle wave patterns representing emotional flow
    paint.color = const Color(0xFF7fb781).withOpacity(0.3);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 2; i++) {
      final wavePath = Path();
      final startY = size.height * (0.3 + i * 0.4);
      final amplitude = 15.0 + i * 5.0;
      final frequency = 0.02 + i * 0.01;
      
      wavePath.moveTo(0, startY);
      for (double x = 0; x <= size.width; x += 2) {
        final y = startY + math.sin(x * frequency + animationValue * 0.5) * amplitude;
        wavePath.lineTo(x, y);
      }
      canvas.drawPath(wavePath, paint);
    }

    // Floating meditation/wellness circles
    for (int i = 0; i < 5; i++) {
      final angle = animationValue + (i * math.pi / 2.5);
      final radius = 20.0 + i * 4.0;
      final centerX = size.width * (0.1 + i * 0.2) + math.sin(angle * 0.3) * 30;
      final centerY = size.height * (0.4 + i * 0.1) + math.cos(angle * 0.3) * 25;
      
      // Outer circle
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF7fb781).withOpacity(0.4 - i * 0.05);
      paint.strokeWidth = 2;
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
      
      // Inner circle
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withOpacity(0.3 - i * 0.04);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * 0.6,
        paint,
      );
    }

    // Gentle leaf patterns representing growth and renewal
    paint.color = const Color(0xFF4CAF50).withOpacity(0.5);
    paint.style = PaintingStyle.fill;
    
    for (int i = 0; i < 4; i++) {
      final angle = animationValue * 0.3 + (i * math.pi / 2);
      final centerX = size.width * (0.8 + i * 0.05) + math.sin(angle) * 40;
      final centerY = size.height * (0.2 + i * 0.15) + math.cos(angle) * 20;
      
      _drawLeaf(canvas, paint, Offset(centerX, centerY), 15.0 - i * 2.0, angle);
    }

    // Soft cloud-like shapes for a calming effect
    paint.color = Colors.white.withOpacity(0.4);
    for (int i = 0; i < 3; i++) {
      final angle = animationValue * 0.2 + (i * math.pi / 1.5);
      final centerX = size.width * (0.1 + i * 0.4) + math.sin(angle) * 25;
      final centerY = size.height * (0.7 + i * 0.1) + math.cos(angle) * 15;
      
      _drawCloud(canvas, paint, Offset(centerX, centerY), 30.0 + i * 5.0);
    }

    // Soft gradient overlay for depth and warmth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFE8F5E8).withOpacity(0.2),
          const Color(0xFFD4E6D4).withOpacity(0.3),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final width = size;
    final height = size;
    
    path.moveTo(center.dx, center.dy + height * 0.3);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.1,
      center.dx - width * 0.5, center.dy + height * 0.2,
      center.dx, center.dy + height * 0.2,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy + height * 0.2,
      center.dx + width * 0.5, center.dy - height * 0.1,
      center.dx, center.dy + height * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double size, double angle) {
    final path = Path();
    final width = size;
    final height = size * 1.5;
    
    // Rotate the leaf based on angle
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    
    path.moveTo(center.dx, center.dy);
    path.quadraticBezierTo(
      center.dx - width * 0.3 * cos + height * 0.2 * sin,
      center.dy - width * 0.3 * sin - height * 0.2 * cos,
      center.dx - width * 0.1 * cos + height * 0.4 * sin,
      center.dy - width * 0.1 * sin - height * 0.4 * cos,
    );
    path.quadraticBezierTo(
      center.dx + width * 0.1 * cos + height * 0.4 * sin,
      center.dy + width * 0.1 * sin - height * 0.4 * cos,
      center.dx + width * 0.3 * cos + height * 0.2 * sin,
      center.dy + width * 0.3 * sin - height * 0.2 * cos,
    );
    path.quadraticBezierTo(
      center.dx, center.dy,
      center.dx, center.dy,
    );
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final width = size;
    final height = size * 0.6;
    
    path.moveTo(center.dx - width * 0.3, center.dy);
    path.quadraticBezierTo(
      center.dx - width * 0.5, center.dy - height * 0.3,
      center.dx - width * 0.2, center.dy - height * 0.2,
    );
    path.quadraticBezierTo(
      center.dx, center.dy - height * 0.4,
      center.dx + width * 0.2, center.dy - height * 0.2,
    );
    path.quadraticBezierTo(
      center.dx + width * 0.5, center.dy - height * 0.3,
      center.dx + width * 0.3, center.dy,
    );
    path.quadraticBezierTo(
      center.dx + width * 0.4, center.dy + height * 0.2,
      center.dx, center.dy + height * 0.1,
    );
    path.quadraticBezierTo(
      center.dx - width * 0.4, center.dy + height * 0.2,
      center.dx - width * 0.3, center.dy,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
