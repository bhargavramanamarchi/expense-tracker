import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// Repository handling local storage persistence of expenses via SharedPreferences.
class ExpenseRepository {
  static const String _storageKey = 'expense_tracker_items_v1';
  static const String _firstRunKey = 'expense_tracker_first_run_v1';

  final SharedPreferences? _prefs;

  ExpenseRepository([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Loads all stored expenses. If first launch, seeds demo items.
  Future<List<Expense>> loadExpenses() async {
    final prefs = await _getPrefs();
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;

    if (isFirstRun) {
      final initialExpenses = _createSeedExpenses();
      await saveExpenses(initialExpenses);
      await prefs.setBool(_firstRunKey, false);
      return initialExpenses;
    }

    final rawJson = prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // In case of parsing error, return empty list
      return [];
    }
  }

  /// Saves the complete list of expenses to SharedPreferences.
  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await _getPrefs();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Adds a new expense to storage.
  Future<List<Expense>> addExpense(Expense newExpense) async {
    final current = await loadExpenses();
    final updated = [newExpense, ...current];
    await saveExpenses(updated);
    return updated;
  }

  /// Updates an existing expense in storage.
  Future<List<Expense>> updateExpense(Expense updatedExpense) async {
    final current = await loadExpenses();
    final index = current.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      current[index] = updatedExpense;
      await saveExpenses(current);
    }
    return current;
  }

  /// Deletes an expense by its unique identifier.
  Future<List<Expense>> deleteExpense(String id) async {
    final current = await loadExpenses();
    current.removeWhere((e) => e.id == id);
    await saveExpenses(current);
    return current;
  }

  /// Removes only demo expenses.
  Future<List<Expense>> removeDemoExpenses() async {
    final current = await loadExpenses();
    current.removeWhere((e) => e.isDemo);
    await saveExpenses(current);
    return current;
  }

  /// Completely clears all saved expenses.
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }

  /// Resets dataset to the initial demo transactions.
  Future<List<Expense>> resetToDemoData() async {
    final demoExpenses = _createSeedExpenses();
    await saveExpenses(demoExpenses);
    return demoExpenses;
  }

  /// Generates initial realistic demo expenses for first launch.
  List<Expense> _createSeedExpenses() {
    final now = DateTime.now();
    return [
      Expense(
        id: 'seed_01',
        title: 'Supermarket Grocery Haul',
        amount: 3450.00,
        category: ExpenseCategory.food,
        date: now.subtract(const Duration(hours: 3)),
        description:
            'Organic vegetables, dairy, pulses, and pantry essentials from supermarket.',
        isDemo: true,
      ),
      Expense(
        id: 'seed_02',
        title: 'Metro Smart Card Transit Recharge',
        amount: 1200.00,
        category: ExpenseCategory.travel,
        date: now.subtract(const Duration(hours: 18)),
        description: 'Monthly commuter pass and subway smart card auto-topup.',
        isDemo: true,
      ),
      Expense(
        id: 'seed_03',
        title: 'High-speed Fiber Broadband',
        amount: 1099.00,
        category: ExpenseCategory.bills,
        date: now.subtract(const Duration(days: 2)),
        description:
            'Monthly home gigabit fiber optic internet connection bill.',
        isDemo: true,
      ),
      Expense(
        id: 'seed_04',
        title: 'Flutter Architecture Masterclass',
        amount: 999.00,
        category: ExpenseCategory.education,
        date: now.subtract(const Duration(days: 3)),
        description:
            'Advanced State Management & Design Patterns certification course.',
        isDemo: true,
      ),
      Expense(
        id: 'seed_05',
        title: 'Ergonomic Desk Workspace Mat',
        amount: 1450.00,
        category: ExpenseCategory.shopping,
        date: now.subtract(const Duration(days: 4)),
        description: 'Water-resistant dual-sided vegan leather desk pad.',
        isDemo: true,
      ),
      Expense(
        id: 'seed_06',
        title: 'Artisan Coffee & Breakfast',
        amount: 380.00,
        category: ExpenseCategory.food,
        date: now.subtract(const Duration(days: 5)),
        description: 'Flat white roast and sourdough croissant.',
        isDemo: true,
      ),
    ];
  }
}
