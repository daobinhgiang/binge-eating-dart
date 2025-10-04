import 'package:flutter/material.dart';
import 'dart:math' as math;

class ToolsBackground extends StatefulWidget {
  final Widget child;

  const ToolsBackground({
    super.key,
    required this.child,
  });

  @override
  State<ToolsBackground> createState() => _ToolsBackgroundState();
}

class _ToolsBackgroundState extends State<ToolsBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 28),
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
        // Main background with a more practical/tools-focused gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFF5F5F5), // Light gray
                Color(0xFFFFFFFF), // Pure white
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
        
        // Animated tools-themed shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ToolsShapesPainter(_animation.value),
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

class ToolsShapesPainter extends CustomPainter {
  final double animationValue;

  ToolsShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Tools and activity themed shapes
    // Floating gear/cog shapes representing tools
    for (int i = 0; i < 4; i++) {
      final angle = animationValue + (i * math.pi / 2);
      final centerX = size.width * (0.2 + i * 0.2) + math.sin(angle * 0.2) * 30;
      final centerY = size.height * (0.15 + i * 0.2) + math.cos(angle * 0.2) * 25;
      final radius = 25.0 + i * 5.0;
      
      paint.color = const Color(0xFF7fb781).withOpacity(0.5 - i * 0.1);
      _drawGear(canvas, paint, Offset(centerX, centerY), radius);
    }

    // Floating puzzle pieces representing problem-solving
    for (int i = 0; i < 5; i++) {
      final angle = animationValue * 0.3 + (i * math.pi / 2.5);
      final centerX = size.width * (0.1 + i * 0.18) + math.sin(angle) * 35;
      final centerY = size.height * (0.4 + i * 0.1) + math.cos(angle) * 30;
      
      paint.color = const Color(0xFF4CAF50).withOpacity(0.6 - i * 0.08);
      _drawPuzzlePiece(canvas, paint, Offset(centerX, centerY), 20.0 + i * 3.0);
    }

    // Floating activity icons
    for (int i = 0; i < 6; i++) {
      final angle = animationValue * 0.4 + (i * math.pi / 3);
      final centerX = size.width * (0.15 + i * 0.14) + math.sin(angle) * 25;
      final centerY = size.height * (0.6 + i * 0.06) + math.cos(angle) * 20;
      
      paint.color = const Color(0xFF7ea66f).withOpacity(0.5 - i * 0.06);
      _drawActivityIcon(canvas, paint, Offset(centerX, centerY), 18.0 + i * 2.0, i % 4);
    }

    // Floating progress bars representing growth
    for (int i = 0; i < 3; i++) {
      final angle = animationValue * 0.2 + (i * math.pi / 1.5);
      final centerX = size.width * (0.7 + i * 0.1) + math.sin(angle) * 30;
      final centerY = size.height * (0.3 + i * 0.2) + math.cos(angle) * 25;
      
      // Progress bar background
      paint.color = Colors.white.withOpacity(0.4);
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 30, centerY - 4, 60, 8),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, paint);
      
      // Progress bar fill
      final progress = (math.sin(angle * 2) + 1) / 2; // 0 to 1
      paint.color = const Color(0xFF4CAF50).withOpacity(0.7);
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 30, centerY - 4, 60 * progress, 8),
        const Radius.circular(4),
      );
      canvas.drawRRect(fillRect, paint);
    }

    // Floating checkmarks representing completed activities
    for (int i = 0; i < 4; i++) {
      final angle = animationValue * 0.3 + (i * math.pi / 2);
      final centerX = size.width * (0.8 + i * 0.05) + math.sin(angle) * 20;
      final centerY = size.height * (0.7 + i * 0.08) + math.cos(angle) * 15;
      
      paint.color = const Color(0xFF4CAF50).withOpacity(0.6 - i * 0.1);
      _drawCheckmark(canvas, paint, Offset(centerX, centerY), 15.0 + i * 2.0);
    }

    // Floating target/circle shapes representing goals
    for (int i = 0; i < 3; i++) {
      final angle = animationValue * 0.25 + (i * math.pi / 1.5);
      final centerX = size.width * (0.1 + i * 0.4) + math.sin(angle) * 40;
      final centerY = size.height * (0.8 + i * 0.1) + math.cos(angle) * 20;
      
      // Target circles
      paint.color = const Color(0xFF7fb781).withOpacity(0.4);
      canvas.drawCircle(Offset(centerX, centerY), 20, paint);
      paint.color = const Color(0xFF4CAF50).withOpacity(0.5);
      canvas.drawCircle(Offset(centerX, centerY), 12, paint);
      paint.color = const Color(0xFF2E7D32).withOpacity(0.6);
      canvas.drawCircle(Offset(centerX, centerY), 6, paint);
    }

    // Soft gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFF5F5F5).withOpacity(0.1),
          const Color(0xFFF0F0F0).withOpacity(0.2),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  void _drawGear(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    final teeth = 8;
    final toothDepth = radius * 0.2;
    
    for (int i = 0; i < teeth; i++) {
      final angle = (i * 2 * math.pi) / teeth;
      final x1 = center.dx + math.cos(angle) * radius;
      final y1 = center.dy + math.sin(angle) * radius;
      final x2 = center.dx + math.cos(angle) * (radius - toothDepth);
      final y2 = center.dy + math.sin(angle) * (radius - toothDepth);
      
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Center hole
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  void _drawPuzzlePiece(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final halfSize = size / 2;
    
    // Create a simple puzzle piece shape
    path.moveTo(center.dx - halfSize, center.dy - halfSize);
    path.lineTo(center.dx + halfSize, center.dy - halfSize);
    path.lineTo(center.dx + halfSize, center.dy);
    path.quadraticBezierTo(
      center.dx + halfSize + 5, center.dy + 5,
      center.dx + halfSize, center.dy + halfSize,
    );
    path.lineTo(center.dx - halfSize, center.dy + halfSize);
    path.lineTo(center.dx - halfSize, center.dy);
    path.quadraticBezierTo(
      center.dx - halfSize - 5, center.dy - 5,
      center.dx - halfSize, center.dy - halfSize,
    );
    
    canvas.drawPath(path, paint);
  }

  void _drawActivityIcon(Canvas canvas, Paint paint, Offset center, double size, int iconType) {
    final halfSize = size / 2;
    
    switch (iconType) {
      case 0: // Heart (self-care)
        _drawHeart(canvas, paint, center, halfSize);
        break;
      case 1: // Star (achievement)
        _drawStar(canvas, paint, center, halfSize);
        break;
      case 2: // Diamond (goal)
        _drawDiamond(canvas, paint, center, halfSize);
        break;
      case 3: // Circle (completion)
        canvas.drawCircle(center, halfSize, paint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.5, center.dy + size * 0.2,
      center.dx, center.dy + size * 0.2,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy + size * 0.2,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final points = 5;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCheckmark(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final halfSize = size / 2;
    path.moveTo(center.dx - halfSize * 0.5, center.dy);
    path.lineTo(center.dx - halfSize * 0.1, center.dy + halfSize * 0.3);
    path.lineTo(center.dx + halfSize * 0.5, center.dy - halfSize * 0.3);
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

