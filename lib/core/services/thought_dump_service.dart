import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/thought_dump.dart';
import 'food_diary_service.dart';

class ThoughtDumpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FoodDiaryService _foodDiaryService = FoodDiaryService();

  // Create a new thought dump entry
  Future<ThoughtDump> createThoughtDump({
    required String userId,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final weekNumber = await _foodDiaryService.getCurrentWeekNumber(userId);
      
      final thoughtDump = ThoughtDump(
        id: '', // Will be set by Firestore
        userId: userId,
        week: weekNumber,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/weeks/{weekNumber}/thoughtDumps/{entryId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('thoughtDumps')
          .add(thoughtDump.toFirestore());

      return thoughtDump.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create thought dump entry: $e';
    }
  }

  // Get all thought dump entries for a specific week
  Future<List<ThoughtDump>> getThoughtDumpsForWeek(String userId, int weekNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('thoughtDumps')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ThoughtDump.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get thought dump entries for week $weekNumber: $e';
    }
  }

  // Get all thought dump entries for the current week
  Future<List<ThoughtDump>> getCurrentWeekThoughtDumps(String userId) async {
    final weekNumber = await _foodDiaryService.getCurrentWeekNumber(userId);
    return getThoughtDumpsForWeek(userId, weekNumber);
  }

  // Get all thought dump entries for a user (across all weeks)
  Future<List<ThoughtDump>> getAllThoughtDumps(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      final allThoughtDumps = <ThoughtDump>[];
      
      for (final weekDoc in querySnapshot.docs) {
        final thoughtDumpsSnapshot = await weekDoc.reference
            .collection('thoughtDumps')
            .orderBy('createdAt', descending: true)
            .get();
        
        allThoughtDumps.addAll(
          thoughtDumpsSnapshot.docs
              .map((doc) => ThoughtDump.fromFirestore(doc))
              .toList()
        );
      }

      // Sort all entries by creation date (most recent first)
      allThoughtDumps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return allThoughtDumps;
    } catch (e) {
      throw 'Failed to get all thought dump entries: $e';
    }
  }

  // Update a thought dump entry
  Future<void> updateThoughtDump({
    required String userId,
    required int weekNumber,
    required String entryId,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('thoughtDumps')
          .doc(entryId)
          .update({
        'content': content,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update thought dump entry: $e';
    }
  }

  // Delete a thought dump entry
  Future<void> deleteThoughtDump(String userId, int weekNumber, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('thoughtDumps')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete thought dump entry: $e';
    }
  }

  // Get thought dump entries for a date range
  Future<List<ThoughtDump>> getThoughtDumpsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allThoughtDumps = await getAllThoughtDumps(userId);
      
      return allThoughtDumps.where((thoughtDump) {
        return thoughtDump.createdAt.isAfter(startDate) && 
               thoughtDump.createdAt.isBefore(endDate);
      }).toList();
    } catch (e) {
      throw 'Failed to get thought dump entries in date range: $e';
    }
  }
}
