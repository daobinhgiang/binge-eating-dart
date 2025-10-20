import 'package:flutter/material.dart';

class SeasonalThemes extends StatefulWidget {
  const SeasonalThemes({super.key});

  @override
  State<SeasonalThemes> createState() => _SeasonalThemesState();
}

class _SeasonalThemesState extends State<SeasonalThemes> {
  String _season = 'spring';

  Map<String, Map<String, Color>> get _colors => {
        'spring': {
          'leaf': const Color(0xFF9CCC65),
          'light': const Color(0xFFC5E1A5),
          'accent': const Color(0xFFFFB6C1),
          'ground': const Color(0xFFC8E6C9),
        },
        'summer': {
          'leaf': const Color(0xFF689F38),
          'light': const Color(0xFF7CB342),
          'accent': const Color(0xFFFFEB3B),
          'ground': const Color(0xFFA5D6A7),
        },
        'autumn': {
          'leaf': const Color(0xFFFF9800),
          'light': const Color(0xFFFFAB40),
          'accent': const Color(0xFFD84315),
          'ground': const Color(0xFFBCAAA4),
        },
        'winter': {
          'leaf': const Color(0xFFB0BEC5),
          'light': const Color(0xFFECEFF1),
          'accent': const Color(0xFF81D4FA),
          'ground': const Color(0xFFEEEEEE),
        },
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(200, 120),
          painter: SeasonalThemesPainter(season: _season, colors: _colors[_season]!),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['spring', 'summer', 'autumn', 'winter'].map((season) {
            final isSelected = _season == season;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => setState(() => _season = season),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xFF030213) : Colors.grey.shade300,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(season[0].toUpperCase() + season.substring(1)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SeasonalThemesPainter extends CustomPainter {
  final String season;
  final Map<String, Color> colors;

  SeasonalThemesPainter({required this.season, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Sky/background
    Color bgColor;
    if (season == 'winter') {
      bgColor = const Color(0xFFE3F2FD);
    } else if (season == 'autumn') {
      bgColor = const Color(0xFFFFF3E0);
    } else {
      bgColor = const Color(0xFFE8F5E9);
    }
    paint.color = bgColor.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Ground
    paint.color = colors['ground']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9417),
        width: 190,
        height: 16,
      ),
      paint,
    );

    // Trees with seasonal colors
    _drawTree1(canvas, size, paint);
    _drawTree2(canvas, size, paint);
    _drawTree3(canvas, size, paint);

    // Seasonal effects
    if (season == 'winter') {
      _drawSnowEffect(canvas, size, paint);
    }
  }

  void _drawTree1(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.65, 12, 35),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = colors['leaf']!;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.5417), 20, paint);
    paint.color = colors['light']!;
    canvas.drawCircle(Offset(size.width * 0.225, size.height * 0.5833), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.335, size.height * 0.5833), 15, paint);
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.4667), 13, paint);
  }

  void _drawTree2(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.47, size.height * 0.5833, 14, 43),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = colors['leaf']!;
    canvas.drawCircle(Offset(size.width * 0.505, size.height * 0.4333), 26, paint);
    paint.color = colors['light']!;
    canvas.drawCircle(Offset(size.width * 0.41, size.height * 0.5), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.5), 20, paint);
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.35), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.35), 18, paint);
  }

  void _drawTree3(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7, size.height * 0.6667, 11, 33),
        const Radius.circular(2),
      ),
      paint,
    );

    paint.color = colors['leaf']!;
    canvas.drawCircle(Offset(size.width * 0.7275, size.height * 0.5667), 19, paint);
    paint.color = colors['light']!;
    canvas.drawCircle(Offset(size.width * 0.675, size.height * 0.6083), 14, paint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.6083), 14, paint);
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.7275, size.height * 0.4917), 12, paint);
  }

  void _drawSnowEffect(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9167),
        width: 180,
        height: 10,
      ),
      paint,
    );

    // Snow particles (static positions)
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.73), 2, paint);
  }

  @override
  bool shouldRepaint(SeasonalThemesPainter oldDelegate) {
    return season != oldDelegate.season;
  }
}
