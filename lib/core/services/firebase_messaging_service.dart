import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notifications_service.dart';
import 'fcm_token_service.dart';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;
  
  // FCM token service for managing tokens
  final FCMTokenService _fcmTokenService = FCMTokenService();

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    // Init local notifications service
    _localNotificationsService = localNotificationsService;

    // Handle FCM token
    _handlePushNotificationsToken();

    // Request user permission for notifications
    _requestPermission();

    // Register handler for background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    try {
      // On iOS, wait for APNS token to be available before requesting FCM token
      if (Platform.isIOS) {
        // Get APNS token first (this ensures it's available)
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          print('APNS token available: ${apnsToken.substring(0, 10)}...');
        } else {
          print('APNS token not available yet, will retry when token refresh occurs');
          // Don't throw error, just wait for token refresh event
          FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
            print('FCM token refreshed: $fcmToken');
            // Note: Token will be saved to user document when user signs in
          }).onError((error) {
            print('Error refreshing FCM token: $error');
          });
          return;
        }
      }

      // Get the FCM token for the device
      final token = await FirebaseMessaging.instance.getToken();
      print('Push notifications/FCM token: $token');

      // Listen for token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        print('FCM token refreshed: $fcmToken');
        // Note: Token will be saved to user document when user signs in
      }).onError((error) {
        // Handle errors during token refresh
        print('Error refreshing FCM token: $error');
      });
    } catch (e) {
      // Handle any errors gracefully - don't let FCM token issues crash the app
      print('Error getting FCM token: $e');
      print('Push notifications may not work until the app is restarted');
    }
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    print('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService?.showNotification(
          notificationData.title, notificationData.body, message.data.toString());
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    // TODO: Add navigation or specific handling based on message data
  }
}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}