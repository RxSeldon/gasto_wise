import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_constants.dart';
import '../models/models.dart';
import '../services/service_locator.dart';
import '../viewmodels/expense_history_viewmodel.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseHistoryViewModel(
        expenseService: ServiceLocator().expenseService,
      )..loadExpenses(),
      child: const _ExpenseHistoryView(),
    );
  }
}

class _ExpenseHistoryView extends StatelessWidget {
  const _ExpenseHistoryView();

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseHistoryViewModel>();

    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage!)),
        );
        vm.clearMessages();
      });
    }

    if (vm.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage!)),
        );
        vm.clearMessages();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterSection(context, vm),
                Expanded(child: _buildExpenseList(context, vm)),
                if (vm.filteredExpenses.isNotEmpty)
                  _buildTotalSection(context, vm),
              ],
            ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, ExpenseHistoryViewModel vm) {
    final categories = ['All', ...AppConstants.categories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  selected: vm.selectedFilter == category,
                  label: Text(category),
                  onSelected: (_) => vm.setFilter(category),
                  selectedColor: Colors.blue.shade800,
                  labelStyle: TextStyle(
                    color: vm.selectedFilter == category
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildExpenseList(
      BuildContext context, ExpenseHistoryViewModel vm) {
    if (vm.filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              'Start adding expenses to see them here',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: vm.filteredExpenses.length,
        itemBuilder: (context, index) =>
            _buildExpenseCard(context, vm, vm.filteredExpenses[index]),
      ),
    );
  }

  Widget _buildExpenseCard(
      BuildContext context, ExpenseHistoryViewModel vm, Expense expense) {
    final icon = AppConstants.categoryIcons[expense.category] ?? Icons.category;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteExpense(expense.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade800),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expense.description.isEmpty
                        ? _getRelativeDate(expense.date)
                        : expense.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getRelativeDate(expense.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-₱${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(
      BuildContext context, ExpenseHistoryViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '-₱${vm.filteredTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
