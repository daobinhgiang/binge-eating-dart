import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../providers/auth_provider.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IntroductionScreen(
            key: _introKey,
            globalBackgroundColor: Colors.white,
            
            pages: [
              // Page 1: Welcome to Nurtra
              PageViewModel(
                title: "Welcome to Nurtra",
                body: "Your compassionate companion in understanding and overcoming binge eating. We're here to support you every step of the way on your journey to a healthier relationship with food.",
                image: _buildImage('assets/logo.png', height: 200),
                decoration: _getPageDecoration(),
              ),
              
              // Page 2: Education Feature
              PageViewModel(
                title: "Learn and Understand",
                body: "Our comprehensive education modules help you understand binge eating disorder. Discover evidence-based insights, expert guidance, and learn proven methods to manage your eating patterns.",
                image: _buildImage('assets/lessons/stages/stage_1.png'),
                decoration: _getPageDecoration(),
              ),
              
              // Page 3: Journal & Tools
              PageViewModel(
                title: "Your Personal Journey Partner",
                body: "Nurtra isn't just an app—it's a friend, a partner that stands by you throughout your journey. Track your progress with our journal, and use our practical tools to support you in real-time whenever you need it.",
                image: _buildImage('assets/journal/food_diary.png'),
                decoration: _getPageDecoration(),
              ),
              
              // Page 4: Supportive Message
              PageViewModel(
                title: "You're Not Alone",
                body: "We want you to know that we're always by your side in this journey. Every step forward, no matter how small, is a victory worth celebrating. You have the strength within you, and we're here to help you find it.",
                image: _buildSupportIcon(),
                decoration: _getPageDecoration(),
              ),
              
              // Page 5: Ready to Begin
              PageViewModel(
                title: "Ready to Start Your Journey?",
                body: "Let's get to know you better so we can personalize your experience. This quick assessment will help us understand your needs and provide the best support for you.\n\nEstimated time: 5 minutes",
                image: _buildStartIcon(),
                decoration: _getPageDecoration(),
              ),
            ],
            
            onDone: _isLoading ? () {} : () => _completeIntro(context),
            
            showSkipButton: false,
            showBackButton: true,
            back: const Icon(Icons.arrow_back),
            skipOrBackFlex: 0,
            nextFlex: 0,
            next: const Icon(Icons.arrow_forward),
            done: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
            
            dotsDecorator: DotsDecorator(
              size: const Size(10.0, 10.0),
              color: Colors.grey[300]!,
              activeSize: const Size(22.0, 10.0),
              activeColor: const Color(0xFF4CAF50),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            
            controlsMargin: const EdgeInsets.all(16),
            controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          ),
          
          // Settings button in top left
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : () => _showSettingsMenu(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String assetName, {double? height}) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Center(
        child: Image.asset(
          assetName,
          height: height ?? 175,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image not found
            return Icon(
              Icons.favorite,
              size: height ?? 175,
              color: const Color(0xFF4CAF50),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSupportIcon() {
    return const Padding(
      padding: EdgeInsets.only(top: 40, bottom: 20),
      child: Center(
        child: Icon(
          Icons.favorite_rounded,
          size: 175,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _buildStartIcon() {
    return const Padding(
      padding: EdgeInsets.only(top: 40, bottom: 20),
      child: Center(
        child: Icon(
          Icons.rocket_launch_rounded,
          size: 175,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1E),
      ),
      bodyTextStyle: const TextStyle(
        fontSize: 18.0,
        color: Color(0xFF3C3C3E),
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.skip_next, color: Color(0xFF4CAF50)),
                title: const Text(
                  'Skip Introduction',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Go directly to onboarding'),
                onTap: () {
                  Navigator.pop(context);
                  _skipIntro(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red[400]),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                subtitle: const Text('Exit your account'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmSignOut(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _skipIntro(BuildContext context) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Update user's intro status
      await ref.read(authNotifierProvider.notifier).updateIntroStatus(hasSeenIntro: true);
      
      if (mounted) {
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[400],
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(authNotifierProvider.notifier).signOut();
        
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeIntro(BuildContext context) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Update user's intro status
      await ref.read(authNotifierProvider.notifier).updateIntroStatus(hasSeenIntro: true);
      
      // Navigate to onboarding - safe to use context here since we're in a callback
      if (mounted) {
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

