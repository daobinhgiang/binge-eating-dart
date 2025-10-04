import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class ComfortingBackground extends StatefulWidget {
  final Widget child;
  final double blurIntensity;
  final bool enableScrollBlur;

  const ComfortingBackground({
    super.key,
    required this.child,
    this.blurIntensity = 0.0,
    this.enableScrollBlur = true,
  });

  @override
  State<ComfortingBackground> createState() => _ComfortingBackgroundState();
}

class _ComfortingBackgroundState extends State<ComfortingBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main background with white gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFFFFFFF), // Pure white
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated abstract shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: AbstractShapesPainter(_animation.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Blur overlay based on scroll
        if (widget.enableScrollBlur && widget.blurIntensity > 0)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurIntensity * 2,
              sigmaY: widget.blurIntensity * 2,
            ),
            child: Container(
              color: Colors.white.withOpacity(widget.blurIntensity * 0.1),
            ),
          ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class AbstractShapesPainter extends CustomPainter {
  final double animationValue;

  AbstractShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Large soft yellow circle (top right) - brighter sun
    final yellowCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(
          size.width * 0.8 + math.sin(animationValue * 0.3) * 20,
          size.height * 0.15 + math.cos(animationValue * 0.3) * 15,
        ),
        radius: size.width * 0.3, // Slightly larger
      ));
    
    // Much brighter, more vibrant yellow sun
    paint.color = const Color(0xFFFFE082).withOpacity(0.9); // Much brighter and more opaque
    canvas.drawPath(yellowCircle, paint);
    
    // Add a stronger glow effect around the sun
    paint.color = const Color(0xFFFFF3C4).withOpacity(0.6);
    canvas.drawPath(yellowCircle, paint);

    // Soft organic shapes (bottom area)
    final organicShapes = Path();
    
    // First organic shape
    organicShapes.moveTo(size.width * 0.1, size.height * 0.7);
    organicShapes.quadraticBezierTo(
      size.width * 0.3 + math.sin(animationValue * 0.2) * 10,
      size.height * 0.6 + math.cos(animationValue * 0.2) * 8,
      size.width * 0.5, size.height * 0.8,
    );
    organicShapes.quadraticBezierTo(
      size.width * 0.7 + math.sin(animationValue * 0.15) * 12,
      size.height * 0.9 + math.cos(animationValue * 0.15) * 6,
      size.width * 0.9, size.height * 0.75,
    );
    organicShapes.lineTo(size.width, size.height);
    organicShapes.lineTo(0, size.height);
    organicShapes.close();

    paint.color = Colors.white.withOpacity(0.8); // Much more visible
    canvas.drawPath(organicShapes, paint);

    // Second organic shape (smaller, more subtle)
    final organicShapes2 = Path();
    organicShapes2.moveTo(size.width * 0.05, size.height * 0.85);
    organicShapes2.quadraticBezierTo(
      size.width * 0.2 + math.sin(animationValue * 0.25) * 8,
      size.height * 0.75 + math.cos(animationValue * 0.25) * 5,
      size.width * 0.4, size.height * 0.9,
    );
    organicShapes2.quadraticBezierTo(
      size.width * 0.6 + math.sin(animationValue * 0.18) * 10,
      size.height * 0.95 + math.cos(animationValue * 0.18) * 4,
      size.width * 0.8, size.height * 0.88,
    );
    organicShapes2.lineTo(size.width * 0.95, size.height);
    organicShapes2.lineTo(size.width * 0.05, size.height);
    organicShapes2.close();

    paint.color = const Color(0xFFF0F8F0).withOpacity(0.9); // Much more visible
    canvas.drawPath(organicShapes2, paint);

    // Much more visible floating circles
    for (int i = 0; i < 5; i++) {
      final angle = animationValue + (i * math.pi / 2.5);
      final radius = 22.0 + i * 5.0; // Larger circles
      final centerX = size.width * (0.2 + i * 0.15) + math.sin(angle) * 30;
      final centerY = size.height * (0.3 + i * 0.1) + math.cos(angle) * 20;
      
      paint.color = Colors.white.withOpacity(0.7 - i * 0.08); // Much more visible
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Soft gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFF5F5F5).withOpacity(0.1),
          const Color(0xFFF0F0F0).withOpacity(0.2),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Scroll-aware background widget with parallax effect
class ScrollAwareComfortingBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const ScrollAwareComfortingBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<ScrollAwareComfortingBackground> createState() =>
      _ScrollAwareComfortingBackgroundState();
}

class _ScrollAwareComfortingBackgroundState
    extends State<ScrollAwareComfortingBackground>
    with TickerProviderStateMixin {
  double _scrollOffset = 0.0;
  ScrollController? _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController?.addListener(_onScroll);
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController?.dispose();
    } else {
      _scrollController?.removeListener(_onScroll);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController?.offset ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate blur intensity based on scroll offset - reduced blur
    final maxBlur = 4.0;
    final blurIntensity = math.min(_scrollOffset / 300.0, 1.0) * maxBlur;

    return Stack(
      children: [
        // Main background with white gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFFFFFFF), // Pure white
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Scroll-aware animated abstract shapes
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ScrollAwareAbstractShapesPainter(
                _animation.value, 
                _scrollOffset,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Blur overlay based on scroll
        if (blurIntensity > 0)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurIntensity * 2,
              sigmaY: blurIntensity * 2,
            ),
            child: Container(
              color: Colors.white.withOpacity(blurIntensity * 0.1),
            ),
          ),
        
        // Content
        widget.child,
      ],
    );
  }
}

// Custom painter that responds to scroll position
class ScrollAwareAbstractShapesPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  ScrollAwareAbstractShapesPainter(this.animationValue, this.scrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Calculate parallax effect - background elements move slower than content
    final parallaxFactor = 0.3; // How much slower background moves (0.3 = 30% of scroll speed)
    final parallaxOffset = scrollOffset * parallaxFactor;

    // Large soft yellow circle (top right) - moves with parallax
    final yellowCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(
          size.width * 0.8 + math.sin(animationValue * 0.3) * 20,
          size.height * 0.15 + math.cos(animationValue * 0.3) * 15 - parallaxOffset * 0.5, // Moves up as we scroll
        ),
        radius: size.width * 0.3,
      ));
    
    // Much brighter, more vibrant yellow sun
    paint.color = const Color(0xFFFFE082).withOpacity(0.9); // Much brighter and more opaque
    canvas.drawPath(yellowCircle, paint);
    
    // Add a stronger glow effect around the sun
    paint.color = const Color(0xFFFFF3C4).withOpacity(0.6); // Stronger glow
    canvas.drawPath(yellowCircle, paint);

    // Soft organic shapes (bottom area) - move with parallax
    final organicShapes = Path();
    
    // First organic shape - moves down as we scroll
    organicShapes.moveTo(size.width * 0.1, size.height * 0.7 + parallaxOffset * 0.3);
    organicShapes.quadraticBezierTo(
      size.width * 0.3 + math.sin(animationValue * 0.2) * 10,
      size.height * 0.6 + math.cos(animationValue * 0.2) * 8 + parallaxOffset * 0.2,
      size.width * 0.5, size.height * 0.8 + parallaxOffset * 0.4,
    );
    organicShapes.quadraticBezierTo(
      size.width * 0.7 + math.sin(animationValue * 0.15) * 12,
      size.height * 0.9 + math.cos(animationValue * 0.15) * 6 + parallaxOffset * 0.5,
      size.width * 0.9, size.height * 0.75 + parallaxOffset * 0.3,
    );
    organicShapes.lineTo(size.width, size.height);
    organicShapes.lineTo(0, size.height);
    organicShapes.close();

    paint.color = Colors.white.withOpacity(0.8); // Much more visible
    canvas.drawPath(organicShapes, paint);

    // Second organic shape (smaller, more subtle) - also moves with parallax
    final organicShapes2 = Path();
    organicShapes2.moveTo(size.width * 0.05, size.height * 0.85 + parallaxOffset * 0.4);
    organicShapes2.quadraticBezierTo(
      size.width * 0.2 + math.sin(animationValue * 0.25) * 8,
      size.height * 0.75 + math.cos(animationValue * 0.25) * 5 + parallaxOffset * 0.3,
      size.width * 0.4, size.height * 0.9 + parallaxOffset * 0.5,
    );
    organicShapes2.quadraticBezierTo(
      size.width * 0.6 + math.sin(animationValue * 0.18) * 10,
      size.height * 0.95 + math.cos(animationValue * 0.18) * 4 + parallaxOffset * 0.6,
      size.width * 0.8, size.height * 0.88 + parallaxOffset * 0.4,
    );
    organicShapes2.lineTo(size.width * 0.95, size.height);
    organicShapes2.lineTo(size.width * 0.05, size.height);
    organicShapes2.close();

    paint.color = const Color(0xFFF0F8F0).withOpacity(0.9); // Much more visible
    canvas.drawPath(organicShapes2, paint);

    // Much more visible floating circles - move with different parallax speeds
    for (int i = 0; i < 5; i++) {
      final angle = animationValue + (i * math.pi / 2.5);
      final radius = 22.0 + i * 5.0; // Larger circles
      final parallaxSpeed = 0.1 + (i * 0.1); // Different speeds for depth
      final centerX = size.width * (0.2 + i * 0.15) + math.sin(angle) * 30;
      final centerY = size.height * (0.3 + i * 0.1) + math.cos(angle) * 20 - parallaxOffset * parallaxSpeed;
      
      paint.color = Colors.white.withOpacity(0.7 - i * 0.08); // Much more visible
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Soft gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFF5F5F5).withOpacity(0.1),
          const Color(0xFFF0F0F0).withOpacity(0.2),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
