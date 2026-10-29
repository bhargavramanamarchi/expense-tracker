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
    final isDark = theme.brightness == Brightness.dark;
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
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: Icon(
                _sortAmountDesc
                    ? Icons.trending_down_rounded
                    : Icons.access_time_rounded,
                size: 16,
              ),
              label: Text(
                _sortAmountDesc ? 'Amount' : 'Recent',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              onPressed: () {
                setState(() {
                  _sortAmountDesc = !_sortAmountDesc;
                });
              },
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, merchant, or notes...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              expenseProvider.setSearchQuery('');
                            },
                          )
                        : null,
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${items.length} ${items.length == 1 ? "transaction" : "transactions"} found',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Subtotal: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            AppMessages.formatCurrency(
                              filteredTotal,
                              symbol: currencySymbol,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? const Color(0xFF818CF8)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
        label: const Text('Add Transaction'),
        elevation: 3,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
              size: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? 'No matching transactions'
                  : 'No transactions recorded',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasActiveFilter
                  ? 'Try adjusting your search criteria or resetting category filter.'
                  : 'Start tracking by recording your first expense.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (hasActiveFilter)
              OutlinedButton.icon(
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Reset Filters'),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  provider.setCategoryFilter(null);
                },
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Record Transaction'),
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
      title: 'Delete Transaction?',
      message: 'Are you sure you want to delete "${expense.title}"?',
      confirmLabel: 'Delete',
    );

    if (confirmed && context.mounted) {
      final success = await context.read<ExpenseProvider>().deleteExpense(
        expense.id,
      );
      if (context.mounted) {
        if (success) {
          AppMessages.showSuccess(context, 'Transaction deleted');
        } else {
          AppMessages.showError(context, 'Could not delete transaction');
        }
      }
    }
  }
}
