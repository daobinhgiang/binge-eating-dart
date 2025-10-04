import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class JournalBackground extends StatefulWidget {
  final Widget child;
  final double blurIntensity;
  final bool enableScrollBlur;

  const JournalBackground({
    super.key,
    required this.child,
    this.blurIntensity = 0.0,
    this.enableScrollBlur = true,
  });

  @override
  State<JournalBackground> createState() => _JournalBackgroundState();
}

class _JournalBackgroundState extends State<JournalBackground>
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
        // Main background with paper-like gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEFEFE), // Very light cream
                Color(0xFFFDFDFD), // Light cream
                Color(0xFFFCFCFC), // Slightly darker cream
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Subtle paper texture overlay
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: JournalPaperPainter(_animation.value),
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

class JournalPaperPainter extends CustomPainter {
  final double animationValue;

  JournalPaperPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw subtle paper texture
    _drawPaperTexture(canvas, size, paint);
    _drawMarginLines(canvas, size, paint);
    _drawSubtleShadows(canvas, size, paint);
    _drawFloatingElements(canvas, size, paint);
  }

  void _drawPaperTexture(Canvas canvas, Size size, Paint paint) {
    // Draw subtle paper grain texture
    paint.color = const Color(0xFFF5F5F5).withValues(alpha: 0.3);
    
    for (int i = 0; i < 200; i++) {
      final x = (i * 17.0) % size.width;
      final y = (i * 23.0) % size.height;
      final radius = 0.5 + (i % 3) * 0.3;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  void _drawMarginLines(Canvas canvas, Size size, Paint paint) {
    // Draw subtle margin lines like a notebook
    paint.color = const Color(0xFFE8E8E8).withValues(alpha: 0.4);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;
    
    // Left margin line
    canvas.drawLine(
      Offset(size.width * 0.08, 0),
      Offset(size.width * 0.08, size.height),
      paint,
    );
    
    // Right margin line
    canvas.drawLine(
      Offset(size.width * 0.92, 0),
      Offset(size.width * 0.92, size.height),
      paint,
    );
    
    // Horizontal lines like notebook paper
    paint.color = const Color(0xFFF0F0F0).withValues(alpha: 0.6);
    paint.strokeWidth = 0.3;
    
    for (int i = 0; i < (size.height / 30).ceil(); i++) {
      final y = i * 30.0;
      if (y < size.height) {
        canvas.drawLine(
          Offset(size.width * 0.08, y),
          Offset(size.width * 0.92, y),
          paint,
        );
      }
    }
  }

  void _drawSubtleShadows(Canvas canvas, Size size, Paint paint) {
    // Draw subtle shadows for depth
    paint.style = PaintingStyle.fill;
    
    // Top shadow
    paint.color = const Color(0xFF000000).withValues(alpha: 0.02);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 2),
      paint,
    );
    
    // Left shadow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 2, size.height),
      paint,
    );
  }

  void _drawFloatingElements(Canvas canvas, Size size, Paint paint) {
    // Draw subtle floating elements like paper clips, ink drops, etc.
    paint.color = const Color(0xFFE0E0E0).withValues(alpha: 0.3);
    
    // Paper clip
    final paperClipX = size.width * 0.05;
    final paperClipY = size.height * 0.2;
    _drawPaperClip(canvas, paint, Offset(paperClipX, paperClipY));
    
    // Ink drop
    final inkX = size.width * 0.95;
    final inkY = size.height * 0.3;
    _drawInkDrop(canvas, paint, Offset(inkX, inkY));
    
    // Subtle corner decorations
    _drawCornerDecorations(canvas, size, paint);
  }

  void _drawPaperClip(Canvas canvas, Paint paint, Offset position) {
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.quadraticBezierTo(
      position.dx + 8, position.dy - 2,
      position.dx + 12, position.dy + 2,
    );
    path.quadraticBezierTo(
      position.dx + 10, position.dy + 6,
      position.dx + 6, position.dy + 4,
    );
    path.quadraticBezierTo(
      position.dx + 2, position.dy + 2,
      position.dx, position.dy,
    );
    canvas.drawPath(path, paint);
  }

  void _drawInkDrop(Canvas canvas, Paint paint, Offset position) {
    paint.color = const Color(0xFFB0B0B0).withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: position,
        width: 6,
        height: 8,
      ),
      paint,
    );
    
    // Small splatter
    paint.color = const Color(0xFFC0C0C0).withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(position.dx + 3, position.dy + 2),
      1.5,
      paint,
    );
  }

  void _drawCornerDecorations(Canvas canvas, Size size, Paint paint) {
    // Top-left corner decoration
    paint.color = const Color(0xFFE8E8E8).withValues(alpha: 0.4);
    paint.strokeWidth = 1.0;
    paint.style = PaintingStyle.stroke;
    
    final cornerSize = 20.0;
    final cornerRect = Rect.fromLTWH(
      size.width * 0.02,
      size.height * 0.02,
      cornerSize,
      cornerSize,
    );
    
    canvas.drawArc(
      cornerRect,
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    
    // Bottom-right corner decoration
    final bottomRightRect = Rect.fromLTWH(
      size.width - cornerSize - size.width * 0.02,
      size.height - cornerSize - size.height * 0.02,
      cornerSize,
      cornerSize,
    );
    
    canvas.drawArc(
      bottomRightRect,
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Scroll-aware journal background widget
class ScrollAwareJournalBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const ScrollAwareJournalBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<ScrollAwareJournalBackground> createState() =>
      _ScrollAwareJournalBackgroundState();
}

class _ScrollAwareJournalBackgroundState
    extends State<ScrollAwareJournalBackground>
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
    // Calculate blur intensity based on scroll offset
    final maxBlur = 2.0;
    final blurIntensity = math.min(_scrollOffset / 300.0, 1.0) * maxBlur;

    return Stack(
      children: [
        // Main background with paper-like gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEFEFE), // Very light cream
                Color(0xFFFDFDFD), // Light cream
                Color(0xFFFCFCFC), // Slightly darker cream
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Scroll-aware animated paper elements
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _scrollOffset * 0.1),
              child: CustomPaint(
                painter: ScrollAwareJournalPaperPainter(
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
class ScrollAwareJournalPaperPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  ScrollAwareJournalPaperPainter(this.animationValue, this.scrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Calculate parallax effect
    final parallaxFactor = 0.1;
    final parallaxOffset = scrollOffset * parallaxFactor;

    // Draw paper elements with parallax
    _drawPaperTextureWithParallax(canvas, size, paint, parallaxOffset);
    _drawMarginLinesWithParallax(canvas, size, paint, parallaxOffset);
    _drawFloatingElementsWithParallax(canvas, size, paint, parallaxOffset);
  }

  void _drawPaperTextureWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    paint.color = const Color(0xFFF5F5F5).withValues(alpha: 0.3);
    
    for (int i = 0; i < 150; i++) {
      final x = (i * 17.0) % size.width;
      final y = (i * 23.0) % size.height + parallaxOffset * 0.1;
      final radius = 0.5 + (i % 3) * 0.3;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  void _drawMarginLinesWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    paint.color = const Color(0xFFE8E8E8).withValues(alpha: 0.4);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;
    
    // Left margin line
    canvas.drawLine(
      Offset(size.width * 0.08, parallaxOffset * 0.2),
      Offset(size.width * 0.08, size.height + parallaxOffset * 0.2),
      paint,
    );
    
    // Right margin line
    canvas.drawLine(
      Offset(size.width * 0.92, parallaxOffset * 0.2),
      Offset(size.width * 0.92, size.height + parallaxOffset * 0.2),
      paint,
    );
    
    // Horizontal lines
    paint.color = const Color(0xFFF0F0F0).withValues(alpha: 0.6);
    paint.strokeWidth = 0.3;
    
    for (int i = 0; i < (size.height / 30).ceil(); i++) {
      final y = i * 30.0 + parallaxOffset * 0.1;
      if (y < size.height) {
        canvas.drawLine(
          Offset(size.width * 0.08, y),
          Offset(size.width * 0.92, y),
          paint,
        );
      }
    }
  }

  void _drawFloatingElementsWithParallax(Canvas canvas, Size size, Paint paint, double parallaxOffset) {
    paint.color = const Color(0xFFE0E0E0).withValues(alpha: 0.3);
    
    // Paper clip with parallax
    final paperClipX = size.width * 0.05;
    final paperClipY = size.height * 0.2 + parallaxOffset * 0.3;
    _drawPaperClip(canvas, paint, Offset(paperClipX, paperClipY));
    
    // Ink drop with parallax
    final inkX = size.width * 0.95;
    final inkY = size.height * 0.3 + parallaxOffset * 0.2;
    _drawInkDrop(canvas, paint, Offset(inkX, inkY));
  }

  void _drawPaperClip(Canvas canvas, Paint paint, Offset position) {
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.quadraticBezierTo(
      position.dx + 8, position.dy - 2,
      position.dx + 12, position.dy + 2,
    );
    path.quadraticBezierTo(
      position.dx + 10, position.dy + 6,
      position.dx + 6, position.dy + 4,
    );
    path.quadraticBezierTo(
      position.dx + 2, position.dy + 2,
      position.dx, position.dy,
    );
    canvas.drawPath(path, paint);
  }

  void _drawInkDrop(Canvas canvas, Paint paint, Offset position) {
    paint.color = const Color(0xFFB0B0B0).withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: position,
        width: 6,
        height: 8,
      ),
      paint,
    );
    
    paint.color = const Color(0xFFC0C0C0).withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(position.dx + 3, position.dy + 2),
      1.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}