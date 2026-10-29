import 'package:flutter/material.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// State management provider for expense items, filtering, searching, and calculations.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  List<Expense> _expenses = [];
  ExpenseCategory? _selectedCategoryFilter;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  ExpenseProvider(this._repository) {
    loadExpenses();
  }

  // Getters
  List<Expense> get allExpenses => List.unmodifiable(_expenses);
  ExpenseCategory? get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasExpenses => _expenses.isNotEmpty;
  bool get hasDemoData => _expenses.any((e) => e.isDemo);

  /// Top 5 most recent expenses sorted by date descending.
  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  /// Expenses filtered by the selected category and search query.
  List<Expense> get filteredExpenses {
    return _expenses.where((expense) {
      final matchesCategory =
          _selectedCategoryFilter == null ||
          expense.category == _selectedCategoryFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Total sum of all expenses.
  double get totalSpending {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum of expenses filtered currently.
  double get filteredTotalSpending {
    return filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum of expenses recorded for today.
  double get todaySpending {
    final now = DateTime.now();
    return _expenses
        .where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month &&
              expense.date.day == now.day;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum of expenses recorded for the current month.
  double get thisMonthSpending {
    final now = DateTime.now();
    return _expenses
        .where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Breakdown of total spending grouped by Category.
  Map<ExpenseCategory, double> get spendingByCategory {
    final map = <ExpenseCategory, double>{};
    for (final cat in ExpenseCategory.values) {
      map[cat] = 0.0;
    }
    for (final expense in _expenses) {
      map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
    }
    return map;
  }

  /// Retrieves a specific expense by ID.
  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Actions

  /// Loads expenses from storage.
  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.loadExpenses();
    } catch (e) {
      _errorMessage = 'Failed to load expenses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new expense item.
  Future<bool> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String description = '',
  }) async {
    final newExpense = Expense(
      id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description.trim(),
      isDemo: false,
    );

    try {
      _expenses = await _repository.addExpense(newExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing expense item.
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      _expenses = await _repository.updateExpense(updatedExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes an expense by its ID.
  Future<bool> deleteExpense(String id) async {
    try {
      _expenses = await _repository.deleteExpense(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clears only demo seeded expenses.
  Future<void> clearDemoExpenses() async {
    try {
      _expenses = await _repository.removeDemoExpenses();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove demo data: $e';
      notifyListeners();
    }
  }

  /// Resets dataset back to the demo items.
  Future<void> resetToDemoData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _repository.resetToDemoData();
    } catch (e) {
      _errorMessage = 'Failed to reset demo data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets category filter (null for all categories).
  void setCategoryFilter(ExpenseCategory? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  /// Sets text search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
