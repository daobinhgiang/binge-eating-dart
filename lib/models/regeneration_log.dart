import 'package:cloud_firestore/cloud_firestore.dart';

class RegenerationLog {
  final String id;
  final String userId;
  final DateTime regeneratedAt;
  final String? seedsDate;      // Date string (YYYY-MM-DD) for Seeds
  final int? growthWeek;        // ISO week number for Growth Tasks
  final int? growthYear;        // Year for Growth Tasks
  final List<String> generatedTaskIds;

  const RegenerationLog({
    required this.id,
    required this.userId,
    required this.regeneratedAt,
    this.seedsDate,
    this.growthWeek,
    this.growthYear,
    required this.generatedTaskIds,
  });

  factory RegenerationLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return RegenerationLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      regeneratedAt: _parseDateTime(data['regeneratedAt']),
      seedsDate: data['seedsDate'],
      growthWeek: data['growthWeek'],
      growthYear: data['growthYear'],
      generatedTaskIds: List<String>.from(data['generatedTaskIds'] ?? []),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    } else {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'regeneratedAt': Timestamp.fromDate(regeneratedAt),
      'seedsDate': seedsDate,
      'growthWeek': growthWeek,
      'growthYear': growthYear,
      'generatedTaskIds': generatedTaskIds,
    };
  }

  RegenerationLog copyWith({
    String? id,
    String? userId,
    DateTime? regeneratedAt,
    String? seedsDate,
    int? growthWeek,
    int? growthYear,
    List<String>? generatedTaskIds,
  }) {
    return RegenerationLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      regeneratedAt: regeneratedAt ?? this.regeneratedAt,
      seedsDate: seedsDate ?? this.seedsDate,
      growthWeek: growthWeek ?? this.growthWeek,
      growthYear: growthYear ?? this.growthYear,
      generatedTaskIds: generatedTaskIds ?? this.generatedTaskIds,
    );
  }

  @override
  String toString() {
    return 'RegenerationLog(id: $id, userId: $userId, seedsDate: $seedsDate, growthWeek: $growthWeek)';
  }
}

