import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_analytics_service.dart';
import '../core/services/app_initialization_service.dart';
import '../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Current user stream provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).currentUserStream;
});

// Auth state provider for managing authentication state
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading());

  final AuthService _authService;
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();
  bool _hasInitialized = false;

  // Initialize auth state
  Future<void> initialize() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    
    state = const AsyncValue.loading();
    try {
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
      
      // Track login event
      await _analytics.trackUserLogin('email_password');
      await _analytics.setUserProperties(
        userRole: user?.role.name,
        onboardingCompleted: user?.onboardingCompleted,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      state = AsyncValue.data(user);
      
      // Track registration event
      await _analytics.trackUserRegistration('email_password');
      await _analytics.setUserProperties(
        userRole: user?.role.name,
        onboardingCompleted: user?.onboardingCompleted,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
      
      // Track login event
      await _analytics.trackUserLogin('google');
      await _analytics.setUserProperties(
        userRole: user?.role.name,
        onboardingCompleted: user?.onboardingCompleted,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      // Clear initialization state for current user before signing out
      final currentUser = state.value;
      if (currentUser != null) {
        AppInitializationService().clearUserInitialization(currentUser.id);
      }
      
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update onboarding status
  Future<void> updateOnboardingStatus({
    bool? onboardingCompleted,
    bool? onboardingPartiallyCompleted,
  }) async {
    try {
      await _authService.updateOnboardingStatus(
        onboardingCompleted: onboardingCompleted,
        onboardingPartiallyCompleted: onboardingPartiallyCompleted,
      );
      
      // Track onboarding completion if completed
      if (onboardingCompleted == true) {
        await _analytics.trackOnboardingCompletion();
      }
      
      // Refresh current user state
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _authService.resetPassword(email: email);
    } catch (e) {
      // Handle error in UI
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      await _authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );
      // Refresh current user data
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      // Clear initialization state for current user before deleting account
      final currentUser = state.value;
      if (currentUser != null) {
        AppInitializationService().clearUserInitialization(currentUser.id);
      }
      
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Clear error state
  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.value);
    }
  }
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

// Convenience providers for common auth states
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentUserDataProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

