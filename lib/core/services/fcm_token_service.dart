import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMTokenService {
  static final FCMTokenService _instance = FCMTokenService._internal();
  factory FCMTokenService() => _instance;
  FCMTokenService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Get the current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to user document in Firestore
  Future<void> saveTokenToUser(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('FCM token saved for user: $userId');
    } catch (e) {
      print('Error saving FCM token: $e');
      throw 'Failed to save FCM token';
    }
  }

  /// Remove FCM token from user document
  Future<void> removeTokenFromUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      print('FCM token removed for user: $userId');
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  /// Get FCM token for a specific user
  Future<String?> getUserToken(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user FCM token: $e');
      return null;
    }
  }

  /// Initialize FCM token handling for authenticated user
  Future<void> initializeForUser(String userId) async {
    try {
      // Get current token
      final token = await getCurrentToken();
      if (token != null) {
        // Save token to user document
        await saveTokenToUser(userId, token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        print('FCM token refreshed: $newToken');
        await saveTokenToUser(userId, newToken);
      });
    } catch (e) {
      print('Error initializing FCM token for user: $e');
    }
  }

  /// Clean up FCM token when user signs out
  Future<void> cleanupForUser(String userId) async {
    try {
      await removeTokenFromUser(userId);
    } catch (e) {
      print('Error cleaning up FCM token for user: $e');
    }
  }

  /// Check if FCM is available on this platform
  bool get isFCMAvailable {
    try {
      // FCM is available on mobile platforms and web
      return true;
    } catch (e) {
      return false;
    }
  }
}
