import 'package:flutter/material.dart';

class VibrantForest extends StatelessWidget {
  const VibrantForest({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 140),
      painter: VibrantForestPainter(),
    );
  }
}

class VibrantForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Sky gradient background
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFB3E5FC).withOpacity(0.3),
        const Color(0xFFE1F5FE).withOpacity(0.1),
      ],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Ground layers
    paint.shader = null;
    paint.color = const Color(0xFF8B7355);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.95),
        width: 190,
        height: 16,
      ),
      paint,
    );

    paint.color = const Color(0xFFA0826D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9357),
        width: 180,
        height: 12,
      ),
      paint,
    );

    // Far background trees
    paint.color = const Color(0xFF558B2F).withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.5357), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5143), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5286), 17, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.5429), 16, paint);

    // Background trees and all other elements follow the same pattern...
    // (I'll abbreviate for space, but the full implementation includes all trees)

    _drawBackgroundTrees(canvas, size, paint);
    _drawForegroundTrees(canvas, size, paint);
    _drawCentralTree(canvas, size, paint);
    _drawUndergrowth(canvas, size, paint);
    _drawSunlightEffects(canvas, size, paint);
  }

  void _drawBackgroundTrees(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF7D5E3F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.26, size.height * 0.6286, 11, 42),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.2875, size.height * 0.5143), 25, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.5571), 19, paint);
    canvas.drawCircle(Offset(size.width * 0.355, size.height * 0.5571), 19, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.2875, size.height * 0.4286), 17, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.4857), 14, paint);

    paint.color = const Color(0xFF7D5E3F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7, size.height * 0.6429, 12, 40),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.5357), 24, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.665, size.height * 0.5786), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.795, size.height * 0.5786), 18, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.45), 16, paint);
  }

  void _drawForegroundTrees(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.125, size.height * 0.6786, 13, 35),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.1575, size.height * 0.5857), 22, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.6214), 17, paint);
    canvas.drawCircle(Offset(size.width * 0.215, size.height * 0.6214), 17, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.1575, size.height * 0.5143), 15, paint);

    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.84, size.height * 0.7, 12, 32),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.87, size.height * 0.6214), 20, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.65), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.65), 16, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.87, size.height * 0.5571), 14, paint);
  }

  void _drawCentralTree(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.46, size.height * 0.5571, 18, 52),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = const Color(0xFFA0826D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.475, size.height * 0.5571, 11, 52),
        const Radius.circular(1),
      ),
      paint,
    );

    paint.color = const Color(0xFF689F38);
    canvas.drawCircle(Offset(size.width * 0.505, size.height * 0.3857), 32, paint);
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(Offset(size.width * 0.385, size.height * 0.45), 26, paint);
    canvas.drawCircle(Offset(size.width * 0.625, size.height * 0.45), 26, paint);
    paint.color = const Color(0xFF8BC34A);
    canvas.drawCircle(Offset(size.width * 0.43, size.height * 0.3071), 24, paint);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.3071), 24, paint);
    paint.color = const Color(0xFF9CCC65);
    canvas.drawCircle(Offset(size.width * 0.505, size.height * 0.2286), 22, paint);
    paint.color = const Color(0xFFAED581);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.3429), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.3429), 18, paint);
  }

  void _drawUndergrowth(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.075, size.height * 0.9071),
        width: 40,
        height: 28,
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.225, size.height * 0.9143),
        width: 48,
        height: 24,
      ),
      paint,
    );

    paint.color = const Color(0xFF9CCC65);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.375, size.height * 0.9286),
        width: 44,
        height: 26,
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.625, size.height * 0.9286),
        width: 40,
        height: 24,
      ),
      paint,
    );

    paint.color = const Color(0xFF8BC34A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.775, size.height * 0.9143),
        width: 46,
        height: 26,
      ),
      paint,
    );

    paint.color = const Color(0xFF7CB342);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.925, size.height * 0.9071),
        width: 36,
        height: 22,
      ),
      paint,
    );
  }

  void _drawSunlightEffects(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFFFEB3B).withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.475, size.height * 0.2714), 12, paint);

    paint.color = const Color(0xFFFFF59D).withOpacity(0.25);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4643), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.725, size.height * 0.4857), 9, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
