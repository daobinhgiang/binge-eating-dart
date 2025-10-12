import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/money_diary.dart';
import '../core/services/money_diary_service.dart';

// Money diary service provider
final moneyDiaryServiceProvider = Provider<MoneyDiaryService>((ref) => MoneyDiaryService());

// Real-time stream of all money diaries
final allMoneyDiariesStreamProvider = StreamProvider.family<List<MoneyDiary>, String>((ref, userId) {
  final service = ref.read(moneyDiaryServiceProvider);
  return service.streamAllMoneyDiaries(userId);
});

// Current week money diaries provider (real-time)
final currentWeekMoneyDiariesProvider = StreamProvider.family<List<MoneyDiary>, String>((ref, userId) async* {
  await for (final allEntries in ref.watch(allMoneyDiariesStreamProvider(userId).stream)) {
    final service = ref.read(moneyDiaryServiceProvider);
    final currentWeek = await service.getCurrentWeekNumber(userId);
    yield allEntries.where((entry) => entry.week == currentWeek).toList();
  }
});

// Money diaries for specific week provider
final weekMoneyDiariesProvider = FutureProvider.family<List<MoneyDiary>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(moneyDiaryServiceProvider);
  return await service.getMoneyDiariesForWeek(params.userId, params.weekNumber);
});

// All money diaries provider (convenience for using .when())
final allMoneyDiariesProvider = StreamProvider.family<List<MoneyDiary>, String>((ref, userId) {
  return ref.watch(allMoneyDiariesStreamProvider(userId).stream);
});

// Total spent provider (real-time)
final totalSpentProvider = StreamProvider.family<double, String>((ref, userId) {
  final service = ref.read(moneyDiaryServiceProvider);
  return service.streamTotalSpent(userId);
});

// Current week total spent provider
final currentWeekTotalSpentProvider = FutureProvider.family<double, String>((ref, userId) async {
  final service = ref.read(moneyDiaryServiceProvider);
  return await service.getCurrentWeekTotalSpent(userId);
});

// Spending by category provider
final spendingByCategoryProvider = FutureProvider.family<Map<String, double>, String>((ref, userId) async {
  final service = ref.read(moneyDiaryServiceProvider);
  return await service.getSpendingByCategory(userId);
});

// Individual money diary entry provider
final moneyDiaryEntryProvider = FutureProvider.family<MoneyDiary?, ({String userId, int weekNumber, String entryId})>((ref, params) async {
  final service = ref.read(moneyDiaryServiceProvider);
  try {
    final weekEntries = await service.getMoneyDiariesForWeek(params.userId, params.weekNumber);
    return weekEntries.firstWhere((entry) => entry.id == params.entryId);
  } catch (e) {
    return null;
  }
});

// Current week number provider (reused from other diary providers)
final currentWeekNumberProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.read(moneyDiaryServiceProvider);
  return await service.getCurrentWeekNumber(userId);
});

// Money diary statistics provider
final moneyDiaryStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(moneyDiaryServiceProvider);
  
  final allEntries = await service.getAllMoneyDiaries(userId);
  final totalSpent = await service.getTotalSpent(userId);
  final currentWeekTotal = await service.getCurrentWeekTotalSpent(userId);
  final spendingByCategory = await service.getSpendingByCategory(userId);
  
  // Calculate additional statistics
  final averagePerEntry = allEntries.isNotEmpty ? totalSpent / allEntries.length : 0.0;
  final totalEntries = allEntries.length;
  
  // Get most expensive entry
  final mostExpensiveEntry = allEntries.isNotEmpty 
      ? allEntries.reduce((a, b) => a.amount > b.amount ? a : b)
      : null;
  
  // Get most common category
  String? mostCommonCategory;
  if (spendingByCategory.isNotEmpty) {
    mostCommonCategory = spendingByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  return {
    'totalSpent': totalSpent,
    'currentWeekTotal': currentWeekTotal,
    'totalEntries': totalEntries,
    'averagePerEntry': averagePerEntry,
    'mostExpensiveAmount': mostExpensiveEntry?.amount ?? 0.0,
    'mostExpensiveDescription': mostExpensiveEntry?.description ?? '',
    'mostCommonCategory': mostCommonCategory ?? '',
    'spendingByCategory': spendingByCategory,
  };
});

// Today's money entries provider (real-time)
final todaysMoneyEntriesProvider = StreamProvider.family<List<MoneyDiary>, String>((ref, userId) async* {
  await for (final allEntries in ref.watch(allMoneyDiariesStreamProvider(userId).stream)) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    yield allEntries.where((entry) {
      final entryDate = DateTime(entry.spentAt.year, entry.spentAt.month, entry.spentAt.day);
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }
});

// Today's total spent provider (real-time)
final todaysTotalSpentProvider = StreamProvider.family<double, String>((ref, userId) async* {
  await for (final todaysEntries in ref.watch(todaysMoneyEntriesProvider(userId).stream)) {
    yield todaysEntries.fold<double>(0.0, (sum, entry) => sum + entry.amount);
  }
});
