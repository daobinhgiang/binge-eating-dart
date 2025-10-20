import 'package:cloud_firestore/cloud_firestore.dart';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user's streak
  Future<int> getCurrentStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;
      return userDoc.get('streak') as int? ?? 0;
    } catch (e) {
      print('❌ Error getting current streak: $e');
      return 0;
    }
  }

  /// Increment streak by 1
  Future<int> incrementStreak(String userId) async {
    try {
      print('🔥 Incrementing streak for user: $userId');
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('❌ User document not found');
        return 0;
      }

      final currentStreak = userDoc.get('streak') as int? ?? 0;
      final newStreak = currentStreak + 1;
      final today = DateTime.now();

      print('   Current streak: $currentStreak');
      print('   New streak: $newStreak');
      print('   Update date: ${today.toString().split(' ')[0]}');

      await _firestore.collection('users').doc(userId).update({
        'streak': newStreak,
        'lastStreakDate': Timestamp.fromDate(today),
      });

      print('✅ Streak incremented successfully');
      return newStreak;
    } catch (e) {
      print('❌ Error incrementing streak: $e');
      return 0;
    }
  }

  /// Reset streak to 0
  Future<void> resetStreak(String userId) async {
    try {
      print('🔄 Resetting streak for user: $userId');
      
      final today = DateTime.now();

      await _firestore.collection('users').doc(userId).update({
        'streak': 0,
        'lastStreakDate': Timestamp.fromDate(today),
      });

      print('✅ Streak reset to 0 successfully');
    } catch (e) {
      print('❌ Error resetting streak: $e');
    }
  }

  /// Check if all daily (Seeds) tasks are completed for today
  Future<bool> getAllDailyTasksCompleted(String userId) async {
    try {
      print('🔍 Checking if all daily tasks are completed for today...');
      
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Get all Seeds tasks for today
      final todosCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('todos');

      final querySnapshot = await todosCollection
          .where('type', isEqualTo: 'seed')
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(todayDate))
          .where('dueDate',
              isLessThan: Timestamp.fromDate(
                  todayDate.add(const Duration(days: 1))))
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('   ℹ️  No Seeds tasks found for today');
        return false;
      }

      print('   📋 Found ${querySnapshot.docs.length} Seeds tasks for today');

      // Check if all are completed
      final allCompleted = querySnapshot.docs.every((doc) {
        final isCompleted = doc.get('isCompleted') as bool? ?? false;
        print('      - ${doc.get('title')}: ${isCompleted ? '✅' : '❌'}');
        return isCompleted;
      });

      print('   Result: ${allCompleted ? 'All completed ✅' : 'Not all completed ❌'}');
      return allCompleted;
    } catch (e) {
      print('❌ Error checking daily task completion: $e');
      return false;
    }
  }

  /// Check if yesterday's tasks were completed, reset streak if not
  /// Returns true if streak was reset, false if it was maintained
  Future<bool> checkAndResetStreakIfNeeded(String userId) async {
    try {
      print(
          '\n🔍 STREAK CHECK: Checking if yesterday\'s tasks were completed...');

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('❌ User document not found');
        return false;
      }

      final lastStreakDate = userDoc.get('lastStreakDate');
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Parse lastStreakDate
      DateTime? lastDate;
      if (lastStreakDate != null) {
        final timestamp = lastStreakDate as Timestamp;
        lastDate = timestamp.toDate();
        final lastDateOnly =
            DateTime(lastDate.year, lastDate.month, lastDate.day);
        print('   Last streak date: $lastDateOnly');
        print('   Today date: $todayDate');

        // If today is the same as lastStreakDate, streak was already updated today
        if (lastDateOnly.isAtSameMomentAs(todayDate)) {
          print('   ✅ Streak already updated today, no check needed');
          return false;
        }
      }

      // Get yesterday's date
      final yesterday = todayDate.subtract(const Duration(days: 1));
      print('   Checking yesterday\'s tasks: $yesterday');

      // Check if there were any Seeds tasks yesterday
      final yesterdayTodos = await _firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .where('type', isEqualTo: 'seed')
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(yesterday))
          .where('dueDate',
              isLessThan: Timestamp.fromDate(
                  yesterday.add(const Duration(days: 1))))
          .get();

      if (yesterdayTodos.docs.isEmpty) {
        print('   ℹ️  No Seeds tasks existed yesterday, no reset needed');
        return false;
      }

      print('   📋 Found ${yesterdayTodos.docs.length} Seeds tasks from yesterday');

      // Check if all yesterday's tasks were completed
      final allYesterdayCompleted =
          yesterdayTodos.docs.every((doc) => doc.get('isCompleted') as bool? ?? false);

      if (!allYesterdayCompleted) {
        print('   ❌ Not all yesterday\'s tasks were completed');
        print('   🔄 Resetting streak to 0');
        await resetStreak(userId);
        return true;
      }

      print('   ✅ All yesterday\'s tasks were completed, streak maintained');
      return false;
    } catch (e) {
      print('❌ Error in checkAndResetStreakIfNeeded: $e');
      return false;
    }
  }
}
