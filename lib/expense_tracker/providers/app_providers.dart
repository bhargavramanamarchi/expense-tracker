import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/auth_repository.dart';
import '../data/expense_repository.dart';
import 'auth_providers.dart';
import 'expense_providers.dart';

/// Provider for app theme (System, Light, Dark).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Helper that configures all necessary providers for the application widget tree.
class AppProviders {
  static List<SingleChildWidget> buildProviders({
    ExpenseRepository? expenseRepository,
    AuthRepository? authRepository,
  }) {
    final expRepo = expenseRepository ?? ExpenseRepository();
    final aRepo = authRepository ?? AuthRepository();

    return [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(aRepo)),
      ChangeNotifierProvider<ExpenseProvider>(
        create: (_) => ExpenseProvider(expRepo),
      ),
    ];
  }
}
