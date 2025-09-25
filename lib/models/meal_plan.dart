import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String id;
  final String userId;
  final DateTime planDate; // Date this meal plan is for
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snacks;
  final String preparationLocation;
  final String? customLocation; // For "Other" option
  final List<String> preparationMethods;
  final String portionGoals;
  final String nutritionGoals;
  final String challenges;
  final String strategies;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.planDate,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.preparationLocation,
    this.customLocation,
    required this.preparationMethods,
    required this.portionGoals,
    required this.nutritionGoals,
    required this.challenges,
    required this.strategies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      userId: data['userId'] ?? '',
      planDate: DateTime.fromMillisecondsSinceEpoch(data['planDate'] ?? 0),
      breakfast: data['breakfast'] ?? '',
      lunch: data['lunch'] ?? '',
      dinner: data['dinner'] ?? '',
      snacks: data['snacks'] ?? '',
      preparationLocation: data['preparationLocation'] ?? '',
      customLocation: data['customLocation'],
      preparationMethods: List<String>.from(data['preparationMethods'] ?? []),
      portionGoals: data['portionGoals'] ?? '',
      nutritionGoals: data['nutritionGoals'] ?? '',
      challenges: data['challenges'] ?? '',
      strategies: data['strategies'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
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
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? planDate,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snacks,
    String? preparationLocation,
    String? customLocation,
    List<String>? preparationMethods,
    String? portionGoals,
    String? nutritionGoals,
    String? challenges,
    String? strategies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDate: planDate ?? this.planDate,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      preparationLocation: preparationLocation ?? this.preparationLocation,
      customLocation: customLocation ?? this.customLocation,
      preparationMethods: preparationMethods ?? this.preparationMethods,
      portionGoals: portionGoals ?? this.portionGoals,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      challenges: challenges ?? this.challenges,
      strategies: strategies ?? this.strategies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MealPlan(id: $id, planDate: $planDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static constants for preparation location options
  static const List<String> locationOptions = [
    'Home kitchen',
    'Work/School cafeteria', 
    'Restaurant',
    'Friend\'s house',
    'Take-out/Delivery',
    'Meal prep service',
    'Other',
  ];

  // Static constants for preparation method options
  static const List<String> preparationMethodOptions = [
    'Cook from scratch',
    'Use pre-made ingredients',
    'Meal prep in advance',
    'Order/Buy prepared',
    'Simple assembly',
    'Batch cooking',
  ];

  // Helper method to get display location
  String get displayLocation {
    if (preparationLocation == 'Other' && customLocation != null && customLocation!.isNotEmpty) {
      return customLocation!;
    }
    return preparationLocation;
  }

  // Helper method to check if plan is complete
  bool get isComplete {
    return breakfast.isNotEmpty && 
           lunch.isNotEmpty && 
           dinner.isNotEmpty &&
           portionGoals.isNotEmpty &&
           nutritionGoals.isNotEmpty;
  }

  // Helper method to get formatted plan date
  String get formattedPlanDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final planDay = DateTime(planDate.year, planDate.month, planDate.day);
    
    if (planDay == today) {
      return 'Today';
    } else if (planDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (planDay.isBefore(today)) {
      final daysAgo = today.difference(planDay).inDays;
      return '$daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else {
      final daysAhead = planDay.difference(today).inDays;
      return 'In $daysAhead day${daysAhead == 1 ? '' : 's'}';
    }
  }

  // Helper method to count planned meals
  int get plannedMealsCount {
    int count = 0;
    if (breakfast.isNotEmpty) count++;
    if (lunch.isNotEmpty) count++;
    if (dinner.isNotEmpty) count++;
    if (snacks.isNotEmpty) count++;
    return count;
  }
}
