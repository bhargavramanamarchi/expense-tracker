import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_providers.dart';
import '../routes.dart';

/// Initial loading and environment check screen.
class SetupCheckScreen extends StatefulWidget {
  const SetupCheckScreen({super.key});

  @override
  State<SetupCheckScreen> createState() => _SetupCheckScreenState();
}

class _SetupCheckScreenState extends State<SetupCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    // Ensure providers have initialized
    final expenseProvider = context.read<ExpenseProvider>();
    if (expenseProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(ExpenseTrackerRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Expense Tracker',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personal Financial Ledger & Analytics',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
