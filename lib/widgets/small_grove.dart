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

class SmallGrovePainterWidget extends StatelessWidget {
  final double? width;
  final double? height;
  
  const SmallGrovePainterWidget({
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
        painter: SmallGrovePainter(),
      ),
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
        center: Offset(size.width / 2, size.height * 0.87),
        width: 140,
        height: 16,
      ),
      paint,
    );

    // Tree 1 - Left
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2188, size.height * 0.54, 12, 67),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.2563, size.height * 0.46), 22, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.1875, size.height * 0.49), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.325, size.height * 0.49), 16, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.2563, size.height * 0.38), 14, paint);

    // Tree 2 - Center
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4625, size.height * 0.50, 14, 75),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.5063, size.height * 0.38), 26, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.4063, size.height * 0.43), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.6063, size.height * 0.43), 20, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.31), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.5625, size.height * 0.31), 18, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.5063, size.height * 0.26), 16, paint);

    // Tree 3 - Right
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7375, size.height * 0.56, 11, 63),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.7719, size.height * 0.48), 20, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.7063, size.height * 0.51), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.8375, size.height * 0.51), 15, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.7719, size.height * 0.41), 13, paint);

    // Bushes in front
    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3438, size.height * 0.85),
        width: 36,
        height: 24,
      ),
      paint,
    );

    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6875, size.height * 0.85),
        width: 30,
        height: 20,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
