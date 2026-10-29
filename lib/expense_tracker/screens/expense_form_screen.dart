import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../utils/app_messages.dart';
import '../utils/expense_validators.dart';

/// Form screen for creating or editing an expense record with fintech card styling.
class ExpenseFormScreen extends StatefulWidget {
  final Expense? initialExpense;

  const ExpenseFormScreen({super.key, this.initialExpense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _selectedCategory = expense?.category ?? ExpenseCategory.food;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _setDateShortcut(int daysAgo) {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now.subtract(Duration(days: daysAgo));
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final expenseProvider = context.read<ExpenseProvider>();

    final cleanTitle = _titleController.text.trim();
    final cleanAmount = double.parse(
      _amountController.text.trim().replaceAll(',', ''),
    );
    final cleanDesc = _descriptionController.text.trim();

    bool success = false;
    if (_isEditing) {
      final updated = widget.initialExpense!.copyWith(
        title: cleanTitle,
        amount: cleanAmount,
        category: _selectedCategory,
        date: _selectedDate,
        description: cleanDesc,
      );
      success = await expenseProvider.updateExpense(updated);
    } else {
      success = await expenseProvider.addExpense(
        title: cleanTitle,
        amount: cleanAmount,
        category: _selectedCategory,
        date: _selectedDate,
        description: cleanDesc,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppMessages.showSuccess(
        context,
        _isEditing
            ? 'Transaction updated successfully'
            : 'Transaction recorded successfully',
      );
      Navigator.of(context).pop();
    } else {
      AppMessages.showError(
        context,
        expenseProvider.errorMessage ?? 'An error occurred while saving',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final currencySymbol = authProvider.currentUser.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Record Transaction',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.add_card_rounded,
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
                                _isEditing
                                    ? 'Update Transaction Details'
                                    : 'New Ledger Entry',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Categorize and log your expenditure',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Title Input
                      Text(
                        'TRANSACTION TITLE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Supermarket Grocery, Electric Bill',
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            size: 20,
                          ),
                        ),
                        validator: ExpenseValidators.validateTitle,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),

                      // Amount Input
                      Text(
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currencySymbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                        ),
                        validator: ExpenseValidators.validateAmount,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Category Selector (Visual Grid)
                      Text(
                        'CATEGORY',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ExpenseCategory.values.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Material(
                            color: isSelected
                                ? cat.color.withValues(alpha: 0.18)
                                : (isDark
                                      ? const Color(0xFF161F30)
                                      : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? cat.color
                                        : theme.colorScheme.outlineVariant,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat.icon,
                                      size: 16,
                                      color: isSelected
                                          ? cat.color
                                          : theme.textTheme.bodySmall?.color
                                                ?.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? cat.color
                                            : theme.textTheme.bodyMedium?.color
                                                  ?.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Date Input & Quick Shortcuts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TRANSACTION DATE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () => _setDateShortcut(0),
                                child: const Text(
                                  'Today',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () => _setDateShortcut(1),
                                child: const Text(
                                  'Yesterday',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                            ),
                            suffixIcon: Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 24,
                            ),
                          ),
                          child: Text(
                            AppMessages.formatDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description Input
                      Text(
                        'NOTES / DESCRIPTION',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Optional context, item details, or tax info...',
                          prefixIcon: Icon(Icons.notes_rounded, size: 20),
                          alignLabelWithHint: true,
                        ),
                        validator: ExpenseValidators.validateDescription,
                      ),
                      const SizedBox(height: 28),

                      // Save Action Button
                      FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _saveForm,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isEditing
                                        ? Icons.save_outlined
                                        : Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEditing
                                        ? 'Update Transaction'
                                        : 'Record Transaction',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
