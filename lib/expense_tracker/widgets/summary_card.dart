import 'package:flutter/material.dart';
import '../utils/app_messages.dart';

/// Interactive summary card displaying total spending, today's amount, and budget status.
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
    final budgetPercent = (monthlyBudget > 0)
        ? (totalSpending / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = totalSpending > monthlyBudget && monthlyBudget > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.6),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Transaction Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Financial Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$transactionCount transactions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Middle Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    context,
                    label: 'Total Spending',
                    amount: totalSpending,
                    icon: Icons.payments_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  height: 48,
                  width: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _buildMetric(
                    context,
                    label: "Today's Spent",
                    amount: todaySpending,
                    icon: Icons.today_rounded,
                    color: const Color(0xFF00897B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Budget Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget (${AppMessages.formatCurrency(monthlyBudget, symbol: currencySymbol)})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isOverBudget
                      ? 'Exceeded by ${AppMessages.formatCurrency(totalSpending - monthlyBudget, symbol: currencySymbol)}'
                      : '${(budgetPercent * 100).toStringAsFixed(0)}% used',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverBudget
                        ? colorScheme.error
                        : budgetPercent > 0.8
                        ? Colors.orange.shade800
                        : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: budgetPercent,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? colorScheme.error
                      : budgetPercent > 0.8
                      ? Colors.orange.shade700
                      : colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppMessages.formatCurrency(amount, symbol: currencySymbol),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
