class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  // Copy with method for cloning with modified fields
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Other',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      if (description != null) 'description': description,
    };
  }

  static String categoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'coffee':
      case 'groceries':
        return '☕';
      case 'transport':
      case 'ride':
      case 'fuel':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'utilities':
        return '🏠';
      case 'entertainment':
      case 'subscription':
        return '🎬';
      default:
        return '💰';
    }
  }

  static String categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c == 'food' || c == 'coffee' || c == 'groceries') return 'food';
    if (c == 'transport' || c == 'ride' || c == 'fuel') return 'transport';
    if (c == 'shopping') return 'shopping';
    if (c == 'utilities') return 'utilities';
    if (c == 'entertainment' || c == 'subscription') return 'entertainment';
    return 'other';
  }
}
