import 'package:flutter/material.dart';
import 'models/expense.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expense_detail_screen.dart';
import 'screens/expense_form_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/setup_check_screen.dart';

/// Centralized route definitions and generator for the Expense Tracker.
class ExpenseTrackerRoutes {
  static const String setup = '/';
  static const String dashboard = '/dashboard';
  static const String expenseList = '/expenses';
  static const String expenseDetail = '/expense-detail';
  static const String expenseForm = '/expense-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case setup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SetupCheckScreen(),
        );

      case dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );

      case expenseList:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExpenseListScreen(),
        );

      case expenseDetail:
        final expense = settings.arguments as Expense?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ExpenseDetailScreen(initialExpense: expense),
        );

      case expenseForm:
        final expense = settings.arguments as Expense?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ExpenseFormScreen(initialExpense: expense),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NotFoundScreen(routeName: settings.name),
        );
    }
  }
}
