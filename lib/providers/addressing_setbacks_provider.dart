import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/addressing_setbacks.dart';
import '../core/services/addressing_setbacks_service.dart';

// Addressing setbacks service provider
final addressingSetbacksServiceProvider = Provider<AddressingSetbacksService>((ref) => AddressingSetbacksService());

// User addressing setbacks exercises provider
final userAddressingSetbacksExercisesProvider = StateNotifierProvider.family<AddressingSetbacksNotifier, AsyncValue<List<AddressingSetbacks>>, String>((ref, userId) {
  return AddressingSetbacksNotifier(ref.read(addressingSetbacksServiceProvider), userId);
});

// Individual addressing setbacks exercise provider
final addressingSetbacksExerciseProvider = FutureProvider.family<AddressingSetbacks?, ({String userId, String exerciseId})>((ref, params) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  return await service.getAddressingSetbacksExercise(params.userId, params.exerciseId);
});

// Recent addressing setbacks exercises provider
final recentAddressingSetbacksExercisesProvider = FutureProvider.family<List<AddressingSetbacks>, ({String userId, int limit})>((ref, params) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  return await service.getRecentAddressingSetbacksExercises(params.userId, limit: params.limit);
});

// Addressing setbacks exercise statistics provider
final addressingSetbacksStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  return await service.getAddressingSetbacksExerciseStatistics(userId);
});

// Setbacks by date range provider
final setbacksByDateRangeProvider = FutureProvider.family<List<AddressingSetbacks>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  return await service.getSetbacksByDateRange(params.userId, params.startDate, params.endDate);
});

class AddressingSetbacksNotifier extends StateNotifier<AsyncValue<List<AddressingSetbacks>>> {
  final AddressingSetbacksService _addressingSetbacksService;
  final String _userId;

  AddressingSetbacksNotifier(this._addressingSetbacksService, this._userId) : super(const AsyncValue.loading()) {
    loadUserExercises();
  }

  Future<void> loadUserExercises() async {
    try {
      state = const AsyncValue.loading();
      final exercises = await _addressingSetbacksService.getUserAddressingSetbacksExercises(_userId);
      state = AsyncValue.data(exercises);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<AddressingSetbacks?> createExercise({
    required String problemCause,
    required String trigger,
    required String addressPlan,
    required DateTime setbackDate,
  }) async {
    try {
      final exercise = await _addressingSetbacksService.createAddressingSetbacksExercise(
        userId: _userId,
        problemCause: problemCause,
        trigger: trigger,
        addressPlan: addressPlan,
        setbackDate: setbackDate,
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
    required String problemCause,
    required String trigger,
    required String addressPlan,
    required DateTime setbackDate,
  }) async {
    try {
      await _addressingSetbacksService.updateAddressingSetbacksExercise(
        userId: _userId,
        exerciseId: exerciseId,
        problemCause: problemCause,
        trigger: trigger,
        addressPlan: addressPlan,
        setbackDate: setbackDate,
      );

      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _addressingSetbacksService.deleteAddressingSetbacksExercise(_userId, exerciseId);
      
      // Refresh current state
      await loadUserExercises();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshExercises() async {
    await loadUserExercises();
  }

  Future<List<AddressingSetbacks>> searchExercises(String query) async {
    try {
      return await _addressingSetbacksService.searchAddressingSetbacksExercises(_userId, query);
    } catch (e) {
      return [];
    }
  }
}

// Provider for checking if user has any addressing setbacks exercises
final hasAddressingSetbacksExercisesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  final exercises = await service.getUserAddressingSetbacksExercises(userId);
  return exercises.isNotEmpty;
});

// Provider for getting the latest exercise
final latestAddressingSetbacksExerciseProvider = FutureProvider.family<AddressingSetbacks?, String>((ref, userId) async {
  final service = ref.read(addressingSetbacksServiceProvider);
  final exercises = await service.getUserAddressingSetbacksExercises(userId);
  return exercises.isNotEmpty ? exercises.first : null;
});

