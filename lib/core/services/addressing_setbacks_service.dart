import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/addressing_setbacks.dart';

class AddressingSetbacksService {
  static final AddressingSetbacksService _instance = AddressingSetbacksService._internal();
  factory AddressingSetbacksService() => _instance;
  AddressingSetbacksService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new addressing setbacks exercise
  Future<AddressingSetbacks> createAddressingSetbacksExercise({
    required String userId,
    required String problemCause,
    required String trigger,
    required String addressPlan,
    required DateTime setbackDate,
  }) async {
    try {
      final now = DateTime.now();
      
      final exercise = AddressingSetbacks(
        id: '', // Will be set by Firestore
        userId: userId,
        problemCause: problemCause,
        trigger: trigger,
        addressPlan: addressPlan,
        setbackDate: setbackDate,
        createdAt: now,
        updatedAt: now,
        isComplete: problemCause.trim().isNotEmpty && 
                   trigger.trim().isNotEmpty && 
                   addressPlan.trim().isNotEmpty,
      );

      // Store in Firestore with structure: users/{userId}/exercises/addressingSetbacks/exercises/{exerciseId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .add(exercise.toFirestore());

      return exercise.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create addressing setbacks exercise: $e';
    }
  }

  // Get all addressing setbacks exercises for a user
  Future<List<AddressingSetbacks>> getUserAddressingSetbacksExercises(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressingSetbacks.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get addressing setbacks exercises: $e';
    }
  }

  // Get a specific addressing setbacks exercise by ID
  Future<AddressingSetbacks?> getAddressingSetbacksExercise(String userId, String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (doc.exists) {
        return AddressingSetbacks.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get addressing setbacks exercise: $e';
    }
  }

  // Update an addressing setbacks exercise
  Future<void> updateAddressingSetbacksExercise({
    required String userId,
    required String exerciseId,
    required String problemCause,
    required String trigger,
    required String addressPlan,
    required DateTime setbackDate,
  }) async {
    try {
      final isComplete = problemCause.trim().isNotEmpty && 
                        trigger.trim().isNotEmpty && 
                        addressPlan.trim().isNotEmpty;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'problemCause': problemCause,
        'trigger': trigger,
        'addressPlan': addressPlan,
        'setbackDate': setbackDate.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isComplete': isComplete,
      });
    } catch (e) {
      throw 'Failed to update addressing setbacks exercise: $e';
    }
  }

  // Delete an addressing setbacks exercise
  Future<void> deleteAddressingSetbacksExercise(String userId, String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to delete addressing setbacks exercise: $e';
    }
  }

  // Get recent addressing setbacks exercises
  Future<List<AddressingSetbacks>> getRecentAddressingSetbacksExercises(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressingSetbacks.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get recent addressing setbacks exercises: $e';
    }
  }

  // Search addressing setbacks exercises
  Future<List<AddressingSetbacks>> searchAddressingSetbacksExercises(String userId, String query) async {
    try {
      final exercises = await getUserAddressingSetbacksExercises(userId);
      return exercises.where((exercise) =>
          exercise.problemCause.toLowerCase().contains(query.toLowerCase()) ||
          exercise.trigger.toLowerCase().contains(query.toLowerCase()) ||
          exercise.addressPlan.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw 'Failed to search addressing setbacks exercises: $e';
    }
  }

  // Get addressing setbacks exercise statistics
  Future<Map<String, dynamic>> getAddressingSetbacksExerciseStatistics(String userId) async {
    try {
      final exercises = await getUserAddressingSetbacksExercises(userId);
      
      if (exercises.isEmpty) {
        return {
          'totalExercises': 0,
          'completedExercises': 0,
          'recentSetbacks': 0,
          'averageTimeBetweenSetbacks': 0.0,
          'mostRecentExercise': null,
        };
      }

      final completedExercises = exercises.where((e) => e.isComplete).length;
      final now = DateTime.now();
      final recentSetbacks = exercises.where((e) => 
          now.difference(e.setbackDate).inDays <= 30
      ).length;

      // Calculate average time between setbacks
      double averageTimeBetweenSetbacks = 0.0;
      if (exercises.length > 1) {
        final sortedByDate = exercises.toList()..sort((a, b) => a.setbackDate.compareTo(b.setbackDate));
        double totalDays = 0.0;
        for (int i = 1; i < sortedByDate.length; i++) {
          totalDays += sortedByDate[i].setbackDate.difference(sortedByDate[i-1].setbackDate).inDays;
        }
        averageTimeBetweenSetbacks = totalDays / (sortedByDate.length - 1);
      }

      return {
        'totalExercises': exercises.length,
        'completedExercises': completedExercises,
        'recentSetbacks': recentSetbacks,
        'averageTimeBetweenSetbacks': averageTimeBetweenSetbacks,
        'mostRecentExercise': exercises.isNotEmpty ? exercises.first : null,
      };
    } catch (e) {
      throw 'Failed to get addressing setbacks exercise statistics: $e';
    }
  }

  // Get setbacks by date range
  Future<List<AddressingSetbacks>> getSetbacksByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingSetbacks')
          .collection('exercises')
          .where('setbackDate', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('setbackDate', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('setbackDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressingSetbacks.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get setbacks by date range: $e';
    }
  }
}

