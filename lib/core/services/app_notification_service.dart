import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_notification.dart';

class AppNotificationService {
  static final AppNotificationService _instance = AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'notifications';

  /// Get all notifications for a user
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get user notifications: $e';
    }
  }

  /// Get unread notifications count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw 'Failed to get unread count: $e';
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
        data: data,
        actionUrl: actionUrl,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .add(notification.toFirestore());
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to delete all notifications: $e';
    }
  }

  /// Create a lesson completion notification
  Future<void> createLessonCompletionNotification({
    required String userId,
    required String lessonTitle,
    required String lessonId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Lesson Completed! 🎉',
      body: 'Great job completing "$lessonTitle"! Keep up the excellent work.',
      type: 'achievement',
      data: {'lessonId': lessonId, 'lessonTitle': lessonTitle},
      actionUrl: '/education',
    );
  }

  /// Create a journal reminder notification
  Future<void> createJournalReminderNotification({
    required String userId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Journal Reminder 📝',
      body: 'Take a moment to reflect on your day and log your thoughts.',
      type: 'reminder',
      actionUrl: '/journal',
    );
  }

  /// Create a regular eating reminder notification
  Future<void> createRegularEatingReminderNotification({
    required String userId,
    required String mealType,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Meal Time! 🍽️',
      body: 'Time for your $mealType. Remember to eat mindfully and enjoy your meal.',
      type: 'reminder',
      actionUrl: '/profile/regular-eating',
    );
  }

  /// Create a progress milestone notification
  Future<void> createProgressMilestoneNotification({
    required String userId,
    required String milestone,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Milestone Achieved! 🏆',
      body: milestone,
      type: 'achievement',
      actionUrl: '/profile',
    );
  }
}
