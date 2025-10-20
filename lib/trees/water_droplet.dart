import 'package:flutter/material.dart';

class WaterDroplet extends StatelessWidget {
  const WaterDroplet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 120),
      painter: WaterDropletPainter(),
    );
  }
}

class WaterDropletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    paint.color = const Color(0xFFB0BEC5).withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9167),
        width: 40,
        height: 12,
      ),
      paint,
    );

    // Main droplet shape
    final dropletPath = Path()
      ..moveTo(size.width / 2, size.height * 0.1667)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.3333,
        size.width * 0.35,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.7083,
        size.width / 2,
        size.height * 0.7917,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.7083,
        size.width * 0.65,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.3333,
        size.width / 2,
        size.height * 0.1667,
      )
      ..close();

    paint.color = const Color(0xFF42A5F5);
    canvas.drawPath(dropletPath, paint);

    // Mid layer for depth
    final midPath = Path()
      ..moveTo(size.width / 2, size.height * 0.1667)
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.3333,
        size.width * 0.37,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.6917,
        size.width / 2,
        size.height * 0.7667,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.6917,
        size.width * 0.63,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.3333,
        size.width / 2,
        size.height * 0.1667,
      )
      ..close();

    paint.color = const Color(0xFF64B5F6);
    canvas.drawPath(midPath, paint);

    // Inner layer
    final innerPath = Path()
      ..moveTo(size.width / 2, size.height * 0.1667)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.3333,
        size.width * 0.4,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.6667,
        size.width / 2,
        size.height * 0.7333,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.6667,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.3333,
        size.width / 2,
        size.height * 0.1667,
      )
      ..close();

    paint.color = const Color(0xFF90CAF9);
    canvas.drawPath(innerPath, paint);

    // Light reflection - large
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.375),
        width: 24,
        height: 32,
      ),
      paint,
    );

    // Light reflection - small highlight
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.43, size.height * 0.3167),
        width: 12,
        height: 16,
      ),
      paint,
    );

    // Tiny sparkle
    paint.color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.4583),
      3,
      paint,
    );

    // Bottom shine
    paint.color = const Color(0xFFE3F2FD).withOpacity(0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.625),
        width: 16,
        height: 12,
      ),
      paint,
    );

    // Darker edge on right for depth
    final edgePath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.6667,
        size.width / 2,
        size.height * 0.7333,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.6667,
        size.width * 0.63,
        size.height * 0.5,
      )
      ..close();

    paint.color = const Color(0xFF1976D2).withOpacity(0.15);
    canvas.drawPath(edgePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
