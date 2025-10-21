import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks lesson completion progress
/// Maintains daily and weekly counts that reset automatically
class LessonProgressService {
  static final LessonProgressService _instance = LessonProgressService._internal();
  factory LessonProgressService() => _instance;
  LessonProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get or create user's lesson progress document
  Future<Map<String, dynamic>> _getUserLessonProgress(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw 'User document not found';
      }

      final data = doc.data() as Map<String, dynamic>;

      // Get existing progress or initialize
      return {
        'lessonsCompletedToday': (data['lessonsCompletedToday'] ?? 0) as int,
        'lessonsCompletedThisWeek': (data['lessonsCompletedThisWeek'] ?? 0) as int,
        'lastLessonCompletionDate': data['lastLessonCompletionDate'],
        'lastLessonCompletionWeek': data['lastLessonCompletionWeek'],
      };
    } catch (e) {
      print('❌ Error getting lesson progress: $e');
      return {
        'lessonsCompletedToday': 0,
        'lessonsCompletedThisWeek': 0,
        'lastLessonCompletionDate': null,
        'lastLessonCompletionWeek': null,
      };
    }
  }

  /// Check if we need to reset daily counter (new day)
  bool _isNewDay(dynamic lastDate) {
    if (lastDate == null) return true;

    DateTime lastDateTime;
    if (lastDate is Timestamp) {
      lastDateTime = lastDate.toDate();
    } else {
      return true;
    }

    final today = DateTime.now();
    final lastDay = DateTime(lastDateTime.year, lastDateTime.month, lastDateTime.day);
    final todayDay = DateTime(today.year, today.month, today.day);

    return !lastDay.isAtSameMomentAs(todayDay);
  }

  /// Check if we need to reset weekly counter (new week)
  bool _isNewWeek(dynamic lastWeekData) {
    if (lastWeekData == null) return true;

    final currentWeek = _getISOWeekNumber(DateTime.now());
    return lastWeekData != currentWeek;
  }

  /// Get ISO week number
  int _getISOWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final startOfYear = jan4.subtract(Duration(days: jan4.weekday - 1));
    final diffDays = date.difference(startOfYear).inDays;
    return (diffDays / 7).floor() + 1;
  }

  /// Record a lesson completion
  /// Returns: { lessonsCompletedToday, lessonsCompletedThisWeek }
  Future<Map<String, int>> recordLessonCompletion(String userId) async {
    try {
      print('\n   [LessonProgressService] Recording lesson completion...');

      final userRef = _firestore.collection('users').doc(userId);
      final progress = await _getUserLessonProgress(userId);

      int lessonsToday = progress['lessonsCompletedToday'] as int;
      int lessonsWeek = progress['lessonsCompletedThisWeek'] as int;

      print('   [LessonProgressService] Current state:');
      print('       - Lessons today: $lessonsToday');
      print('       - Lessons this week: $lessonsWeek');
      print('       - Last completion date: ${progress['lastLessonCompletionDate']}');
      print('       - Last completion week: ${progress['lastLessonCompletionWeek']}');

      // Check if we need to reset daily counter
      if (_isNewDay(progress['lastLessonCompletionDate'])) {
        print('   [LessonProgressService] 📅 NEW DAY detected - resetting daily counter');
        lessonsToday = 0;
      }

      // Check if we need to reset weekly counter
      if (_isNewWeek(progress['lastLessonCompletionWeek'])) {
        print('   [LessonProgressService] 📆 NEW WEEK detected - resetting weekly counter');
        lessonsWeek = 0;
      }

      // Increment both counters
      lessonsToday++;
      lessonsWeek++;

      final now = DateTime.now();
      final weekNumber = _getISOWeekNumber(now);

      print('   [LessonProgressService] Incremented:');
      print('       - Lessons today: $lessonsToday');
      print('       - Lessons this week: $lessonsWeek');

      // Update Firestore
      await userRef.update({
        'lessonsCompletedToday': lessonsToday,
        'lessonsCompletedThisWeek': lessonsWeek,
        'lastLessonCompletionDate': Timestamp.fromDate(now),
        'lastLessonCompletionWeek': weekNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('   [LessonProgressService] ✅ Firestore updated successfully');

      return {
        'lessonsCompletedToday': lessonsToday,
        'lessonsCompletedThisWeek': lessonsWeek,
      };
    } catch (e) {
      print('   [LessonProgressService] ❌ Error recording lesson completion: $e');
      rethrow;
    }
  }

  /// Get current lesson progress
  Future<Map<String, int>> getLessonProgress(String userId) async {
    try {
      final progress = await _getUserLessonProgress(userId);

      int lessonsToday = progress['lessonsCompletedToday'] as int;
      int lessonsWeek = progress['lessonsCompletedThisWeek'] as int;

      // Check and reset if needed (don't save, just return current values)
      if (_isNewDay(progress['lastLessonCompletionDate'])) {
        lessonsToday = 0;
      }

      if (_isNewWeek(progress['lastLessonCompletionWeek'])) {
        lessonsWeek = 0;
      }

      return {
        'lessonsCompletedToday': lessonsToday,
        'lessonsCompletedThisWeek': lessonsWeek,
      };
    } catch (e) {
      print('Error getting lesson progress: $e');
      return {
        'lessonsCompletedToday': 0,
        'lessonsCompletedThisWeek': 0,
      };
    }
  }
}
