import 'package:flutter/material.dart';
import '../utils/app_messages.dart';

/// Premium fintech summary card displaying spending metrics, budget progress, and transaction health.
class SummaryCard extends StatelessWidget {
  final double totalSpending;
  final double todaySpending;
  final double monthlyBudget;
  final String currencySymbol;
  final int transactionCount;

  const SummaryCard({
    super.key,
    required this.totalSpending,
    required this.todaySpending,
    required this.monthlyBudget,
    required this.currencySymbol,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final budgetPercent = (monthlyBudget > 0)
        ? (totalSpending / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = totalSpending > monthlyBudget && monthlyBudget > 0;
    final remainingBudget = (monthlyBudget - totalSpending).clamp(
      0.0,
      double.infinity,
    );

    // Fintech Accent Colors
    final statusColor = isOverBudget
        ? const Color(0xFFE11D48)
        : budgetPercent > 0.8
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 540;

        return Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF161F30), colorScheme.surface]
                    : [const Color(0xFFF8FAFC), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title, Transaction Pill & Health Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE0E7FF),
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: isDark
                                ? const Color(0xFF818CF8)
                                : const Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Overview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Real-time spending & monthly ledger',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.65),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '$transactionCount txns',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOverBudget
                                    ? 'Over Budget'
                                    : budgetPercent > 0.8
                                    ? 'Nearing Limit'
                                    : 'On Track',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Metrics Grid
                if (isCompact) ...[
                  // Stack on narrow screen
                  _buildMetricTile(
                    context,
                    label: 'TOTAL EXPENDITURE',
                    amount: totalSpending,
                    currencySymbol: currencySymbol,
                    subtitle: 'Current billing cycle',
                    accentColor: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFF0F172A),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          label: "TODAY'S SPENT",
                          amount: todaySpending,
                          currencySymbol: currencySymbol,
                          subtitle: 'Live tracker',
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          label: 'REMAINING BUDGET',
                          amount: remainingBudget,
                          currencySymbol: currencySymbol,
                          subtitle: isOverBudget ? 'Deficit' : 'Safe to spend',
                          accentColor: statusColor,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // 3-Column on wider screens
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildMetricTile(
                          context,
                          label: 'TOTAL EXPENDITURE',
                          amount: totalSpending,
                          currencySymbol: currencySymbol,
                          subtitle: 'Current billing cycle',
                          accentColor: isDark
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF0F172A),
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildMetricTile(
                          context,
                          label: "TODAY'S SPENT",
                          amount: todaySpending,
                          currencySymbol: currencySymbol,
                          subtitle: 'Live tracker',
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildMetricTile(
                          context,
                          label: 'REMAINING BUDGET',
                          amount: remainingBudget,
                          currencySymbol: currencySymbol,
                          subtitle: isOverBudget ? 'Deficit' : 'Safe to spend',
                          accentColor: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 14),

                // Budget Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Monthly Target: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        Text(
                          AppMessages.formatCurrency(
                            monthlyBudget,
                            symbol: currencySymbol,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isOverBudget
                          ? 'Deficit of ${AppMessages.formatCurrency(totalSpending - monthlyBudget, symbol: currencySymbol)}'
                          : '${(budgetPercent * 100).toStringAsFixed(1)}% utilized',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budgetPercent,
                    minHeight: 7,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required double amount,
    required String currencySymbol,
    required String subtitle,
    required Color accentColor,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppMessages.formatCurrency(amount, symbol: currencySymbol),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: isPrimary ? 22 : 18,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
