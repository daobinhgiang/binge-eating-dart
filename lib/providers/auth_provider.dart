import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_analytics_service.dart';
import '../core/services/app_initialization_service.dart';
import '../core/services/task_regeneration_service.dart';
import '../core/services/todo_service.dart';
import '../core/services/lesson_progress_service.dart';
import '../core/services/quest_completion_service.dart';
import '../core/services/streak_service.dart';
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
  bool _hasDoneTutorialCheck = false; // Track if we've done the tutorial check this session
  StreamSubscription<UserModel?>? _userStreamSubscription;

  // Initialize auth state with real-time streaming
  Future<void> initialize() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    
    state = const AsyncValue.loading();
    
    // Listen to real-time user data changes
    _userStreamSubscription = _authService.currentUserStream.listen(
      (user) async {
        // Check and reset incomplete tutorial on app launch (ONLY ONCE per session)
        // This happens when user data is first loaded (sign-in OR session restore)
        if (user != null && !_hasDoneTutorialCheck) {
          _hasDoneTutorialCheck = true; // Mark as checked for this session
          
          // Check if user completed onboarding but not the tutorial closing slides
          if (user.onboardingCompleted && 
          user.hasSeenAppTutorial && 
          user.hasCompletedFirstLesson 
          && user.hasSeenExercisesTutorial 
          && user.hasSeenJournalTutorial 
          && user.hasLoggedWeightDuringTutorial 
          && user.hasSeenWeightDiaryTutorial 
          && user.hasVisitedWeightDiary && 
          user.hasSeenStreakTutorial && 
          user.hasSeenPlantGrowthTutorial && 
          !user.hasSeenTimerClosingSlides) {
            print('⚠️ TUTORIAL CHECK (APP LAUNCH): User completed onboarding but not tutorial slides');
            print('   hasSeenIntro: ${user.hasSeenIntro}');
            print('   onboardingCompleted: ${user.onboardingCompleted}');
            print('   hasSeenTimerClosingSlides: ${user.hasSeenTimerClosingSlides}');
            
            // Reset only the tutorial closing slides flag
            // User will be redirected to tutorial slides by AuthGuard
            try {
              await _authService.resetTutorialClosingSlides();
              print('✅ TUTORIAL CHECK (APP LAUNCH): Tutorial slides reset - user will resume from slides');
              
              // Don't set state here - let the stream update handle it
              // The reset will trigger a Firestore update, which will flow through the stream
              return;
            } catch (e) {
              print('❌ TUTORIAL CHECK ERROR: $e');
              // Continue with setting state even if reset fails
            }
          } else {
            print('✅ TUTORIAL CHECK (APP LAUNCH): Tutorial is complete or not yet started');
          }
        }
        
        state = AsyncValue.data(user);
        
        // Check and regenerate quests when user session is restored
        if (user != null) {
          try {
            await TaskRegenerationService().checkAndRegenerateTasks(user.id);
          } catch (e) {
            print('Error during daily quest check on session restore: $e');
          }
        }
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      var user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Track login event
      await _analytics.trackUserLogin('email_password');
      await _analytics.setUserProperties(
        userRole: user?.role.name,
        onboardingCompleted: user?.onboardingCompleted,
      );
      
      // Identify user with Superwall for paywall targeting
      if (user != null && !kIsWeb) {
        await _identifyUserWithSuperwall(user);
      }
      
      // Check and regenerate daily quests on login
      // This must complete before login to ensure onboarding flow has tasks
      if (user != null) {
        try {
          await TaskRegenerationService().checkAndRegenerateTasks(user.id);
        } catch (e) {
          print('Error during daily quest check on login: $e');
        }
      }
      
      // Update state explicitly after all async operations complete
      state = AsyncValue.data(user);
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
      
      // Track registration event
      await _analytics.trackUserRegistration('email_password');
      await _analytics.setUserProperties(
        userRole: user?.role.name,
        onboardingCompleted: user?.onboardingCompleted,
      );
      
      // Identify user with Superwall for paywall targeting
      if (user != null && !kIsWeb) {
        await _identifyUserWithSuperwall(user);
      }
      // Check and regenerate daily quests on sign up
      // This must complete before sign up to ensure onboarding flow has tasks
      if (user != null) {
        try {
          await TaskRegenerationService().checkAndRegenerateTasks(user.id);
        } catch (e) {
          print('Error during daily quest check on sign up: $e');
        }
      }
      
      // Update state explicitly after all async operations complete
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      var user = await _authService.signInWithGoogle();
      
      // If user is null, it means sign-in was cancelled - reset to data state
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      // Track login event
      await _analytics.trackUserLogin('google');
      await _analytics.setUserProperties(
        userRole: user.role.name,
        onboardingCompleted: user.onboardingCompleted,
      );
      
      // Identify user with Superwall for paywall targeting
      if (!kIsWeb) {
        await _identifyUserWithSuperwall(user);
      }
      
      // Check and regenerate daily quests on login
      // This must complete before login to ensure onboarding flow has tasks
      try {
        await TaskRegenerationService().checkAndRegenerateTasks(user.id);
      } catch (e) {
        print('Error during daily quest check on Google login: $e');
      }
      
      // Update state explicitly after all async operations complete
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      var user = await _authService.signInWithApple();
      
      // If user is null, it means sign-in was cancelled - reset to data state
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      // Track login event
      await _analytics.trackUserLogin('apple');
      await _analytics.setUserProperties(
        userRole: user.role.name,
        onboardingCompleted: user.onboardingCompleted,
      );
      
      // Check and regenerate daily quests on login
      // This must complete before login to ensure onboarding flow has tasks
      try {
        await TaskRegenerationService().checkAndRegenerateTasks(user.id);
      } catch (e) {
        print('Error during daily quest check on Apple login: $e');
      }
      
      // Update state explicitly after all async operations complete
      state = AsyncValue.data(user);
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
      
      // Reset tutorial check flag so next user (or same user on re-login) gets checked
      _hasDoneTutorialCheck = false;
      
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

  // Update intro status
  Future<void> updateIntroStatus({required bool hasSeenIntro}) async {
    try {
      await _authService.updateIntroStatus(hasSeenIntro: hasSeenIntro);
      
      // Refresh current user state
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update tutorial status
  Future<void> updateTutorialStatus({
    bool? hasSeenAppTutorial,
    bool? hasCompletedFirstLesson,
    bool? hasSeenExercisesTutorial,
    bool? hasSeenJournalTutorial,
    bool? hasLoggedWeightDuringTutorial,
    bool? hasSeenWeightDiaryTutorial,
    bool? hasVisitedWeightDiary,
    bool? hasSeenStreakTutorial,
    bool? hasSeenPlantGrowthTutorial,
    bool? hasSeenTimerClosingSlides,
  }) async {
    try {
      await _authService.updateTutorialStatus(
        hasSeenAppTutorial: hasSeenAppTutorial,
        hasCompletedFirstLesson: hasCompletedFirstLesson,
        hasSeenExercisesTutorial: hasSeenExercisesTutorial,
        hasSeenJournalTutorial: hasSeenJournalTutorial,
        hasLoggedWeightDuringTutorial: hasLoggedWeightDuringTutorial,
        hasSeenWeightDiaryTutorial: hasSeenWeightDiaryTutorial,
        hasVisitedWeightDiary: hasVisitedWeightDiary,
        hasSeenStreakTutorial: hasSeenStreakTutorial,
        hasSeenPlantGrowthTutorial: hasSeenPlantGrowthTutorial,
        hasSeenTimerClosingSlides: hasSeenTimerClosingSlides,
      );
      
      // Refresh current user state
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reset ALL tutorial flags to force user to redo tutorials from beginning
  // Called at app start if tutorials are incomplete
  Future<void> resetAllTutorialFlags() async {
    try {
      await _authService.resetAllTutorialFlags();
      
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
        print('🧹 Clearing all service caches before account deletion...');
        
        // Clear app initialization state
        AppInitializationService().clearUserInitialization(currentUser.id);
        
        // Clear all service caches to prevent stale data after account deletion
        // This ensures that if a new account is created, no old data persists
        TodoService().clearAllCaches();
        TaskRegenerationService().clearCache();
        LessonProgressService().clearCache();
        QuestCompletionService().clearCache();
        StreakService().clearCache();
        
        print('✅ All service caches cleared');
        
        // Reset Superwall to clear subscription state and user identity
        // This removes subscription entitlements and paywall assignments
        if (!kIsWeb) {
          try {
            await Superwall.shared.reset();
            print('✅ Superwall reset - subscription data and user identity cleared');
          } catch (e) {
            print('⚠️ Error resetting Superwall: $e');
            // Continue with account deletion even if Superwall reset fails
          }
        }
      }
      
      // Reset tutorial check flag so next user gets checked
      _hasDoneTutorialCheck = false;
      
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Refresh user data from Firebase
  Future<void> refreshUserData() async {
    try {
      final user = await _authService.currentUser;
      state = AsyncValue.data(user);
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

  // Update Superwall subscription status when user's premium status changes
  Future<void> updateSuperwallSubscriptionStatus(UserModel user) async {
    if (kIsWeb) return; // Skip on web
    
    try {
      print('🔄 SUPERWALL: Updating subscription status...');
      print('   User: ${user.email}');
      print('   isPremium: ${user.isPremium}');
      
      if (user.isPremium) {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatusActive(entitlements: {}));
        print('✅ SUPERWALL: Subscription status updated to ACTIVE');
      } else {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.inactive);
        print('✅ SUPERWALL: Subscription status updated to INACTIVE');
      }
    } catch (e) {
      print('❌ SUPERWALL ERROR: Failed to update subscription status: $e');
    }
  }

  // Identify user with Superwall for paywall targeting
  Future<void> _identifyUserWithSuperwall(UserModel user) async {
    try {
      print('🔍 SUPERWALL: Identifying user with Superwall...');
      print('   User ID: ${user.id}');
      print('   Email: ${user.email}');
      print('   isPremium: ${user.isPremium}');
      print('   trialEligible: ${user.trialEligible}');
      print('   Role: ${user.role.name}');
      print('   Onboarding Completed: ${user.onboardingCompleted}');
      
      // Set subscription status to prevent "No such key: has_active_subscription" error
      if (user.isPremium) {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatusActive(entitlements: {}));
        print('✅ SUPERWALL: Subscription status set to ACTIVE');
      } else {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.inactive);
        print('✅ SUPERWALL: Subscription status set to INACTIVE');
      }
      
      // Set user attributes for Superwall rule matching
      await Superwall.shared.setUserAttributes({
        'user_id': user.id,
        'email': user.email,
        'is_premium': user.isPremium,
        'has_active_subscription': user.isPremium,  // Add this - Superwall looks for this key
        'trial_eligible': user.trialEligible,
        'user_role': user.role.name,
        'onboarding_completed': user.onboardingCompleted,
        'has_seen_timer_closing_slides': user.hasSeenTimerClosingSlides,
        'level': user.level,
        'exp': user.exp,
        'streak': user.streak,
      });
      
      print('✅ SUPERWALL: User attributes set successfully');
    } catch (e) {
      print('❌ SUPERWALL ERROR: Failed to identify user: $e');
      // Don't throw - this shouldn't block authentication
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

