import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_messages.dart';

/// Premium fintech transaction tile with category badge, clean typography, and hover highlight.
class ExpenseCard extends StatefulWidget {
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
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = widget.expense.category;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _isHovered
              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Category Icon Squircle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: category.borderColor, width: 1),
                  ),
                  child: Icon(category.icon, color: category.color, size: 21),
                ),
                const SizedBox(width: 14),

                // Transaction Title, Category Tag & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.expense.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.expense.isDemo) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: category.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: category.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${AppMessages.formatRelativeDate(widget.expense.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      if (widget.expense.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.expense.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.5,
                            ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '- ${AppMessages.formatCurrency(widget.expense.amount, symbol: widget.currencySymbol)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (widget.onEdit != null || widget.onDelete != null) ...[
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'edit' && widget.onEdit != null) {
                            widget.onEdit!();
                          } else if (value == 'delete' &&
                              widget.onDelete != null) {
                            widget.onDelete!();
                          }
                        },
                        itemBuilder: (context) => [
                          if (widget.onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit details'),
                                ],
                              ),
                            ),
                          if (widget.onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Color(0xFFE11D48),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Color(0xFFE11D48)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
