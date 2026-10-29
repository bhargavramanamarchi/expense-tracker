import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/expense_tracker/utils/expense_validators.dart';

void main() {
  group('ExpenseValidators.validateTitle', () {
    test('returns error for empty or whitespace title', () {
      expect(ExpenseValidators.validateTitle(null), isNotNull);
      expect(ExpenseValidators.validateTitle(''), isNotNull);
      expect(ExpenseValidators.validateTitle('   '), isNotNull);
    });

    test('returns error if title is shorter than 2 chars', () {
      expect(ExpenseValidators.validateTitle('A'), isNotNull);
    });

    test('returns error if title exceeds 50 chars', () {
      final longTitle = 'A' * 51;
      expect(ExpenseValidators.validateTitle(longTitle), isNotNull);
    });

    test('accepts valid titles', () {
      expect(ExpenseValidators.validateTitle('Coffee'), isNull);
      expect(ExpenseValidators.validateTitle('Train monthly ticket'), isNull);
    });
  });

  group('ExpenseValidators.validateAmount', () {
    test('returns error for null, empty or invalid strings', () {
      expect(ExpenseValidators.validateAmount(null), isNotNull);
      expect(ExpenseValidators.validateAmount(''), isNotNull);
      expect(ExpenseValidators.validateAmount('abc'), isNotNull);
    });

    test('returns error for negative or zero amounts', () {
      expect(ExpenseValidators.validateAmount('0'), isNotNull);
      expect(ExpenseValidators.validateAmount('-15.50'), isNotNull);
    });

    test('accepts valid positive numbers', () {
      expect(ExpenseValidators.validateAmount('12.50'), isNull);
      expect(ExpenseValidators.validateAmount('100'), isNull);
      expect(ExpenseValidators.validateAmount('1,500.00'), isNull);
    });
  });

  group('ExpenseValidators.validateDescription', () {
    test('accepts null or empty description', () {
      expect(ExpenseValidators.validateDescription(null), isNull);
      expect(ExpenseValidators.validateDescription(''), isNull);
    });

    test('rejects description longer than 250 characters', () {
      final longDesc = 'X' * 251;
      expect(ExpenseValidators.validateDescription(longDesc), isNotNull);
    });

    test('accepts description within length limit', () {
      expect(ExpenseValidators.validateDescription('Short note'), isNull);
    });
  });
}
