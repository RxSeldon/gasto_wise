import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_constants.dart';
import '../services/service_locator.dart';
import '../viewmodels/add_expense_viewmodel.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddExpenseViewModel(
        expenseService: ServiceLocator().expenseService,
        validationService: ServiceLocator().validationService,
      ),
      child: const _AddExpenseView(),
    );
  }
}

class _AddExpenseView extends StatefulWidget {
  const _AddExpenseView();

  @override
  State<_AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<_AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final vm = context.read<AddExpenseViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      vm.setDate(picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AddExpenseViewModel>();
    final success = await vm.saveExpense(
      amount: _amountController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (success) {
      _showMessage(vm.successMessage!);
      _formKey.currentState?.reset();
      _amountController.clear();
      _descriptionController.clear();
      vm.resetForm();
    } else if (vm.errorMessage != null) {
      _showMessage(vm.errorMessage!);
    }
    vm.clearMessages();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _descriptionController.clear();
    context.read<AddExpenseViewModel>().resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddExpenseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Expense Details'),
              const SizedBox(height: 20),
              _buildCategoryDropdown(vm),
              const SizedBox(height: 16),
              _buildAmountField(vm),
              const SizedBox(height: 16),
              _buildDatePicker(context, vm),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildActionButtons(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryDropdown(AddExpenseViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: vm.selectedCategory,
          items: AppConstants.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        AppConstants.categoryIcons[category] ?? Icons.category,
                        size: 20,
                        color: Colors.blue.shade800,
                      ),
                      const SizedBox(width: 12),
                      Text(category),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) vm.setCategory(value);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(AddExpenseViewModel vm) {
    return TextFormField(
      controller: _amountController,
      validator: vm.validateAmount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: 'Enter amount',
        prefixIcon: const Icon(Icons.monetization_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AddExpenseViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vm.selectedDate.month}/${vm.selectedDate.day}/${vm.selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(Icons.calendar_today, color: Colors.blue.shade800),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description (optional)',
        hintText: 'Add expense notes',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildActionButtons(AddExpenseViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: vm.isLoading ? null : _clearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.blue.shade800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              disabledBackgroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
