import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class ForestBackground extends StatefulWidget {
  final Widget child;
  final double blurIntensity;
  final bool enableScrollBlur;

  const ForestBackground({
    super.key,
    required this.child,
    this.blurIntensity = 0.0,
    this.enableScrollBlur = true,
  });

  @override
  State<ForestBackground> createState() => _ForestBackgroundState();
}

class _ForestBackgroundState extends State<ForestBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFF5F5F5), // Light gray
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated forest elements
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ForestBackgroundPainter(_animation.value),
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

class ForestBackgroundPainter extends CustomPainter {
  final double animationValue;

  ForestBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw trees on the left side
    _drawLeftForest(canvas, size, paint);
    
    // Draw trees on the right side
    _drawRightForest(canvas, size, paint);
    
    // Draw subtle forest floor elements
    _drawForestFloor(canvas, size, paint);
    
    // Draw gentle wind effect on trees
    _drawWindEffect(canvas, size, paint);
  }

  void _drawLeftForest(Canvas canvas, Size size, Paint paint) {
    // Left side trees - positioned to frame the center content
    final leftTrees = [
      {'x': 0.02, 'y': 0.2, 'height': 0.5, 'width': 0.06},
      {'x': 0.05, 'y': 0.4, 'height': 0.45, 'width': 0.05},
      {'x': 0.03, 'y': 0.6, 'height': 0.4, 'width': 0.05},
      {'x': 0.06, 'y': 0.8, 'height': 0.2, 'width': 0.04},
      {'x': 0.01, 'y': 0.9, 'height': 0.1, 'width': 0.03},
    ];

    for (final tree in leftTrees) {
      _drawTree(
        canvas,
        size,
        paint,
        Offset(size.width * tree['x']!, size.height * tree['y']!),
        size.height * tree['height']!,
        size.width * tree['width']!,
        const Color(0xFF2D5016), // Dark forest green
        const Color(0xFF4A6741), // Medium forest green
      );
    }
  }

  void _drawRightForest(Canvas canvas, Size size, Paint paint) {
    // Right side trees - positioned to frame the center content
    final rightTrees = [
      {'x': 0.98, 'y': 0.2, 'height': 0.5, 'width': 0.06},
      {'x': 0.95, 'y': 0.4, 'height': 0.45, 'width': 0.05},
      {'x': 0.97, 'y': 0.6, 'height': 0.4, 'width': 0.05},
      {'x': 0.94, 'y': 0.8, 'height': 0.2, 'width': 0.04},
      {'x': 0.99, 'y': 0.9, 'height': 0.1, 'width': 0.03},
    ];

    for (final tree in rightTrees) {
      _drawTree(
        canvas,
        size,
        paint,
        Offset(size.width * tree['x']!, size.height * tree['y']!),
        size.height * tree['height']!,
        size.width * tree['width']!,
        const Color(0xFF2D5016), // Dark forest green
        const Color(0xFF4A6741), // Medium forest green
      );
    }
  }

  void _drawTree(Canvas canvas, Size size, Paint paint, Offset position, 
      double height, double width, Color trunkColor, Color foliageColor) {
    
    // Draw trunk
    paint.color = trunkColor.withValues(alpha: 0.08);
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + height * 0.3),
      width: width * 0.3,
      height: height * 0.4,
    );
    canvas.drawRect(trunkRect, paint);
    
    // Draw foliage layers with subtle animation
    final windOffset = math.sin(animationValue + position.dx * 0.01) * 1.5;
    
    // Bottom foliage layer
    paint.color = foliageColor.withValues(alpha: 0.04);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset, position.dy),
        width: width,
        height: height * 0.6,
      ),
      paint,
    );
    
    // Middle foliage layer
    paint.color = foliageColor.withValues(alpha: 0.03);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx + windOffset * 0.5, position.dy - height * 0.1),
        width: width * 0.8,
        height: height * 0.5,
      ),
      paint,
    );
    
    // Top foliage layer
    paint.color = foliageColor.withValues(alpha: 0.02);
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
    // Draw subtle forest floor elements
    paint.color = const Color(0xFF5a7f4f).withValues(alpha: 0.015);
    
    // Draw gentle curves representing forest floor
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
    
    // Draw small forest elements in the middle area
    _drawSmallForestElements(canvas, size, paint);
  }

  void _drawSmallForestElements(Canvas canvas, Size size, Paint paint) {
    // Small trees and bushes in the middle area (but not too distracting)
    final smallElements = [
      {'x': 0.3, 'y': 0.8, 'size': 0.02},
      {'x': 0.7, 'y': 0.75, 'size': 0.025},
      {'x': 0.4, 'y': 0.9, 'size': 0.015},
      {'x': 0.6, 'y': 0.85, 'size': 0.02},
    ];

    for (final element in smallElements) {
      paint.color = const Color(0xFF6e955f).withValues(alpha: 0.01);
      canvas.drawCircle(
        Offset(size.width * element['x']!, size.height * element['y']!),
        size.width * element['size']!,
        paint,
      );
    }
  }

  void _drawWindEffect(Canvas canvas, Size size, Paint paint) {
    // Draw subtle wind lines between trees
    paint.color = const Color(0xFF7fb781).withValues(alpha: 0.01);
    paint.strokeWidth = 1;
    
    for (int i = 0; i < 3; i++) {
      final windY = size.height * (0.2 + i * 0.3);
      final windOffset = math.sin(animationValue + i) * 10;
      
      final path = Path();
      path.moveTo(size.width * 0.1, windY + windOffset);
      path.quadraticBezierTo(
        size.width * 0.3, windY + windOffset * 0.5,
        size.width * 0.5, windY,
      );
      path.quadraticBezierTo(
        size.width * 0.7, windY - windOffset * 0.5,
        size.width * 0.9, windY - windOffset,
      );
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Scroll-aware forest background widget with parallax effect
class ScrollAwareForestBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const ScrollAwareForestBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<ScrollAwareForestBackground> createState() =>
      _ScrollAwareForestBackgroundState();
}

class _ScrollAwareForestBackgroundState
    extends State<ScrollAwareForestBackground>
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
      duration: const Duration(seconds: 30),
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
    return Stack(
      children: [
        // Main background with white gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFFAFAFA), // Very light gray
                Color(0xFFF5F5F5), // Light gray
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated forest elements with parallax
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _scrollOffset * 0.3),
              child: CustomPaint(
                painter: ForestBackgroundPainter(_animation.value),
                size: Size.infinite,
              ),
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}
