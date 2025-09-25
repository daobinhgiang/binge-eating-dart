import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weight_diary.dart';
import '../core/services/weight_diary_service.dart';

// Weight diary service provider
final weightDiaryServiceProvider = Provider<WeightDiaryService>((ref) => WeightDiaryService());

// Current week weight diaries provider
final currentWeekWeightDiariesProvider = StateNotifierProvider.family<WeightDiaryNotifier, AsyncValue<List<WeightDiary>>, String>((ref, userId) {
  return WeightDiaryNotifier(ref.read(weightDiaryServiceProvider), userId);
});

// Weight diaries for specific week provider
final weekWeightDiariesProvider = FutureProvider.family<List<WeightDiary>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightDiariesForWeek(params.userId, params.weekNumber);
});

// All weight diaries provider
final allWeightDiariesProvider = FutureProvider.family<Map<int, List<WeightDiary>>, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getAllWeightDiaries(userId);
});

// Week weight statistics provider
final weekWeightStatisticsProvider = FutureProvider.family<Map<String, dynamic>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeekStatistics(params.userId, params.weekNumber);
});

// Individual weight diary entry provider
final weightDiaryEntryProvider = FutureProvider.family<WeightDiary?, ({String userId, int weekNumber, String entryId})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightDiary(params.userId, params.weekNumber, params.entryId);
});

// Weight trend provider
final weightTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String userId, int numberOfWeeks})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightTrend(params.userId, numberOfWeeks: params.numberOfWeeks);
});

class WeightDiaryNotifier extends StateNotifier<AsyncValue<List<WeightDiary>>> {
  final WeightDiaryService _weightDiaryService;
  final String _userId;

  WeightDiaryNotifier(this._weightDiaryService, this._userId) : super(const AsyncValue.loading()) {
    loadCurrentWeekEntries();
  }

  Future<void> loadCurrentWeekEntries() async {
    try {
      state = const AsyncValue.loading();
      final entries = await _weightDiaryService.getCurrentWeekWeightDiaries(_userId);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadWeekEntries(int weekNumber) async {
    try {
      state = const AsyncValue.loading();
      final entries = await _weightDiaryService.getWeightDiariesForWeek(_userId, weekNumber);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<WeightDiary?> createEntry({
    required double weight,
    required String unit,
  }) async {
    try {
      final entry = await _weightDiaryService.createWeightDiary(
        userId: _userId,
        weight: weight,
        unit: unit,
      );

      // Refresh current state
      await loadCurrentWeekEntries();
      
      return entry;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateEntry({
    required int weekNumber,
    required String entryId,
    required double weight,
    required String unit,
  }) async {
    try {
      await _weightDiaryService.updateWeightDiary(
        userId: _userId,
        weekNumber: weekNumber,
        entryId: entryId,
        weight: weight,
        unit: unit,
      );

      // Refresh current state
      await loadCurrentWeekEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(int weekNumber, String entryId) async {
    try {
      await _weightDiaryService.deleteWeightDiary(_userId, weekNumber, entryId);
      
      // Refresh current state
      await loadCurrentWeekEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshEntries() async {
    await loadCurrentWeekEntries();
  }

  Future<void> refreshWeekEntries(int weekNumber) async {
    await loadWeekEntries(weekNumber);
  }
}

// Helper provider for getting entries in date range
final weightDiariesInDateRangeProvider = FutureProvider.family<List<WeightDiary>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightDiariesInDateRange(params.userId, params.startDate, params.endDate);
});

// Provider for getting today's entries
final todayWeightDiariesProvider = FutureProvider.family<List<WeightDiary>, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  return await service.getWeightDiariesInDateRange(userId, startOfDay, endOfDay);
});

// Provider for checking if user has any weight diary entries
final hasWeightDiaryEntriesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  final allDiaries = await service.getAllWeightDiaries(userId);
  return allDiaries.isNotEmpty && allDiaries.values.any((entries) => entries.isNotEmpty);
});

// Provider for latest weight entry across all weeks
final latestWeightEntryProvider = FutureProvider.family<WeightDiary?, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  final allDiaries = await service.getAllWeightDiaries(userId);
  
  WeightDiary? latestEntry;
  
  for (final entries in allDiaries.values) {
    for (final entry in entries) {
      if (latestEntry == null || entry.createdAt.isAfter(latestEntry.createdAt)) {
        latestEntry = entry;
      }
    }
  }
  
  return latestEntry;
});
