import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_tracker/providers/app_providers.dart';
import 'expense_tracker/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

/// Root widget of the application, configuring providers, premium fintech themes, and routing.
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
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            initialRoute: ExpenseTrackerRoutes.setup,
            onGenerateRoute: ExpenseTrackerRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }

  static ThemeData _buildLightTheme() {
    const primaryNavy = Color(0xFF0F172A);
    const accentIndigo = Color(0xFF4F46E5);
    const bgSlate = Color(0xFFF8FAFC);
    const borderSlate = Color(0xFFE2E8F0);

    final colorScheme = ColorScheme.light(
      primary: primaryNavy,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEEF2FF),
      onPrimaryContainer: const Color(0xFF312E81),
      secondary: accentIndigo,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE0E7FF),
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainer: const Color(0xFFF1F5F9),
      surfaceContainerHighest: const Color(0xFFE2E8F0),
      outline: const Color(0xFF94A3B8),
      outlineVariant: borderSlate,
      error: const Color(0xFFE11D48),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgSlate,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSlate, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSlate, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSlate, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentIndigo, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSlate,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    const primaryIndigo = Color(0xFF818CF8);
    const accentSky = Color(0xFF38BDF8);
    const darkBg = Color(0xFF0B0F19);
    const darkSurface = Color(0xFF111827);
    const darkBorder = Color(0xFF1E293B);

    final colorScheme = ColorScheme.dark(
      primary: primaryIndigo,
      onPrimary: const Color(0xFF0F172A),
      primaryContainer: const Color(0xFF1E1B4B),
      onPrimaryContainer: const Color(0xFFC7D2FE),
      secondary: accentSky,
      onSecondary: const Color(0xFF0F172A),
      secondaryContainer: const Color(0xFF082F49),
      surface: darkSurface,
      onSurface: const Color(0xFFF8FAFC),
      surfaceContainerLow: const Color(0xFF0E1424),
      surfaceContainer: const Color(0xFF161F30),
      surfaceContainerHighest: const Color(0xFF1E293B),
      outline: const Color(0xFF64748B),
      outlineVariant: darkBorder,
      error: const Color(0xFFF43F5E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF161F30),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryIndigo, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
