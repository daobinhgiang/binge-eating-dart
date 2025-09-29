import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class TropicalForestBackground extends StatefulWidget {
  final Widget child;
  final double blurIntensity;
  final bool enableScrollBlur;

  const TropicalForestBackground({
    super.key,
    required this.child,
    this.blurIntensity = 0.0,
    this.enableScrollBlur = true,
  });

  @override
  State<TropicalForestBackground> createState() => _TropicalForestBackgroundState();
}

class _TropicalForestBackgroundState extends State<TropicalForestBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 25),
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
        // Main background with tropical forest green gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F5E8), // Light forest green
                Color(0xFFD4E6D4), // Medium forest green
                Color(0xFFC8E0C8), // Slightly deeper green
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated tropical forest elements
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: TropicalForestPainter(_animation.value),
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

class TropicalForestPainter extends CustomPainter {
  final double animationValue;

  TropicalForestPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw tropical forest elements based on the SVG structure
    _drawTropicalTrees(canvas, size, paint);
    _drawForestFloor(canvas, size, paint);
    _drawFogEffect(canvas, size, paint);
    _drawFloatingLeaves(canvas, size, paint);
  }

  void _drawTropicalTrees(Canvas canvas, Size size, Paint paint) {
    // Left side tropical trees - inspired by the SVG forest
    final leftTrees = [
      {'x': 0.02, 'y': 0.15, 'height': 0.6, 'width': 0.08, 'type': 'palm'},
      {'x': 0.05, 'y': 0.3, 'height': 0.5, 'width': 0.06, 'type': 'spruce'},
      {'x': 0.03, 'y': 0.5, 'height': 0.45, 'width': 0.05, 'type': 'palm'},
      {'x': 0.06, 'y': 0.7, 'height': 0.3, 'width': 0.04, 'type': 'spruce'},
      {'x': 0.01, 'y': 0.85, 'height': 0.15, 'width': 0.03, 'type': 'palm'},
    ];

    for (final tree in leftTrees) {
      _drawTropicalTree(
        canvas,
        size,
        paint,
        Offset(size.width * (tree['x'] as double), size.height * (tree['y'] as double)),
        size.height * (tree['height'] as double),
        size.width * (tree['width'] as double),
        tree['type'] as String,
      );
    }

    // Right side tropical trees
    final rightTrees = [
      {'x': 0.98, 'y': 0.15, 'height': 0.6, 'width': 0.08, 'type': 'palm'},
      {'x': 0.95, 'y': 0.3, 'height': 0.5, 'width': 0.06, 'type': 'spruce'},
      {'x': 0.97, 'y': 0.5, 'height': 0.45, 'width': 0.05, 'type': 'palm'},
      {'x': 0.94, 'y': 0.7, 'height': 0.3, 'width': 0.04, 'type': 'spruce'},
      {'x': 0.99, 'y': 0.85, 'height': 0.15, 'width': 0.03, 'type': 'palm'},
    ];

    for (final tree in rightTrees) {
      _drawTropicalTree(
        canvas,
        size,
        paint,
        Offset(size.width * (tree['x'] as double), size.height * (tree['y'] as double)),
        size.height * (tree['height'] as double),
        size.width * (tree['width'] as double),
        tree['type'] as String,
      );
    }
  }

  void _drawTropicalTree(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, String type) {
    
    // Gentle wind effect
    final windOffset = math.sin(animationValue + position.dx * 0.01) * 2.0;
    
    if (type == 'palm') {
      _drawPalmTree(canvas, size, paint, position, height, width, windOffset);
    } else {
      _drawSpruceTree(canvas, size, paint, position, height, width, windOffset);
    }
  }

  void _drawPalmTree(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, double windOffset) {
    
    // Palm trunk - thin and tall
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.08);
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + height * 0.2),
      width: width * 0.2,
      height: height * 0.6,
    );
    canvas.drawRect(trunkRect, paint);
    
    // Palm fronds - multiple layers
    paint.color = const Color(0xFF2D5016).withValues(alpha: 0.06);
    
    // Main frond
    final frondPath = Path();
    frondPath.moveTo(position.dx, position.dy - height * 0.1);
    frondPath.quadraticBezierTo(
      position.dx + windOffset * 2, position.dy - height * 0.3,
      position.dx + windOffset * 4, position.dy - height * 0.5,
    );
    frondPath.quadraticBezierTo(
      position.dx + windOffset * 3, position.dy - height * 0.4,
      position.dx + windOffset, position.dy - height * 0.2,
    );
    frondPath.close();
    canvas.drawPath(frondPath, paint);
    
    // Additional fronds
    for (int i = 0; i < 3; i++) {
      final angle = (i - 1) * 0.3;
      final frondX = position.dx + math.cos(angle) * width * 0.3;
      final frondY = position.dy - height * 0.1;
      
      final additionalFrond = Path();
      additionalFrond.moveTo(frondX, frondY);
      additionalFrond.quadraticBezierTo(
        frondX + windOffset * 1.5, frondY - height * 0.2,
        frondX + windOffset * 3, frondY - height * 0.4,
      );
      additionalFrond.quadraticBezierTo(
        frondX + windOffset * 2, frondY - height * 0.3,
        frondX + windOffset * 0.5, frondY - height * 0.15,
      );
      additionalFrond.close();
      canvas.drawPath(additionalFrond, paint);
    }
  }

  void _drawSpruceTree(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, double windOffset) {
    
    // Spruce trunk
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.08);
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + height * 0.3),
      width: width * 0.3,
      height: height * 0.4,
    );
    canvas.drawRect(trunkRect, paint);
    
    // Spruce foliage layers
    paint.color = const Color(0xFF2D5016).withValues(alpha: 0.05);
    
    // Bottom layer
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset, position.dy),
        width: width,
        height: height * 0.6,
      ),
      paint,
    );
    
    // Middle layer
    paint.color = const Color(0xFF4A6741).withValues(alpha: 0.04);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset * 0.5, position.dy - height * 0.1),
        width: width * 0.8,
        height: height * 0.5,
      ),
      paint,
    );
    
    // Top layer
    paint.color = const Color(0xFF6B8E23).withValues(alpha: 0.03);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset * 0.3, position.dy - height * 0.2),
        width: width * 0.6,
        height: height * 0.4,
      ),
      paint,
    );
  }

  void _drawForestFloor(Canvas canvas, Size size, Paint paint) {
    // Draw tropical forest floor with organic curves
    paint.color = const Color(0xFF5a7f4f).withValues(alpha: 0.02);
    
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.95,
      size.width * 0.2, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.98,
      size.width * 0.6, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.97,
      size.width, size.height,
    );
    canvas.drawPath(path, paint);
    
    // Add tropical ground elements
    _drawTropicalGroundElements(canvas, size, paint);
  }

  void _drawTropicalGroundElements(Canvas canvas, Size size, Paint paint) {
    // Small tropical plants and bushes
    final groundElements = [
      {'x': 0.3, 'y': 0.8, 'size': 0.02, 'type': 'fern'},
      {'x': 0.7, 'y': 0.75, 'size': 0.025, 'type': 'bush'},
      {'x': 0.4, 'y': 0.9, 'size': 0.015, 'type': 'fern'},
      {'x': 0.6, 'y': 0.85, 'size': 0.02, 'type': 'bush'},
      {'x': 0.2, 'y': 0.88, 'size': 0.018, 'type': 'fern'},
      {'x': 0.8, 'y': 0.82, 'size': 0.022, 'type': 'bush'},
    ];

    for (final element in groundElements) {
      final elementType = element['type'] as String;
      if (elementType == 'fern') {
        paint.color = const Color(0xFF6e955f).withValues(alpha: 0.015);
        _drawFern(canvas, size, paint, 
          Offset(size.width * (element['x'] as double), size.height * (element['y'] as double)),
          size.width * (element['size'] as double));
      } else {
        paint.color = const Color(0xFF6e955f).withValues(alpha: 0.01);
        canvas.drawCircle(
          Offset(size.width * (element['x'] as double), size.height * (element['y'] as double)),
          size.width * (element['size'] as double),
          paint,
        );
      }
    }
  }

  void _drawFern(Canvas canvas, Size size, Paint paint, Offset position, double fernSize) {
    // Draw a simple fern shape
    final fernPath = Path();
    fernPath.moveTo(position.dx, position.dy);
    fernPath.quadraticBezierTo(
      position.dx + fernSize * 2, position.dy - fernSize * 3,
      position.dx + fernSize * 4, position.dy - fernSize * 6,
    );
    fernPath.quadraticBezierTo(
      position.dx + fernSize * 3, position.dy - fernSize * 4,
      position.dx + fernSize, position.dy - fernSize * 2,
    );
    fernPath.quadraticBezierTo(
      position.dx - fernSize, position.dy - fernSize * 2,
      position.dx - fernSize * 3, position.dy - fernSize * 4,
    );
    fernPath.quadraticBezierTo(
      position.dx - fernSize * 4, position.dy - fernSize * 6,
      position.dx - fernSize * 2, position.dy - fernSize * 3,
    );
    fernPath.close();
    canvas.drawPath(fernPath, paint);
  }

  void _drawFogEffect(Canvas canvas, Size size, Paint paint) {
    // Draw subtle fog effect inspired by the SVG
    paint.color = const Color(0xFFB0C4DE).withValues(alpha: 0.03);
    
    for (int i = 0; i < 3; i++) {
      final fogY = size.height * (0.2 + i * 0.3);
      final fogOffset = math.sin(animationValue * 0.5 + i) * 15;
      
      final fogPath = Path();
      fogPath.moveTo(size.width * 0.1, fogY + fogOffset);
      fogPath.quadraticBezierTo(
        size.width * 0.3, fogY + fogOffset * 0.5,
        size.width * 0.5, fogY,
      );
      fogPath.quadraticBezierTo(
        size.width * 0.7, fogY - fogOffset * 0.5,
        size.width * 0.9, fogY - fogOffset,
      );
      
      canvas.drawPath(fogPath, paint);
    }
  }

  void _drawFloatingLeaves(Canvas canvas, Size size, Paint paint) {
    // Draw floating tropical leaves
    for (int i = 0; i < 8; i++) {
      final angle = animationValue + (i * math.pi / 4);
      final radius = 8.0 + i * 2.0;
      final centerX = size.width * (0.1 + i * 0.1) + math.sin(angle) * 20;
      final centerY = size.height * (0.2 + i * 0.08) + math.cos(angle) * 15;
      
      paint.color = const Color(0xFF6B8E23).withValues(alpha: 0.04 - i * 0.003);
      _drawLeaf(canvas, paint, Offset(centerX, centerY), radius);
    }
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double size) {
    // Draw a simple leaf shape
    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy);
    leafPath.quadraticBezierTo(
      center.dx + size, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size,
    );
    leafPath.quadraticBezierTo(
      center.dx, center.dy - size * 0.5,
      center.dx - size * 0.5, center.dy - size,
    );
    leafPath.quadraticBezierTo(
      center.dx - size, center.dy - size * 0.5,
      center.dx, center.dy,
    );
    leafPath.close();
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Scroll-aware tropical forest background widget with parallax effect
class ScrollAwareTropicalForestBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const ScrollAwareTropicalForestBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<ScrollAwareTropicalForestBackground> createState() =>
      _ScrollAwareTropicalForestBackgroundState();
}

class _ScrollAwareTropicalForestBackgroundState
    extends State<ScrollAwareTropicalForestBackground>
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
      duration: const Duration(seconds: 25),
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
    // Calculate blur intensity based on scroll offset
    final maxBlur = 4.0;
    final blurIntensity = math.min(_scrollOffset / 300.0, 1.0) * maxBlur;

    return Stack(
      children: [
        // Main background with tropical forest green gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F5E8), // Light forest green
                Color(0xFFD4E6D4), // Medium forest green
                Color(0xFFC8E0C8), // Slightly deeper green
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Scroll-aware animated tropical forest elements
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _scrollOffset * 0.3),
              child: CustomPaint(
                painter: ScrollAwareTropicalForestPainter(
                  _animation.value, 
                  _scrollOffset,
                ),
                size: Size.infinite,
              ),
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
class ScrollAwareTropicalForestPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  ScrollAwareTropicalForestPainter(this.animationValue, this.scrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Calculate parallax effect - background elements move slower than content
    final parallaxFactor = 0.3;
    final parallaxOffset = scrollOffset * parallaxFactor;

    // Draw tropical forest elements with parallax
    _drawTropicalTreesWithParallax(canvas, size, paint, parallaxOffset);
    _drawForestFloorWithParallax(canvas, size, paint, parallaxOffset);
    _drawFogEffectWithParallax(canvas, size, paint, parallaxOffset);
    _drawFloatingLeavesWithParallax(canvas, size, paint, parallaxOffset);
  }

  void _drawTropicalTreesWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    // Left side tropical trees with parallax
    final leftTrees = [
      {'x': 0.02, 'y': 0.15, 'height': 0.6, 'width': 0.08, 'type': 'palm'},
      {'x': 0.05, 'y': 0.3, 'height': 0.5, 'width': 0.06, 'type': 'spruce'},
      {'x': 0.03, 'y': 0.5, 'height': 0.45, 'width': 0.05, 'type': 'palm'},
      {'x': 0.06, 'y': 0.7, 'height': 0.3, 'width': 0.04, 'type': 'spruce'},
      {'x': 0.01, 'y': 0.85, 'height': 0.15, 'width': 0.03, 'type': 'palm'},
    ];

    for (final tree in leftTrees) {
      _drawTropicalTreeWithParallax(
        canvas,
        size,
        paint,
        Offset(size.width * (tree['x'] as double), size.height * (tree['y'] as double) + parallaxOffset * 0.2),
        size.height * (tree['height'] as double),
        size.width * (tree['width'] as double),
        tree['type'] as String,
      );
    }

    // Right side tropical trees with parallax
    final rightTrees = [
      {'x': 0.98, 'y': 0.15, 'height': 0.6, 'width': 0.08, 'type': 'palm'},
      {'x': 0.95, 'y': 0.3, 'height': 0.5, 'width': 0.06, 'type': 'spruce'},
      {'x': 0.97, 'y': 0.5, 'height': 0.45, 'width': 0.05, 'type': 'palm'},
      {'x': 0.94, 'y': 0.7, 'height': 0.3, 'width': 0.04, 'type': 'spruce'},
      {'x': 0.99, 'y': 0.85, 'height': 0.15, 'width': 0.03, 'type': 'palm'},
    ];

    for (final tree in rightTrees) {
      _drawTropicalTreeWithParallax(
        canvas,
        size,
        paint,
        Offset(size.width * (tree['x'] as double), size.height * (tree['y'] as double) + parallaxOffset * 0.2),
        size.height * (tree['height'] as double),
        size.width * (tree['width'] as double),
        tree['type'] as String,
      );
    }
  }

  void _drawTropicalTreeWithParallax(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, String type) {
    
    // Gentle wind effect
    final windOffset = math.sin(animationValue + position.dx * 0.01) * 2.0;
    
    if (type == 'palm') {
      _drawPalmTreeWithParallax(canvas, size, paint, position, height, width, windOffset);
    } else {
      _drawSpruceTreeWithParallax(canvas, size, paint, position, height, width, windOffset);
    }
  }

  void _drawPalmTreeWithParallax(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, double windOffset) {
    
    // Palm trunk
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.08);
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + height * 0.2),
      width: width * 0.2,
      height: height * 0.6,
    );
    canvas.drawRect(trunkRect, paint);
    
    // Palm fronds with wind effect
    paint.color = const Color(0xFF2D5016).withValues(alpha: 0.06);
    
    final frondPath = Path();
    frondPath.moveTo(position.dx, position.dy - height * 0.1);
    frondPath.quadraticBezierTo(
      position.dx + windOffset * 2, position.dy - height * 0.3,
      position.dx + windOffset * 4, position.dy - height * 0.5,
    );
    frondPath.quadraticBezierTo(
      position.dx + windOffset * 3, position.dy - height * 0.4,
      position.dx + windOffset, position.dy - height * 0.2,
    );
    frondPath.close();
    canvas.drawPath(frondPath, paint);
  }

  void _drawSpruceTreeWithParallax(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, double windOffset) {
    
    // Spruce trunk
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.08);
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + height * 0.3),
      width: width * 0.3,
      height: height * 0.4,
    );
    canvas.drawRect(trunkRect, paint);
    
    // Spruce foliage layers
    paint.color = const Color(0xFF2D5016).withValues(alpha: 0.05);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset, position.dy),
        width: width,
        height: height * 0.6,
      ),
      paint,
    );
  }

  void _drawForestFloorWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    paint.color = const Color(0xFF5a7f4f).withValues(alpha: 0.02);
    
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.95 + parallaxOffset * 0.1,
      size.width * 0.2, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.98 + parallaxOffset * 0.05,
      size.width * 0.6, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.97 + parallaxOffset * 0.1,
      size.width, size.height,
    );
    canvas.drawPath(path, paint);
  }

  void _drawFogEffectWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    paint.color = const Color(0xFFB0C4DE).withValues(alpha: 0.03);
    
    for (int i = 0; i < 3; i++) {
      final fogY = size.height * (0.2 + i * 0.3) - parallaxOffset * 0.3;
      final fogOffset = math.sin(animationValue * 0.5 + i) * 15;
      
      final fogPath = Path();
      fogPath.moveTo(size.width * 0.1, fogY + fogOffset);
      fogPath.quadraticBezierTo(
        size.width * 0.3, fogY + fogOffset * 0.5,
        size.width * 0.5, fogY,
      );
      fogPath.quadraticBezierTo(
        size.width * 0.7, fogY - fogOffset * 0.5,
        size.width * 0.9, fogY - fogOffset,
      );
      
      canvas.drawPath(fogPath, paint);
    }
  }

  void _drawFloatingLeavesWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    for (int i = 0; i < 8; i++) {
      final angle = animationValue + (i * math.pi / 4);
      final radius = 8.0 + i * 2.0;
      final parallaxSpeed = 0.1 + (i * 0.1);
      final centerX = size.width * (0.1 + i * 0.1) + math.sin(angle) * 20;
      final centerY = size.height * (0.2 + i * 0.08) + math.cos(angle) * 15 - parallaxOffset * parallaxSpeed;
      
      paint.color = const Color(0xFF6B8E23).withValues(alpha: 0.04 - i * 0.003);
      _drawLeaf(canvas, paint, Offset(centerX, centerY), radius);
    }
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double size) {
    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy);
    leafPath.quadraticBezierTo(
      center.dx + size, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size,
    );
    leafPath.quadraticBezierTo(
      center.dx, center.dy - size * 0.5,
      center.dx - size * 0.5, center.dy - size,
    );
    leafPath.quadraticBezierTo(
      center.dx - size, center.dy - size * 0.5,
      center.dx, center.dy,
    );
    leafPath.close();
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
