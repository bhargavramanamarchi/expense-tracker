import 'package:flutter/material.dart';
import '../models/expense_category.dart';

/// Modern fintech horizontal category filter chip bar.
class CategoryFilter extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?> onSelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All Categories" chip
          _buildChip(
            context,
            label: 'All',
            icon: Icons.layers_outlined,
            isSelected: selectedCategory == null,
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF0F172A),
            onTap: () => onSelected(null),
          ),
          ...ExpenseCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return _buildChip(
              context,
              label: category.displayName,
              icon: category.icon,
              isSelected: isSelected,
              color: category.color,
              onTap: () => onSelected(isSelected ? null : category),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? color.withValues(alpha: isDark ? 0.25 : 0.12)
        : (isDark ? const Color(0xFF161F30) : const Color(0xFFF1F5F9));

    final borderColor = isSelected
        ? color.withValues(alpha: isDark ? 0.6 : 0.4)
        : theme.colorScheme.outlineVariant;

    final textColor = isSelected
        ? (isDark ? Colors.white : color)
        : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: isSelected ? color : textColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
