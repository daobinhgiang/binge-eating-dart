import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../models/regular_eating.dart';
import 'firebase_token_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseTokenService _tokenService = FirebaseTokenService();

  bool _isInitialized = false;

  // Notification channel IDs
  static const String _regularEatingChannelId = 'regular_eating_reminders';
  static const String _regularEatingChannelName = 'Regular Eating Reminders';
  static const String _regularEatingChannelDescription = 'Reminders for regular eating schedule';

  // Notification IDs
  static const int _regularEatingNotificationId = 1000;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Only initialize local notifications on mobile platforms
      if (!kIsWeb) {
        await _initializeLocalNotifications();
      }

      // Request permissions
      await _requestPermissions();

      // Initialize Firebase Messaging (works on all platforms)
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize NotificationService: $e');
      }
      rethrow;
    }
  }

  /// Initialize local notifications for mobile platforms
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Skip local notification permissions on web
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        await androidImplementation?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request local notification permissions: $e');
      }
    }
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print('Firebase Messaging permission status: ${settings.authorizationStatus}');
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // For web, also handle browser notifications
      if (kIsWeb) {
        await _initializeWebNotifications();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Firebase Messaging: $e');
      }
      // Don't rethrow - allow the app to continue without notifications
    }
  }

  /// Initialize web-specific notifications
  Future<void> _initializeWebNotifications() async {
    try {
      // Request browser notification permission
      if (kIsWeb) {
        // Check if service worker is available
        if (await _isServiceWorkerAvailable()) {
          if (kDebugMode) {
            print('Web notifications initialized via Firebase messaging');
          }
        } else {
          if (kDebugMode) {
            print('Service worker not available, using fallback notification method');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize web notifications: $e');
      }
    }
  }

  /// Check if service worker is available
  Future<bool> _isServiceWorkerAvailable() async {
    try {
      if (kIsWeb) {
        // Check if service workers are supported
        return true; // Assume available for now
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Handle navigation based on payload
    // This could navigate to the Regular Eating screen or home screen
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.notification?.title}');
    }
    
    // Show local notification for foreground messages
    _showLocalNotification(
      title: message.notification?.title ?? 'Regular Eating Reminder',
      body: message.notification?.body ?? 'Time for your regular meal!',
    );
  }

  /// Initialize token service for a user
  Future<void> _initializeTokenService(String userId) async {
    try {
      // Save the current FCM token
      await _tokenService.saveUserToken(userId);
      
      // Set up token refresh listener
      _tokenService.setupTokenRefreshListener(userId);
      
      if (kDebugMode) {
        print('Token service initialized for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize token service: $e');
      }
      // Don't rethrow - this is not critical for app functionality
    }
  }

  /// Schedule regular eating notifications based on user settings
  Future<void> scheduleRegularEatingNotifications(RegularEating regularEating) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Save FCM token for Cloud Functions
      await _tokenService.saveUserToken(regularEating.userId);

      // Cancel existing local notifications first
      await cancelRegularEatingNotifications();

      // Create notification channel for Android
      await _createNotificationChannel();

      // Calculate meal times for the next 7 days
      final now = DateTime.now();
      final List<DateTime> mealTimes = [];

      for (int day = 0; day < 7; day++) {
        final date = now.add(Duration(days: day));
        final dayMealTimes = regularEating.getMealTimesForDate(date);
        mealTimes.addAll(dayMealTimes);
      }

      if (kIsWeb) {
        // For web, we rely entirely on Firebase Cloud Functions
        if (kDebugMode) {
          print('Web platform: Regular eating notifications will be handled via Firebase Cloud Functions');
          print('Calculated ${mealTimes.length} meal times for the next 7 days');
        }
        return;
      }

      // For mobile platforms, we can still use local notifications as backup
      // But Cloud Functions will be the primary method
      for (int i = 0; i < mealTimes.length; i++) {
        final mealTime = mealTimes[i];
        final mealNumber = (i % 4) + 1; // 1-4 meals per day
        
        await _scheduleNotification(
          id: _regularEatingNotificationId + i,
          title: _getNotificationTitle(mealNumber),
          body: _getNotificationBody(mealNumber, regularEating.mealIntervalHours),
          scheduledDate: mealTime,
        );
      }

      if (kDebugMode) {
        print('Scheduled ${mealTimes.length} regular eating notifications (local + Cloud Functions)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule regular eating notifications: $e');
      }
      rethrow;
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          _regularEatingChannelId,
          _regularEatingChannelName,
          description: _regularEatingChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        await androidImplementation?.createNotificationChannel(channel);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create notification channel: $e');
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Skip on web platform - use Firebase messaging instead
    if (kIsWeb) {
      if (kDebugMode) {
        print('Web platform: Skipping local notification scheduling. Use Firebase messaging for web notifications.');
      }
      return;
    }

    // Only schedule if the date is in the future
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _regularEatingChannelId,
        _regularEatingChannelName,
        channelDescription: _regularEatingChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule notification: $e');
      }
    }
  }

  /// Cancel all regular eating notifications
  Future<void> cancelRegularEatingNotifications() async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      // Cancel all notifications with IDs in the regular eating range
      for (int i = 0; i < 28; i++) { // 7 days * 4 meals max
        await _localNotifications.cancel(_regularEatingNotificationId + i);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel notifications: $e');
      }
    }
  }

  /// Show immediate local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    // Skip on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print('Web platform: Cannot show local notification. Use browser notifications or Firebase messaging.');
      }
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _regularEatingChannelId,
        _regularEatingChannelName,
        channelDescription: _regularEatingChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show local notification: $e');
      }
    }
  }

  /// Get notification title based on meal number
  String _getNotificationTitle(int mealNumber) {
    switch (mealNumber) {
      case 1:
        return '🌅 Time for Breakfast!';
      case 2:
        return '☀️ Lunch Time!';
      case 3:
        return '🌤️ Afternoon Snack!';
      case 4:
        return '🌙 Dinner Time!';
      default:
        return '🍽️ Meal Reminder!';
    }
  }

  /// Get notification body based on meal number and interval
  String _getNotificationBody(int mealNumber, double intervalHours) {
    final intervalText = intervalHours == intervalHours.round() 
        ? '${intervalHours.round()} hour${intervalHours.round() == 1 ? '' : 's'}'
        : '${intervalHours.toStringAsFixed(1)} hours';
    
    switch (mealNumber) {
      case 1:
        return 'Start your day with a nourishing breakfast! Your regular eating schedule helps maintain healthy habits.';
      case 2:
        return 'Time for lunch! Keep up with your $intervalText eating schedule.';
      case 3:
        return 'Afternoon snack time! Stay consistent with your regular eating routine.';
      case 4:
        return 'Dinner time! You\'re doing great with your regular eating schedule.';
      default:
        return 'Time for your regular meal! Stay consistent with your $intervalText eating schedule.';
    }
  }

  /// Get Firebase token for push notifications
  Future<String?> getFirebaseToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get Firebase token: $e');
        if (kIsWeb) {
          print('Web notification setup may be incomplete. Service worker registration failed.');
        }
      }
      return null;
    }
  }

  /// Subscribe to regular eating topic for push notifications
  Future<void> subscribeToRegularEatingTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic('regular_eating');
      if (kDebugMode) {
        print('Subscribed to regular_eating topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to regular_eating topic: $e');
      }
    }
  }

  /// Unsubscribe from regular eating topic
  Future<void> unsubscribeFromRegularEatingTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('regular_eating');
      if (kDebugMode) {
        print('Unsubscribed from regular_eating topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unsubscribe from regular_eating topic: $e');
      }
    }
  }

  /// Remove all tokens for a user (when they log out)
  Future<void> removeUserTokens(String userId) async {
    try {
      await _tokenService.removeAllUserTokens(userId);
      if (kDebugMode) {
        print('Removed all tokens for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove user tokens: $e');
      }
    }
  }

  /// Update token last used timestamp
  Future<void> updateTokenLastUsed(String userId) async {
    try {
      final token = await getFirebaseToken();
      if (token != null) {
        await _tokenService.updateTokenLastUsed(userId, token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update token last used: $e');
      }
    }
  }
}

/// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}
