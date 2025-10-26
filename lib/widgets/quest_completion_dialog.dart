import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../core/services/quest_completion_service.dart';
import '../providers/auth_provider.dart';
import '../providers/exp_provider.dart';
import 'streak_animation_popup.dart';

/// Dialog shown when user completes a quest
/// Displays celebration animation, EXP earned, and quest details
class QuestCompletionDialog extends ConsumerStatefulWidget {
  final QuestCompletionResult result;
  final VoidCallback onDismiss;
  final VoidCallback? onStreakAnimationShown;

  const QuestCompletionDialog({
    required this.result,
    required this.onDismiss,
    this.onStreakAnimationShown,
    super.key,
  });

  @override
  ConsumerState<QuestCompletionDialog> createState() => _QuestCompletionDialogState();
}

class _QuestCompletionDialogState extends ConsumerState<QuestCompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for pop-in effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
      _confettiController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.result.completedQuest;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50), // Nurtra green primary
                  Color(0xFF66BB6A), // Nurtra green secondary
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Confetti particles
                _buildConfetti(),
                
                // Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration Animation / Icon
                    Padding(
                      padding: EdgeInsets.only(
                        top: isSmallScreen ? 24 : 32, 
                        bottom: isSmallScreen ? 8 : 12,
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: isSmallScreen ? 100 : 120,
                              height: isSmallScreen ? 100 : 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFE8F5E8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.celebration_rounded,
                                  size: isSmallScreen ? 50 : 60,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Main Title
                    Padding(
                      padding: EdgeInsets.only(
                        top: isSmallScreen ? 16 : 20, 
                        left: 20, 
                        right: 20,
                      ),
                      child: Text(
                        'Great Job! 🎉',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quest Title
                    if (quest != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                        child: Text(
                          quest.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),

                    // EXP Reward with animation
                    Padding(
                      padding: EdgeInsets.only(
                        top: isSmallScreen ? 20 : 24, 
                        left: 20, 
                        right: 20,
                      ),
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.result.expAwarded),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 20 : 24,
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB951),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFB951).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '+$value EXP',
                                  style: GoogleFonts.quicksand(
                                    fontSize: isSmallScreen ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Streak info if applicable
                    if (widget.result.streakUpdated && widget.result.currentStreak != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: isSmallScreen ? 12 : 16, 
                          left: 20, 
                          right: 20,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 14 : 16,
                            vertical: isSmallScreen ? 10 : 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6B6B).withOpacity(0.25),
                                const Color(0xFFFF6B6B).withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B).withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.result.currentStreak} day streak!',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Continue Button
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            widget.onDismiss();
                            
                            // Always refresh auth provider after quest completion to update EXP/streak in UI
                            print('   🔄 Refreshing auth provider after quest dialog dismissed...');
                            await ref.read(authNotifierProvider.notifier).refreshUserData();
                            print('   ✅ Auth provider refreshed');
                            
                            // Check if we need to show streak animation after dismissal
                            final suppressionState = ref.read(streakAnimationSuppressionProvider);
                            if (suppressionState.isSuppressed && 
                                suppressionState.oldStreak != null && 
                                suppressionState.newStreak != null) {
                              
                              // Check if we're in tutorial mode (user hasn't seen streak tutorial yet)
                              final user = ref.read(authNotifierProvider).valueOrNull;
                              final isInTutorialFlow = user != null && !user.hasSeenStreakTutorial;
                              
                              if (isInTutorialFlow) {
                                print('   🎓 In tutorial mode - keeping streak animation suppressed for tutorial overlay');
                                // DON'T clear suppression - let main_navigation show it with tutorial mode
                                // Don't show the animation here, but trigger callback if provided
                                if (widget.onStreakAnimationShown != null) {
                                  widget.onStreakAnimationShown!();
                                }
                              } else {
                                print('   🔥 Showing streak animation after auth refresh');
                                // Show streak animation in next frame after UI updates
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    showStreakAnimation(
                                      context,
                                      oldStreak: suppressionState.oldStreak!,
                                      newStreak: suppressionState.newStreak!,
                                      isReset: suppressionState.isReset,
                                    );
                                    // Clear the suppression flag after showing animation
                                    ref.read(streakAnimationSuppressionProvider.notifier).clearSuppression();
                                    
                                    // Trigger callback after streak animation is shown (if provided)
                                    if (widget.onStreakAnimationShown != null) {
                                      // Wait for streak animation to complete before triggering callback
                                      Future.delayed(const Duration(milliseconds: 2000), () {
                                        if (mounted) {
                                          widget.onStreakAnimationShown!();
                                        }
                                      });
                                    }
                                  }
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.quicksand(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(_confettiController.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double animationValue;
  
  ConfettiPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent animation
    
    // Create confetti particles
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue * 2 - i * 0.1).clamp(0.0, 1.0);
      if (progress <= 0) continue;
      
      // Random position
      final x = random.nextDouble() * size.width;
      final y = size.height * 0.2 + (size.height * 0.8) * progress;
      
      // Random color
      final colors = [
        const Color(0xFFFFB951), // Gold
        const Color(0xFFFF6B6B), // Red
        const Color(0xFF4CAF50),  // Green
        const Color(0xFF2196F3),  // Blue
        const Color(0xFF9C27B0),  // Purple
        Colors.white,
      ];
      paint.color = colors[i % colors.length];
      
      // Random size
      final particleSize = 3 + random.nextDouble() * 4;
      
      // Draw confetti particle
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
      
      // Add some sparkle effect
      if (random.nextDouble() > 0.7) {
        paint.color = Colors.white.withOpacity(0.8);
        canvas.drawCircle(
          Offset(x, y),
          particleSize * 0.5,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Show quest completion dialog
void showQuestCompletionDialog(
  BuildContext context,
  QuestCompletionResult result, {
  VoidCallback? onDismiss,
  VoidCallback? onStreakAnimationShown,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: false,
    builder: (context) => QuestCompletionDialog(
      result: result,
      onDismiss: onDismiss ?? () {},
      onStreakAnimationShown: onStreakAnimationShown,
    ),
  );
}
