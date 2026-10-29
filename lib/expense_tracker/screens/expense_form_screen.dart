import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/auth_providers.dart';
import '../providers/expense_providers.dart';
import '../utils/app_messages.dart';
import '../utils/expense_validators.dart';

/// Form screen for creating or editing an expense record.
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
            ? 'Expense updated successfully'
            : 'Expense created successfully',
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
    final authProvider = context.watch<AuthProvider>();
    final currencySymbol = authProvider.currentUser.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add New Expense'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Expense Title *',
                      hintText: 'e.g. Grocery shopping, Metro card refill',
                      prefixIcon: Icon(Icons.title_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: ExpenseValidators.validateTitle,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount *',
                      hintText: '0.00',
                      prefixText: '$currencySymbol ',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    validator: ExpenseValidators.validateAmount,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  DropdownButtonFormField<ExpenseCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 20),
                            const SizedBox(width: 10),
                            Text(cat.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Field
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Date *',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                      ),
                      child: Text(
                        AppMessages.formatDate(_selectedDate),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText:
                          'Additional details or notes about this purchase...',
                      prefixIcon: Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: ExpenseValidators.validateDescription,
                  ),
                  const SizedBox(height: 28),

                  // Save Action Button
                  FilledButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : (_isEditing ? 'Save Changes' : 'Record Expense'),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isSaving ? null : _saveForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
