import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_tracker/providers/app_providers.dart';
import 'expense_tracker/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

/// Root widget of the application, configuring providers, themes, and routing.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.buildProviders(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF1E88E5), // Clean modern Blue
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
              cardTheme: const CardThemeData(elevation: 1),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF1E88E5),
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
              cardTheme: const CardThemeData(elevation: 1),
            ),
            initialRoute: ExpenseTrackerRoutes.setup,
            onGenerateRoute: ExpenseTrackerRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
