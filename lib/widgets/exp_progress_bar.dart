import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exp_provider.dart';
import '../core/services/exp_service.dart';

/// A reusable widget to display EXP progress towards next level
class ExpProgressBar extends ConsumerWidget {
  final bool showLabel;
  final bool compact;
  
  const ExpProgressBar({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userExp = ref.watch(userExpProvider);
    
    if (userExp == null) {
      return const SizedBox.shrink();
    }

    final service = ExpService();
    final progress = service.getCurrentLevelProgress(userExp.exp, userExp.level);
    final expRemaining = service.getExpRemainingForNextLevel(userExp.exp, userExp.level);
    final isMaxLevel = userExp.level >= 5;

    if (compact) {
      return _buildCompact(context, userExp.level, userExp.exp, progress, expRemaining, isMaxLevel);
    }
    
    return _buildFull(context, userExp.level, userExp.exp, progress, expRemaining, isMaxLevel);
  }

  Widget _buildCompact(BuildContext context, int level, int exp, double progress, int expRemaining, bool isMaxLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            isMaxLevel ? 'Max Level!' : '$expRemaining EXP to Level ${level + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        if (showLabel) const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLevelColor(level),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFull(BuildContext context, int level, int exp, double progress, int expRemaining, bool isMaxLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMaxLevel ? 'Max Level Reached!' : 'Progress to Level ${level + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$exp EXP',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getLevelColor(level),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(level),
                      _getLevelColor(level).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _getLevelColor(level).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showLabel && !isMaxLevel) ...[
          const SizedBox(height: 4),
          Text(
            '$expRemaining EXP remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF9E9E9E); // Gray
      case 2:
        return const Color(0xFF4CAF50); // Green
      case 3:
        return const Color(0xFF2196F3); // Blue
      case 4:
        return const Color(0xFF9C27B0); // Purple
      case 5:
        return const Color(0xFFFFD700); // Gold
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

