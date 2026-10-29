import 'package:flutter/material.dart';

/// Supported categories for personal expenses.
enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  education,
  other;

  /// Returns a clean, user-friendly display name.
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.travel:
        return 'Travel & Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills & Utilities';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Category icon representation.
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.travel:
        return Icons.directions_subway_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  /// Primary color associated with this category.
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF7043); // Orange
      case ExpenseCategory.travel:
        return const Color(0xFF29B6F6); // Light Blue
      case ExpenseCategory.shopping:
        return const Color(0xFFAB47BC); // Purple
      case ExpenseCategory.bills:
        return const Color(0xFFEF5350); // Red
      case ExpenseCategory.education:
        return const Color(0xFF26A69A); // Teal
      case ExpenseCategory.other:
        return const Color(0xFF78909C); // Blue Grey
    }
  }

  /// Background tint color for badge chips.
  Color get backgroundColor {
    return color.withValues(alpha: 0.15);
  }

  /// Parses a string to an [ExpenseCategory], defaulting to [ExpenseCategory.other].
  static ExpenseCategory fromString(String? value) {
    if (value == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (cat) => cat.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
