import 'package:flutter/material.dart';

class YoungTreePainterWidget extends StatelessWidget {
  final double? width;
  final double? height;
  
  const YoungTreePainterWidget({
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
        painter: YoungTreePainter(),
      ),
    );
  }
}

class YoungTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground mound - smaller and more integrated
    paint.color = const Color(0xFFC4A57B);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.51, size.height * 0.80),
        width: 60,
        height: 14,
      ),
      paint,
    );

    // Trunk - moved closer to ground
    paint.color = const Color(0xFF9B8B7E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.47,
          size.height * 0.62,
          13,
          35,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Top leaf bush - medium green (largest, at the top)
    paint.color = const Color(0xFF7CB342);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.52),
      22,
      paint,
    );

    // Left leaf bush - darkest green (slightly smaller, on the left side)
    paint.color = const Color(0xFF558B2F);
    canvas.drawCircle(
      Offset(size.width * 0.44, size.height * 0.60),
      17,
      paint,
    );

    // Right leaf bush - brightest green (smallest, on the right side)
    paint.color = const Color(0xFFAED581);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.6),
      15,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
