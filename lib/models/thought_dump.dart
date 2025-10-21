import 'package:cloud_firestore/cloud_firestore.dart';

class ThoughtDump {
  final String id;
  final String userId;
  final int week; // Week number since user first used the app
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ThoughtDump({
    required this.id,
    required this.userId,
    required this.week,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ThoughtDump.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ThoughtDump(
      id: doc.id,
      userId: data['userId'] ?? '',
      week: data['week'] ?? 1,
      content: data['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'week': week,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  ThoughtDump copyWith({
    String? id,
    String? userId,
    int? week,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThoughtDump(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      week: week ?? this.week,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
