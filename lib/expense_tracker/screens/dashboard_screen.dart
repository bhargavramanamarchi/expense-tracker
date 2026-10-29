import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../routes.dart';
import '../utils/app_messages.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';

/// Central dashboard screen displaying spending metrics, category breakdown, and recent transactions.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = authProvider.currentUser;
    final currencySymbol = user.currencySymbol;
    final recentExpenses = expenseProvider.recentExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.insights_rounded, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Expense Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            tooltip: 'Budget & Preferences',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showPreferencesDialog(context),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: RefreshIndicator(
            onRefresh: () => expenseProvider.loadExpenses(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // Demo Data Notification Banner
                if (expenseProvider.hasDemoData)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sample transactions loaded for demonstration. You can clear or edit them anytime.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final confirm = await AppMessages.showConfirmDialog(
                              context,
                              title: 'Clear Sample Data?',
                              message:
                                  'This will delete all demo transactions from local storage.',
                              confirmLabel: 'Clear Demo Data',
                            );
                            if (confirm && context.mounted) {
                              await expenseProvider.clearDemoExpenses();
                              if (context.mounted) {
                                AppMessages.showSuccess(
                                  context,
                                  'Demo transactions cleared',
                                );
                              }
                            }
                          },
                          child: const Text('Clear Demo'),
                        ),
                      ],
                    ),
                  ),

                // Greeting & Profile Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${user.name}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Here is your financial activity overview.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.list_alt_rounded, size: 18),
                        label: const Text('All Expenses'),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(ExpenseTrackerRoutes.expenseList);
                        },
                      ),
                    ],
                  ),
                ),

                // Overview Summary Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SummaryCard(
                    totalSpending: expenseProvider.totalSpending,
                    todaySpending: expenseProvider.todaySpending,
                    monthlyBudget: user.monthlyBudget,
                    currencySymbol: currencySymbol,
                    transactionCount: expenseProvider.allExpenses.length,
                  ),
                ),

                // Category Breakdown Section
                if (expenseProvider.hasExpenses) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Spending by Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCategoryBreakdown(
                    context,
                    expenseProvider,
                    currencySymbol,
                  ),
                ],

                // Recent Transactions Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (expenseProvider.allExpenses.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(ExpenseTrackerRoutes.expenseList);
                          },
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                ),

                // Recent Transactions List or Empty State
                if (recentExpenses.isEmpty)
                  _buildEmptyState(context)
                else
                  ...recentExpenses.map((expense) {
                    return ExpenseCard(
                      expense: expense,
                      currencySymbol: currencySymbol,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ExpenseTrackerRoutes.expenseDetail,
                          arguments: expense,
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).pushNamed(
                          ExpenseTrackerRoutes.expenseForm,
                          arguments: expense,
                        );
                      },
                      onDelete: () => _handleDelete(context, expense),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
        onPressed: () {
          Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseForm);
        },
      ),
    );
  }

  /// Builds a visual breakdown of spending across all categories.
  Widget _buildCategoryBreakdown(
    BuildContext context,
    ExpenseProvider provider,
    String currencySymbol,
  ) {
    final theme = Theme.of(context);
    final spending = provider.spendingByCategory;
    final total = provider.totalSpending;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Multi-color segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: ExpenseCategory.values.map((cat) {
                  final catAmount = spending[cat] ?? 0.0;
                  final flex = total > 0
                      ? (catAmount / total * 1000).toInt()
                      : 0;
                  if (flex <= 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: flex,
                    child: Container(color: cat.color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category Chips with Amounts & Percentages
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ExpenseCategory.values.map((cat) {
              final catAmount = spending[cat] ?? 0.0;
              final percent = total > 0 ? (catAmount / total * 100) : 0.0;
              if (catAmount <= 0) return const SizedBox.shrink();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${cat.displayName}: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${AppMessages.formatCurrency(catAmount, symbol: currencySymbol)} (${percent.toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Empty state placeholder when no transactions are recorded.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.read<ExpenseProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses recorded yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "+ Add Expense" to record your first transaction,\nor load demo data to inspect the dashboard.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Load Demo Data'),
              onPressed: () async {
                await expenseProvider.resetToDemoData();
                if (context.mounted) {
                  AppMessages.showSuccess(context, 'Sample data loaded');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms and deletes an expense.
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
        } else {
          AppMessages.showError(context, 'Could not delete expense');
        }
      }
    }
  }

  /// Dialog to edit budget, user name, and currency preferences.
  void _showPreferencesDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    final nameController = TextEditingController(text: user.name);
    final budgetController = TextEditingController(
      text: user.monthlyBudget.toStringAsFixed(0),
    );
    String selectedCurrency = user.currencySymbol;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preferences & Budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Monthly Budget',
                    border: const OutlineInputBorder(),
                    prefixText: '$selectedCurrency ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency Symbol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '\$',
                      child: Text('\$ (USD / AUD)'),
                    ),
                    DropdownMenuItem(value: '₹', child: Text('₹ (INR)')),
                    DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                    DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                    DropdownMenuItem(value: '¥', child: Text('¥ (JPY)')),
                    DropdownMenuItem(value: 'C\$', child: Text('C\$ (CAD)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCurrency = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final budgetVal =
                    double.tryParse(budgetController.text) ?? 2500.0;
                await authProvider.updateUser(
                  user.copyWith(
                    name: nameController.text.trim().isEmpty
                        ? user.name
                        : nameController.text.trim(),
                    monthlyBudget: budgetVal,
                    currencySymbol: selectedCurrency,
                  ),
                );
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  AppMessages.showSuccess(ctx, 'Preferences updated');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
