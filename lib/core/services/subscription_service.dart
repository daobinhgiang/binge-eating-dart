import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

/// Service to manage subscription status
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize subscription service
  Future<void> initialize() async {
    // Skip Superwall on web
    if (kIsWeb) {
      print('⚠️ Superwall not available on web platform');
      return;
    }

    print('✅ Subscription service initialized');
  }

  /// Update subscription status in Firestore
  Future<void> updateSubscriptionStatus(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ Cannot update subscription status: No user logged in');
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isPremium': isPremium,
      });
      print('✅ Subscription status updated to: $isPremium');
    } catch (e) {
      print('❌ Error updating subscription status: $e');
      rethrow;
    }
  }

  /// Check if user has active subscription from Firestore
  Future<bool> hasActiveSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final isPremium = doc.data()?['isPremium'] ?? false;
      return isPremium;
    } catch (e) {
      print('❌ Error checking subscription status: $e');
      return false;
    }
  }

  /// Sync subscription status from Superwall to Firestore
  /// This checks Superwall's subscription status and updates our database
  Future<void> syncSubscriptionStatus() async {
    if (kIsWeb) return;

    print('🔄 Syncing subscription status from Superwall...');
    
    try {
      // Get subscription status from Superwall
      final subscriptionStatus = await Superwall.shared.subscriptionStatus;
      print('📱 Superwall subscription status: $subscriptionStatus');
      
      // Determine if user has active subscription
      // SubscriptionStatus is a sealed class with SubscriptionStatusActive, 
      // SubscriptionStatusInactive, and SubscriptionStatusUnknown subclasses
      bool isPremium = subscriptionStatus is SubscriptionStatusActive;
      print('💎 isPremium determined as: $isPremium');
      
      // Update Firestore with the current status
      await updateSubscriptionStatus(isPremium);
      print('✅ Subscription status synced successfully');
    } catch (e) {
      print('❌ Error syncing subscription status from Superwall: $e');
      // Don't rethrow - allow the app to continue even if sync fails
      // The user might still have a valid subscription, we just couldn't verify it
    }
  }
}

