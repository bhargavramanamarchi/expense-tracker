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

/// Central fintech dashboard screen with responsive desktop sidebar and mobile layout.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = authProvider.currentUser;
    final currencySymbol = user.currencySymbol;
    final recentExpenses = expenseProvider.recentExpenses;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 920;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE0E7FF),
                          ),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: isDark
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF4F46E5),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Expense Tracker',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Toggle Theme',
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                    IconButton(
                      tooltip: 'Preferences & Budget',
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () => _showPreferencesDialog(context),
                    ),
                  ],
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Desktop Left Navigation Sidebar
              if (isDesktop)
                _buildDesktopSidebar(
                  context,
                  user: user,
                  themeProvider: themeProvider,
                ),

              // Main Dashboard Content
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: RefreshIndicator(
                      onRefresh: () => expenseProvider.loadExpenses(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                        children: [
                          // Desktop Header Bar
                          if (isDesktop) ...[
                            _buildDesktopTopBar(
                              context,
                              user: user,
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Demo Data Alert Banner
                          if (expenseProvider.hasDemoData)
                            _buildDemoBanner(context, expenseProvider),

                          // Welcome Header (Mobile only)
                          if (!isDesktop) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back, ${user.name}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.3,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Here is your financial activity overview.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.6),
                                                fontSize: 11.5,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.list_alt_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('All Expenses'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        ExpenseTrackerRoutes.expenseList,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Financial Overview Summary Card
                          SummaryCard(
                            totalSpending: expenseProvider.totalSpending,
                            todaySpending: expenseProvider.todaySpending,
                            monthlyBudget: user.monthlyBudget,
                            currencySymbol: currencySymbol,
                            transactionCount:
                                expenseProvider.allExpenses.length,
                          ),
                          const SizedBox(height: 20),

                          // Category Analytics Card
                          if (expenseProvider.hasExpenses) ...[
                            _buildCategoryAnalyticsCard(
                              context,
                              provider: expenseProvider,
                              currencySymbol: currencySymbol,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Recent Transactions Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Transactions',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                  Text(
                                    'Latest activities recorded in local ledger',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (expenseProvider.allExpenses.isNotEmpty)
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('View All'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      ExpenseTrackerRoutes.expenseList,
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

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
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Record Expense'),
            elevation: 3,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () {
              Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseForm);
            },
          ),
          bottomNavigationBar: isDesktop
              ? null
              : _buildMobileBottomBar(context),
        );
      },
    );
  }

  /// Compact left navigation sidebar for desktop screens.
  Widget _buildDesktopSidebar(
    BuildContext context, {
    required dynamic user,
    required ThemeProvider themeProvider,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Tracker',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'Fintech Personal Suite',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.55,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Navigation Links
          _buildSidebarNavItem(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Overview',
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(height: 4),
          _buildSidebarNavItem(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'All Expenses',
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseList);
            },
          ),
          const SizedBox(height: 4),
          _buildSidebarNavItem(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Record Expense',
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseForm);
            },
          ),
          const SizedBox(height: 4),
          _buildSidebarNavItem(
            context,
            icon: Icons.tune_rounded,
            label: 'Preferences',
            isActive: false,
            onTap: () => _showPreferencesDialog(context),
          ),

          const Spacer(),

          // Theme Toggle Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // User Profile Snippet
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161F30) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Budget: ${AppMessages.formatCurrency(user.monthlyBudget, symbol: user.currencySymbol)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark
        ? const Color(0xFF818CF8)
        : const Color(0xFF4F46E5);
    final activeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);

    return Material(
      color: isActive ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? activeColor
                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? activeColor
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.8,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top bar for desktop mode with greeting and action buttons.
  Widget _buildDesktopTopBar(
    BuildContext context, {
    required dynamic user,
    required ThemeProvider themeProvider,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user.name}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Track expenses, monitor budget thresholds, and manage personal cash flow.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt_rounded, size: 16),
              label: const Text('View All Transactions'),
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(ExpenseTrackerRoutes.expenseList);
              },
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: 'Preferences & Budget Settings',
              icon: const Icon(Icons.tune_rounded, size: 18),
              onPressed: () => _showPreferencesDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile bottom navigation bar for quick access.
  Widget _buildMobileBottomBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      height: 60,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseList);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(ExpenseTrackerRoutes.expenseForm);
        } else if (index == 3) {
          _showPreferencesDialog(context);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'Expenses',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Add',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune_rounded),
          label: 'Settings',
        ),
      ],
    );
  }

  /// Alert banner for demo transactions.
  Widget _buildDemoBanner(BuildContext context, ExpenseProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Colors.amber,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Sample demo transactions active. Clear or edit anytime.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () async {
              final confirm = await AppMessages.showConfirmDialog(
                context,
                title: 'Clear Demo Data?',
                message:
                    'This will remove all sample transactions from local browser storage.',
                confirmLabel: 'Clear Demo Data',
              );
              if (confirm && context.mounted) {
                await provider.clearDemoExpenses();
                if (context.mounted) {
                  AppMessages.showSuccess(context, 'Demo transactions cleared');
                }
              }
            },
            child: const Text('Clear Demo'),
          ),
        ],
      ),
    );
  }

  /// Visual category breakdown analytics card with distribution progress bar.
  Widget _buildCategoryAnalyticsCard(
    BuildContext context, {
    required ExpenseProvider provider,
    required String currencySymbol,
  }) {
    final theme = Theme.of(context);
    final spending = provider.spendingByCategory;
    final total = provider.totalSpending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Category Breakdown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${spending.values.where((v) => v > 0).length} active categories',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continuous distribution segmented bar
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
            const SizedBox(height: 18),

            // Category Distribution Grid
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: ExpenseCategory.values.map((cat) {
                final catAmount = spending[cat] ?? 0.0;
                final percent = total > 0 ? (catAmount / total * 100) : 0.0;
                if (catAmount <= 0) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cat.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cat.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14, color: cat.color),
                      const SizedBox(width: 6),
                      Text(
                        '${cat.displayName}: ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: cat.color,
                        ),
                      ),
                      Text(
                        '${AppMessages.formatCurrency(catAmount, symbol: currencySymbol)} (${percent.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state placeholder when no transactions exist.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.read<ExpenseProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No transactions recorded yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Record an expense or load demo transactions to explore dashboard insights.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Load Demo Transactions'),
                onPressed: () async {
                  await expenseProvider.resetToDemoData();
                  if (context.mounted) {
                    AppMessages.showSuccess(
                      context,
                      'Sample transactions loaded',
                    );
                  }
                },
              ),
            ],
          ),
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

  /// Fintech preferences modal dialog.
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
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Budget & Preferences',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Monthly Spending Target',
                    prefixText: '$selectedCurrency ',
                    prefixIcon: const Icon(Icons.savings_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Default Currency',
                    prefixIcon: Icon(Icons.currency_exchange_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '₹',
                      child: Text('₹ (INR - Indian Rupee)'),
                    ),
                    DropdownMenuItem(
                      value: '\$',
                      child: Text('\$ (USD - US Dollar)'),
                    ),
                    DropdownMenuItem(value: '€', child: Text('€ (EUR - Euro)')),
                    DropdownMenuItem(
                      value: '£',
                      child: Text('£ (GBP - British Pound)'),
                    ),
                    DropdownMenuItem(
                      value: '¥',
                      child: Text('¥ (JPY - Japanese Yen)'),
                    ),
                    DropdownMenuItem(
                      value: 'C\$',
                      child: Text('C\$ (CAD - Canadian Dollar)'),
                    ),
                    DropdownMenuItem(
                      value: 'A\$',
                      child: Text('A\$ (AUD - Australian Dollar)'),
                    ),
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
                    double.tryParse(budgetController.text) ?? 50000.0;
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
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
