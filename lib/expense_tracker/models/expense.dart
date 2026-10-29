import 'expense_category.dart';

/// Represents a single recorded expense transaction.
class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String description;
  final bool isDemo;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
    this.isDemo = false,
  });

  /// Creates a copy of this expense with modified fields.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? description,
    bool? isDemo,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  /// Converts the Expense instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'description': description,
      'isDemo': isDemo,
    };
  }

  /// Constructs an Expense instance from a JSON Map.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(json['category'] as String?),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          amount == other.amount &&
          category == other.category &&
          date == other.date &&
          description == other.description &&
          isDemo == other.isDemo;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      description.hashCode ^
      isDemo.hashCode;
}
