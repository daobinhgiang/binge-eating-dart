import 'package:cloud_firestore/cloud_firestore.dart';

class ImportanceItem {
  final String id;
  final String description;
  final double importance; // Percentage (0-100)

  const ImportanceItem({
    required this.id,
    required this.description,
    required this.importance,
  });

  factory ImportanceItem.fromMap(Map<String, dynamic> map) {
    return ImportanceItem(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      importance: (map['importance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'importance': importance,
    };
  }

  ImportanceItem copyWith({
    String? id,
    String? description,
    double? importance,
  }) {
    return ImportanceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      importance: importance ?? this.importance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportanceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ImportanceItem(id: $id, description: $description, importance: $importance%)';
  }
}

class AddressingOverconcern {
  final String id;
  final String userId;
  final List<ImportanceItem> importanceItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressingOverconcern({
    required this.id,
    required this.userId,
    required this.importanceItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressingOverconcern.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressingOverconcern(
      id: doc.id,
      userId: data['userId'] ?? '',
      importanceItems: (data['importanceItems'] as List<dynamic>? ?? [])
          .map((item) => ImportanceItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'importanceItems': importanceItems.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  AddressingOverconcern copyWith({
    String? id,
    String? userId,
    List<ImportanceItem>? importanceItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressingOverconcern(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      importanceItems: importanceItems ?? this.importanceItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get total importance (should ideally be 100%)
  double get totalImportance => importanceItems.fold(0.0, (sum, item) => sum + item.importance);

  // Check if percentages add up to 100% (with some tolerance)
  bool get isBalanced => (totalImportance - 100.0).abs() < 0.1;

  // Get normalized percentages (in case they don't add up to 100%)
  List<ImportanceItem> get normalizedItems {
    if (totalImportance == 0) return importanceItems;
    
    final factor = 100.0 / totalImportance;
    return importanceItems.map((item) => 
      item.copyWith(importance: item.importance * factor)
    ).toList();
  }

  // Total items count
  int get totalItems => importanceItems.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressingOverconcern && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AddressingOverconcern(id: $id, items: ${importanceItems.length})';
  }

  // Static helper for creating new instances
  static AddressingOverconcern createNew({
    required String userId,
    List<ImportanceItem>? importanceItems,
  }) {
    final now = DateTime.now();
    return AddressingOverconcern(
      id: '',
      userId: userId,
      importanceItems: importanceItems ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper to add item
  AddressingOverconcern addItem(ImportanceItem item) {
    final updatedItems = List<ImportanceItem>.from(importanceItems);
    updatedItems.add(item);
    return copyWith(
      importanceItems: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  // Helper to update item
  AddressingOverconcern updateItem(ImportanceItem updatedItem) {
    final updatedItems = importanceItems.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
    return copyWith(
      importanceItems: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  // Helper to remove item
  AddressingOverconcern removeItem(String itemId) {
    final updatedItems = importanceItems.where((item) => item.id != itemId).toList();
    return copyWith(
      importanceItems: updatedItems,
      updatedAt: DateTime.now(),
    );
  }
}
