import 'package:flutter/material.dart';

/// Supported categories for personal expenses with fintech palette styling.
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
        return 'Travel & Transit';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills & Utilities';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.other:
        return 'General / Other';
    }
  }

  /// Category icon representation.
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.travel:
        return Icons.commute_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.bills:
        return Icons.receipt_long_outlined;
      case ExpenseCategory.education:
        return Icons.school_outlined;
      case ExpenseCategory.other:
        return Icons.category_outlined;
    }
  }

  /// Primary color associated with this category.
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFF97316); // Amber Orange
      case ExpenseCategory.travel:
        return const Color(0xFF0284C7); // Cobalt Sky
      case ExpenseCategory.shopping:
        return const Color(0xFF7C3AED); // Modern Indigo-Violet
      case ExpenseCategory.bills:
        return const Color(0xFFE11D48); // Fintech Rose
      case ExpenseCategory.education:
        return const Color(0xFF059669); // Crisp Emerald
      case ExpenseCategory.other:
        return const Color(0xFF475569); // Slate Grey
    }
  }

  /// Background tint color for badge chips.
  Color get backgroundColor {
    return color.withValues(alpha: 0.12);
  }

  /// Subtle border tint for tags.
  Color get borderColor {
    return color.withValues(alpha: 0.28);
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
