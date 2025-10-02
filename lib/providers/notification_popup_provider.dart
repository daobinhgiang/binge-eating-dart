import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';
import '../models/app_notification.dart';

/// Provider for NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for managing notification popup display
final notificationPopupProvider = StateNotifierProvider<NotificationPopupNotifier, AppNotification?>((ref) {
  return NotificationPopupNotifier(ref.read(notificationServiceProvider));
});

class NotificationPopupNotifier extends StateNotifier<AppNotification?> {
  final NotificationService _notificationService;

  NotificationPopupNotifier(this._notificationService) : super(null) {
    // Set up callback for new notifications
    _notificationService.onNewNotification = _handleNewNotification;
  }

  void _handleNewNotification(AppNotification notification) {
    state = notification;
  }

  void clearNotification() {
    state = null;
  }

  void initializeForUser(String userId) {
    _notificationService.initializeForUser(userId);
  }

  void cleanup() {
    _notificationService.cleanup();
    state = null;
  }

  @override
  void dispose() {
    _notificationService.cleanup();
    super.dispose();
  }
}

