import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weight_diary.dart';
import '../core/services/weight_diary_service.dart';
import '../core/services/firebase_analytics_service.dart';

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

// Flat list of all weight entries, sorted by time ascending
final allWeightEntriesProvider = FutureProvider.family<List<WeightDiary>, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getAllWeightEntries(userId);
});

// Helper provider: entries in date range
final weightDiariesInDateRangeProvider = FutureProvider.family<List<WeightDiary>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightDiariesInDateRange(params.userId, params.startDate, params.endDate);
});

// Helper provider: entries in the last 24 hours
final last24hWeightDiariesProvider = FutureProvider.family<List<WeightDiary>, String>((ref, userId) async {
  final service = ref.read(weightDiaryServiceProvider);
  // Use optimized service to avoid collection group index
  return await service.getWeightDiariesLast24h(userId);
});

// Individual weight diary entry provider
final weightDiaryEntryProvider = FutureProvider.family<WeightDiary?, ({String userId, int weekNumber, String entryId})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeightDiary(params.userId, params.weekNumber, params.entryId);
});

// Week statistics for weight
final weightWeekStatisticsProvider = FutureProvider.family<Map<String, dynamic>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(weightDiaryServiceProvider);
  return await service.getWeekStatistics(params.userId, params.weekNumber);
});

class WeightDiaryNotifier extends StateNotifier<AsyncValue<List<WeightDiary>>> {
  final WeightDiaryService _weightDiaryService;
  final String _userId;
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();

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

      await loadCurrentWeekEntries();
      await _analytics.trackWeightDiaryEntry();

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

      await loadCurrentWeekEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(int weekNumber, String entryId) async {
    try {
      await _weightDiaryService.deleteWeightDiary(_userId, weekNumber, entryId);
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


