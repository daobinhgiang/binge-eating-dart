import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/money_diary.dart';
import 'dart:async';

class MoneyDiaryService {
  static final MoneyDiaryService _instance = MoneyDiaryService._internal();
  factory MoneyDiaryService() => _instance;
  MoneyDiaryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get current week number for a user
  Future<int> getCurrentWeekNumber(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final createdAt = userData['createdAt'] as int?;
        
        if (createdAt != null) {
          final userStartDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
          final now = DateTime.now();
          final daysDifference = now.difference(userStartDate).inDays;
          return (daysDifference / 7).floor() + 1;
        }
      }
      return 1; // Default to week 1 if no creation date found
    } catch (e) {
      return 1; // Default to week 1 on error
    }
  }

  // Create a new money diary entry
  Future<MoneyDiary> createMoneyDiary({
    required String userId,
    required double amount,
    required String currency,
    required String description,
    required DateTime spentAt,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final weekNumber = await getCurrentWeekNumber(userId);
      
      final moneyDiary = MoneyDiary(
        id: '', // Will be set by Firestore
        userId: userId,
        week: weekNumber,
        amount: amount,
        currency: currency,
        description: description,
        spentAt: spentAt,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/weeks/{weekNumber}/moneyDiaries/{entryId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('moneyDiaries')
          .add(moneyDiary.toFirestore());

      return moneyDiary.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create money diary entry: $e';
    }
  }

  // Get all money diary entries for a specific week
  Future<List<MoneyDiary>> getMoneyDiariesForWeek(String userId, int weekNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('moneyDiaries')
          .orderBy('spentAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoneyDiary.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get money diary entries for week $weekNumber: $e';
    }
  }

  // Get all money diary entries for the current week
  Future<List<MoneyDiary>> getCurrentWeekMoneyDiaries(String userId) async {
    final weekNumber = await getCurrentWeekNumber(userId);
    return getMoneyDiariesForWeek(userId, weekNumber);
  }

  // Get all money diary entries for a user (across all weeks)
  Future<List<MoneyDiary>> getAllMoneyDiaries(String userId) async {
    try {
      final weekDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      List<MoneyDiary> allEntries = [];

      for (final weekDoc in weekDocs.docs) {
        final moneyDiarySnapshot = await weekDoc.reference
            .collection('moneyDiaries')
            .orderBy('spentAt', descending: true)
            .get();

        final weekEntries = moneyDiarySnapshot.docs
            .map((doc) => MoneyDiary.fromFirestore(doc))
            .toList();

        allEntries.addAll(weekEntries);
      }

      // Sort all entries by spentAt date (most recent first)
      allEntries.sort((a, b) => b.spentAt.compareTo(a.spentAt));

      return allEntries;
    } catch (e) {
      throw 'Failed to get all money diary entries: $e';
    }
  }

  // Get total amount spent across all entries
  Future<double> getTotalSpent(String userId, {String? currency}) async {
    try {
      final allEntries = await getAllMoneyDiaries(userId);
      
      if (currency != null) {
        // Filter by specific currency
        return allEntries
            .where((entry) => entry.currency == currency)
            .fold<double>(0.0, (sum, entry) => sum + entry.amount);
      } else {
        // Sum all entries regardless of currency (assuming same currency for simplicity)
        return allEntries.fold<double>(0.0, (sum, entry) => sum + entry.amount);
      }
    } catch (e) {
      throw 'Failed to calculate total spent: $e';
    }
  }

  // Get total amount spent for current week
  Future<double> getCurrentWeekTotalSpent(String userId, {String? currency}) async {
    try {
      final currentWeekEntries = await getCurrentWeekMoneyDiaries(userId);
      
      if (currency != null) {
        // Filter by specific currency
        return currentWeekEntries
            .where((entry) => entry.currency == currency)
            .fold<double>(0.0, (sum, entry) => sum + entry.amount);
      } else {
        // Sum all entries regardless of currency
        return currentWeekEntries.fold<double>(0.0, (sum, entry) => sum + entry.amount);
      }
    } catch (e) {
      throw 'Failed to calculate current week total spent: $e';
    }
  }

  // Update an existing money diary entry
  Future<MoneyDiary> updateMoneyDiary(MoneyDiary moneyDiary) async {
    try {
      final now = DateTime.now();
      final updatedEntry = moneyDiary.copyWith(updatedAt: now);

      await _firestore
          .collection('users')
          .doc(moneyDiary.userId)
          .collection('weeks')
          .doc('week_${moneyDiary.week}')
          .collection('moneyDiaries')
          .doc(moneyDiary.id)
          .update(updatedEntry.toFirestore());

      return updatedEntry;
    } catch (e) {
      throw 'Failed to update money diary entry: $e';
    }
  }

  // Delete a money diary entry
  Future<void> deleteMoneyDiary(String userId, int week, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$week')
          .collection('moneyDiaries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete money diary entry: $e';
    }
  }

  // Get spending statistics by category
  Future<Map<String, double>> getSpendingByCategory(String userId, {String? currency}) async {
    try {
      final allEntries = await getAllMoneyDiaries(userId);
      final Map<String, double> categoryTotals = {};

      for (final entry in allEntries) {
        if (currency == null || entry.currency == currency) {
          categoryTotals[entry.description] = 
              (categoryTotals[entry.description] ?? 0.0) + entry.amount;
        }
      }

      return categoryTotals;
    } catch (e) {
      throw 'Failed to get spending by category: $e';
    }
  }

  // Stream all money diaries in real-time
  Stream<List<MoneyDiary>> streamAllMoneyDiaries(String userId) async* {
    try {
      final currentWeek = await getCurrentWeekNumber(userId);
      
      // Create a stream that combines current week real-time updates with historical data
      await for (final currentWeekSnapshot in _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$currentWeek')
          .collection('moneyDiaries')
          .orderBy('spentAt', descending: true)
          .snapshots()) {
        
        // Get current week entries from snapshot
        final currentWeekEntries = currentWeekSnapshot.docs
            .map((doc) => MoneyDiary.fromFirestore(doc))
            .toList();
        
        // Get historical entries (previous weeks)
        final historicalEntries = <MoneyDiary>[];
        
        for (int week = 1; week < currentWeek; week++) {
          try {
            final weekEntries = await getMoneyDiariesForWeek(userId, week);
            historicalEntries.addAll(weekEntries);
          } catch (e) {
            // Week might not exist, continue
          }
        }
        
        // Combine and sort all entries
        final allEntries = [...historicalEntries, ...currentWeekEntries];
        allEntries.sort((a, b) => b.spentAt.compareTo(a.spentAt));
        
        yield allEntries;
      }
    } catch (e) {
      throw 'Failed to stream money diaries: $e';
    }
  }

  // Stream total spent in real-time
  Stream<double> streamTotalSpent(String userId, {String? currency}) async* {
    await for (final allEntries in streamAllMoneyDiaries(userId)) {
      if (currency != null) {
        yield allEntries
            .where((entry) => entry.currency == currency)
            .fold<double>(0.0, (sum, entry) => sum + entry.amount);
      } else {
        yield allEntries.fold<double>(0.0, (sum, entry) => sum + entry.amount);
      }
    }
  }
}
