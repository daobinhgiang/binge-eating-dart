import '../../models/food_diary.dart';
import '../../models/weight_diary.dart';
import '../../models/body_image_diary.dart';
import 'food_diary_service.dart';
import 'weight_diary_service.dart';
import 'body_image_diary_service.dart';

class WeekDataService {
  static final WeekDataService _instance = WeekDataService._internal();
  factory WeekDataService() => _instance;
  WeekDataService._internal();

  final FoodDiaryService _foodDiaryService = FoodDiaryService();
  final WeightDiaryService _weightDiaryService = WeightDiaryService();
  final BodyImageDiaryService _bodyImageDiaryService = BodyImageDiaryService();

  /// Get comprehensive data for the current week
  Future<Map<String, dynamic>> getCurrentWeekData(String userId) async {
    try {
      final weekNumber = await _foodDiaryService.getCurrentWeekNumber(userId);
      
      // Fetch all data for the current week in parallel
      final results = await Future.wait([
        _foodDiaryService.getCurrentWeekFoodDiaries(userId),
        _weightDiaryService.getCurrentWeekWeightDiaries(userId),
        _bodyImageDiaryService.getCurrentWeekBodyImageDiaries(userId),
      ]);

      final foodDiaries = results[0] as List<FoodDiary>;
      final weightDiaries = results[1] as List<WeightDiary>;
      final bodyImageDiaries = results[2] as List<BodyImageDiary>;

      // Calculate statistics
      final bingeCount = foodDiaries.where((entry) => entry.isBinge).length;
      final totalMeals = foodDiaries.length;
      final bingeRate = totalMeals > 0 ? (bingeCount / totalMeals) * 100 : 0.0;

      // Get latest weight if available
      final latestWeight = weightDiaries.isNotEmpty 
          ? weightDiaries.first.weight 
          : null;

      // Count body image checks
      final bodyImageCheckCount = bodyImageDiaries.length;

      // Analyze binge patterns
      final bingeEntries = foodDiaries.where((entry) => entry.isBinge).toList();
      final bingeLocations = <String, int>{};
      final bingeTimes = <String, int>{};
      
      for (final entry in bingeEntries) {
        // Count by location
        final location = entry.customLocation ?? entry.location;
        bingeLocations[location] = (bingeLocations[location] ?? 0) + 1;
        
        // Count by time of day
        final hour = entry.mealTime.hour;
        String timeCategory;
        if (hour < 6) {
          timeCategory = 'Late night (12am-6am)';
        } else if (hour < 12) {
          timeCategory = 'Morning (6am-12pm)';
        } else if (hour < 18) {
          timeCategory = 'Afternoon (12pm-6pm)';
        } else {
          timeCategory = 'Evening (6pm-12am)';
        }
        
        bingeTimes[timeCategory] = (bingeTimes[timeCategory] ?? 0) + 1;
      }

      return {
        'weekNumber': weekNumber,
        'totalMeals': totalMeals,
        'bingeCount': bingeCount,
        'bingeRate': bingeRate,
        'latestWeight': latestWeight,
        'bodyImageCheckCount': bodyImageCheckCount,
        'bingeLocations': bingeLocations,
        'bingeTimes': bingeTimes,
        'foodDiaries': foodDiaries.map((e) => {
          'foodAndDrinks': e.foodAndDrinks,
          'mealTime': e.mealTime.toIso8601String(),
          'location': e.location,
          'isBinge': e.isBinge,
          'purgeMethod': e.purgeMethod,
          'contextAndComments': e.contextAndComments,
        }).toList(),
        'weightDiaries': weightDiaries.map((e) => {
          'weight': e.weight,
          'unit': e.unit,
          'createdAt': e.createdAt.toIso8601String(),
        }).toList(),
        'bodyImageDiaries': bodyImageDiaries.map((e) => {
          'howChecked': e.howChecked,
          'whereChecked': e.whereChecked,
          'checkTime': e.checkTime.toIso8601String(),
          'contextAndFeelings': e.contextAndFeelings,
        }).toList(),
      };
    } catch (e) {
      throw 'Failed to get current week data: $e';
    }
  }

  /// Get data for a specific week
  Future<Map<String, dynamic>> getWeekData(String userId, int weekNumber) async {
    try {
      // Fetch all data for the specific week in parallel
      final results = await Future.wait([
        _foodDiaryService.getFoodDiariesForWeek(userId, weekNumber),
        _weightDiaryService.getWeightDiariesForWeek(userId, weekNumber),
        _bodyImageDiaryService.getBodyImageDiariesForWeek(userId, weekNumber),
      ]);

      final foodDiaries = results[0] as List<FoodDiary>;
      final weightDiaries = results[1] as List<WeightDiary>;
      final bodyImageDiaries = results[2] as List<BodyImageDiary>;

      // Calculate statistics
      final bingeCount = foodDiaries.where((entry) => entry.isBinge).length;
      final totalMeals = foodDiaries.length;
      final bingeRate = totalMeals > 0 ? (bingeCount / totalMeals) * 100 : 0.0;

      // Get latest weight if available
      final latestWeight = weightDiaries.isNotEmpty 
          ? weightDiaries.first.weight 
          : null;

      // Count body image checks
      final bodyImageCheckCount = bodyImageDiaries.length;

      return {
        'weekNumber': weekNumber,
        'totalMeals': totalMeals,
        'bingeCount': bingeCount,
        'bingeRate': bingeRate,
        'latestWeight': latestWeight,
        'bodyImageCheckCount': bodyImageCheckCount,
        'foodDiaries': foodDiaries.map((e) => {
          'foodAndDrinks': e.foodAndDrinks,
          'mealTime': e.mealTime.toIso8601String(),
          'location': e.location,
          'isBinge': e.isBinge,
          'purgeMethod': e.purgeMethod,
          'contextAndComments': e.contextAndComments,
        }).toList(),
        'weightDiaries': weightDiaries.map((e) => {
          'weight': e.weight,
          'unit': e.unit,
          'createdAt': e.createdAt.toIso8601String(),
        }).toList(),
        'bodyImageDiaries': bodyImageDiaries.map((e) => {
          'howChecked': e.howChecked,
          'whereChecked': e.whereChecked,
          'checkTime': e.checkTime.toIso8601String(),
          'contextAndFeelings': e.contextAndFeelings,
        }).toList(),
      };
    } catch (e) {
      throw 'Failed to get week $weekNumber data: $e';
    }
  }
}
