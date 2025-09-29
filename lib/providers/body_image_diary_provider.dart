import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_image_diary.dart';
import '../core/services/body_image_diary_service.dart';
import '../core/services/firebase_analytics_service.dart';

// Body image diary service provider
final bodyImageDiaryServiceProvider = Provider<BodyImageDiaryService>((ref) => BodyImageDiaryService());

// Current week body image diaries provider
final currentWeekBodyImageDiariesProvider = StateNotifierProvider.family<BodyImageDiaryNotifier, AsyncValue<List<BodyImageDiary>>, String>((ref, userId) {
  return BodyImageDiaryNotifier(ref.read(bodyImageDiaryServiceProvider), userId);
});

// Body image diaries for specific week provider
final weekBodyImageDiariesProvider = FutureProvider.family<List<BodyImageDiary>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getBodyImageDiariesForWeek(params.userId, params.weekNumber);
});

// All body image diaries provider
final allBodyImageDiariesProvider = FutureProvider.family<Map<int, List<BodyImageDiary>>, String>((ref, userId) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getAllBodyImageDiaries(userId);
});

// Week body image statistics provider
final weekBodyImageStatisticsProvider = FutureProvider.family<Map<String, dynamic>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getWeekStatistics(params.userId, params.weekNumber);
});

// Individual body image diary entry provider
final bodyImageDiaryEntryProvider = FutureProvider.family<BodyImageDiary?, ({String userId, int weekNumber, String entryId})>((ref, params) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getBodyImageDiary(params.userId, params.weekNumber, params.entryId);
});

// Body checking trend provider
final bodyCheckingTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String userId, int numberOfWeeks})>((ref, params) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getBodyCheckingTrend(params.userId, numberOfWeeks: params.numberOfWeeks);
});

class BodyImageDiaryNotifier extends StateNotifier<AsyncValue<List<BodyImageDiary>>> {
  final BodyImageDiaryService _bodyImageDiaryService;
  final String _userId;
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();

  BodyImageDiaryNotifier(this._bodyImageDiaryService, this._userId) : super(const AsyncValue.loading()) {
    loadCurrentWeekEntries();
  }

  Future<void> loadCurrentWeekEntries() async {
    try {
      state = const AsyncValue.loading();
      final entries = await _bodyImageDiaryService.getCurrentWeekBodyImageDiaries(_userId);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadWeekEntries(int weekNumber) async {
    try {
      state = const AsyncValue.loading();
      final entries = await _bodyImageDiaryService.getBodyImageDiariesForWeek(_userId, weekNumber);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<BodyImageDiary?> createEntry({
    required String howChecked,
    String? customHowChecked,
    required DateTime checkTime,
    required String whereChecked,
    String? customWhereChecked,
    required String contextAndFeelings,
  }) async {
    try {
      final entry = await _bodyImageDiaryService.createBodyImageDiary(
        userId: _userId,
        howChecked: howChecked,
        customHowChecked: customHowChecked,
        checkTime: checkTime,
        whereChecked: whereChecked,
        customWhereChecked: customWhereChecked,
        contextAndFeelings: contextAndFeelings,
      );

      // Refresh current state
      await loadCurrentWeekEntries();
      
      // Track body image diary entry creation
      await _analytics.trackBodyImageDiaryEntry();
      
      return entry;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateEntry({
    required int weekNumber,
    required String entryId,
    required String howChecked,
    String? customHowChecked,
    required DateTime checkTime,
    required String whereChecked,
    String? customWhereChecked,
    required String contextAndFeelings,
  }) async {
    try {
      await _bodyImageDiaryService.updateBodyImageDiary(
        userId: _userId,
        weekNumber: weekNumber,
        entryId: entryId,
        howChecked: howChecked,
        customHowChecked: customHowChecked,
        checkTime: checkTime,
        whereChecked: whereChecked,
        customWhereChecked: customWhereChecked,
        contextAndFeelings: contextAndFeelings,
      );

      // Refresh current state
      await loadCurrentWeekEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(int weekNumber, String entryId) async {
    try {
      await _bodyImageDiaryService.deleteBodyImageDiary(_userId, weekNumber, entryId);
      
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
final bodyImageDiariesInDateRangeProvider = FutureProvider.family<List<BodyImageDiary>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  return await service.getBodyImageDiariesInDateRange(params.userId, params.startDate, params.endDate);
});

// Provider for getting today's entries
final todayBodyImageDiariesProvider = FutureProvider.family<List<BodyImageDiary>, String>((ref, userId) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  return await service.getBodyImageDiariesInDateRange(userId, startOfDay, endOfDay);
});

// Provider for checking if user has any body image diary entries
final hasBodyImageDiaryEntriesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(bodyImageDiaryServiceProvider);
  final allDiaries = await service.getAllBodyImageDiaries(userId);
  return allDiaries.isNotEmpty && allDiaries.values.any((entries) => entries.isNotEmpty);
});
