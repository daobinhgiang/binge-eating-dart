import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/weight_diary.dart';

class WeightDiaryService {
  static final WeightDiaryService _instance = WeightDiaryService._internal();
  factory WeightDiaryService() => _instance;
  WeightDiaryService._internal();

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

  // Create a new weight diary entry
  Future<WeightDiary> createWeightDiary({
    required String userId,
    required double weight,
    required String unit,
  }) async {
    try {
      final now = DateTime.now();
      final weekNumber = await getCurrentWeekNumber(userId);
      
      final weightDiary = WeightDiary(
        id: '', // Will be set by Firestore
        userId: userId,
        week: weekNumber,
        weight: weight,
        unit: unit,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/weeks/{weekNumber}/weightDiaries/{entryId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('weightDiaries')
          .add(weightDiary.toFirestore());

      return weightDiary.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create weight diary entry: $e';
    }
  }

  // Get all weight diary entries for a specific week
  Future<List<WeightDiary>> getWeightDiariesForWeek(String userId, int weekNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('weightDiaries')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightDiary.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get weight diary entries for week $weekNumber: $e';
    }
  }

  // Get all weight diary entries for the current week
  Future<List<WeightDiary>> getCurrentWeekWeightDiaries(String userId) async {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      return await getWeightDiariesForWeek(userId, currentWeek);
    } catch (e) {
      throw 'Failed to get current week weight diary entries: $e';
    }
  }

  // Get all weight diary entries for all weeks
  Future<Map<int, List<WeightDiary>>> getAllWeightDiaries(String userId) async {
    try {
      final weeksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      final Map<int, List<WeightDiary>> allDiaries = {};

      for (final weekDoc in weeksSnapshot.docs) {
        final weekNumber = int.tryParse(weekDoc.id.replaceAll('week_', ''));
        if (weekNumber != null) {
          final diaries = await getWeightDiariesForWeek(userId, weekNumber);
          if (diaries.isNotEmpty) {
            allDiaries[weekNumber] = diaries;
          }
        }
      }

      return allDiaries;
    } catch (e) {
      throw 'Failed to get all weight diary entries: $e';
    }
  }

  // Get a specific weight diary entry
  Future<WeightDiary?> getWeightDiary(String userId, int weekNumber, String entryId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('weightDiaries')
          .doc(entryId)
          .get();

      if (doc.exists) {
        return WeightDiary.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get weight diary entry: $e';
    }
  }

  // Update a weight diary entry
  Future<void> updateWeightDiary({
    required String userId,
    required int weekNumber,
    required String entryId,
    required double weight,
    required String unit,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('weightDiaries')
          .doc(entryId)
          .update({
        'weight': weight,
        'unit': unit,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update weight diary entry: $e';
    }
  }

  // Delete a weight diary entry
  Future<void> deleteWeightDiary(String userId, int weekNumber, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('weightDiaries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete weight diary entry: $e';
    }
  }

  // Get weight diary entries for a date range
  Future<List<WeightDiary>> getWeightDiariesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allDiaries = await getAllWeightDiaries(userId);
      final List<WeightDiary> filteredDiaries = [];

      for (final diaries in allDiaries.values) {
        for (final diary in diaries) {
          if (diary.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
              diary.createdAt.isBefore(endDate.add(const Duration(days: 1)))) {
            filteredDiaries.add(diary);
          }
        }
      }

      // Sort by creation time, most recent first
      filteredDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredDiaries;
    } catch (e) {
      throw 'Failed to get weight diary entries in date range: $e';
    }
  }

  // Get statistics for a specific week
  Future<Map<String, dynamic>> getWeekStatistics(String userId, int weekNumber) async {
    try {
      final diaries = await getWeightDiariesForWeek(userId, weekNumber);
      
      if (diaries.isEmpty) {
        return {
          'totalEntries': 0,
          'averageWeight': null,
          'minWeight': null,
          'maxWeight': null,
          'weightChange': null,
        };
      }

      // Sort by creation date
      diaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Convert all weights to the same unit (kg) for calculations
      final weightsInKg = diaries.map((d) => d.convertWeight('kg')).toList();
      
      final stats = {
        'totalEntries': diaries.length,
        'averageWeight': weightsInKg.reduce((a, b) => a + b) / weightsInKg.length,
        'minWeight': weightsInKg.reduce((a, b) => a < b ? a : b),
        'maxWeight': weightsInKg.reduce((a, b) => a > b ? a : b),
        'weightChange': diaries.length > 1 
            ? weightsInKg.last - weightsInKg.first 
            : null,
        'firstEntry': diaries.first,
        'lastEntry': diaries.last,
      };

      return stats;
    } catch (e) {
      throw 'Failed to get week statistics: $e';
    }
  }

  // Get weight trend over multiple weeks
  Future<List<Map<String, dynamic>>> getWeightTrend(String userId, {int numberOfWeeks = 12}) async {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      final List<Map<String, dynamic>> trend = [];

      for (int week = currentWeek - numberOfWeeks + 1; week <= currentWeek; week++) {
        if (week > 0) {
          final diaries = await getWeightDiariesForWeek(userId, week);
          if (diaries.isNotEmpty) {
            // Get the latest entry for that week
            diaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final latestEntry = diaries.first;
            
            trend.add({
              'week': week,
              'weight': latestEntry.weight,
              'unit': latestEntry.unit,
              'date': latestEntry.createdAt,
            });
          }
        }
      }

      return trend;
    } catch (e) {
      throw 'Failed to get weight trend: $e';
    }
  }
}
