import 'package:flutter/material.dart';

/// A reusable widget to display user's current level as a badge
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;
  final bool showLabel;
  
  const LevelBadge({
    super.key,
    required this.level,
    this.size = 60,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getLevelColors(level),
        ),
        boxShadow: [
          BoxShadow(
            color: _getLevelColors(level)[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLabel)
            Text(
              'Level',
              style: TextStyle(
                fontSize: size * 0.16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          Text(
            level.toString(),
            style: TextStyle(
              fontSize: size * 0.42,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getLevelColors(int level) {
    switch (level) {
      case 1:
        return [const Color(0xFF9E9E9E), const Color(0xFF757575)]; // Gray
      case 2:
        return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]; // Green
      case 3:
        return [const Color(0xFF2196F3), const Color(0xFF1565C0)]; // Blue
      case 4:
        return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)]; // Purple
      case 5:
        return [const Color(0xFFFFD700), const Color(0xFFFFA000)]; // Gold
      default:
        return [const Color(0xFF9E9E9E), const Color(0xFF757575)]; // Gray
    }
  }
}

