import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firebase_analytics_service.dart';

/// Provider for Firebase Analytics service
final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Provider for analytics initialization
final analyticsInitializationProvider = FutureProvider<void>((ref) async {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  await analyticsService.initializeAnalytics();
});

/// Provider for tracking app open events
final appOpenTrackingProvider = Provider<void Function()>((ref) {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  
  return () async {
    await analyticsService.trackAppOpen();
    await analyticsService.trackDailyActiveUser();
    await analyticsService.trackWeeklyActiveUser();
  };
});

/// Provider for tracking feature engagement
final featureEngagementProvider = Provider<Future<void> Function(String, {Map<String, dynamic>? parameters})>((ref) {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  
  return (String featureName, {Map<String, dynamic>? parameters}) async {
    await analyticsService.trackFeatureEngagement(featureName, parameters: parameters);
  };
});

/// Provider for tracking session duration
final sessionTrackingProvider = Provider<Future<void> Function(int)>((ref) {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  
  return (int durationSeconds) async {
    await analyticsService.trackSessionDuration(durationSeconds);
  };
});

/// Provider for tracking retention milestones
final retentionTrackingProvider = Provider<Future<void> Function(String)>((ref) {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  
  return (String milestone) async {
    await analyticsService.trackRetentionMilestone(milestone);
  };
});

/// Provider for setting user properties
final userPropertiesProvider = Provider<Future<void> Function({
  String? userRole,
  bool? onboardingCompleted,
  String? appVersion,
})>((ref) {
  final analyticsService = ref.read(firebaseAnalyticsServiceProvider);
  
  return ({
    String? userRole,
    bool? onboardingCompleted,
    String? appVersion,
  }) async {
    await analyticsService.setUserProperties(
      userRole: userRole,
      onboardingCompleted: onboardingCompleted,
      appVersion: appVersion,
    );
  };
});
