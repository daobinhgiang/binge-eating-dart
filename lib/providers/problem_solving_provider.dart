import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/problem_solving.dart';
import '../core/services/problem_solving_service.dart';

// Problem solving service provider
final problemSolvingServiceProvider = Provider<ProblemSolvingService>((ref) => ProblemSolvingService());

// User problem solving exercises provider
final userProblemSolvingExercisesProvider = StateNotifierProvider.family<ProblemSolvingNotifier, AsyncValue<List<ProblemSolving>>, String>((ref, userId) {
  return ProblemSolvingNotifier(ref.read(problemSolvingServiceProvider), userId);
});

// Individual problem solving exercise provider
final problemSolvingExerciseProvider = FutureProvider.family<ProblemSolving?, ({String userId, String exerciseId})>((ref, params) async {
  final service = ref.read(problemSolvingServiceProvider);
  return await service.getProblemSolvingExercise(params.userId, params.exerciseId);
});

// Problem solving statistics provider
final problemSolvingStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(problemSolvingServiceProvider);
  return await service.getProblemSolvingStatistics(userId);
});

// Recent problem solving exercises provider
final recentProblemSolvingExercisesProvider = FutureProvider.family<List<ProblemSolving>, ({String userId, int limit})>((ref, params) async {
  final service = ref.read(problemSolvingServiceProvider);
  return await service.getRecentProblemSolvingExercises(params.userId, limit: params.limit);
});

// Problem solving exercises in date range provider
final problemSolvingExercisesInDateRangeProvider = FutureProvider.family<List<ProblemSolving>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(problemSolvingServiceProvider);
  return await service.getProblemSolvingExercisesInDateRange(params.userId, params.startDate, params.endDate);
});

// Common problem themes provider
final commonProblemThemesProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final service = ref.read(problemSolvingServiceProvider);
  return await service.getCommonProblemThemes(userId);
});

class ProblemSolvingNotifier extends StateNotifier<AsyncValue<List<ProblemSolving>>> {
  final ProblemSolvingService _problemSolvingService;
  final String _userId;

  ProblemSolvingNotifier(this._problemSolvingService, this._userId) : super(const AsyncValue.loading()) {
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      state = const AsyncValue.loading();
      final exercises = await _problemSolvingService.getUserProblemSolvingExercises(_userId);
      state = AsyncValue.data(exercises);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<ProblemSolving?> createExercise({
    required String problemDescription,
    required List<String> specificProblems,
    required List<PotentialSolution> potentialSolutions,
    required List<String> chosenSolutionIds,
  }) async {
    try {
      final exercise = await _problemSolvingService.createProblemSolvingExercise(
        userId: _userId,
        problemDescription: problemDescription,
        specificProblems: specificProblems,
        potentialSolutions: potentialSolutions,
        chosenSolutionIds: chosenSolutionIds,
      );

      // Refresh current state
      await loadExercises();
      
      return exercise;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateExercise({
    required String exerciseId,
    required String problemDescription,
    required List<String> specificProblems,
    required List<PotentialSolution> potentialSolutions,
    required List<String> chosenSolutionIds,
  }) async {
    try {
      await _problemSolvingService.updateProblemSolvingExercise(
        userId: _userId,
        exerciseId: exerciseId,
        problemDescription: problemDescription,
        specificProblems: specificProblems,
        potentialSolutions: potentialSolutions,
        chosenSolutionIds: chosenSolutionIds,
      );

      // Refresh current state
      await loadExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _problemSolvingService.deleteProblemSolvingExercise(_userId, exerciseId);
      
      // Refresh current state
      await loadExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshExercises() async {
    await loadExercises();
  }

  Future<List<ProblemSolving>> searchExercises(String query) async {
    try {
      return await _problemSolvingService.searchProblemSolvingExercises(_userId, query);
    } catch (e) {
      return [];
    }
  }
}

// Provider for checking if user has any problem solving exercises
final hasProblemSolvingExercisesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(problemSolvingServiceProvider);
  final exercises = await service.getUserProblemSolvingExercises(userId);
  return exercises.isNotEmpty;
});

// Provider for today's problem solving exercises
final todayProblemSolvingExercisesProvider = FutureProvider.family<List<ProblemSolving>, String>((ref, userId) async {
  final service = ref.read(problemSolvingServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  return await service.getProblemSolvingExercisesInDateRange(userId, startOfDay, endOfDay);
});
