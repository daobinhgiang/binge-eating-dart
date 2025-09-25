import 'package:cloud_firestore/cloud_firestore.dart';

class AddressingSetbacks {
  final String id;
  final String userId;
  final String problemCause;
  final String trigger;
  final String addressPlan;
  final DateTime setbackDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isComplete;

  const AddressingSetbacks({
    required this.id,
    required this.userId,
    required this.problemCause,
    required this.trigger,
    required this.addressPlan,
    required this.setbackDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isComplete,
  });

  factory AddressingSetbacks.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressingSetbacks(
      id: doc.id,
      userId: data['userId'] ?? '',
      problemCause: data['problemCause'] ?? '',
      trigger: data['trigger'] ?? '',
      addressPlan: data['addressPlan'] ?? '',
      setbackDate: DateTime.fromMillisecondsSinceEpoch(data['setbackDate'] ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
      isComplete: data['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'problemCause': problemCause,
      'trigger': trigger,
      'addressPlan': addressPlan,
      'setbackDate': setbackDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isComplete': isComplete,
    };
  }

  AddressingSetbacks copyWith({
    String? id,
    String? userId,
    String? problemCause,
    String? trigger,
    String? addressPlan,
    DateTime? setbackDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isComplete,
  }) {
    return AddressingSetbacks(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      problemCause: problemCause ?? this.problemCause,
      trigger: trigger ?? this.trigger,
      addressPlan: addressPlan ?? this.addressPlan,
      setbackDate: setbackDate ?? this.setbackDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  // Check if all required fields are filled
  bool get hasRequiredFields => 
      problemCause.trim().isNotEmpty && 
      trigger.trim().isNotEmpty && 
      addressPlan.trim().isNotEmpty;

  // Get a brief summary for display
  String get summary => problemCause.length > 50 
      ? '${problemCause.substring(0, 50)}...' 
      : problemCause;

  // Get time since setback
  String get timeSinceSetback {
    final now = DateTime.now();
    final difference = now.difference(setbackDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressingSetbacks && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AddressingSetbacks(id: $id, problemCause: ${problemCause.substring(0, problemCause.length > 20 ? 20 : problemCause.length)}, isComplete: $isComplete)';
  }

  // Static helper for creating new instances
  static AddressingSetbacks createNew({
    required String userId,
    String problemCause = '',
    String trigger = '',
    String addressPlan = '',
    DateTime? setbackDate,
  }) {
    final now = DateTime.now();
    return AddressingSetbacks(
      id: '',
      userId: userId,
      problemCause: problemCause,
      trigger: trigger,
      addressPlan: addressPlan,
      setbackDate: setbackDate ?? now,
      createdAt: now,
      updatedAt: now,
      isComplete: false,
    );
  }

  // Helper to mark as complete
  AddressingSetbacks markComplete() {
    return copyWith(
      isComplete: hasRequiredFields,
      updatedAt: DateTime.now(),
    );
  }

  // Helper to update fields
  AddressingSetbacks updateFields({
    String? problemCause,
    String? trigger,
    String? addressPlan,
    DateTime? setbackDate,
  }) {
    final updated = copyWith(
      problemCause: problemCause,
      trigger: trigger,
      addressPlan: addressPlan,
      setbackDate: setbackDate,
      updatedAt: DateTime.now(),
    );
    return updated.copyWith(isComplete: updated.hasRequiredFields);
  }
}

