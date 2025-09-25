import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/body_image_diary.dart';

class BodyImageDiaryService {
  static final BodyImageDiaryService _instance = BodyImageDiaryService._internal();
  factory BodyImageDiaryService() => _instance;
  BodyImageDiaryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calculate the current week number based on user's first app use
  Future<int> getCurrentWeekNumber(String userId) async {
    try {
      // Get user's first app use date from user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw 'User document not found';
      }

      final userData = userDoc.data()!;
      final firstAppUse = userData['firstAppUse'] as int?;
      
      if (firstAppUse == null) {
        // If firstAppUse is not set, set it to now and return week 1
        await _firestore.collection('users').doc(userId).update({
          'firstAppUse': DateTime.now().millisecondsSinceEpoch,
        });
        return 1;
      }

      final firstAppUseDate = DateTime.fromMillisecondsSinceEpoch(firstAppUse);
      final now = DateTime.now();
      
      // Calculate the difference in days
      final daysDifference = now.difference(firstAppUseDate).inDays;
      
      // Calculate week number (starting from week 1)
      final weekNumber = (daysDifference / 7).floor() + 1;
      
      return weekNumber;
    } catch (e) {
      throw 'Failed to calculate current week: $e';
    }
  }

  // Create a new body image diary entry
  Future<BodyImageDiary> createBodyImageDiary({
    required String userId,
    required String howChecked,
    String? customHowChecked,
    required DateTime checkTime,
    required String whereChecked,
    String? customWhereChecked,
    required String contextAndFeelings,
  }) async {
    try {
      final now = DateTime.now();
      final weekNumber = await getCurrentWeekNumber(userId);
      
      final bodyImageDiary = BodyImageDiary(
        id: '', // Will be set by Firestore
        userId: userId,
        week: weekNumber,
        howChecked: howChecked,
        customHowChecked: customHowChecked,
        checkTime: checkTime,
        whereChecked: whereChecked,
        customWhereChecked: customWhereChecked,
        contextAndFeelings: contextAndFeelings,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/weeks/{weekNumber}/bodyImageDiaries/{entryId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('bodyImageDiaries')
          .add(bodyImageDiary.toFirestore());

      return bodyImageDiary.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create body image diary entry: $e';
    }
  }

  // Get all body image diary entries for a specific week
  Future<List<BodyImageDiary>> getBodyImageDiariesForWeek(String userId, int weekNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('bodyImageDiaries')
          .orderBy('checkTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BodyImageDiary.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get body image diary entries for week $weekNumber: $e';
    }
  }

  // Get all body image diary entries for the current week
  Future<List<BodyImageDiary>> getCurrentWeekBodyImageDiaries(String userId) async {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      return await getBodyImageDiariesForWeek(userId, currentWeek);
    } catch (e) {
      throw 'Failed to get current week body image diary entries: $e';
    }
  }

  // Get all body image diary entries for all weeks
  Future<Map<int, List<BodyImageDiary>>> getAllBodyImageDiaries(String userId) async {
    try {
      final weeksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      final Map<int, List<BodyImageDiary>> allDiaries = {};

      for (final weekDoc in weeksSnapshot.docs) {
        final weekNumber = int.tryParse(weekDoc.id.replaceAll('week_', ''));
        if (weekNumber != null) {
          final diaries = await getBodyImageDiariesForWeek(userId, weekNumber);
          if (diaries.isNotEmpty) {
            allDiaries[weekNumber] = diaries;
          }
        }
      }

      return allDiaries;
    } catch (e) {
      throw 'Failed to get all body image diary entries: $e';
    }
  }

  // Get a specific body image diary entry
  Future<BodyImageDiary?> getBodyImageDiary(String userId, int weekNumber, String entryId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('bodyImageDiaries')
          .doc(entryId)
          .get();

      if (doc.exists) {
        return BodyImageDiary.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get body image diary entry: $e';
    }
  }

  // Update a body image diary entry
  Future<void> updateBodyImageDiary({
    required String userId,
    required int weekNumber,
    required String entryId,
    required String howChecked,
    String? customHowChecked,
    required DateTime checkTime,
    required String whereChecked,
    String? customWhereChecked,
    required String contextAndFeelings,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('bodyImageDiaries')
          .doc(entryId)
          .update({
        'howChecked': howChecked,
        'customHowChecked': customHowChecked,
        'checkTime': checkTime.millisecondsSinceEpoch,
        'whereChecked': whereChecked,
        'customWhereChecked': customWhereChecked,
        'contextAndFeelings': contextAndFeelings,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update body image diary entry: $e';
    }
  }

  // Delete a body image diary entry
  Future<void> deleteBodyImageDiary(String userId, int weekNumber, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('bodyImageDiaries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete body image diary entry: $e';
    }
  }

  // Get body image diary entries for a date range
  Future<List<BodyImageDiary>> getBodyImageDiariesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allDiaries = await getAllBodyImageDiaries(userId);
      final List<BodyImageDiary> filteredDiaries = [];

      for (final diaries in allDiaries.values) {
        for (final diary in diaries) {
          if (diary.checkTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
              diary.checkTime.isBefore(endDate.add(const Duration(days: 1)))) {
            filteredDiaries.add(diary);
          }
        }
      }

      // Sort by check time, most recent first
      filteredDiaries.sort((a, b) => b.checkTime.compareTo(a.checkTime));

      return filteredDiaries;
    } catch (e) {
      throw 'Failed to get body image diary entries in date range: $e';
    }
  }

  // Get statistics for a specific week
  Future<Map<String, dynamic>> getWeekStatistics(String userId, int weekNumber) async {
    try {
      final diaries = await getBodyImageDiariesForWeek(userId, weekNumber);
      
      final stats = {
        'totalEntries': diaries.length,
        'mostCommonHowChecked': _getMostCommonMethod(diaries, (d) => d.displayHowChecked),
        'mostCommonWhereChecked': _getMostCommonMethod(diaries, (d) => d.displayWhereChecked),
        'averageChecksPerDay': diaries.length / 7.0,
        'checkingFrequency': _getCheckingFrequency(diaries),
      };

      return stats;
    } catch (e) {
      throw 'Failed to get week statistics: $e';
    }
  }

  String _getMostCommonMethod(List<BodyImageDiary> diaries, String Function(BodyImageDiary) getter) {
    if (diaries.isEmpty) return 'N/A';
    
    final Map<String, int> counts = {};
    for (final diary in diaries) {
      final method = getter(diary);
      counts[method] = (counts[method] ?? 0) + 1;
    }
    
    return counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, int> _getCheckingFrequency(List<BodyImageDiary> diaries) {
    final Map<String, int> frequency = {};
    
    for (final diary in diaries) {
      final hour = diary.checkTime.hour;
      String timeOfDay;
      
      if (hour >= 5 && hour < 12) {
        timeOfDay = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        timeOfDay = 'Afternoon';
      } else if (hour >= 17 && hour < 21) {
        timeOfDay = 'Evening';
      } else {
        timeOfDay = 'Night';
      }
      
      frequency[timeOfDay] = (frequency[timeOfDay] ?? 0) + 1;
    }
    
    return frequency;
  }

  // Get body checking patterns over multiple weeks
  Future<List<Map<String, dynamic>>> getBodyCheckingTrend(String userId, {int numberOfWeeks = 4}) async {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      final List<Map<String, dynamic>> trend = [];

      for (int week = currentWeek - numberOfWeeks + 1; week <= currentWeek; week++) {
        if (week > 0) {
          final diaries = await getBodyImageDiariesForWeek(userId, week);
          trend.add({
            'week': week,
            'totalChecks': diaries.length,
            'averagePerDay': diaries.length / 7.0,
            'mostCommonMethod': _getMostCommonMethod(diaries, (d) => d.displayHowChecked),
          });
        }
      }

      return trend;
    } catch (e) {
      throw 'Failed to get body checking trend: $e';
    }
  }
}
