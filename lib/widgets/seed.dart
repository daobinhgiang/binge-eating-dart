import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreeGrowthWidget extends StatelessWidget {
  final GlobalKey? treeImageKey;
  
  const TreeGrowthWidget({super.key, this.treeImageKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mound display with key
        Container(
          key: treeImageKey,
          child: SizedBox(
            height: 200,
            width: 200,
            child: CustomPaint(
              painter: MoundPainter(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Title
        Text(
          'Your Progress',
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          'Keep growing your recovery journey',
          style: GoogleFonts.quicksand(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MoundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.65; // Move mound closer to bottom (65% down from top)
    
    // Draw shadow first
    _drawShadow(canvas, centerX, centerY);
    
    // Draw the brown mound
    _drawMound(canvas, centerX, centerY, size);
    
    // Draw the yellow drop on top
    _drawDrop(canvas, centerX, centerY, size);
  }

  void _drawShadow(Canvas canvas, double centerX, double centerY) {
    // Multiple shadow layers for more natural effect
    
    // Outer diffuse shadow
    final outerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    final outerShadowPath = Path();
    outerShadowPath.moveTo(centerX - 80, centerY + 25);
    outerShadowPath.quadraticBezierTo(centerX - 40, centerY + 50, centerX, centerY + 45);
    outerShadowPath.quadraticBezierTo(centerX + 40, centerY + 50, centerX + 80, centerY + 25);
    outerShadowPath.quadraticBezierTo(centerX + 50, centerY + 35, centerX, centerY + 30);
    outerShadowPath.quadraticBezierTo(centerX - 50, centerY + 35, centerX - 80, centerY + 25);
    outerShadowPath.close();
    
    canvas.drawPath(outerShadowPath, outerShadowPaint);
    
    // Inner shadow
    final innerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    final innerShadowPath = Path();
    innerShadowPath.moveTo(centerX - 65, centerY + 22);
    innerShadowPath.quadraticBezierTo(centerX - 35, centerY + 42, centerX, centerY + 38);
    innerShadowPath.quadraticBezierTo(centerX + 35, centerY + 42, centerX + 65, centerY + 22);
    innerShadowPath.quadraticBezierTo(centerX + 45, centerY + 32, centerX, centerY + 28);
    innerShadowPath.quadraticBezierTo(centerX - 45, centerY + 32, centerX - 65, centerY + 22);
    innerShadowPath.close();
    
    canvas.drawPath(innerShadowPath, innerShadowPaint);
  }

  void _drawMound(Canvas canvas, double centerX, double centerY, Size size) {
    // Create a more irregular, organic mound shape
    final moundPath = Path();
    
    // Start from left side with slight asymmetry
    moundPath.moveTo(centerX - 75, centerY + 18);
    
    // Left side with bumps and irregularities
    moundPath.quadraticBezierTo(centerX - 65, centerY + 5, centerX - 55, centerY - 2);
    moundPath.quadraticBezierTo(centerX - 45, centerY - 8, centerX - 30, centerY - 3);
    moundPath.quadraticBezierTo(centerX - 20, centerY - 12, centerX - 10, centerY - 8);
    
    // Top area with natural valley and peaks
    moundPath.quadraticBezierTo(centerX - 5, centerY - 18, centerX + 2, centerY - 12);
    moundPath.quadraticBezierTo(centerX + 8, centerY - 20, centerX + 15, centerY - 6);
    
    // Right side with different irregularities
    moundPath.quadraticBezierTo(centerX + 25, centerY - 2, centerX + 35, centerY - 8);
    moundPath.quadraticBezierTo(centerX + 45, centerY - 5, centerX + 55, centerY - 12);
    moundPath.quadraticBezierTo(centerX + 65, centerY - 3, centerX + 75, centerY + 8);
    
    // Right side down with natural slope
    moundPath.quadraticBezierTo(centerX + 80, centerY + 12, centerX + 78, centerY + 20);
    
    // Bottom curve with organic shape
    moundPath.quadraticBezierTo(centerX + 60, centerY + 28, centerX + 40, centerY + 25);
    moundPath.quadraticBezierTo(centerX + 20, centerY + 30, centerX, centerY + 22);
    moundPath.quadraticBezierTo(centerX - 20, centerY + 30, centerX - 40, centerY + 25);
    moundPath.quadraticBezierTo(centerX - 60, centerY + 28, centerX - 75, centerY + 18);
    
    moundPath.close();
    
    // Create multi-stop radial gradient for more 3D effect
    final gradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        const Color(0xFF9B6B47), // Lightest brown with orange tint at top
        const Color(0xFF8B5A3C), // Medium brown
        const Color(0xFF6B4423), // Darker brown
        const Color(0xFF5A3621), // Darkest brown with reddish tint at bottom
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(moundPath, gradientPaint);
    
    // Add enhanced texture system
    _addEnhancedMoundTexture(canvas, centerX, centerY);
    
    // Add depth details
    _addDepthDetails(canvas, centerX, centerY);
  }

  void _addEnhancedMoundTexture(Canvas canvas, double centerX, double centerY) {
    // Large clumps (darker soil particles)
    final largeClumpPaint = Paint()
      ..color = const Color(0xFF4A2F1A).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    final largeClumps = [
      Offset(centerX - 25, centerY - 3),
      Offset(centerX + 15, centerY + 8),
      Offset(centerX - 5, centerY + 12),
      Offset(centerX + 35, centerY - 5),
      Offset(centerX - 40, centerY + 5),
      Offset(centerX + 50, centerY + 2),
    ];
    
    for (final clump in largeClumps) {
      canvas.drawCircle(clump, 12, largeClumpPaint);
    }
    
    // Medium clumps (medium soil particles)
    final mediumClumpPaint = Paint()
      ..color = const Color(0xFF5A3A1F).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final mediumClumps = [
      Offset(centerX - 15, centerY + 2),
      Offset(centerX + 25, centerY - 8),
      Offset(centerX - 30, centerY + 8),
      Offset(centerX + 10, centerY + 15),
      Offset(centerX - 45, centerY - 2),
      Offset(centerX + 40, centerY + 5),
      Offset(centerX - 10, centerY - 12),
      Offset(centerX + 30, centerY + 12),
    ];
    
    for (final clump in mediumClumps) {
      canvas.drawCircle(clump, 6, mediumClumpPaint);
    }
    
    // Small particles (fine soil texture)
    final smallParticlePaint = Paint()
      ..color = const Color(0xFF6B4423).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    
    final smallParticles = [
      Offset(centerX - 20, centerY - 5),
      Offset(centerX + 5, centerY + 3),
      Offset(centerX - 35, centerY + 3),
      Offset(centerX + 20, centerY - 3),
      Offset(centerX - 10, centerY + 8),
      Offset(centerX + 15, centerY + 8),
      Offset(centerX - 25, centerY + 15),
      Offset(centerX + 35, centerY + 2),
      Offset(centerX - 5, centerY - 8),
      Offset(centerX + 45, centerY - 8),
    ];
    
    for (final particle in smallParticles) {
      canvas.drawCircle(particle, 3, smallParticlePaint);
    }
    
    // Light particles (moisture or light-catching particles)
    final lightParticlePaint = Paint()
      ..color = const Color(0xFF8B6B47).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    final lightParticles = [
      Offset(centerX - 15, centerY - 8),
      Offset(centerX + 8, centerY + 5),
      Offset(centerX - 30, centerY + 12),
      Offset(centerX + 25, centerY - 5),
      Offset(centerX - 5, centerY + 18),
    ];
    
    for (final particle in lightParticles) {
      canvas.drawCircle(particle, 2, lightParticlePaint);
    }
  }

  void _addDepthDetails(Canvas canvas, double centerX, double centerY) {
    // Add subtle cracks/crevices
    final crackPaint = Paint()
      ..color = const Color(0xFF3A2515).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw small cracks
    final cracks = [
      [Offset(centerX - 20, centerY - 5), Offset(centerX - 15, centerY + 2)],
      [Offset(centerX + 10, centerY + 8), Offset(centerX + 15, centerY + 12)],
      [Offset(centerX - 5, centerY + 15), Offset(centerX + 2, centerY + 18)],
      [Offset(centerX + 25, centerY - 3), Offset(centerX + 30, centerY + 2)],
    ];
    
    for (final crack in cracks) {
      canvas.drawLine(crack[0], crack[1], crackPaint);
    }
    
    // Add edge shading for 3D effect
    final edgeShadePaint = Paint()
      ..color = const Color(0xFF4A2F1A).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw subtle edge lines
    final edgeLines = [
      [Offset(centerX - 70, centerY + 10), Offset(centerX - 60, centerY + 5)],
      [Offset(centerX + 60, centerY + 5), Offset(centerX + 70, centerY + 10)],
      [Offset(centerX - 50, centerY - 8), Offset(centerX - 40, centerY - 5)],
      [Offset(centerX + 40, centerY - 5), Offset(centerX + 50, centerY - 8)],
    ];
    
    for (final line in edgeLines) {
      canvas.drawLine(line[0], line[1], edgeShadePaint);
    }
    
    // Add small granules along edges
    final granulePaint = Paint()
      ..color = const Color(0xFF6B4423).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    final granules = [
      Offset(centerX - 75, centerY + 12),
      Offset(centerX - 70, centerY + 8),
      Offset(centerX + 70, centerY + 8),
      Offset(centerX + 75, centerY + 12),
      Offset(centerX - 45, centerY - 10),
      Offset(centerX + 45, centerY - 10),
      Offset(centerX - 30, centerY - 15),
      Offset(centerX + 30, centerY - 15),
    ];
    
    for (final granule in granules) {
      canvas.drawCircle(granule, 1.5, granulePaint);
    }
  }

  void _drawDrop(Canvas canvas, double centerX, double centerY, Size size) {
    // Create the yellow drop shape
    final dropPath = Path();
    
    // Start from the top point
    final topY = centerY - 25;
    final bottomY = centerY - 5;
    
    // Teardrop shape
    dropPath.moveTo(centerX, topY);
    dropPath.quadraticBezierTo(centerX - 8, topY + 5, centerX - 6, topY + 15);
    dropPath.quadraticBezierTo(centerX - 4, bottomY, centerX, bottomY);
    dropPath.quadraticBezierTo(centerX + 4, bottomY, centerX + 6, topY + 15);
    dropPath.quadraticBezierTo(centerX + 8, topY + 5, centerX, topY);
    dropPath.close();
    
    // Create gradient for the drop
    final dropGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFEB3B), // Bright yellow
        const Color(0xFFFDD835), // Slightly darker yellow
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final dropPaint = Paint()
      ..shader = dropGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(dropPath, dropPaint);
    
    // Add highlight to the drop
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    highlightPath.moveTo(centerX - 2, topY + 2);
    highlightPath.quadraticBezierTo(centerX - 1, topY + 8, centerX - 1, topY + 12);
    highlightPath.quadraticBezierTo(centerX - 1, topY + 8, centerX - 2, topY + 2);
    highlightPath.close();
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Static design, no need to repaint
  }
}
