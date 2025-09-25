import 'package:cloud_firestore/cloud_firestore.dart';

class UrgeEvent {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int urgeLevel; // 0-100
  final String? location;
  final List<String> triggers;
  final List<String> copingStrategies;
  final String? notes;
  final bool wasResisted; // true if user resisted the urge
  final String? outcome; // what happened after the urge

  const UrgeEvent({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.urgeLevel,
    this.location,
    this.triggers = const [],
    this.copingStrategies = const [],
    this.notes,
    this.wasResisted = false,
    this.outcome,
  });

  factory UrgeEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UrgeEvent(
      id: doc.id,
      userId: data['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      urgeLevel: data['urgeLevel'] ?? 0,
      location: data['location'],
      triggers: List<String>.from(data['triggers'] ?? []),
      copingStrategies: List<String>.from(data['copingStrategies'] ?? []),
      notes: data['notes'],
      wasResisted: data['wasResisted'] ?? false,
      outcome: data['outcome'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'urgeLevel': urgeLevel,
      'location': location,
      'triggers': triggers,
      'copingStrategies': copingStrategies,
      'notes': notes,
      'wasResisted': wasResisted,
      'outcome': outcome,
    };
  }

  UrgeEvent copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    int? urgeLevel,
    String? location,
    List<String>? triggers,
    List<String>? copingStrategies,
    String? notes,
    bool? wasResisted,
    String? outcome,
  }) {
    return UrgeEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      urgeLevel: urgeLevel ?? this.urgeLevel,
      location: location ?? this.location,
      triggers: triggers ?? this.triggers,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      notes: notes ?? this.notes,
      wasResisted: wasResisted ?? this.wasResisted,
      outcome: outcome ?? this.outcome,
    );
  }
}
