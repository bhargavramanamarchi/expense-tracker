/// Validation helpers for expense form input fields.
class ExpenseValidators {
  /// Validates the title of an expense.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title for the expense';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Title must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'Title must not exceed 50 characters';
    }
    return null;
  }

  /// Validates the monetary amount of an expense.
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final sanitized = value.trim().replaceAll(',', '');
    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    if (parsed > 1000000) {
      return 'Amount cannot exceed 1,000,000';
    }
    return null;
  }

  /// Validates the optional description field.
  static String? validateDescription(String? value) {
    if (value != null && value.trim().length > 250) {
      return 'Description cannot exceed 250 characters';
    }
    return null;
  }
}
