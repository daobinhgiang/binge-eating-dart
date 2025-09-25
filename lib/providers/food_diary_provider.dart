import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_diary.dart';
import '../core/services/food_diary_service.dart';

// Food diary service provider
final foodDiaryServiceProvider = Provider<FoodDiaryService>((ref) => FoodDiaryService());

// Current week number provider
final currentWeekNumberProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getCurrentWeekNumber(userId);
});

// Current week food diaries provider
final currentWeekFoodDiariesProvider = StateNotifierProvider.family<FoodDiaryNotifier, AsyncValue<List<FoodDiary>>, String>((ref, userId) {
  return FoodDiaryNotifier(ref.read(foodDiaryServiceProvider), userId);
});

// Food diaries for specific week provider
final weekFoodDiariesProvider = FutureProvider.family<List<FoodDiary>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getFoodDiariesForWeek(params.userId, params.weekNumber);
});

// All food diaries provider
final allFoodDiariesProvider = FutureProvider.family<Map<int, List<FoodDiary>>, String>((ref, userId) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getAllFoodDiaries(userId);
});

// Week statistics provider
final weekStatisticsProvider = FutureProvider.family<Map<String, dynamic>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getWeekStatistics(params.userId, params.weekNumber);
});

// Individual food diary entry provider
final foodDiaryEntryProvider = FutureProvider.family<FoodDiary?, ({String userId, int weekNumber, String entryId})>((ref, params) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getFoodDiary(params.userId, params.weekNumber, params.entryId);
});

class FoodDiaryNotifier extends StateNotifier<AsyncValue<List<FoodDiary>>> {
  final FoodDiaryService _foodDiaryService;
  final String _userId;

  FoodDiaryNotifier(this._foodDiaryService, this._userId) : super(const AsyncValue.loading()) {
    loadCurrentWeekEntries();
  }

  Future<void> loadCurrentWeekEntries() async {
    try {
      state = const AsyncValue.loading();
      final entries = await _foodDiaryService.getCurrentWeekFoodDiaries(_userId);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadWeekEntries(int weekNumber) async {
    try {
      state = const AsyncValue.loading();
      final entries = await _foodDiaryService.getFoodDiariesForWeek(_userId, weekNumber);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<FoodDiary?> createEntry({
    required String foodAndDrinks,
    required DateTime mealTime,
    required String location,
    String? customLocation,
    required bool isBinge,
    required String purgeMethod,
    required String contextAndComments,
  }) async {
    try {
      final entry = await _foodDiaryService.createFoodDiary(
        userId: _userId,
        foodAndDrinks: foodAndDrinks,
        mealTime: mealTime,
        location: location,
        customLocation: customLocation,
        isBinge: isBinge,
        purgeMethod: purgeMethod,
        contextAndComments: contextAndComments,
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
    required String foodAndDrinks,
    required DateTime mealTime,
    required String location,
    String? customLocation,
    required bool isBinge,
    required String purgeMethod,
    required String contextAndComments,
  }) async {
    try {
      await _foodDiaryService.updateFoodDiary(
        userId: _userId,
        weekNumber: weekNumber,
        entryId: entryId,
        foodAndDrinks: foodAndDrinks,
        mealTime: mealTime,
        location: location,
        customLocation: customLocation,
        isBinge: isBinge,
        purgeMethod: purgeMethod,
        contextAndComments: contextAndComments,
      );

      // Refresh current state
      await loadCurrentWeekEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(int weekNumber, String entryId) async {
    try {
      await _foodDiaryService.deleteFoodDiary(_userId, weekNumber, entryId);
      
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
final foodDiariesInDateRangeProvider = FutureProvider.family<List<FoodDiary>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(foodDiaryServiceProvider);
  return await service.getFoodDiariesInDateRange(params.userId, params.startDate, params.endDate);
});

// Provider for getting today's entries
final todayFoodDiariesProvider = FutureProvider.family<List<FoodDiary>, String>((ref, userId) async {
  final service = ref.read(foodDiaryServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  return await service.getFoodDiariesInDateRange(userId, startOfDay, endOfDay);
});

// Provider for checking if user has any food diary entries
final hasFoodDiaryEntriesProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(foodDiaryServiceProvider);
  final allDiaries = await service.getAllFoodDiaries(userId);
  return allDiaries.isNotEmpty && allDiaries.values.any((entries) => entries.isNotEmpty);
});
