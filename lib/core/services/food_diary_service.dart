import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_diary.dart';

class FoodDiaryService {
  static final FoodDiaryService _instance = FoodDiaryService._internal();
  factory FoodDiaryService() => _instance;
  FoodDiaryService._internal();

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

  // Create a new food diary entry
  Future<FoodDiary> createFoodDiary({
    required String userId,
    required String foodAndDrinks,
    required DateTime mealTime,
    required String location,
    String? customLocation,
    required bool isBinge,
    required String purgeMethod,
    required String contextAndComments,
  }) async {
    try {
      final now = DateTime.now();
      final weekNumber = await getCurrentWeekNumber(userId);
      
      final foodDiary = FoodDiary(
        id: '', // Will be set by Firestore
        userId: userId,
        week: weekNumber,
        foodAndDrinks: foodAndDrinks,
        mealTime: mealTime,
        location: location,
        customLocation: customLocation,
        isBinge: isBinge,
        purgeMethod: purgeMethod,
        contextAndComments: contextAndComments,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/weeks/{weekNumber}/foodDiaries/{entryId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('foodDiaries')
          .add(foodDiary.toFirestore());

      return foodDiary.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create food diary entry: $e';
    }
  }

  // Get all food diary entries for a specific week
  Future<List<FoodDiary>> getFoodDiariesForWeek(String userId, int weekNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('foodDiaries')
          .orderBy('mealTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FoodDiary.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get food diary entries for week $weekNumber: $e';
    }
  }

  // Get all food diary entries for the current week
  Future<List<FoodDiary>> getCurrentWeekFoodDiaries(String userId) async {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      return await getFoodDiariesForWeek(userId, currentWeek);
    } catch (e) {
      throw 'Failed to get current week food diary entries: $e';
    }
  }

  // Get all food diary entries for all weeks
  Future<Map<int, List<FoodDiary>>> getAllFoodDiaries(String userId) async {
    try {
      final weeksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      final Map<int, List<FoodDiary>> allDiaries = {};

      for (final weekDoc in weeksSnapshot.docs) {
        final weekNumber = int.tryParse(weekDoc.id.replaceAll('week_', ''));
        if (weekNumber != null) {
          final diaries = await getFoodDiariesForWeek(userId, weekNumber);
          if (diaries.isNotEmpty) {
            allDiaries[weekNumber] = diaries;
          }
        }
      }

      return allDiaries;
    } catch (e) {
      throw 'Failed to get all food diary entries: $e';
    }
  }

  // Get a specific food diary entry
  Future<FoodDiary?> getFoodDiary(String userId, int weekNumber, String entryId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('foodDiaries')
          .doc(entryId)
          .get();

      if (doc.exists) {
        return FoodDiary.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get food diary entry: $e';
    }
  }

  // Update a food diary entry
  Future<void> updateFoodDiary({
    required String userId,
    required int weekNumber,
    required String entryId,
    required String foodAndDrinks,
    required DateTime mealTime,
    required String location,
    String? customLocation,
    required bool isBinge,
    required String purgeMethod,
    required String contextAndComments,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('foodDiaries')
          .doc(entryId)
          .update({
        'foodAndDrinks': foodAndDrinks,
        'mealTime': mealTime.millisecondsSinceEpoch,
        'location': location,
        'customLocation': customLocation,
        'isBinge': isBinge,
        'purgeMethod': purgeMethod,
        'contextAndComments': contextAndComments,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update food diary entry: $e';
    }
  }

  // Delete a food diary entry
  Future<void> deleteFoodDiary(String userId, int weekNumber, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('foodDiaries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete food diary entry: $e';
    }
  }

  // Get food diary entries for a date range
  Future<List<FoodDiary>> getFoodDiariesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allDiaries = await getAllFoodDiaries(userId);
      final List<FoodDiary> filteredDiaries = [];

      for (final diaries in allDiaries.values) {
        for (final diary in diaries) {
          if (diary.mealTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
              diary.mealTime.isBefore(endDate.add(const Duration(days: 1)))) {
            filteredDiaries.add(diary);
          }
        }
      }

      // Sort by meal time, most recent first
      filteredDiaries.sort((a, b) => b.mealTime.compareTo(a.mealTime));

      return filteredDiaries;
    } catch (e) {
      throw 'Failed to get food diary entries in date range: $e';
    }
  }

  // Get statistics for a specific week
  Future<Map<String, dynamic>> getWeekStatistics(String userId, int weekNumber) async {
    try {
      final diaries = await getFoodDiariesForWeek(userId, weekNumber);
      
      final stats = {
        'totalEntries': diaries.length,
        'bingeEpisodes': diaries.where((d) => d.isBinge).length,
        'vomitingEpisodes': diaries.where((d) => d.purgeMethod == 'vomit' || d.purgeMethod == 'both').length,
        'laxativeUse': diaries.where((d) => d.purgeMethod == 'laxatives' || d.purgeMethod == 'both').length,
        'mostCommonLocation': _getMostCommonLocation(diaries),
      };

      return stats;
    } catch (e) {
      throw 'Failed to get week statistics: $e';
    }
  }

  String _getMostCommonLocation(List<FoodDiary> diaries) {
    if (diaries.isEmpty) return 'N/A';
    
    final Map<String, int> locationCounts = {};
    for (final diary in diaries) {
      final location = diary.displayLocation;
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }
    
    return locationCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
