import 'package:cloud_firestore/cloud_firestore.dart';

class BodyImageDiary {
  final String id;
  final String userId;
  final int week; // Week number since user first used the app
  final String howChecked; // How they checked their shape
  final String? customHowChecked; // For "Other" option
  final DateTime checkTime; // When they checked their shape
  final String whereChecked; // Where they checked their shape
  final String? customWhereChecked; // For "Other" option
  final String contextAndFeelings; // Context, thoughts, and feelings
  final DateTime createdAt;
  final DateTime updatedAt;

  const BodyImageDiary({
    required this.id,
    required this.userId,
    required this.week,
    required this.howChecked,
    this.customHowChecked,
    required this.checkTime,
    required this.whereChecked,
    this.customWhereChecked,
    required this.contextAndFeelings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BodyImageDiary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BodyImageDiary(
      id: doc.id,
      userId: data['userId'] ?? '',
      week: data['week'] ?? 1,
      howChecked: data['howChecked'] ?? '',
      customHowChecked: data['customHowChecked'],
      checkTime: DateTime.fromMillisecondsSinceEpoch(data['checkTime'] ?? 0),
      whereChecked: data['whereChecked'] ?? '',
      customWhereChecked: data['customWhereChecked'],
      contextAndFeelings: data['contextAndFeelings'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'week': week,
      'howChecked': howChecked,
      'customHowChecked': customHowChecked,
      'checkTime': checkTime.millisecondsSinceEpoch,
      'whereChecked': whereChecked,
      'customWhereChecked': customWhereChecked,
      'contextAndFeelings': contextAndFeelings,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  BodyImageDiary copyWith({
    String? id,
    String? userId,
    int? week,
    String? howChecked,
    String? customHowChecked,
    DateTime? checkTime,
    String? whereChecked,
    String? customWhereChecked,
    String? contextAndFeelings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BodyImageDiary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      week: week ?? this.week,
      howChecked: howChecked ?? this.howChecked,
      customHowChecked: customHowChecked ?? this.customHowChecked,
      checkTime: checkTime ?? this.checkTime,
      whereChecked: whereChecked ?? this.whereChecked,
      customWhereChecked: customWhereChecked ?? this.customWhereChecked,
      contextAndFeelings: contextAndFeelings ?? this.contextAndFeelings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BodyImageDiary(id: $id, week: $week, howChecked: $howChecked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyImageDiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static constants for "how checked" options
  static const List<String> howCheckedOptions = [
    'Mirror',
    'Touching/pinching',
    'Weighing scale',
    'Photos',
    'Clothes fitting',
    'Measuring tape',
    'Other',
  ];

  // Static constants for "where checked" options
  static const List<String> whereCheckedOptions = [
    'Bathroom',
    'Bedroom',
    'Gym/fitness center',
    'Changing room',
    'Living room',
    'Work/school',
    'Other',
  ];

  // Helper method to get display text for how checked
  String get displayHowChecked {
    if (howChecked == 'Other' && customHowChecked != null && customHowChecked!.isNotEmpty) {
      return customHowChecked!;
    }
    return howChecked;
  }

  // Helper method to get display text for where checked
  String get displayWhereChecked {
    if (whereChecked == 'Other' && customWhereChecked != null && customWhereChecked!.isNotEmpty) {
      return customWhereChecked!;
    }
    return whereChecked;
  }

  // Helper method to format check time
  String get displayCheckTime {
    final hour = checkTime.hour == 0 ? 12 : (checkTime.hour > 12 ? checkTime.hour - 12 : checkTime.hour);
    final minute = checkTime.minute.toString().padLeft(2, '0');
    final period = checkTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
