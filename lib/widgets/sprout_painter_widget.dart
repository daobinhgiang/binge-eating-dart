import 'package:flutter/material.dart';
import 'dart:math' as math;

class SproutPainterWidget extends StatelessWidget {
  final double? width;
  final double? height;
  
  const SproutPainterWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
      height: height ?? 200,
      child: CustomPaint(
        painter: SproutPainter(),
      ),
    );
  }
}

class SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground
    paint.color = const Color(0xFFC4A57B);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.85),
        width: 50,
        height: 16,
      ),
      paint,
    );

    // Stem
    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7CB342);

    final stemPath = Path()
      ..moveTo(size.width / 2, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.7,
        size.width / 2,
        size.height * 0.55,
      );
    canvas.drawPath(stemPath, stemPaint);

    // Left leaf
    canvas.save();
    canvas.translate(size.width * 0.45, size.height * 0.56);
    canvas.rotate(-30 * math.pi / 180);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 24),
      paint,
    );
    canvas.restore();

    // Right leaf
    canvas.save();
    canvas.translate(size.width * 0.55, size.height * 0.55);
    canvas.rotate(25 * math.pi / 180);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 22),
      paint,
    );
    canvas.restore();

    // Leaf veins
    final veinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF7CB342).withOpacity(0.5);

    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.50),
      Offset(size.width * 0.45, size.height * 0.62),
      veinPaint,
    );

    veinPaint.color = const Color(0xFF689F38).withOpacity(0.5);
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.49),
      Offset(size.width * 0.55, size.height * 0.61),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
