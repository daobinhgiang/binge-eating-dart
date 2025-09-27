import 'package:cloud_firestore/cloud_firestore.dart';

enum TodoType {
  tool,
  journal,
}

class TodoItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TodoType type;
  final String activityId; // ID or identifier for the specific tool/journal activity
  final Map<String, dynamic>? activityData; // Additional data about the activity (e.g., tool type)
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.activityId,
    this.activityData,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoItem.fromFirestore(DocumentSnapshot doc, {String? userId}) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Extract userId from document path if not provided
    String finalUserId = userId ?? '';
    if (finalUserId.isEmpty && doc.reference.path.contains('/users/')) {
      final pathParts = doc.reference.path.split('/');
      final userIndex = pathParts.indexOf('users');
      if (userIndex >= 0 && userIndex + 1 < pathParts.length) {
        finalUserId = pathParts[userIndex + 1];
      }
    }
    
    return TodoItem(
      id: doc.id,
      userId: finalUserId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: TodoType.values.firstWhere(
        (e) => e.toString() == 'TodoType.${data['type']}',
        orElse: () => TodoType.tool,
      ),
      activityId: data['activityId'] ?? '',
      activityData: data['activityData'] != null 
          ? Map<String, dynamic>.from(data['activityData'])
          : null,
      dueDate: _parseDateTime(data['dueDate']),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? _parseDateTime(data['completedAt'])
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  // Helper method to parse DateTime from either Timestamp or int
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    } else {
      // Fallback to current time if we can't parse
      return DateTime.now();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last, // Convert enum to string
      'activityId': activityId,
      'activityData': activityData,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TodoItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TodoType? type,
    String? activityId,
    Map<String, dynamic>? activityData,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      activityId: activityId ?? this.activityId,
      activityData: activityData ?? this.activityData,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, type: $type, dueDate: $dueDate, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case TodoType.tool:
        return 'Tool';
      case TodoType.journal:
        return 'Journal';
    }
  }

  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate);
  }

  bool get isDueToday {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.isAtSameMomentAs(due);
  }

  bool get isDueSoon {
    if (isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 3; // Due within 3 days
  }
}
