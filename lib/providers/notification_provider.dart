import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';
import '../models/regular_eating.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

// Notification settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref.read(notificationServiceProvider));
});

// Regular eating notifications provider
final regularEatingNotificationsProvider = StateNotifierProvider<RegularEatingNotificationsNotifier, AsyncValue<bool>>((ref) {
  return RegularEatingNotificationsNotifier(ref.read(notificationServiceProvider));
});

class NotificationSettings {
  final bool isEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String? firebaseToken;

  const NotificationSettings({
    this.isEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.firebaseToken,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? firebaseToken,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      firebaseToken: firebaseToken ?? this.firebaseToken,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _notificationService;

  NotificationSettingsNotifier(this._notificationService) : super(const NotificationSettings()) {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      await _notificationService.initialize();
      final token = await _notificationService.getFirebaseToken();
      state = state.copyWith(firebaseToken: token);
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        state = state.copyWith(isEnabled: false);
      }
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    
    if (enabled) {
      await _notificationService.subscribeToRegularEatingTopic();
    } else {
      await _notificationService.unsubscribeFromRegularEatingTopic();
    }
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
  }

  Future<void> refreshToken() async {
    try {
      final token = await _notificationService.getFirebaseToken();
      state = state.copyWith(firebaseToken: token);
    } catch (e) {
      // Handle token refresh error
    }
  }
}

class RegularEatingNotificationsNotifier extends StateNotifier<AsyncValue<bool>> {
  final NotificationService _notificationService;

  RegularEatingNotificationsNotifier(this._notificationService) : super(const AsyncValue.loading()) {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      state = const AsyncValue.data(true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> scheduleNotifications(RegularEating regularEating) async {
    try {
      state = const AsyncValue.loading();
      await _notificationService.scheduleRegularEatingNotifications(regularEating);
      state = const AsyncValue.data(true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> cancelNotifications() async {
    try {
      state = const AsyncValue.loading();
      await _notificationService.cancelRegularEatingNotifications();
      state = const AsyncValue.data(false);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> rescheduleNotifications(RegularEating regularEating) async {
    try {
      state = const AsyncValue.loading();
      await _notificationService.cancelRegularEatingNotifications();
      await _notificationService.scheduleRegularEatingNotifications(regularEating);
      state = const AsyncValue.data(true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
