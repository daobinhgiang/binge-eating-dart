import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final authError = ref.watch(authErrorProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              
              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // App Name and Tagline
              Text(
                'Nurtra',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Take Control Over Binge Eating',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Error Message
              if (authError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authError,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Google Sign-In Button
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Apple Sign-In Button
              if (Theme.of(context).platform == TargetPlatform.iOS)
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _signInWithApple,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(
                      Icons.apple,
                      size: 24,
                    ),
                    label: const Text(
                      'Continue with Apple',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              
              if (Theme.of(context).platform == TargetPlatform.iOS)
                const SizedBox(height: 16),
              
              // Email Sign-In Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _goToEmailAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text(
                    'Continue with Other Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Notice
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    // Clear any previous errors
    ref.read(authNotifierProvider.notifier).clearError();
    
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.hasValue && authState.value != null) {
        context.go('/');
      }
    }
  }

  void _goToEmailAuth() {
    context.go('/email-auth');
  }

  Future<void> _signInWithApple() async {
    // Clear any previous errors
    ref.read(authNotifierProvider.notifier).clearError();
    
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.hasValue && authState.value != null) {
        context.go('/');
      }
    }
  }
}
