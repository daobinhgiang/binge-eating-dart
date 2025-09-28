import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for tracking app retention and user engagement metrics
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize analytics for the current user
  Future<void> initializeAnalytics() async {
    try {
      // Set user properties for better segmentation
      final user = _auth.currentUser;
      if (user != null) {
        await _analytics.setUserId(id: user.uid);
        await _analytics.setUserProperty(
          name: 'user_id',
          value: user.uid,
        );
      }
    } catch (e) {
      print('Error initializing analytics: $e');
    }
  }

  /// Track app open events for retention analysis
  Future<void> trackAppOpen() async {
    try {
      await _analytics.logEvent(
        name: 'app_open',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking app open: $e');
    }
  }

  /// Track daily active user events
  Future<void> trackDailyActiveUser() async {
    try {
      await _analytics.logEvent(
        name: 'daily_active_user',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD format
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking daily active user: $e');
    }
  }

  /// Track weekly active user events
  Future<void> trackWeeklyActiveUser() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      await _analytics.logEvent(
        name: 'weekly_active_user',
        parameters: {
          'timestamp': now.millisecondsSinceEpoch,
          'week_start': weekStart.toIso8601String().split('T')[0],
          'week_end': weekEnd.toIso8601String().split('T')[0],
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking weekly active user: $e');
    }
  }

  /// Track user engagement with specific features
  Future<void> trackFeatureEngagement(String featureName, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: 'feature_engagement',
        parameters: {
          'feature_name': featureName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          ...?parameters,
        },
      );
    } catch (e) {
      print('Error tracking feature engagement: $e');
    }
  }

  /// Track user session duration
  Future<void> trackSessionDuration(int durationSeconds) async {
    try {
      await _analytics.logEvent(
        name: 'session_duration',
        parameters: {
          'duration_seconds': durationSeconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking session duration: $e');
    }
  }

  /// Track user retention milestones
  Future<void> trackRetentionMilestone(String milestone) async {
    try {
      await _analytics.logEvent(
        name: 'retention_milestone',
        parameters: {
          'milestone': milestone,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking retention milestone: $e');
    }
  }

  /// Track specific app features for retention analysis
  Future<void> trackJournalEntry() async {
    await trackFeatureEngagement('journal_entry');
  }

  Future<void> trackFoodDiaryEntry() async {
    await trackFeatureEngagement('food_diary_entry');
  }

  Future<void> trackWeightDiaryEntry() async {
    await trackFeatureEngagement('weight_diary_entry');
  }

  Future<void> trackBodyImageDiaryEntry() async {
    await trackFeatureEngagement('body_image_diary_entry');
  }

  Future<void> trackEMASurveyCompletion() async {
    await trackFeatureEngagement('ema_survey_completion');
  }

  Future<void> trackToolUsage(String toolName) async {
    await trackFeatureEngagement('tool_usage', parameters: {'tool_name': toolName});
  }

  Future<void> trackEducationArticleRead(String articleId) async {
    await trackFeatureEngagement('education_article_read', parameters: {'article_id': articleId});
  }

  Future<void> trackChatbotInteraction() async {
    await trackFeatureEngagement('chatbot_interaction');
  }

  Future<void> trackTodoCompletion() async {
    await trackFeatureEngagement('todo_completion');
  }

  /// Track user onboarding completion
  Future<void> trackOnboardingCompletion() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking onboarding completion: $e');
    }
  }

  /// Track user authentication events
  Future<void> trackUserLogin(String loginMethod) async {
    try {
      await _analytics.logEvent(
        name: 'user_login',
        parameters: {
          'login_method': loginMethod,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking user login: $e');
    }
  }

  Future<void> trackUserRegistration(String registrationMethod) async {
    try {
      await _analytics.logEvent(
        name: 'user_registration',
        parameters: {
          'registration_method': registrationMethod,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
        },
      );
    } catch (e) {
      print('Error tracking user registration: $e');
    }
  }

  /// Set user properties for better segmentation
  Future<void> setUserProperties({
    String? userRole,
    bool? onboardingCompleted,
    String? appVersion,
  }) async {
    try {
      if (userRole != null) {
        await _analytics.setUserProperty(name: 'user_role', value: userRole);
      }
      if (onboardingCompleted != null) {
        await _analytics.setUserProperty(
          name: 'onboarding_completed',
          value: onboardingCompleted.toString(),
        );
      }
      if (appVersion != null) {
        await _analytics.setUserProperty(name: 'app_version', value: appVersion);
      }
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  /// Get analytics instance for advanced usage
  FirebaseAnalytics get analytics => _analytics;
}
