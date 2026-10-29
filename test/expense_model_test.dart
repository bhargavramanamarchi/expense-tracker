import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/expense_tracker/models/expense.dart';
import 'package:expense_tracker/expense_tracker/models/expense_category.dart';
import 'package:expense_tracker/expense_tracker/models/app_user.dart';

void main() {
  group('ExpenseCategory Tests', () {
    test('fromString parses valid names correctly', () {
      expect(ExpenseCategory.fromString('food'), ExpenseCategory.food);
      expect(ExpenseCategory.fromString('travel'), ExpenseCategory.travel);
      expect(ExpenseCategory.fromString('shopping'), ExpenseCategory.shopping);
      expect(ExpenseCategory.fromString('bills'), ExpenseCategory.bills);
      expect(
        ExpenseCategory.fromString('education'),
        ExpenseCategory.education,
      );
      expect(ExpenseCategory.fromString('other'), ExpenseCategory.other);
    });

    test('fromString defaults to other for invalid or null string', () {
      expect(ExpenseCategory.fromString(null), ExpenseCategory.other);
      expect(
        ExpenseCategory.fromString('unknown_category'),
        ExpenseCategory.other,
      );
    });

    test('displayName returns user-friendly label', () {
      expect(ExpenseCategory.food.displayName, 'Food & Dining');
      expect(ExpenseCategory.bills.displayName, 'Bills & Utilities');
    });
  });

  group('Expense Model Tests', () {
    test('toJson and fromJson serialize correctly', () {
      final now = DateTime(2026, 10, 29, 10, 0, 0);
      final expense = Expense(
        id: 'test_123',
        title: 'Lunch with Team',
        amount: 32.50,
        category: ExpenseCategory.food,
        date: now,
        description: 'Italian bistro lunch',
        isDemo: true,
      );

      final json = expense.toJson();
      expect(json['id'], 'test_123');
      expect(json['title'], 'Lunch with Team');
      expect(json['amount'], 32.50);
      expect(json['category'], 'food');
      expect(json['description'], 'Italian bistro lunch');
      expect(json['isDemo'], true);

      final reconstructed = Expense.fromJson(json);
      expect(reconstructed.id, expense.id);
      expect(reconstructed.title, expense.title);
      expect(reconstructed.amount, expense.amount);
      expect(reconstructed.category, expense.category);
      expect(reconstructed.date, expense.date);
      expect(reconstructed.description, expense.description);
      expect(reconstructed.isDemo, expense.isDemo);
    });

    test('copyWith updates specified fields only', () {
      final original = Expense(
        id: '1',
        title: 'Original Title',
        amount: 10.0,
        category: ExpenseCategory.other,
        date: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(title: 'Updated Title', amount: 25.0);

      expect(updated.id, '1');
      expect(updated.title, 'Updated Title');
      expect(updated.amount, 25.0);
      expect(updated.category, ExpenseCategory.other);
    });
  });

  group('AppUser Model Tests', () {
    test('defaultProfile initializes sensible defaults', () {
      final user = AppUser.defaultProfile();
      expect(user.currencySymbol, '₹');
      expect(user.monthlyBudget, greaterThan(0));
      expect(user.name.isNotEmpty, true);
    });

    test('toJson and fromJson work correctly', () {
      final user = AppUser(
        id: 'u1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        currencySymbol: '€',
        monthlyBudget: 3000.0,
      );

      final json = user.toJson();
      final reconstructed = AppUser.fromJson(json);

      expect(reconstructed.id, user.id);
      expect(reconstructed.name, user.name);
      expect(reconstructed.currencySymbol, '€');
      expect(reconstructed.monthlyBudget, 3000.0);
    });
  });
}
