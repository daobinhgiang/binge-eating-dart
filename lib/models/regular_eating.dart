import 'package:cloud_firestore/cloud_firestore.dart';

class RegularEating {
  final String id;
  final String userId;
  final double mealIntervalHours; // 2-6 hours between meals
  final int firstMealHour; // 0-23 hour for first meal
  final int firstMealMinute; // 0-59 minute for first meal
  final int mealCount; // Number of meals per day (3-10)
  final List<String> mealTimes; // Array of meal times in HH:mm format
  final DateTime createdAt;
  final DateTime updatedAt;

  const RegularEating({
    required this.id,
    required this.userId,
    required this.mealIntervalHours,
    required this.firstMealHour,
    required this.firstMealMinute,
    required this.mealCount,
    required this.mealTimes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegularEating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse meal times from Firestore
    List<String> mealTimes = [];
    if (data['mealTimes'] != null) {
      final List<dynamic> mealTimesData = data['mealTimes'];
      mealTimes = mealTimesData.map((timeData) {
        if (timeData is String) {
          return timeData;
        }
        return '08:00'; // Default fallback
      }).toList();
    }
    
    return RegularEating(
      id: doc.id,
      userId: data['userId'] ?? '',
      mealIntervalHours: (data['mealIntervalHours'] ?? 3.0).toDouble(),
      firstMealHour: data['firstMealHour'] ?? 8,
      firstMealMinute: data['firstMealMinute'] ?? 0,
      mealCount: data['mealCount'] ?? 3,
      mealTimes: mealTimes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'mealIntervalHours': mealIntervalHours,
      'firstMealHour': firstMealHour,
      'firstMealMinute': firstMealMinute,
      'mealCount': mealCount,
      'mealTimes': mealTimes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  RegularEating copyWith({
    String? id,
    String? userId,
    double? mealIntervalHours,
    int? firstMealHour,
    int? firstMealMinute,
    int? mealCount,
    List<String>? mealTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegularEating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealIntervalHours: mealIntervalHours ?? this.mealIntervalHours,
      firstMealHour: firstMealHour ?? this.firstMealHour,
      firstMealMinute: firstMealMinute ?? this.firstMealMinute,
      mealCount: mealCount ?? this.mealCount,
      mealTimes: mealTimes ?? this.mealTimes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RegularEating(id: $id, userId: $userId, interval: ${mealIntervalHours}h, firstMeal: $firstMealTimeFormatted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegularEating && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  String get firstMealTimeFormatted {
    final hour = firstMealHour % 12 == 0 ? 12 : firstMealHour % 12;
    final minute = firstMealMinute.toString().padLeft(2, '0');
    final period = firstMealHour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get mealIntervalFormatted {
    if (mealIntervalHours == mealIntervalHours.round()) {
      return '${mealIntervalHours.round()} hour${mealIntervalHours.round() == 1 ? '' : 's'}';
    } else {
      return '${mealIntervalHours.toStringAsFixed(1)} hours';
    }
  }

  // Calculate suggested meal times based on first meal and interval
  List<String> getMealTimesForDate(DateTime date) {
    final firstMeal = DateTime(
      date.year,
      date.month,
      date.day,
      firstMealHour,
      firstMealMinute,
    );

    final List<DateTime> calculatedMealTimes = [firstMeal];
    
    // Add subsequent meals based on mealCount
    for (int i = 1; i < mealCount; i++) {
      final nextMeal = firstMeal.add(Duration(
        hours: (mealIntervalHours * i).floor(),
        minutes: ((mealIntervalHours * i % 1) * 60).round(),
      ));
      
      // Only add if it's reasonable eating hours (before 10 PM)
      if (nextMeal.hour < 22) {
        calculatedMealTimes.add(nextMeal);
      }
    }
    
    // Convert to time strings (HH:mm format)
    return calculatedMealTimes.map((dateTime) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }).toList();
  }

  // Generate meal times based on current settings
  List<String> generateMealTimes() {
    final today = DateTime.now();
    return getMealTimesForDate(today);
  }

  // Helper method to format time string for display
  String formatTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return timeString;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$displayHour:$minuteStr $period';
  }

  // Default values
  static const double defaultMealIntervalHours = 3.0;
  static const int defaultFirstMealHour = 8;
  static const int defaultFirstMealMinute = 0;
  static const int defaultMealCount = 3;
  static const double minMealIntervalHours = 2.0;
  static const double maxMealIntervalHours = 6.0;
  static const int minMealCount = 3;
  static const int maxMealCount = 10;
}

