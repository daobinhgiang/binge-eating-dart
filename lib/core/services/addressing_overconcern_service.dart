import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/addressing_overconcern.dart';

class AddressingOverconcernService {
  static final AddressingOverconcernService _instance = AddressingOverconcernService._internal();
  factory AddressingOverconcernService() => _instance;
  AddressingOverconcernService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new addressing overconcern exercise
  Future<AddressingOverconcern> createAddressingOverconcernExercise({
    required String userId,
    required List<ImportanceItem> importanceItems,
  }) async {
    try {
      final now = DateTime.now();
      
      final exercise = AddressingOverconcern(
        id: '', // Will be set by Firestore
        userId: userId,
        importanceItems: importanceItems,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/exercises/addressingOverconcern/exercises/{exerciseId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .add(exercise.toFirestore());

      return exercise.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create addressing overconcern exercise: $e';
    }
  }

  // Get all addressing overconcern exercises for a user
  Future<List<AddressingOverconcern>> getUserAddressingOverconcernExercises(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressingOverconcern.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get addressing overconcern exercises: $e';
    }
  }

  // Get a specific addressing overconcern exercise by ID
  Future<AddressingOverconcern?> getAddressingOverconcernExercise(String userId, String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (doc.exists) {
        return AddressingOverconcern.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get addressing overconcern exercise: $e';
    }
  }

  // Update an addressing overconcern exercise
  Future<void> updateAddressingOverconcernExercise({
    required String userId,
    required String exerciseId,
    required List<ImportanceItem> importanceItems,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'importanceItems': importanceItems.map((item) => item.toMap()).toList(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update addressing overconcern exercise: $e';
    }
  }

  // Delete an addressing overconcern exercise
  Future<void> deleteAddressingOverconcernExercise(String userId, String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to delete addressing overconcern exercise: $e';
    }
  }

  // Get recent addressing overconcern exercises
  Future<List<AddressingOverconcern>> getRecentAddressingOverconcernExercises(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('addressingOverconcern')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressingOverconcern.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get recent addressing overconcern exercises: $e';
    }
  }

  // Search addressing overconcern exercises
  Future<List<AddressingOverconcern>> searchAddressingOverconcernExercises(String userId, String query) async {
    try {
      final exercises = await getUserAddressingOverconcernExercises(userId);
      return exercises.where((exercise) =>
          exercise.importanceItems.any((item) =>
              item.description.toLowerCase().contains(query.toLowerCase())
          )
      ).toList();
    } catch (e) {
      throw 'Failed to search addressing overconcern exercises: $e';
    }
  }

  // Get addressing overconcern exercise statistics
  Future<Map<String, dynamic>> getAddressingOverconcernExerciseStatistics(String userId) async {
    try {
      final exercises = await getUserAddressingOverconcernExercises(userId);
      
      if (exercises.isEmpty) {
        return {
          'totalExercises': 0,
          'totalItems': 0,
          'averageItemsPerExercise': 0.0,
          'averageBalance': 0.0,
          'mostRecentExercise': null,
        };
      }

      final totalItems = exercises.fold<int>(0, (sum, exercise) => sum + exercise.totalItems);
      final averageBalance = exercises.fold<double>(0, (sum, exercise) => sum + (exercise.isBalanced ? 1 : 0)) / exercises.length;

      return {
        'totalExercises': exercises.length,
        'totalItems': totalItems,
        'averageItemsPerExercise': totalItems / exercises.length,
        'averageBalance': averageBalance,
        'mostRecentExercise': exercises.isNotEmpty ? exercises.first : null,
      };
    } catch (e) {
      throw 'Failed to get addressing overconcern exercise statistics: $e';
    }
  }
}
