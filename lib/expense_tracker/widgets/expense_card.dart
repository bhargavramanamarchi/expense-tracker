import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_messages.dart';

/// Reusable card displaying an individual expense transaction.
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.currencySymbol,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = expense.category;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category Icon Circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: category.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: category.color, size: 22),
              ),
              const SizedBox(width: 14),

              // Title, Category & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (expense.isDemo) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.amber.shade400,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'DEMO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          category.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' • ${AppMessages.formatRelativeDate(expense.date)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expense.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expense.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Amount & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppMessages.formatCurrency(
                      expense.amount,
                      symbol: currencySymbol,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
