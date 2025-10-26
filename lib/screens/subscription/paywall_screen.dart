import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../../providers/auth_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = true;
  bool _paywallDismissed = false;

  @override
  void initState() {
    super.initState();
    print('🏪 PAYWALL SCREEN: Initialized');
    _initializePaywall();
  }

  Future<void> _initializePaywall() async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('🏪 PAYWALL FLOW STARTED');
      print('═══════════════════════════════════════════════════════════');
      
      // Check if user already has subscription
      print('🔍 PAYWALL: Checking if user already has subscription...');
      final user = ref.read(currentUserDataProvider);
      
      if (user == null) {
        print('❌ PAYWALL ERROR: User is null');
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      print('   Result: isPremium = ${user.isPremium}');
      
      if (user.isPremium) {
        print('✅ PAYWALL: User already has subscription, proceeding to home');
        if (mounted) {
          context.go('/home');
        }
        return;
      }
      
      // User needs subscription, present Superwall paywall
      print('📱 PAYWALL: User needs subscription, presenting Superwall paywall...');
      print('   Placement ID: campaign_trigger');
      
      // Add delay to ensure Superwall WebView is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        try {
          Superwall.shared.registerPlacement('campaign_trigger', feature: () {
            // This callback executes after paywall is dismissed
            print('───────────────────────────────────────────────────────────');
            print('📱 PAYWALL CALLBACK: Paywall dismissed by user');
            print('───────────────────────────────────────────────────────────');
            
            _handlePaywallDismissed();
          });
          
          print('✅ PAYWALL: Superwall paywall registration complete, waiting for user interaction...');
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        } catch (superwallError) {
          print('❌ PAYWALL ERROR: Superwall registration failed: $superwallError');
          print('   This might be due to JavaScript bridge not being ready');
          
          // Retry after a longer delay
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            try {
              Superwall.shared.registerPlacement('campaign_trigger', feature: () {
                _handlePaywallDismissed();
              });
              print('✅ PAYWALL: Retry successful');
              
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            } catch (retryError) {
              print('❌ PAYWALL ERROR: Retry also failed: $retryError');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ PAYWALL ERROR: Exception during initialization: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePaywallDismissed() async {
    try {
      print('🔄 PAYWALL: Syncing subscription status from Superwall to Firestore...');
      
      // Refresh auth state to get latest subscription status
      await ref.read(authNotifierProvider.notifier).refreshUserData();
      
      print('🔍 PAYWALL: Re-checking subscription status from Firestore...');
      final user = ref.read(currentUserDataProvider);
      
      if (user != null) {
        print('   Result: isPremium = ${user.isPremium}');
        
        if (user.isPremium) {
          print('✅ PAYWALL SUCCESS: User subscribed! Proceeding to home');
          // Update Superwall subscription status to prevent "has_active_subscription" error
          await ref.read(authNotifierProvider.notifier).updateSuperwallSubscriptionStatus(user);
          print('═══════════════════════════════════════════════════════════');
          if (mounted) {
            context.go('/home');
          }
        } else {
          print('⚠️ PAYWALL: User dismissed without subscribing');
          print('═══════════════════════════════════════════════════════════');
          if (mounted) {
            setState(() {
              _paywallDismissed = true;
            });
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ PAYWALL ERROR: Exception during callback handling: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _paywallDismissed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes to detect subscription updates
    final authState = ref.watch(authNotifierProvider);
    
    authState.whenData((user) {
      if (user != null && user.isPremium) {
        print('🎉 PAYWALL: Subscription status updated to premium via AuthProvider stream!');
        // Update Superwall subscription status to prevent "has_active_subscription" error
        ref.read(authNotifierProvider.notifier).updateSuperwallSubscriptionStatus(user);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading subscription options...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lock icon
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Premium Access Required',
                        style: GoogleFonts.quicksand(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Subscribe to unlock all features and continue your recovery journey.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Show message if paywall was dismissed
                      if (_paywallDismissed)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Subscription required to continue. Please subscribe to access the app.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Retry button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _paywallDismissed = false;
                            _isLoading = true;
                          });
                          _initializePaywall();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Subscription Options',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

