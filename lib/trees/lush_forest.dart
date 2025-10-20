import 'package:flutter/material.dart';

class LushForest extends StatelessWidget {
  const LushForest({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 140),
      painter: LushForestPainter(),
    );
  }
}

class LushForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground layers
    paint.color = const Color(0xFF9C8461);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9429),
        width: 170,
        height: 16,
      ),
      paint,
    );

    paint.color = const Color(0xFFB8956A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9286),
        width: 160,
        height: 12,
      ),
      paint,
    );

    // Background trees (darker, smaller)
    paint.color = const Color(0xFF558B2F).withOpacity(0.7);
    canvas.drawCircle(Offset(size.width * 0.1667, size.height * 0.5), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.2778, size.height * 0.4643), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.7222, size.height * 0.4857), 19, paint);
    canvas.drawCircle(Offset(size.width * 0.8333, size.height * 0.5143), 17, paint);

    // Mid-ground trees
    paint.color = const Color(0xFF7D5E3F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.6429, 10, 40),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.2778, size.height * 0.5357), 24, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.2111, size.height * 0.5714), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.3444, size.height * 0.5714), 18, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.2778, size.height * 0.45), 16, paint);

    paint.color = const Color(0xFF7D5E3F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.6667, size.height * 0.6571, 11, 38),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.6972, size.height * 0.5571), 22, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.6333, size.height * 0.5929), 17, paint);
    canvas.drawCircle(Offset(size.width * 0.7611, size.height * 0.5929), 17, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.6972, size.height * 0.4714), 15, paint);

    // Foreground large tree
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4556, size.height * 0.5857, 16, 48),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFFA0826D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4667, size.height * 0.5857, 10, 48),
        const Radius.circular(1),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4286), 30, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.3778, size.height * 0.4857), 24, paint);
    canvas.drawCircle(Offset(size.width * 0.6222, size.height * 0.4857), 24, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.4333, size.height * 0.3429), 22, paint);
    canvas.drawCircle(Offset(size.width * 0.5667, size.height * 0.3429), 22, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.2714), 20, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.4556, size.height * 0.3929), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.5444, size.height * 0.3929), 16, paint);

    // Bushes and undergrowth
    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.1389, size.height * 0.8929),
        width: 44,
        height: 28,
      ),
      paint,
    );

    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3889, size.height * 0.9143),
        width: 40,
        height: 24,
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.8611, size.height * 0.9),
        width: 36,
        height: 24,
      ),
      paint,
    );

    // Light spots
    paint.color = const Color(0xFFAED581).withOpacity(0.5);
    canvas.drawCircle(Offset(size.width * 0.4722, size.height * 0.3214), 10, paint);

    paint.color = const Color(0xFFC5E1A5).withOpacity(0.4);
    canvas.drawCircle(Offset(size.width * 0.3056, size.height * 0.5), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
