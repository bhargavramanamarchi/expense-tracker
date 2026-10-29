import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../routes.dart';
import '../utils/app_messages.dart';

/// Detailed view of a single expense transaction.
class ExpenseDetailScreen extends StatelessWidget {
  final Expense? initialExpense;

  const ExpenseDetailScreen({super.key, this.initialExpense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currencySymbol = authProvider.currentUser.currencySymbol;

    // Retrieve active instance from provider or passed argument
    final expense = initialExpense != null
        ? expenseProvider.getExpenseById(initialExpense!.id) ?? initialExpense!
        : null;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text('Expense not found or has been removed.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final category = expense.category;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Expense',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(ExpenseTrackerRoutes.expenseForm, arguments: expense);
            },
          ),
          IconButton(
            tooltip: 'Delete Expense',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _handleDelete(context, expense),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Amount Display Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        category.backgroundColor,
                        theme.colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 36,
                          color: category.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppMessages.formatCurrency(
                          expense.amount,
                          symbol: currencySymbol,
                        ),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (expense.isDemo) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'SAMPLE DEMO RECORD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Detailed Info Tiles
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: category.displayName,
                        valueColor: category.color,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Date & Time',
                        value: AppMessages.formatDateTime(expense.date),
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Description',
                        value: expense.description.isNotEmpty
                            ? expense.description
                            : 'No additional notes provided.',
                        isMultiLine: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      onPressed: () => _handleDelete(context, expense),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Expense'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          ExpenseTrackerRoutes.expenseForm,
                          arguments: expense,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiLine = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, Expense expense) async {
    final confirmed = await AppMessages.showConfirmDialog(
      context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete "${expense.title}"?',
      confirmLabel: 'Delete',
    );

    if (confirmed && context.mounted) {
      final success = await context.read<ExpenseProvider>().deleteExpense(
        expense.id,
      );
      if (context.mounted) {
        if (success) {
          AppMessages.showSuccess(context, 'Expense deleted');
          Navigator.of(context).pop();
        } else {
          AppMessages.showError(context, 'Could not delete expense');
        }
      }
    }
  }
}
