import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/addressing_overconcern.dart';
import '../core/services/addressing_overconcern_service.dart';

// Addressing overconcern service provider
final addressingOverconcernServiceProvider = Provider<AddressingOverconcernService>((ref) => AddressingOverconcernService());

// User addressing overconcern exercises provider
final userAddressingOverconcernExercisesProvider = StateNotifierProvider.family<AddressingOverconcernNotifier, AsyncValue<List<AddressingOverconcern>>, String>((ref, userId) {
  return AddressingOverconcernNotifier(ref.read(addressingOverconcernServiceProvider), userId);
});

// Individual addressing overconcern exercise provider
final addressingOverconcernExerciseProvider = FutureProvider.family<AddressingOverconcern?, ({String userId, String exerciseId})>((ref, params) async {
  final service = ref.read(addressingOverconcernServiceProvider);
  return await service.getAddressingOverconcernExercise(params.userId, params.exerciseId);
});

// Recent addressing overconcern exercises provider
final recentAddressingOverconcernExercisesProvider = FutureProvider.family<List<AddressingOverconcern>, ({String userId, int limit})>((ref, params) async {
  final service = ref.read(addressingOverconcernServiceProvider);
  return await service.getRecentAddressingOverconcernExercises(params.userId, limit: params.limit);
});

// Addressing overconcern exercise statistics provider
final addressingOverconcernStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(addressingOverconcernServiceProvider);
  return await service.getAddressingOverconcernExerciseStatistics(userId);
});

class AddressingOverconcernNotifier extends StateNotifier<AsyncValue<List<AddressingOverconcern>>> {
  final AddressingOverconcernService _addressingOverconcernService;
  final String _userId;

  AddressingOverconcernNotifier(this._addressingOverconcernService, this._userId) : super(const AsyncValue.loading()) {
    loadUserExercises();
  }

  Future<void> loadUserExercises() async {
    try {
      state = const AsyncValue.loading();
      final exercises = await _addressingOverconcernService.getUserAddressingOverconcernExercises(_userId);
      state = AsyncValue.data(exercises);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<AddressingOverconcern?> createExercise({
    required List<ImportanceItem> importanceItems,
  }) async {
    try {
      final exercise = await _addressingOverconcernService.createAddressingOverconcernExercise(
        userId: _userId,
        importanceItems: importanceItems,
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
    required List<ImportanceItem> importanceItems,
  }) async {
    try {
      await _addressingOverconcernService.updateAddressingOverconcernExercise(
        userId: _userId,
        exerciseId: exerciseId,
        importanceItems: importanceItems,
      );

      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _addressingOverconcernService.deleteAddressingOverconcernExercise(_userId, exerciseId);
      
      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshExercises() async {
    await loadUserExercises();
  }

  Future<List<AddressingOverconcern>> searchExercises(String query) async {
    try {
      return await _addressingOverconcernService.searchAddressingOverconcernExercises(_userId, query);
    } catch (e) {
      return [];
    }
  }
}

// Provider for checking if user has any addressing overconcern exercises
final hasAddressingOverconcernExercisesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(addressingOverconcernServiceProvider);
  final exercises = await service.getUserAddressingOverconcernExercises(userId);
  return exercises.isNotEmpty;
});

// Provider for getting the latest exercise
final latestAddressingOverconcernExerciseProvider = FutureProvider.family<AddressingOverconcern?, String>((ref, userId) async {
  final service = ref.read(addressingOverconcernServiceProvider);
  final exercises = await service.getUserAddressingOverconcernExercises(userId);
  return exercises.isNotEmpty ? exercises.first : null;
});
