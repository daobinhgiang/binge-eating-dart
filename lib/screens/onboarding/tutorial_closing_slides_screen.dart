import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../../providers/auth_provider.dart';

class TutorialClosingSlidesScreen extends ConsumerStatefulWidget {
  const TutorialClosingSlidesScreen({super.key});

  @override
  ConsumerState<TutorialClosingSlidesScreen> createState() => _TutorialClosingSlidesScreenState();
}

class _TutorialClosingSlidesScreenState extends ConsumerState<TutorialClosingSlidesScreen> {
  bool _isLoading = false;
  int _currentPage = 0;
  final Set<int> _viewedSlides = {0}; // Track which slides have been viewed (start with slide 0)

  @override
  void initState() {
    super.initState();
    print('📖 TUTORIAL SLIDES: Starting tutorial closing slides (3 slides total)');
    print('   User must view all 3 slides to complete tutorial');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page content
          Center(
            child: _buildPageContent(),
          ),
          
          // Continue button at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: _buildContinueFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= _currentPage 
                    ? const Color(0xFF4CAF50) 
                    : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          
          // Slide content
          if (_currentPage == 0) _buildSlide1(),
          if (_currentPage == 1) _buildSlide2(),
          if (_currentPage == 2) _buildSlide3(),
        ],
      ),
    );
  }

  Widget _buildSlide1() {
    return Column(
      children: [
        Icon(
          Icons.celebration,
          size: 80,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 24),
        Text(
          'Nice job!',
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Now let\'s build a habit of practicing and growing your plant everyday.',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            color: Colors.black54,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSlide2() {
    return Column(
      children: [
        Icon(
          Icons.psychology,
          size: 80,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 24),
        Text(
          'Nurtra helps you better manage your symptoms',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '100+ beta users of Nurtra reported improvements in symptoms after 1 month of usage',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSlide3() {
    return Column(
      children: [
        Icon(
          Icons.science,
          size: 80,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 24),
        Text(
          'Nurtra was designed based on CBT-E',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Evidence-based method',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            color: Colors.black54,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            'Cognitive Behavioral Therapy for Eating Disorders (CBT-E) is a proven treatment approach',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueFooter() {
    final totalPages = 3; // We have 3 pages
    final hasViewedAllSlides = _viewedSlides.length >= totalPages;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress text showing which slide user is on
            if (_currentPage < totalPages - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Slide ${_currentPage + 1} of $totalPages',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_currentPage < totalPages - 1) {
                    // Not the last page, go to next
                    setState(() {
                      _currentPage++;
                      _viewedSlides.add(_currentPage);
                      print('📖 TUTORIAL SLIDES: Moved to slide ${_currentPage + 1}/$totalPages');
                      print('   Viewed slides: $_viewedSlides');
                    });
                  } else {
                    // Last page - check if all slides have been viewed
                    if (hasViewedAllSlides) {
                      print('✅ TUTORIAL SLIDES: All slides viewed, completing tutorial...');
                      _completeTutorial(context);
                    } else {
                      print('⚠️ TUTORIAL SLIDES: Not all slides viewed yet');
                      // This shouldn't happen with linear navigation, but just in case
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please view all slides to continue'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_currentPage) {
      case 0:
        return "I'm committed";
      case 1:
        return "Understood!";
      case 2:
        return "Got it";
      default:
        return "Continue";
    }
  }

  Future<void> _completeTutorial(BuildContext context) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('🎯 TUTORIAL SLIDES: Marking tutorial closing slides as complete...');
      
      // Mark that user has seen the timer closing slides
      // This happens BEFORE the paywall, so users have completed the tutorial
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasSeenTimerClosingSlides: true,
      );
      
      print('✅ TUTORIAL SLIDES: Tutorial closing slides marked complete');
      
      // Web: skip Superwall paywall and go directly to home
      if (kIsWeb) {
        print('🌐 TUTORIAL SLIDES: Web platform - skipping paywall, going to home');
        if (mounted) {
          context.go('/home');
        }
      } else {
        // Native platforms: Check premium status and present gated paywall
        if (mounted) {
          final user = ref.read(currentUserDataProvider);
          
          if (user != null && user.isPremium) {
            // User already has premium, go directly to home
            print('✅ PAYWALL: User already has premium subscription, proceeding to home');
            context.go('/home');
            return;
          }
          
          // User needs subscription, present gated Superwall paywall
          print('📱 PAYWALL: User needs subscription, presenting gated Superwall paywall...');
          print('   Placement ID: campaign_trigger');
          
          Superwall.shared.registerPlacement('campaign_trigger', feature: () {
            // This feature callback executes after paywall is dismissed
            print('📱 PAYWALL: Feature callback triggered - paywall was shown and dismissed');
            
            // Check if user subscribed after paywall dismissal
            _checkSubscriptionAndProceed();
          });
        }
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

  Future<void> _checkSubscriptionAndProceed() async {
    try {
      print('🔄 PAYWALL: Checking subscription status after paywall dismissal...');
      
      // Refresh auth state to get latest subscription status
      await ref.read(authNotifierProvider.notifier).refreshUserData();
      
      // Get updated user data
      final user = ref.read(currentUserDataProvider);
      
      if (user != null) {
        print('   Result: isPremium = ${user.isPremium}');
        
        if (user.isPremium) {
          print('✅ PAYWALL SUCCESS: User subscribed! Proceeding to home');
          if (mounted) {
            context.go('/home');
          }
        } else {
          print('⚠️ PAYWALL: User dismissed without subscribing - staying on tutorial');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Show message that subscription is required
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'A subscription is required to continue. Please subscribe to access the full app.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orange[700],
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Try Again',
                  textColor: Colors.white,
                  onPressed: () {
                    // User can tap "Try Again" to show paywall again
                    _completeTutorial(context);
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ PAYWALL ERROR: Exception during subscription check: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
