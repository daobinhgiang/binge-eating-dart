import 'package:cloud_firestore/cloud_firestore.dart';

class AlternativeActivity {
  final String id;
  final String name;
  final String description;
  final bool isActive;      // Active vs passive
  final bool isEnjoyable;   // Enjoyable vs chore
  final bool isRealistic;   // Realistic vs unlikely

  const AlternativeActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.isEnjoyable,
    required this.isRealistic,
  });

  factory AlternativeActivity.fromMap(Map<String, dynamic> map) {
    return AlternativeActivity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? false,
      isEnjoyable: map['isEnjoyable'] ?? false,
      isRealistic: map['isRealistic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'isEnjoyable': isEnjoyable,
      'isRealistic': isRealistic,
    };
  }

  AlternativeActivity copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    bool? isEnjoyable,
    bool? isRealistic,
  }) {
    return AlternativeActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isEnjoyable: isEnjoyable ?? this.isEnjoyable,
      isRealistic: isRealistic ?? this.isRealistic,
    );
  }

  // Check if activity meets all three criteria
  bool get meetsAllCriteria => isActive && isEnjoyable && isRealistic;

  // Get count of met criteria
  int get criteriaCount {
    int count = 0;
    if (isActive) count++;
    if (isEnjoyable) count++;
    if (isRealistic) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlternativeActivity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AlternativeActivity(id: $id, name: $name, criteria: $criteriaCount/3)';
  }
}

class UrgeSurfing {
  final String id;
  final String userId;
  final String title;
  final String notes;
  final List<AlternativeActivity> activities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UrgeSurfing({
    required this.id,
    required this.userId,
    required this.title,
    required this.notes,
    required this.activities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UrgeSurfing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UrgeSurfing(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      notes: data['notes'] ?? '',
      activities: (data['activities'] as List<dynamic>? ?? [])
          .map((activity) => AlternativeActivity.fromMap(activity as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'notes': notes,
      'activities': activities.map((activity) => activity.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  UrgeSurfing copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    List<AlternativeActivity>? activities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrgeSurfing(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get activities that meet all criteria
  List<AlternativeActivity> get idealActivities => 
      activities.where((activity) => activity.meetsAllCriteria).toList();

  // Get activities by criteria count
  List<AlternativeActivity> getActivitiesByCriteriaCount(int count) =>
      activities.where((activity) => activity.criteriaCount == count).toList();

  // Check if the list is complete (has good activities)
  bool get isComplete => activities.isNotEmpty && idealActivities.isNotEmpty;

  // Get completion percentage
  double get completionRate {
    if (activities.isEmpty) return 0.0;
    return idealActivities.length / activities.length;
  }

  // Total activities count
  int get totalActivities => activities.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrgeSurfing && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UrgeSurfing(id: $id, title: $title, activities: ${activities.length})';
  }

  // Static helper for creating new instances
  static UrgeSurfing createNew({
    required String userId,
    String title = 'My Urge Surfing Activities',
    String notes = '',
    List<AlternativeActivity>? activities,
  }) {
    final now = DateTime.now();
    return UrgeSurfing(
      id: '',
      userId: userId,
      title: title,
      notes: notes,
      activities: activities ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper to add activity
  UrgeSurfing addActivity(AlternativeActivity activity) {
    final updatedActivities = List<AlternativeActivity>.from(activities);
    updatedActivities.add(activity);
    return copyWith(
      activities: updatedActivities,
      updatedAt: DateTime.now(),
    );
  }

  // Helper to update activity
  UrgeSurfing updateActivity(AlternativeActivity updatedActivity) {
    final updatedActivities = activities.map((activity) {
      return activity.id == updatedActivity.id ? updatedActivity : activity;
    }).toList();
    return copyWith(
      activities: updatedActivities,
      updatedAt: DateTime.now(),
    );
  }

  // Helper to remove activity
  UrgeSurfing removeActivity(String activityId) {
    final updatedActivities = activities.where((activity) => activity.id != activityId).toList();
    return copyWith(
      activities: updatedActivities,
      updatedAt: DateTime.now(),
    );
  }
}
