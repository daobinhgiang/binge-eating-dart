import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../../core/services/subscription_service.dart';

/// Dedicated paywall screen that requires subscription to proceed
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Show paywall immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaywall();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 40),
            
            // Message
            Text(
              'Premium Access Required',
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Subscribe to unlock all features and start your recovery journey with Nurtra',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading indicator or retry button
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else
              ElevatedButton(
                onPressed: _showPaywall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'View Subscription Options',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Shows the Superwall paywall and handles subscription
  Future<void> _showPaywall() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    // Web: redirect to home (no paywall on web)
    if (kIsWeb) {
      if (mounted) {
        context.go('/home');
      }
      return;
    }

    try {
      final subscriptionService = SubscriptionService();
      
      // Check if user already has subscription
      bool isPremium = await subscriptionService.hasActiveSubscription();
      
      if (isPremium) {
        print('✅ User already has subscription, proceeding to home');
        if (mounted) {
          context.go('/home');
        }
        return;
      }

      // Show paywall
      print('📱 Presenting paywall to user...');
      Superwall.shared.registerPlacement('campaign_trigger', feature: () async {
        print('📱 Paywall dismissed, checking subscription status...');
        
        // Sync subscription status from Superwall to Firestore
        await subscriptionService.syncSubscriptionStatus();
        
        // Check if user subscribed
        isPremium = await subscriptionService.hasActiveSubscription();
        
        if (isPremium) {
          print('✅ User subscribed! Proceeding to home');
          if (mounted) {
            context.go('/home');
          }
        } else {
          print('⚠️ User has not subscribed, staying on paywall screen');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Show message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please subscribe to access Nurtra',
                  style: GoogleFonts.quicksand(),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('❌ Error showing paywall: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load subscription. Please try again.',
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

