import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetTimerService {
  static final ResetTimerService _instance = ResetTimerService._internal();
  factory ResetTimerService() => _instance;
  ResetTimerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log a reset time for the current user
  Future<void> logResetTime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      final resetTime = DateTime.now();
      
      await _firestore.collection('users').doc(user.uid).update({
        'lastResetTime': resetTime.millisecondsSinceEpoch,
        'resetTimes': FieldValue.arrayUnion([resetTime.millisecondsSinceEpoch]),
      });
      
      print('Reset time logged for user: ${user.uid} at ${resetTime.toIso8601String()}');
    } catch (e) {
      print('Error logging reset time: $e');
      throw 'Failed to log reset time. Please try again.';
    }
  }

  /// Get the last reset time for the current user
  Future<DateTime?> getLastResetTime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final lastResetTime = data['lastResetTime'] as int?;
        if (lastResetTime != null) {
          return DateTime.fromMillisecondsSinceEpoch(lastResetTime);
        }
      }
      return null;
    } catch (e) {
      print('Error getting last reset time: $e');
      return null;
    }
  }

  /// Get all reset times for the current user
  Future<List<DateTime>> getAllResetTimes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final resetTimes = data['resetTimes'] as List<dynamic>?;
        if (resetTimes != null) {
          return resetTimes
              .map((timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp as int))
              .toList()
            ..sort((a, b) => b.compareTo(a)); // Sort in descending order (most recent first)
        }
      }
      return [];
    } catch (e) {
      print('Error getting all reset times: $e');
      return [];
    }
  }

  /// Get the time since the last reset
  Future<Duration?> getTimeSinceLastReset() async {
    try {
      final lastResetTime = await getLastResetTime();
      if (lastResetTime == null) return null;
      
      return DateTime.now().difference(lastResetTime);
    } catch (e) {
      print('Error getting time since last reset: $e');
      return null;
    }
  }

  /// Get a formatted string of time since last reset
  Future<String?> getFormattedTimeSinceLastReset() async {
    try {
      final duration = await getTimeSinceLastReset();
      if (duration == null) return null;

      final days = duration.inDays;
      final hours = duration.inHours % 24;
      final minutes = duration.inMinutes % 60;

      if (days > 0) {
        return '${days}d ${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      print('Error formatting time since last reset: $e');
      return null;
    }
  }
}
