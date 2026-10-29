import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../models/app_user.dart';

/// State management provider for user profile, currency symbol, and monthly budget.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AppUser _currentUser = AppUser.defaultProfile();
  bool _isLoading = false;

  AuthProvider(this._repository) {
    loadUser();
  }

  AppUser get currentUser => _currentUser;
  String get currencySymbol => _currentUser.currencySymbol;
  double get monthlyBudget => _currentUser.monthlyBudget;
  bool get isLoading => _isLoading;

  /// Loads current user from repository.
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();
    } catch (_) {
      _currentUser = AppUser.defaultProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the user's monthly budget.
  Future<void> updateMonthlyBudget(double budget) async {
    _currentUser = await _repository.updateBudget(budget);
    notifyListeners();
  }

  /// Updates the user's preferred currency symbol.
  Future<void> updateCurrency(String symbol) async {
    _currentUser = await _repository.updateCurrency(symbol);
    notifyListeners();
  }

  /// Updates user profile info (name, email, etc.).
  Future<void> updateUser(AppUser updatedUser) async {
    await _repository.saveUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}
