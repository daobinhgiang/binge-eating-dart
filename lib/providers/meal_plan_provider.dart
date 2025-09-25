import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
import '../core/services/meal_plan_service.dart';

// Meal plan service provider
final mealPlanServiceProvider = Provider<MealPlanService>((ref) => MealPlanService());

// User meal plans provider
final userMealPlansProvider = StateNotifierProvider.family<MealPlanNotifier, AsyncValue<List<MealPlan>>, String>((ref, userId) {
  return MealPlanNotifier(ref.read(mealPlanServiceProvider), userId);
});

// All user meal plans provider (alias for compatibility)
final allUserMealPlansProvider = StateNotifierProvider.family<AllMealPlansNotifier, AsyncValue<List<MealPlan>>, String>((ref, userId) {
  return AllMealPlansNotifier(ref.read(mealPlanServiceProvider), userId);
});

// Individual meal plan provider
final mealPlanProvider = FutureProvider.family<MealPlan?, ({String userId, String planId})>((ref, params) async {
  final service = ref.read(mealPlanServiceProvider);
  return await service.getMealPlan(params.userId, params.planId);
});

// Recent meal plans provider
final recentMealPlansProvider = FutureProvider.family<List<MealPlan>, ({String userId, int limit})>((ref, params) async {
  final service = ref.read(mealPlanServiceProvider);
  return await service.getRecentMealPlans(params.userId, limit: params.limit);
});

// Meal plan statistics provider
final mealPlanStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(mealPlanServiceProvider);
  return await service.getMealPlanStatistics(userId);
});

// Meal plans in date range provider
final mealPlansInDateRangeProvider = FutureProvider.family<List<MealPlan>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(mealPlanServiceProvider);
  return await service.getMealPlansInDateRange(params.userId, params.startDate, params.endDate);
});

class MealPlanNotifier extends StateNotifier<AsyncValue<List<MealPlan>>> {
  final MealPlanService _mealPlanService;
  final String _userId;

  MealPlanNotifier(this._mealPlanService, this._userId) : super(const AsyncValue.loading()) {
    loadUserMealPlans();
  }

  Future<void> loadUserMealPlans() async {
    try {
      state = const AsyncValue.loading();
      final plans = await _mealPlanService.getUserMealPlans(_userId);
      state = AsyncValue.data(plans);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<MealPlan?> createPlan({
    required DateTime planDate,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
    required String preparationLocation,
    String? customLocation,
    required List<String> preparationMethods,
    required String portionGoals,
    required String nutritionGoals,
    required String challenges,
    required String strategies,
  }) async {
    try {
      final plan = await _mealPlanService.createMealPlan(
        userId: _userId,
        planDate: planDate,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snacks: snacks,
        preparationLocation: preparationLocation,
        customLocation: customLocation,
        preparationMethods: preparationMethods,
        portionGoals: portionGoals,
        nutritionGoals: nutritionGoals,
        challenges: challenges,
        strategies: strategies,
      );

      // Refresh current state
      await loadUserMealPlans();
      
      return plan;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updatePlan({
    required String planId,
    required DateTime planDate,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
    required String preparationLocation,
    String? customLocation,
    required List<String> preparationMethods,
    required String portionGoals,
    required String nutritionGoals,
    required String challenges,
    required String strategies,
  }) async {
    try {
      await _mealPlanService.updateMealPlan(
        userId: _userId,
        planId: planId,
        planDate: planDate,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snacks: snacks,
        preparationLocation: preparationLocation,
        customLocation: customLocation,
        preparationMethods: preparationMethods,
        portionGoals: portionGoals,
        nutritionGoals: nutritionGoals,
        challenges: challenges,
        strategies: strategies,
      );

      // Refresh current state
      await loadUserMealPlans();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _mealPlanService.deleteMealPlan(_userId, planId);
      
      // Refresh current state
      await loadUserMealPlans();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshPlans() async {
    await loadUserMealPlans();
  }
}

class AllMealPlansNotifier extends StateNotifier<AsyncValue<List<MealPlan>>> {
  final MealPlanService _mealPlanService;
  final String _userId;

  AllMealPlansNotifier(this._mealPlanService, this._userId) : super(const AsyncValue.loading()) {
    loadAllPlans();
  }

  Future<void> loadAllPlans() async {
    try {
      state = const AsyncValue.loading();
      final plans = await _mealPlanService.getUserMealPlans(_userId);
      state = AsyncValue.data(plans);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshPlans() async {
    await loadAllPlans();
  }

  Future<MealPlan?> createPlan({
    required DateTime planDate,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
    required String preparationLocation,
    String? customLocation,
    required List<String> preparationMethods,
    required String portionGoals,
    required String nutritionGoals,
    required String challenges,
    required String strategies,
  }) async {
    try {
      final plan = await _mealPlanService.createMealPlan(
        userId: _userId,
        planDate: planDate,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snacks: snacks,
        preparationLocation: preparationLocation,
        customLocation: customLocation,
        preparationMethods: preparationMethods,
        portionGoals: portionGoals,
        nutritionGoals: nutritionGoals,
        challenges: challenges,
        strategies: strategies,
      );

      // Refresh current state
      await loadAllPlans();
      
      return plan;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<List<MealPlan>> searchPlans(String query) async {
    try {
      return await _mealPlanService.searchMealPlans(_userId, query);
    } catch (e) {
      return [];
    }
  }
}

// Provider for checking if user has any meal plans
final hasMealPlansProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(mealPlanServiceProvider);
  final plans = await service.getUserMealPlans(userId);
  return plans.isNotEmpty;
});

// Provider for today's meal plans
final todayMealPlansProvider = FutureProvider.family<List<MealPlan>, String>((ref, userId) async {
  final service = ref.read(mealPlanServiceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  
  return await service.getMealPlansInDateRange(userId, today, tomorrow);
});

// Provider for upcoming meal plans (next 7 days)
final upcomingMealPlansProvider = FutureProvider.family<List<MealPlan>, String>((ref, userId) async {
  final service = ref.read(mealPlanServiceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final nextWeek = today.add(const Duration(days: 7));
  
  return await service.getMealPlansInDateRange(userId, today, nextWeek);
});

// Current week meal plans provider (alias for compatibility)
final currentWeekMealPlansProvider = userMealPlansProvider;
