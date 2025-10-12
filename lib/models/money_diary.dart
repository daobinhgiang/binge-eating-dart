import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyDiary {
  final String id;
  final String userId;
  final int week; // Week number since user first used the app
  final double amount; // Amount spent on binging
  final String currency; // Currency symbol/code (e.g., '$', '€', 'USD')
  final String description; // What was purchased/spent on
  final DateTime spentAt; // When the money was spent
  final String? notes; // Additional notes about the spending
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoneyDiary({
    required this.id,
    required this.userId,
    required this.week,
    required this.amount,
    required this.currency,
    required this.description,
    required this.spentAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoneyDiary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoneyDiary(
      id: doc.id,
      userId: data['userId'] ?? '',
      week: data['week'] ?? 1,
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? '\$',
      description: data['description'] ?? '',
      spentAt: DateTime.fromMillisecondsSinceEpoch(data['spentAt'] ?? 0),
      notes: data['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'week': week,
      'amount': amount,
      'currency': currency,
      'description': description,
      'spentAt': spentAt.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  MoneyDiary copyWith({
    String? id,
    String? userId,
    int? week,
    double? amount,
    String? currency,
    String? description,
    DateTime? spentAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoneyDiary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      week: week ?? this.week,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      spentAt: spentAt ?? this.spentAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MoneyDiary(id: $id, week: $week, amount: $amount $currency, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoneyDiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static constants for currency options
  static const List<String> currencyOptions = [
    '\$', // USD
    '€', // EUR
    '£', // GBP
    '¥', // JPY/CNY
    'CAD',
    'AUD',
    'CHF',
    'SEK',
    'NOK',
    'DKK',
  ];

  // Static constants for common spending categories
  static const List<String> spendingCategories = [
    'Fast food',
    'Takeout/Delivery',
    'Groceries (binge foods)',
    'Convenience store',
    'Restaurant',
    'Vending machine',
    'Coffee shop',
    'Bakery',
    'Other',
  ];
}
