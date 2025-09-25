import 'package:cloud_firestore/cloud_firestore.dart';

class WeightDiary {
  final String id;
  final String userId;
  final int week; // Week number since user first used the app
  final double weight; // Weight in kg or lbs
  final String unit; // 'kg' or 'lbs'
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightDiary({
    required this.id,
    required this.userId,
    required this.week,
    required this.weight,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeightDiary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightDiary(
      id: doc.id,
      userId: data['userId'] ?? '',
      week: data['week'] ?? 1,
      weight: (data['weight'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'kg',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'week': week,
      'weight': weight,
      'unit': unit,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  WeightDiary copyWith({
    String? id,
    String? userId,
    int? week,
    double? weight,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightDiary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      week: week ?? this.week,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WeightDiary(id: $id, week: $week, weight: $weight $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightDiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static constants for weight units
  static const List<String> weightUnits = ['kg', 'lbs'];

  // Helper method to get display text for weight
  String get displayWeight {
    return '${weight.toStringAsFixed(1)} $unit';
  }

  // Helper method to convert between units
  double convertWeight(String targetUnit) {
    if (unit == targetUnit) return weight;
    
    if (unit == 'kg' && targetUnit == 'lbs') {
      return weight * 2.20462; // kg to lbs
    } else if (unit == 'lbs' && targetUnit == 'kg') {
      return weight * 0.453592; // lbs to kg
    }
    
    return weight; // fallback
  }
}
