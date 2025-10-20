import 'package:flutter/material.dart';

class YoungTree extends StatelessWidget {
  const YoungTree({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: YoungTreePainter(),
    );
  }
}

class YoungTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground
    paint.color = const Color(0xFFB8956A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9167),
        width: 70,
        height: 16,
      ),
      paint,
    );

    // Trunk outer
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.4583,
          size.height * 0.5833,
          10,
          40,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Trunk inner
    paint.color = const Color(0xFFA0826D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.4667,
          size.height * 0.5833,
          6,
          40,
        ),
        const Radius.circular(1),
      ),
      paint,
    );

    // Branches
    final branchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B7355);

    final leftBranch = Path()
      ..moveTo(size.width / 2, size.height * 0.6667)
      ..quadraticBezierTo(
        size.width * 0.4167,
        size.height * 0.625,
        size.width * 0.375,
        size.height * 0.5833,
      );
    canvas.drawPath(leftBranch, branchPaint);

    final rightBranch = Path()
      ..moveTo(size.width / 2, size.height * 0.625)
      ..quadraticBezierTo(
        size.width * 0.5833,
        size.height * 0.5833,
        size.width * 0.625,
        size.height * 0.5417,
      );
    canvas.drawPath(rightBranch, branchPaint);

    // Leaf clusters
    paint.style = PaintingStyle.fill;
    
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.375, size.height * 0.5667), 12, paint);
    
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.625, size.height * 0.525), 11, paint);
    
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4583), 14, paint);
    
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.4333, size.height * 0.4833), 10, paint);
    
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.5667, size.height * 0.4667), 9, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
