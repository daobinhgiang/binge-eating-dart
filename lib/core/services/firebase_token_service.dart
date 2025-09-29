import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseTokenService {
  static final FirebaseTokenService _instance = FirebaseTokenService._internal();
  factory FirebaseTokenService() => _instance;
  FirebaseTokenService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Save user's FCM token to Firestore
  Future<void> saveUserToken(String userId) async {
    try {
      // Get the current FCM token
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        if (kDebugMode) {
          print('No FCM token available');
        }
        return;
      }

      // Get device info
      final platform = _getPlatform();
      
      // Save token to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .doc(token) // Use token as document ID to avoid duplicates
          .set({
        'token': token,
        'platform': platform,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUsed': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('FCM token saved for user $userId: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save FCM token: $e');
      }
      rethrow;
    }
  }

  /// Remove user's FCM token from Firestore
  Future<void> removeUserToken(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .doc(token)
          .delete();

      if (kDebugMode) {
        print('FCM token removed for user $userId: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove FCM token: $e');
      }
      rethrow;
    }
  }

  /// Remove all tokens for a user
  Future<void> removeAllUserTokens(String userId) async {
    try {
      final tokensSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .get();

      final batch = _firestore.batch();
      for (final doc in tokensSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (kDebugMode) {
        print('All FCM tokens removed for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove all FCM tokens: $e');
      }
      rethrow;
    }
  }

  /// Update token last used timestamp
  Future<void> updateTokenLastUsed(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .doc(token)
          .update({
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update token last used: $e');
      }
    }
  }

  /// Get current platform string
  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else {
      // For mobile platforms, you might want to get more specific info
      return 'mobile';
    }
  }

  /// Listen for token refresh and update Firestore
  void setupTokenRefreshListener(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      try {
        // Save the new token
        await saveUserToken(userId);
        
        if (kDebugMode) {
          print('FCM token refreshed and saved: $newToken');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save refreshed token: $e');
        }
      }
    });
  }

  /// Get all tokens for a user (for debugging)
  Future<List<String>> getUserTokens(String userId) async {
    try {
      final tokensSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .get();

      return tokensSnapshot.docs.map((doc) => doc.data()['token'] as String).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user tokens: $e');
      }
      return [];
    }
  }
}
