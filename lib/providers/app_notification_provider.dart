import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/app_notification_service.dart';
import '../models/app_notification.dart';

// App notification service provider
final appNotificationServiceProvider = Provider<AppNotificationService>((ref) => AppNotificationService());

// User notifications provider
final userNotificationsProvider = StreamProvider.family<List<AppNotification>, String>((ref, userId) {
  final service = ref.read(appNotificationServiceProvider);
  return service.getUserNotifications(userId).asStream();
});

// Unread notifications count provider
final unreadNotificationsCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.read(appNotificationServiceProvider);
  return await service.getUnreadCount(userId);
});

// Notification actions provider
final notificationActionsProvider = StateNotifierProvider<NotificationActionsNotifier, AsyncValue<void>>((ref) {
  return NotificationActionsNotifier(ref.read(appNotificationServiceProvider));
});

class NotificationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final AppNotificationService _service;

  NotificationActionsNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      state = const AsyncValue.loading();
      await _service.markAsRead(userId, notificationId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      state = const AsyncValue.loading();
      await _service.markAllAsRead(userId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteNotification(userId, notificationId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteAllNotifications(userId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createLessonCompletionNotification({
    required String userId,
    required String lessonTitle,
    required String lessonId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _service.createLessonCompletionNotification(
        userId: userId,
        lessonTitle: lessonTitle,
        lessonId: lessonId,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createJournalReminderNotification(String userId) async {
    try {
      state = const AsyncValue.loading();
      await _service.createJournalReminderNotification(userId: userId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createRegularEatingReminderNotification({
    required String userId,
    required String mealType,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _service.createRegularEatingReminderNotification(
        userId: userId,
        mealType: mealType,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createProgressMilestoneNotification({
    required String userId,
    required String milestone,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _service.createProgressMilestoneNotification(
        userId: userId,
        milestone: milestone,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
