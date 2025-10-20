import 'package:flutter/material.dart';
import 'dart:math' as math;

class Seed extends StatelessWidget {
  const Seed({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: SeedPainter(),
    );
  }
}

class SeedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Outer ellipse
    paint.color = const Color(0xFF8B7355);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.5625),
        width: 30,
        height: 40,
      ),
      paint,
    );

    // Inner ellipse
    paint.color = const Color(0xFFA0826D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.5625),
        width: 24,
        height: 32,
      ),
      paint,
    );

    // Curve detail
    final curvePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF6B5744);

    final curvePath = Path()
      ..moveTo(size.width * 0.4375, size.height * 0.4375)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.375,
        size.width * 0.5625,
        size.height * 0.4375,
      );
    canvas.drawPath(curvePath, curvePaint);

    // Center spot
    paint.color = const Color(0xFF6B5744).withOpacity(0.3);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.5625),
      3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
