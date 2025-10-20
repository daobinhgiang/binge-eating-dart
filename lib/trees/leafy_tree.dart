import 'package:flutter/material.dart';

class LeafyTree extends StatelessWidget {
  const LeafyTree({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: LeafyTreePainter(),
    );
  }
}

class LeafyTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground
    paint.color = const Color(0xFFB8956A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9286),
        width: 80,
        height: 16,
      ),
      paint,
    );

    // Trunk outer
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.45,
          size.height * 0.6071,
          14,
          45,
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
          size.width * 0.4643,
          size.height * 0.6071,
          8,
          45,
        ),
        const Radius.circular(1),
      ),
      paint,
    );

    // Branches
    final branchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B7355);

    branchPaint.strokeWidth = 4;
    var branch = Path()
      ..moveTo(size.width * 0.4786, size.height * 0.6786)
      ..quadraticBezierTo(
        size.width * 0.3571,
        size.height * 0.6429,
        size.width * 0.2857,
        size.height * 0.6071,
      );
    canvas.drawPath(branch, branchPaint);

    branch = Path()
      ..moveTo(size.width * 0.5214, size.height * 0.6786)
      ..quadraticBezierTo(
        size.width * 0.6429,
        size.height * 0.6429,
        size.width * 0.7143,
        size.height * 0.6071,
      );
    canvas.drawPath(branch, branchPaint);

    branchPaint.strokeWidth = 3;
    branch = Path()
      ..moveTo(size.width * 0.4786, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.3929,
        size.height * 0.7143,
        size.width * 0.3429,
        size.height * 0.6786,
      );
    canvas.drawPath(branch, branchPaint);

    branch = Path()
      ..moveTo(size.width * 0.5214, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.6071,
        size.height * 0.7143,
        size.width * 0.6571,
        size.height * 0.6786,
      );
    canvas.drawPath(branch, branchPaint);

    // Large leaf canopy
    paint.style = PaintingStyle.fill;
    
    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4643), 28, paint);
    
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.3571, size.height * 0.5357), 22, paint);
    canvas.drawCircle(Offset(size.width * 0.6429, size.height * 0.5357), 22, paint);
    
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.4286, size.height * 0.3929), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5714, size.height * 0.3929), 20, paint);
    
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.3214), 18, paint);
    
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.3929, size.height * 0.4643), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.6071, size.height * 0.4643), 16, paint);
    
    // Highlights
    paint.color = const Color(0xFFAED581).withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.4643, size.height * 0.3571), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
