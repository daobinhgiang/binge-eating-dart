import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/meal_plan.dart';

class MealPlanService {
  static final MealPlanService _instance = MealPlanService._internal();
  factory MealPlanService() => _instance;
  MealPlanService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new meal plan
  Future<MealPlan> createMealPlan({
    required String userId,
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
      final now = DateTime.now();
      
      final mealPlan = MealPlan(
        id: '', // Will be set by Firestore
        userId: userId,
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
        createdAt: now,
        updatedAt: now,
      );

      // Store in Firestore with structure: users/{userId}/exercises/mealPlan/exercises/{planId}
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .add(mealPlan.toFirestore());

      return mealPlan.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create meal plan: $e';
    }
  }

  // Get all meal plans for a user
  Future<List<MealPlan>> getUserMealPlans(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get meal plans: $e';
    }
  }

  // Get a specific meal plan by ID
  Future<MealPlan?> getMealPlan(String userId, String planId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .doc(planId)
          .get();

      if (doc.exists) {
        return MealPlan.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get meal plan: $e';
    }
  }

  // Update a meal plan
  Future<void> updateMealPlan({
    required String userId,
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .doc(planId)
          .update({
        'planDate': planDate.millisecondsSinceEpoch,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'snacks': snacks,
        'preparationLocation': preparationLocation,
        'customLocation': customLocation,
        'preparationMethods': preparationMethods,
        'portionGoals': portionGoals,
        'nutritionGoals': nutritionGoals,
        'challenges': challenges,
        'strategies': strategies,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update meal plan: $e';
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String userId, String planId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .doc(planId)
          .delete();
    } catch (e) {
      throw 'Failed to delete meal plan: $e';
    }
  }

  // Get all meal plans for a user (alias for getUserMealPlans for compatibility)
  Future<List<MealPlan>> getAllUserMealPlans(String userId) async {
    return getUserMealPlans(userId);
  }

  // Get recent meal plans
  Future<List<MealPlan>> getRecentMealPlans(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get recent meal plans: $e';
    }
  }

  // Get meal plans for a date range
  Future<List<MealPlan>> getMealPlansInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc('mealPlan')
          .collection('exercises')
          .where('planDate', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('planDate', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('planDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get meal plans in date range: $e';
    }
  }

  // Search meal plans
  Future<List<MealPlan>> searchMealPlans(String userId, String query) async {
    try {
      final allPlans = await getUserMealPlans(userId);
      return allPlans.where((plan) =>
          plan.breakfast.toLowerCase().contains(query.toLowerCase()) ||
          plan.lunch.toLowerCase().contains(query.toLowerCase()) ||
          plan.dinner.toLowerCase().contains(query.toLowerCase()) ||
          plan.snacks.toLowerCase().contains(query.toLowerCase()) ||
          plan.nutritionGoals.toLowerCase().contains(query.toLowerCase()) ||
          plan.portionGoals.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw 'Failed to search meal plans: $e';
    }
  }

  // Get meal plan statistics
  Future<Map<String, dynamic>> getMealPlanStatistics(String userId) async {
    try {
      final allPlans = await getUserMealPlans(userId);
      
      if (allPlans.isEmpty) {
        return {
          'totalPlans': 0,
          'completePlans': 0,
          'averageMealsPerPlan': 0.0,
          'completionRate': 0.0,
          'mostRecentPlan': null,
        };
      }

      final completePlans = allPlans.where((plan) => plan.isComplete).length;
      final totalMeals = allPlans.fold<int>(0, (sum, plan) => sum + plan.plannedMealsCount);

      return {
        'totalPlans': allPlans.length,
        'completePlans': completePlans,
        'averageMealsPerPlan': totalMeals / allPlans.length,
        'completionRate': completePlans / allPlans.length,
        'mostRecentPlan': allPlans.isNotEmpty ? allPlans.first : null,
      };
    } catch (e) {
      throw 'Failed to get meal plan statistics: $e';
    }
  }
}
