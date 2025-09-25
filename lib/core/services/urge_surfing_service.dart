import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/urge_surfing.dart';

class UrgeSurfingService {
  static final UrgeSurfingService _instance = UrgeSurfingService._internal();
  factory UrgeSurfingService() => _instance;
  UrgeSurfingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new urge surfing exercise
  Future<UrgeSurfing> createUrgeSurfingExercise({
    required String userId,
    required String title,
    required String notes,
    required List<AlternativeActivity> activities,
  }) async {
    try {
      final now = DateTime.now();
      
      final urgeSurfing = UrgeSurfing(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        notes: notes,
        activities: activities,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/exercises/urgeSurfing/exercises/{exerciseId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .add(urgeSurfing.toFirestore());

      return urgeSurfing.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create urge surfing exercise: $e';
    }
  }

  // Get all urge surfing exercises for a user
  Future<List<UrgeSurfing>> getUserUrgeSurfingExercises(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UrgeSurfing.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get urge surfing exercises: $e';
    }
  }

  // Get a specific urge surfing exercise by ID
  Future<UrgeSurfing?> getUrgeSurfingExercise(String userId, String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (doc.exists) {
        return UrgeSurfing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get urge surfing exercise: $e';
    }
  }

  // Update an urge surfing exercise
  Future<void> updateUrgeSurfingExercise({
    required String userId,
    required String exerciseId,
    required String title,
    required String notes,
    required List<AlternativeActivity> activities,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'title': title,
        'notes': notes,
        'activities': activities.map((activity) => activity.toMap()).toList(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update urge surfing exercise: $e';
    }
  }

  // Delete an urge surfing exercise
  Future<void> deleteUrgeSurfingExercise(String userId, String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to delete urge surfing exercise: $e';
    }
  }

  // Get recent urge surfing exercises
  Future<List<UrgeSurfing>> getRecentUrgeSurfingExercises(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('urgeSurfing')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UrgeSurfing.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get recent urge surfing exercises: $e';
    }
  }

  // Search urge surfing exercises
  Future<List<UrgeSurfing>> searchUrgeSurfingExercises(String userId, String query) async {
    try {
      final exercises = await getUserUrgeSurfingExercises(userId);
      return exercises.where((exercise) =>
          exercise.title.toLowerCase().contains(query.toLowerCase()) ||
          exercise.notes.toLowerCase().contains(query.toLowerCase()) ||
          exercise.activities.any((activity) =>
              activity.name.toLowerCase().contains(query.toLowerCase()) ||
              activity.description.toLowerCase().contains(query.toLowerCase())
          )
      ).toList();
    } catch (e) {
      throw 'Failed to search urge surfing exercises: $e';
    }
  }

  // Get urge surfing exercise statistics
  Future<Map<String, dynamic>> getUrgeSurfingExerciseStatistics(String userId) async {
    try {
      final exercises = await getUserUrgeSurfingExercises(userId);
      
      if (exercises.isEmpty) {
        return {
          'totalExercises': 0,
          'totalActivities': 0,
          'idealActivities': 0,
          'averageActivitiesPerExercise': 0.0,
          'averageIdealRate': 0.0,
          'mostRecentExercise': null,
        };
      }

      final totalActivities = exercises.fold<int>(0, (sum, exercise) => sum + exercise.totalActivities);
      final totalIdealActivities = exercises.fold<int>(0, (sum, exercise) => sum + exercise.idealActivities.length);
      final averageIdealRate = exercises.fold<double>(0, (sum, exercise) => sum + exercise.completionRate) / exercises.length;

      return {
        'totalExercises': exercises.length,
        'totalActivities': totalActivities,
        'idealActivities': totalIdealActivities,
        'averageActivitiesPerExercise': totalActivities / exercises.length,
        'averageIdealRate': averageIdealRate,
        'mostRecentExercise': exercises.isNotEmpty ? exercises.first : null,
      };
    } catch (e) {
      throw 'Failed to get urge surfing exercise statistics: $e';
    }
  }

  // Get all activities across all exercises for a user
  Future<List<AlternativeActivity>> getAllUserActivities(String userId) async {
    try {
      final exercises = await getUserUrgeSurfingExercises(userId);
      final allActivities = <AlternativeActivity>[];
      
      for (final exercise in exercises) {
        allActivities.addAll(exercise.activities);
      }
      
      return allActivities;
    } catch (e) {
      throw 'Failed to get all user activities: $e';
    }
  }

  // Get ideal activities across all exercises
  Future<List<AlternativeActivity>> getAllIdealActivities(String userId) async {
    try {
      final allActivities = await getAllUserActivities(userId);
      return allActivities.where((activity) => activity.meetsAllCriteria).toList();
    } catch (e) {
      throw 'Failed to get ideal activities: $e';
    }
  }
}
