import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/urge_surfing.dart';
import '../core/services/urge_surfing_service.dart';

// Urge surfing service provider
final urgeSurfingServiceProvider = Provider<UrgeSurfingService>((ref) => UrgeSurfingService());

// User urge surfing exercises provider
final userUrgeSurfingExercisesProvider = StateNotifierProvider.family<UrgeSurfingNotifier, AsyncValue<List<UrgeSurfing>>, String>((ref, userId) {
  return UrgeSurfingNotifier(ref.read(urgeSurfingServiceProvider), userId);
});

// Individual urge surfing exercise provider
final urgeSurfingExerciseProvider = FutureProvider.family<UrgeSurfing?, ({String userId, String exerciseId})>((ref, params) async {
  final service = ref.read(urgeSurfingServiceProvider);
  return await service.getUrgeSurfingExercise(params.userId, params.exerciseId);
});

// Recent urge surfing exercises provider
final recentUrgeSurfingExercisesProvider = FutureProvider.family<List<UrgeSurfing>, ({String userId, int limit})>((ref, params) async {
  final service = ref.read(urgeSurfingServiceProvider);
  return await service.getRecentUrgeSurfingExercises(params.userId, limit: params.limit);
});

// Urge surfing exercise statistics provider
final urgeSurfingStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(urgeSurfingServiceProvider);
  return await service.getUrgeSurfingExerciseStatistics(userId);
});

// All user activities provider
final allUserActivitiesProvider = FutureProvider.family<List<AlternativeActivity>, String>((ref, userId) async {
  final service = ref.read(urgeSurfingServiceProvider);
  return await service.getAllUserActivities(userId);
});

// All ideal activities provider
final allIdealActivitiesProvider = FutureProvider.family<List<AlternativeActivity>, String>((ref, userId) async {
  final service = ref.read(urgeSurfingServiceProvider);
  return await service.getAllIdealActivities(userId);
});

class UrgeSurfingNotifier extends StateNotifier<AsyncValue<List<UrgeSurfing>>> {
  final UrgeSurfingService _urgeSurfingService;
  final String _userId;

  UrgeSurfingNotifier(this._urgeSurfingService, this._userId) : super(const AsyncValue.loading()) {
    loadUserExercises();
  }

  Future<void> loadUserExercises() async {
    try {
      state = const AsyncValue.loading();
      final exercises = await _urgeSurfingService.getUserUrgeSurfingExercises(_userId);
      state = AsyncValue.data(exercises);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<UrgeSurfing?> createExercise({
    required String title,
    required String notes,
    required List<AlternativeActivity> activities,
  }) async {
    try {
      final exercise = await _urgeSurfingService.createUrgeSurfingExercise(
        userId: _userId,
        title: title,
        notes: notes,
        activities: activities,
      );

      // Refresh current state
      await loadUserExercises();
      
      return exercise;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateExercise({
    required String exerciseId,
    required String title,
    required String notes,
    required List<AlternativeActivity> activities,
  }) async {
    try {
      await _urgeSurfingService.updateUrgeSurfingExercise(
        userId: _userId,
        exerciseId: exerciseId,
        title: title,
        notes: notes,
        activities: activities,
      );

      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _urgeSurfingService.deleteUrgeSurfingExercise(_userId, exerciseId);
      
      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshExercises() async {
    await loadUserExercises();
  }

  Future<List<UrgeSurfing>> searchExercises(String query) async {
    try {
      return await _urgeSurfingService.searchUrgeSurfingExercises(_userId, query);
    } catch (e) {
      return [];
    }
  }
}

// Provider for checking if user has any urge surfing exercises
final hasUrgeSurfingExercisesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(urgeSurfingServiceProvider);
  final exercises = await service.getUserUrgeSurfingExercises(userId);
  return exercises.isNotEmpty;
});

// Provider for getting the latest exercise
final latestUrgeSurfingExerciseProvider = FutureProvider.family<UrgeSurfing?, String>((ref, userId) async {
  final service = ref.read(urgeSurfingServiceProvider);
  final exercises = await service.getUserUrgeSurfingExercises(userId);
  return exercises.isNotEmpty ? exercises.first : null;
});

// Individual activity management notifier
class UserActivitiesNotifier extends StateNotifier<AsyncValue<List<AlternativeActivity>>> {
  final UrgeSurfingService _urgeSurfingService;
  final String _userId;

  UserActivitiesNotifier(this._urgeSurfingService, this._userId) : super(const AsyncValue.loading()) {
    loadUserActivities();
  }

  Future<void> loadUserActivities() async {
    try {
      state = const AsyncValue.loading();
      final activities = await _urgeSurfingService.getAllUserActivities(_userId);
      state = AsyncValue.data(activities);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<AlternativeActivity?> addActivity({
    required String name,
    required String description,
    required bool isActive,
    required bool isEnjoyable,
    required bool isRealistic,
  }) async {
    try {
      final activity = await _urgeSurfingService.addUserActivity(
        userId: _userId,
        name: name,
        description: description,
        isActive: isActive,
        isEnjoyable: isEnjoyable,
        isRealistic: isRealistic,
      );

      // Refresh current state
      await loadUserActivities();
      
      return activity;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateActivity({
    required String activityId,
    required String name,
    required String description,
    required bool isActive,
    required bool isEnjoyable,
    required bool isRealistic,
  }) async {
    try {
      await _urgeSurfingService.updateUserActivity(
        userId: _userId,
        activityId: activityId,
        name: name,
        description: description,
        isActive: isActive,
        isEnjoyable: isEnjoyable,
        isRealistic: isRealistic,
      );

      // Refresh current state
      await loadUserActivities();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _urgeSurfingService.deleteUserActivity(_userId, activityId);
      
      // Refresh current state
      await loadUserActivities();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshActivities() async {
    await loadUserActivities();
  }
}

// User activities provider
final userActivitiesProvider = StateNotifierProvider.family<UserActivitiesNotifier, AsyncValue<List<AlternativeActivity>>, String>((ref, userId) {
  return UserActivitiesNotifier(ref.read(urgeSurfingServiceProvider), userId);
});
