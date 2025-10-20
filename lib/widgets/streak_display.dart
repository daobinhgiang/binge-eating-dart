import 'package:flutter/material.dart';

/// A widget that displays the user's streak with a sun icon
/// Shows the streak number centered on the sun icon
class StreakDisplay extends StatelessWidget {
  final int streak;
  final VoidCallback? onTap;

  const StreakDisplay({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber[50],
          border: Border.all(
            color: Colors.amber[400]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber[200]!.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sun icon
            Icon(
              Icons.wb_sunny_rounded,
              size: 42,
              color: Colors.amber[600],
            ),
            // Streak number centered on the sun
            Text(
              streak.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
