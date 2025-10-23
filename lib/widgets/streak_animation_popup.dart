import 'package:flutter/material.dart';

/// A popup dialog that animates streak number changes
/// Shows old number sliding down and new number sliding from top
class StreakAnimationPopup extends StatefulWidget {
  final int oldStreak;
  final int newStreak;
  final bool isReset;
  final bool pauseAutoDismiss; // DEPRECATED: Use isTutorialMode instead
  final bool isTutorialMode; // If true, won't auto-dismiss and behaves for tutorial flow
  final VoidCallback? onAnimationComplete; // Called when animation finishes

  const StreakAnimationPopup({
    super.key,
    required this.oldStreak,
    required this.newStreak,
    this.isReset = false,
    @Deprecated('Use isTutorialMode instead') this.pauseAutoDismiss = false,
    this.isTutorialMode = false,
    this.onAnimationComplete,
  });

  @override
  State<StreakAnimationPopup> createState() => _StreakAnimationPopupState();
}

class _StreakAnimationPopupState extends State<StreakAnimationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideOldAnimation;
  late Animation<Offset> _slideNewAnimation;
  late Animation<double> _fadeOldAnimation;
  late Animation<double> _fadeNewAnimation;

  @override
  void initState() {
    super.initState();
    
    print('🔥 [StreakPopup] initState called');
    print('   📊 Streak change: ${widget.oldStreak} → ${widget.newStreak}');
    print('   🔄 Is reset: ${widget.isReset}');
    print('   🎓 Tutorial mode: ${widget.isTutorialMode}');
    print('   ⏸️  Pause auto-dismiss (deprecated): ${widget.pauseAutoDismiss}');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    print('   ✅ Animation controller created (duration: 1200ms)');

    // Old streak: starts at center, slides down and fades out
    _slideOldAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

    _fadeOldAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    // New streak: starts from top, slides to center
    _slideNewAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeNewAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    print('   ✅ Animations configured');

    print('   ▶️  Starting animation controller');
    _controller.forward();

    // Notify when animation completes
    _controller.addStatusListener((status) {
      print('   🎬 Animation status: $status');
      if (status == AnimationStatus.completed) {
        print('   ✅ Animation completed! Triggering onAnimationComplete callback');
        widget.onAnimationComplete?.call();
        print('   ✅ onAnimationComplete callback invoked');
      }
    });

    // Note: Auto-dismiss is now handled in the showStreakAnimation function
    // by scheduling a pop from the dialog's context
    print('   ℹ️  Auto-dismiss will be handled by showStreakAnimation function');
  }

  @override
  void dispose() {
    print('🔥 [StreakPopup] dispose called - cleaning up animation controller');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReset = widget.newStreak == 0;
    final headerText = isReset
        ? 'Streak Reset 😔'
        : 'Streak Extended! 🔥';
    final subText = isReset
        ? 'Complete all daily tasks tomorrow to rebuild your streak'
        : 'Keep it up! Complete all daily tasks tomorrow';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isReset
                ? [Colors.red[50]!, Colors.orange[50]!]
                : [Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              headerText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Animated streak numbers container
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
                border: Border.all(
                  color: isReset ? Colors.red[300]! : Colors.amber[400]!,
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sun icon background
                  Icon(
                    Icons.wb_sunny_rounded,
                    size: 120,
                    color: isReset
                        ? Colors.red[200]
                        : Colors.amber[300],
                  ),

                  // Old streak number (slides down and fades)
                  SlideTransition(
                    position: _slideOldAnimation,
                    child: FadeTransition(
                      opacity: _fadeOldAnimation,
                      child: Text(
                        widget.oldStreak.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isReset
                              ? Colors.red[600]
                              : Colors.amber[600],
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // New streak number (slides from top and fades in)
                  SlideTransition(
                    position: _slideNewAnimation,
                    child: FadeTransition(
                      opacity: _fadeNewAnimation,
                      child: Text(
                        widget.newStreak.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isReset
                              ? Colors.red[700]
                              : Colors.amber[700],
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sub text
            Text(
              subText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Show streak animation popup
/// Returns a GlobalKey that can be used to target the popup (useful for tutorials)
GlobalKey showStreakAnimation(
  BuildContext context, {
  required int oldStreak,
  required int newStreak,
  bool isReset = false,
  @Deprecated('Use isTutorialMode instead') bool pauseAutoDismiss = false,
  bool isTutorialMode = false,
  VoidCallback? onAnimationComplete,
}) {
  print('🔥 [showStreakAnimation] Function called');
  print('   📊 Parameters: old=$oldStreak, new=$newStreak, isReset=$isReset');
  print('   🎓 Tutorial mode: $isTutorialMode');
  print('   📞 Has callback: ${onAnimationComplete != null}');
  
  final popupKey = GlobalKey();
  print('   🔑 Created GlobalKey for popup targeting');
  
  print('   🎭 Showing dialog...');
  showDialog(
    context: context,
    barrierDismissible: !isTutorialMode && !pauseAutoDismiss, // Allow dismiss by tapping outside (except in tutorial mode)
    builder: (dialogContext) {
      print('   📍 Dialog context created');
      
      // Schedule auto-dismiss outside the builder to ensure proper dismissal
      final shouldPauseAutoDismiss = isTutorialMode || pauseAutoDismiss;
      if (!shouldPauseAutoDismiss) {
        Future.delayed(const Duration(milliseconds: 3000), () {
          print('   🚪 Auto-dismiss delay reached (3000ms)');
          try {
            Navigator.of(dialogContext).pop();
            print('   ✅ Successfully popped dialog from outer context');
          } catch (e) {
            print('   ❌ Error popping dialog: $e');
          }
        });
      }
      
      // Wrap with GestureDetector to allow tapping on the dialog itself to dismiss
      return GestureDetector(
        onTap: () {
          if (!shouldPauseAutoDismiss) {
            print('   👆 User tapped to dismiss streak popup');
            Navigator.of(dialogContext).pop();
          }
        },
        child: StreakAnimationPopup(
          key: popupKey,
          oldStreak: oldStreak,
          newStreak: newStreak,
          isReset: isReset,
          // Support both for backward compatibility
          pauseAutoDismiss: pauseAutoDismiss,
          isTutorialMode: isTutorialMode,
          onAnimationComplete: onAnimationComplete,
        ),
      );
    },
  );
  print('   ✅ Dialog shown, returning GlobalKey');
  
  return popupKey;
}
