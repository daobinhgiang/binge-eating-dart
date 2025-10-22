import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for pop-in effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.result.completedQuest;

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
                  Color(0xFF6C5CE7),
                  Color(0xFF9D8CF0),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Animation / Icon
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 1.2),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.elasticInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.star_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Title
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    'Quest Completed!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
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
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // EXP Reward with animation
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                  child: TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.result.expAwarded),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB951),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+$value EXP',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
                    padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.result.currentStreak} day streak!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
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
                  padding: const EdgeInsets.all(24),
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
