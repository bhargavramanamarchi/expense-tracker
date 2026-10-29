import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets(
    'ExpenseTrackerApp smoke test loads and transitions to dashboard',
    (WidgetTester tester) async {
      // Mock initial shared preferences in memory
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const ExpenseTrackerApp());
      // Initial frame shows setup screen
      expect(find.text('Expense Tracker'), findsOneWidget);

      // Pump and settle to let the 300ms timer and navigation complete
      await tester.pumpAndSettle();

      // Verify dashboard has loaded with title
      expect(find.text('Expense Tracker'), findsOneWidget);
      expect(find.text('Financial Overview'), findsOneWidget);
    },
  );
}
