import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDiary {
  final String id;
  final String userId;
  final int week; // Week number since user first used the app
  final String foodAndDrinks;
  final DateTime mealTime;
  final String location;
  final String? customLocation; // For "Other" option
  final bool isBinge;
  final String purgeMethod; // 'vomit', 'laxatives', 'both', 'none'
  final String contextAndComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodDiary({
    required this.id,
    required this.userId,
    required this.week,
    required this.foodAndDrinks,
    required this.mealTime,
    required this.location,
    this.customLocation,
    required this.isBinge,
    required this.purgeMethod,
    required this.contextAndComments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodDiary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodDiary(
      id: doc.id,
      userId: data['userId'] ?? '',
      week: data['week'] ?? 1,
      foodAndDrinks: data['foodAndDrinks'] ?? '',
      mealTime: DateTime.fromMillisecondsSinceEpoch(data['mealTime'] ?? 0),
      location: data['location'] ?? '',
      customLocation: data['customLocation'],
      isBinge: data['isBinge'] ?? false,
      purgeMethod: data['purgeMethod'] ?? 'none',
      contextAndComments: data['contextAndComments'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'week': week,
      'foodAndDrinks': foodAndDrinks,
      'mealTime': mealTime.millisecondsSinceEpoch,
      'location': location,
      'customLocation': customLocation,
      'isBinge': isBinge,
      'purgeMethod': purgeMethod,
      'contextAndComments': contextAndComments,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  FoodDiary copyWith({
    String? id,
    String? userId,
    int? week,
    String? foodAndDrinks,
    DateTime? mealTime,
    String? location,
    String? customLocation,
    bool? isBinge,
    String? purgeMethod,
    String? contextAndComments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodDiary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      week: week ?? this.week,
      foodAndDrinks: foodAndDrinks ?? this.foodAndDrinks,
      mealTime: mealTime ?? this.mealTime,
      location: location ?? this.location,
      customLocation: customLocation ?? this.customLocation,
      isBinge: isBinge ?? this.isBinge,
      purgeMethod: purgeMethod ?? this.purgeMethod,
      contextAndComments: contextAndComments ?? this.contextAndComments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FoodDiary(id: $id, week: $week, foodAndDrinks: $foodAndDrinks, isBinge: $isBinge)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodDiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static constants for location options
  static const List<String> locationOptions = [
    'Home',
    'Restaurant',
    'Work/School',
    'Friend\'s house',
    'Car',
    'Other',
  ];

  // Static constants for purge method options
  static const List<String> purgeMethodOptions = [
    'none',
    'vomit',
    'laxatives',
    'both',
  ];

  // Helper method to get display text for purge method
  String get purgeMethodDisplay {
    switch (purgeMethod) {
      case 'none':
        return 'None';
      case 'vomit':
        return 'Vomiting';
      case 'laxatives':
        return 'Laxatives';
      case 'both':
        return 'Both vomiting and laxatives';
      default:
        return 'None';
    }
  }

  // Helper method to get display location
  String get displayLocation {
    if (location == 'Other' && customLocation != null && customLocation!.isNotEmpty) {
      return customLocation!;
    }
    return location;
  }
}
