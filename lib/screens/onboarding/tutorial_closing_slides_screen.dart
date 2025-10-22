import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () {
              final totalPages = 3; // We have 3 pages
              
              if (_currentPage < totalPages - 1) {
                // Not the last page, go to next
                setState(() {
                  _currentPage++;
                });
              } else {
                // Last page, complete tutorial
                _completeTutorial(context);
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
      // Mark that user has seen the timer closing slides
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasSeenTimerClosingSlides: true,
      );
      
      // Present Superwall paywall using placement registration
      if (mounted) {
        Superwall.shared.registerPlacement('campaign_trigger', feature: () {
          // This feature callback executes after paywall is dismissed
          // (whether user subscribes or not, since it's Non-Gated)
          if (mounted) {
            context.go('/home');
          }
        });
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
