import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/problem_solving.dart';

class ProblemSolvingService {
  static final ProblemSolvingService _instance = ProblemSolvingService._internal();
  factory ProblemSolvingService() => _instance;
  ProblemSolvingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new problem solving exercise
  Future<ProblemSolving> createProblemSolvingExercise({
    required String userId,
    required String problemDescription,
    required List<String> specificProblems,
    required List<PotentialSolution> potentialSolutions,
    required List<String> chosenSolutionIds,
  }) async {
    try {
      final now = DateTime.now();
      
      final problemSolving = ProblemSolving(
        id: '', // Will be set by Firestore
        userId: userId,
        problemDescription: problemDescription,
        specificProblems: specificProblems,
        potentialSolutions: potentialSolutions,
        chosenSolutionIds: chosenSolutionIds,
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/exercises/problemSolving/exercises/{exerciseId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .add(problemSolving.toFirestore());

      return problemSolving.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create problem solving exercise: $e';
    }
  }

  // Get all problem solving exercises for a user
  Future<List<ProblemSolving>> getUserProblemSolvingExercises(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProblemSolving.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get problem solving exercises: $e';
    }
  }

  // Get a specific problem solving exercise by ID
  Future<ProblemSolving?> getProblemSolvingExercise(String userId, String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (doc.exists) {
        return ProblemSolving.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get problem solving exercise: $e';
    }
  }

  // Update a problem solving exercise
  Future<void> updateProblemSolvingExercise({
    required String userId,
    required String exerciseId,
    required String problemDescription,
    required List<String> specificProblems,
    required List<PotentialSolution> potentialSolutions,
    required List<String> chosenSolutionIds,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'problemDescription': problemDescription,
        'specificProblems': specificProblems,
        'potentialSolutions': potentialSolutions.map((solution) => solution.toMap()).toList(),
        'chosenSolutionIds': chosenSolutionIds,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update problem solving exercise: $e';
    }
  }

  // Delete a problem solving exercise
  Future<void> deleteProblemSolvingExercise(String userId, String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to delete problem solving exercise: $e';
    }
  }

  // Get problem solving exercises for a date range
  Future<List<ProblemSolving>> getProblemSolvingExercisesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .where('createdAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('createdAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProblemSolving.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get problem solving exercises in date range: $e';
    }
  }

  // Get statistics for problem solving exercises
  Future<Map<String, dynamic>> getProblemSolvingStatistics(String userId) async {
    try {
      final exercises = await getUserProblemSolvingExercises(userId);
      
      if (exercises.isEmpty) {
        return {
          'totalExercises': 0,
          'completedExercises': 0,
          'averageProblemsPerExercise': 0.0,
          'averageSolutionsPerExercise': 0.0,
          'completionRate': 0.0,
        };
      }

      final completedExercises = exercises.where((e) => e.isComplete).length;
      final totalProblems = exercises.fold<int>(0, (total, e) => total + e.specificProblems.length);
      final totalSolutions = exercises.fold<int>(0, (total, e) => total + e.potentialSolutions.length);

      final stats = {
        'totalExercises': exercises.length,
        'completedExercises': completedExercises,
        'averageProblemsPerExercise': totalProblems / exercises.length,
        'averageSolutionsPerExercise': totalSolutions / exercises.length,
        'completionRate': completedExercises / exercises.length,
        'lastExerciseDate': exercises.isNotEmpty ? exercises.first.createdAt : null,
      };

      return stats;
    } catch (e) {
      throw 'Failed to get problem solving statistics: $e';
    }
  }

  // Get recent problem solving exercises
  Future<List<ProblemSolving>> getRecentProblemSolvingExercises(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('problemSolving')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProblemSolving.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get recent problem solving exercises: $e';
    }
  }

  // Search problem solving exercises by problem description
  Future<List<ProblemSolving>> searchProblemSolvingExercises(String userId, String query) async {
    try {
      final allExercises = await getUserProblemSolvingExercises(userId);
      return allExercises
          .where((exercise) => 
              exercise.problemDescription.toLowerCase().contains(query.toLowerCase()) ||
              exercise.specificProblems.any((problem) => problem.toLowerCase().contains(query.toLowerCase())) ||
              exercise.potentialSolutions.any((solution) => 
                  solution.description.toLowerCase().contains(query.toLowerCase()) ||
                  solution.implications.toLowerCase().contains(query.toLowerCase())
              )
          )
          .toList();
    } catch (e) {
      throw 'Failed to search problem solving exercises: $e';
    }
  }

  // Get common problem themes
  Future<Map<String, int>> getCommonProblemThemes(String userId) async {
    try {
      final exercises = await getUserProblemSolvingExercises(userId);
      final Map<String, int> themes = {};

      for (final exercise in exercises) {
        // Simple keyword extraction from problem descriptions
        final words = exercise.problemDescription.toLowerCase().split(' ');
        for (final word in words) {
          if (word.length > 3) { // Only consider words longer than 3 characters
            themes[word] = (themes[word] ?? 0) + 1;
          }
        }
      }

      // Sort by frequency and return top themes
      final sortedEntries = themes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sortedEntries.take(10));
    } catch (e) {
      throw 'Failed to get common problem themes: $e';
    }
  }
}
