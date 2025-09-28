import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/onboarding_service.dart';
import '../core/services/firebase_analytics_service.dart';
import '../models/onboarding_data.dart';

// Onboarding service provider
final onboardingServiceProvider = Provider<OnboardingService>((ref) => OnboardingService());

// Onboarding data provider for a specific user
final onboardingDataProvider = FutureProvider.family<OnboardingData?, String>((ref, userId) async {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return await onboardingService.getOnboardingData(userId);
});

// Onboarding completion status provider
final onboardingCompletionProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return await onboardingService.hasCompletedOnboarding(userId);
});
