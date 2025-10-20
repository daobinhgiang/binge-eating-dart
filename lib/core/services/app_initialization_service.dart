import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notifications_service.dart';

/// Service to handle app-level initialization of services
/// This ensures services are only initialized once per user session
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final Set<String> _initializedUsers = <String>{};
  final LocalNotificationsService _notificationService = LocalNotificationsService.instance();

  /// Initialize all services for a user (only once per user session)
  Future<void> initializeForUser(String userId, WidgetRef ref) async {
    if (_initializedUsers.contains(userId)) {
      if (kDebugMode) {
        print('✅ Services already initialized for user: $userId');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🚀 Initializing services for user: $userId');
      }

      // Initialize notification service
      await _notificationService.init();

      // Mark user as initialized
      _initializedUsers.add(userId);

      if (kDebugMode) {
        print('✅ All services initialized successfully for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize services for user $userId: $e');
      }
      // Don't rethrow - this should be a background operation
    }
  }

  /// Check if services are initialized for a user
  bool isInitializedForUser(String userId) {
    return _initializedUsers.contains(userId);
  }

  /// Clear initialization state for a user (useful for logout)
  void clearUserInitialization(String userId) {
    _initializedUsers.remove(userId);
    if (kDebugMode) {
      print('🧹 Cleared initialization state for user: $userId');
    }
  }

  /// Clear all initialization states (useful for app restart)
  void clearAllInitializations() {
    _initializedUsers.clear();
    if (kDebugMode) {
      print('🧹 Cleared all initialization states');
    }
  }
}

/// Provider for the app initialization service
final appInitializationServiceProvider = Provider<AppInitializationService>((ref) {
  return AppInitializationService();
});
