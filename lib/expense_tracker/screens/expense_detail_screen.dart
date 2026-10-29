import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../routes.dart';
import '../utils/app_messages.dart';

/// Detailed view of a single expense transaction with receipt-like fintech card.
class ExpenseDetailScreen extends StatelessWidget {
  final Expense? initialExpense;

  const ExpenseDetailScreen({super.key, this.initialExpense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currencySymbol = authProvider.currentUser.currencySymbol;

    final expense = initialExpense != null
        ? expenseProvider.getExpenseById(initialExpense!.id) ?? initialExpense!
        : null;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              const Text('Transaction not found or has been deleted.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Transactions'),
              ),
            ],
          ),
        ),
      );
    }

    final category = expense.category;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Transaction',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(ExpenseTrackerRoutes.expenseForm, arguments: expense);
            },
          ),
          IconButton(
            tooltip: 'Delete Transaction',
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Color(0xFFE11D48),
            ),
            onPressed: () => _handleDelete(context, expense),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Receipt / Ledger Card
              Card(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              category.backgroundColor.withValues(alpha: 0.15),
                              theme.colorScheme.surface,
                            ]
                          : [
                              category.backgroundColor.withValues(alpha: 0.3),
                              Colors.white,
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Category Icon Squircle
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: category.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: category.borderColor),
                        ),
                        child: Icon(
                          category.icon,
                          size: 32,
                          color: category.color,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Large Amount in INR
                      Text(
                        '- ${AppMessages.formatCurrency(expense.amount, symbol: currencySymbol)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Status Pills
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Recorded',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (expense.isDemo) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'SAMPLE RECORD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Transaction Metadata Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                        icon: Icons.tag_rounded,
                        label: 'Reference ID',
                        value: expense.id,
                        isMono: true,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        icon: Icons.notes_rounded,
                        label: 'Notes',
                        value: expense.description.isNotEmpty
                            ? expense.description
                            : 'No additional notes provided for this transaction.',
                        isMultiLine: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFE11D48),
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFE11D48)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE11D48)),
                      ),
                      onPressed: () => _handleDelete(context, expense),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Transaction'),
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
    bool isMono = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
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
              fontFamily: isMono ? 'monospace' : null,
              fontSize: isMono ? 12 : null,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, Expense expense) async {
    final confirmed = await AppMessages.showConfirmDialog(
      context,
      title: 'Delete Transaction?',
      message:
          'Are you sure you want to permanently delete "${expense.title}"?',
      confirmLabel: 'Delete',
    );

    if (confirmed && context.mounted) {
      final success = await context.read<ExpenseProvider>().deleteExpense(
        expense.id,
      );
      if (context.mounted) {
        if (success) {
          AppMessages.showSuccess(context, 'Transaction deleted');
          Navigator.of(context).pop();
        } else {
          AppMessages.showError(context, 'Could not delete transaction');
        }
      }
    }
  }
}
