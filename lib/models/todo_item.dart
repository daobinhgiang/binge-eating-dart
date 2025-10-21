import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_template.dart';

enum TodoType {
  lesson,
  tool,
  journal,
}

class TodoItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TodoType type;
  final String activityId; // ID or identifier for the specific lesson/tool/journal activity
  final Map<String, dynamic>? activityData; // Additional data about the activity (e.g., chapter/lesson numbers, tool type)
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // New tier-related fields
  final TaskTier? tier;                    // Seeds, GrowthTasks, MasteryQuests
  final String? templateId;                // Reference to template
  final String? regenerationBatchId;       // Track regeneration batches
  final DateTime? autoDeleteDate;          // Auto-clear date for Seeds/Growth Tasks
  final Map<String, dynamic>? tierMetadata; // Tier-specific data

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
    this.tier,
    this.templateId,
    this.regenerationBatchId,
    this.autoDeleteDate,
    this.tierMetadata,
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
        orElse: () => TodoType.lesson,
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
      tier: data['tier'] != null
          ? TaskTier.values.firstWhere(
              (e) => e.toString() == 'TaskTier.${data['tier']}',
              orElse: () => TaskTier.seeds,
            )
          : null,
      templateId: data['templateId'],
      regenerationBatchId: data['regenerationBatchId'],
      autoDeleteDate: data['autoDeleteDate'] != null
          ? _parseDateTime(data['autoDeleteDate'])
          : null,
      tierMetadata: data['tierMetadata'] != null
          ? Map<String, dynamic>.from(data['tierMetadata'])
          : null,
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
      'tier': tier?.toString().split('.').last,
      'templateId': templateId,
      'regenerationBatchId': regenerationBatchId,
      'autoDeleteDate': autoDeleteDate != null ? Timestamp.fromDate(autoDeleteDate!) : null,
      'tierMetadata': tierMetadata,
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
    TaskTier? tier,
    String? templateId,
    String? regenerationBatchId,
    DateTime? autoDeleteDate,
    Map<String, dynamic>? tierMetadata,
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
      tier: tier ?? this.tier,
      templateId: templateId ?? this.templateId,
      regenerationBatchId: regenerationBatchId ?? this.regenerationBatchId,
      autoDeleteDate: autoDeleteDate ?? this.autoDeleteDate,
      tierMetadata: tierMetadata ?? this.tierMetadata,
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
      case TodoType.lesson:
        return 'Lesson';
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

  // Helper methods for tiers
  bool get isSeed => tier == TaskTier.seeds;
  bool get isGrowthTask => tier == TaskTier.growthTasks;
  bool get isMasteryQuest => tier == TaskTier.masteryQuests;
  
  String get tierDisplayName {
    if (tier == null) return 'Quest';
    switch (tier!) {
      case TaskTier.seeds:
        return 'Daily Seed';
      case TaskTier.growthTasks:
        return 'Growth Task';
      case TaskTier.masteryQuests:
        return 'Mastery Quest';
    }
  }
  
  int get expReward {
    if (tierMetadata != null && tierMetadata!.containsKey('expReward')) {
      return tierMetadata!['expReward'] as int;
    }
    // Default EXP rewards by tier
    if (tier == null) return 50;
    switch (tier!) {
      case TaskTier.seeds:
        return 50;
      case TaskTier.growthTasks:
        return 200;
      case TaskTier.masteryQuests:
        return 500;
    }
  }
  
  // Helper methods for progress-based quests (like "Complete 3 Lessons")
  
  /// Check if this quest tracks progress (has requiredCount)
  bool get hasProgress {
    return tierMetadata != null && 
           tierMetadata!.containsKey('requiredCount');
  }
  
  /// Get the current progress count (e.g., 2 lessons completed)
  int get currentCount {
    if (tierMetadata != null && tierMetadata!.containsKey('currentCount')) {
      return tierMetadata!['currentCount'] as int? ?? 0;
    }
    return 0;
  }
  
  /// Get the required count to complete (e.g., 3 lessons needed)
  int get requiredCount {
    if (tierMetadata != null && tierMetadata!.containsKey('requiredCount')) {
      return tierMetadata!['requiredCount'] as int? ?? 1;
    }
    return 1;
  }
  
  /// Get progress as a percentage (0.0 to 1.0)
  double get progressPercentage {
    if (!hasProgress) return 0.0;
    if (requiredCount == 0) return 0.0;
    final progress = currentCount / requiredCount;
    return progress > 1.0 ? 1.0 : progress; // Cap at 100%
  }
  
  /// Get progress as a string (e.g., "2/3")
  String get progressString {
    if (!hasProgress) return '';
    return '$currentCount/$requiredCount';
  }
  
  /// Check if this quest is about to be completed (one more action needed)
  bool get isAlmostComplete {
    if (!hasProgress || isCompleted) return false;
    return currentCount >= requiredCount - 1;
  }
}
