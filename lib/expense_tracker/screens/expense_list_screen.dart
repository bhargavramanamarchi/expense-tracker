import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../routes.dart';
import '../utils/app_messages.dart';
import '../widgets/category_filter.dart';
import '../widgets/expense_card.dart';

/// Screen listing all expenses with live search, category filtering, and sorting.
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortAmountDesc = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currencySymbol = authProvider.currentUser.currencySymbol;

    var items = List<Expense>.from(expenseProvider.filteredExpenses);
    if (_sortAmountDesc) {
      items.sort((a, b) => b.amount.compareTo(a.amount));
    }

    final filteredTotal = expenseProvider.filteredTotalSpending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          IconButton(
            tooltip: _sortAmountDesc ? 'Sort by Date' : 'Sort by Amount',
            icon: Icon(
              _sortAmountDesc ? Icons.swap_vert_rounded : Icons.sort_rounded,
            ),
            onPressed: () {
              setState(() {
                _sortAmountDesc = !_sortAmountDesc;
              });
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title or description...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              expenseProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    expenseProvider.setSearchQuery(val);
                  },
                ),
              ),

              // Category Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CategoryFilter(
                  selectedCategory: expenseProvider.selectedCategoryFilter,
                  onSelected: (cat) {
                    expenseProvider.setCategoryFilter(cat);
                  },
                ),
              ),

              // Filter Summary Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} ${items.length == 1 ? "expense" : "expenses"} found',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    Text(
                      'Total: ${AppMessages.formatCurrency(filteredTotal, symbol: currencySymbol)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Expense List or Empty State
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState(context, expenseProvider)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 90),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final expense = items[index];
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
                        },
                      ),
              ),
            ],
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

  Widget _buildEmptyState(BuildContext context, ExpenseProvider provider) {
    final theme = Theme.of(context);
    final hasActiveFilter =
        provider.selectedCategoryFilter != null ||
        provider.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? 'No matching expenses found'
                  : 'No expenses recorded yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilter
                  ? 'Try searching with different terms or resetting the category filter.'
                  : 'Start tracking your spending by adding a new expense.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            if (hasActiveFilter)
              OutlinedButton.icon(
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Reset Filters'),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  provider.setCategoryFilter(null);
                },
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add First Expense'),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(ExpenseTrackerRoutes.expenseForm);
                },
              ),
          ],
        ),
      ),
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
        } else {
          AppMessages.showError(context, 'Could not delete expense');
        }
      }
    }
  }
}
