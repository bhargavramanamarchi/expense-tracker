import 'package:flutter/material.dart';
import '../models/expense_category.dart';

/// Horizontal scrolling category selector chip bar.
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
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: const Icon(Icons.apps_rounded, size: 18),
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onSelected(null),
              showCheckmark: false,
            ),
          ),
          ...ExpenseCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? null : category.color,
                ),
                label: Text(category.displayName),
                selected: isSelected,
                selectedColor: category.color.withValues(alpha: 0.25),
                onSelected: (_) => onSelected(isSelected ? null : category),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
