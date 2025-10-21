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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '☀️ $streak',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
