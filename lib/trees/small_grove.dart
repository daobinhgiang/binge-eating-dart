import 'package:flutter/material.dart';

class SmallGrove extends StatelessWidget {
  const SmallGrove({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(160, 140),
      painter: SmallGrovePainter(),
    );
  }
}

class SmallGrovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground
    paint.color = const Color(0xFFB8956A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9286),
        width: 140,
        height: 16,
      ),
      paint,
    );

    // Tree 1 - Left
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2188, size.height * 0.6429, 12, 40),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.2563, size.height * 0.5357), 22, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.1875, size.height * 0.5714), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.325, size.height * 0.5714), 16, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.2563, size.height * 0.4643), 14, paint);

    // Tree 2 - Center
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4625, size.height * 0.6071, 14, 45),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.5063, size.height * 0.4643), 26, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.4063, size.height * 0.5143), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.6063, size.height * 0.5143), 20, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.3929), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.5625, size.height * 0.3929), 18, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.5063, size.height * 0.3429), 16, paint);

    // Tree 3 - Right
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7375, size.height * 0.6571, 11, 38),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.7719, size.height * 0.5571), 20, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.7063, size.height * 0.5929), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.8375, size.height * 0.5929), 15, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.7719, size.height * 0.4857), 13, paint);

    // Bushes in front
    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3438, size.height * 0.8929),
        width: 36,
        height: 24,
      ),
      paint,
    );

    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6875, size.height * 0.8929),
        width: 30,
        height: 20,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
