import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_item.dart';

enum TaskTier {
  seeds,           // Daily tasks
  growthTasks,     // Weekly tasks
  masteryQuests,   // Persistent tasks
}

class TaskTemplate {
  final String id;
  final String category;      // 'journaling', 'exercises', 'lessons'
  final TaskTier tier;
  final String title;
  final String description;
  final String? activityId;   // Reference to actual activity
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int expReward;        // EXP awarded on completion

  const TaskTemplate({
    required this.id,
    required this.category,
    required this.tier,
    required this.title,
    required this.description,
    this.activityId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.expReward = 50,
  });

  factory TaskTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TaskTemplate(
      id: doc.id,
      category: data['category'] ?? '',
      tier: TaskTier.values.firstWhere(
        (e) => e.toString() == 'TaskTier.${data['tier']}',
        orElse: () => TaskTier.seeds,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      activityId: data['activityId'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      expReward: data['expReward'] ?? 50,
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
      'category': category,
      'tier': tier.toString().split('.').last,
      'title': title,
      'description': description,
      'activityId': activityId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expReward': expReward,
    };
  }

  // Convert template to TodoItem instance
  TodoItem toTodoItem(String userId, DateTime dueDate, {String? regenerationBatchId}) {
    final now = DateTime.now();
    final docId = '${userId}_${tier.toString().split('.').last}_${now.millisecondsSinceEpoch}';
    
    // Convert category to TodoType
    TodoType todoType;
    switch (category.toLowerCase()) {
      case 'lessons':
        todoType = TodoType.lesson;
        break;
      case 'exercises':
      case 'tools':
        todoType = TodoType.tool;
        break;
      case 'journaling':
      case 'journal':
        todoType = TodoType.journal;
        break;
      default:
        todoType = TodoType.lesson;
    }

    return TodoItem(
      id: docId,
      userId: userId,
      title: title,
      description: description,
      type: todoType,
      activityId: activityId ?? '',
      activityData: metadata,
      dueDate: dueDate,
      isCompleted: false,
      completedAt: null,
      createdAt: now,
      updatedAt: now,
      tier: tier,
      templateId: id,
      regenerationBatchId: regenerationBatchId,
      autoDeleteDate: _calculateAutoDeleteDate(tier, dueDate),
      tierMetadata: {
        'expReward': expReward,
      },
    );
  }

  DateTime? _calculateAutoDeleteDate(TaskTier tier, DateTime dueDate) {
    switch (tier) {
      case TaskTier.seeds:
        // Delete at end of day (11:59 PM)
        return DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59);
      case TaskTier.growthTasks:
        // Delete at end of week (Sunday 11:59 PM)
        final endOfWeek = dueDate.add(Duration(days: 7 - dueDate.weekday));
        return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
      case TaskTier.masteryQuests:
        // Never auto-delete
        return null;
    }
  }

  TaskTemplate copyWith({
    String? id,
    String? category,
    TaskTier? tier,
    String? title,
    String? description,
    String? activityId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? expReward,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      title: title ?? this.title,
      description: description ?? this.description,
      activityId: activityId ?? this.activityId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expReward: expReward ?? this.expReward,
    );
  }

  @override
  String toString() {
    return 'TaskTemplate(id: $id, title: $title, tier: $tier, category: $category)';
  }
}

