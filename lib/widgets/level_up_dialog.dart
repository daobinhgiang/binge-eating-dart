import 'package:flutter/material.dart';
import 'dart:math' as math;

class LevelUpDialog extends StatefulWidget {
  final int oldLevel;
  final int newLevel;
  final int expEarned;
  final int totalExp;

  const LevelUpDialog({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.expEarned,
    required this.totalExp,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLevelMessage(int level) {
    switch (level) {
      case 2:
        return 'Great progress! You\'re building momentum!';
      case 3:
        return 'Excellent work! Keep learning and growing!';
      case 4:
        return 'Impressive dedication! You\'re mastering the material!';
      case 5:
        return 'Congratulations! You\'ve reached the highest level!';
      default:
        return 'Keep up the amazing work!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Confetti background
          ...List.generate(20, (index) {
            return _buildConfetti(index);
          }),
          
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Trophy icon
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: const Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Color(0xFFFFD700), // Gold color
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Level Up text
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'LEVEL UP!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Level progression
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLevelBadge(widget.oldLevel, false),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF4CAF50),
                                  size: 32,
                                ),
                              ),
                              _buildLevelBadge(widget.newLevel, true),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // EXP earned
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${widget.expEarned} EXP Earned',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Encouraging message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _getLevelMessage(widget.newLevel),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Close button
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int level, bool isNew) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isNew
              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
              : [Colors.grey[400]!, Colors.grey[600]!],
        ),
        boxShadow: [
          BoxShadow(
            color: (isNew ? const Color(0xFF4CAF50) : Colors.grey)
                .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Level',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            level.toString(),
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final delay = random.nextDouble() * 0.5;
    final duration = 1.5 + random.nextDouble();
    
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFFD700),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = ((_controller.value - delay) / duration).clamp(0.0, 1.0);
        final top = -50 + (MediaQuery.of(context).size.height + 100) * progress;
        
        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: _fadeAnimation.value * (1 - progress),
            child: Transform.rotate(
              angle: progress * 4 * math.pi,
              child: Container(
                width: 8,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

