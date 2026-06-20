import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../services/expense_service.dart';
import '../services/service_locator.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  late final IExpenseService _expenseService;

  String _selectedFilter = 'All';
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _expenseService = ServiceLocator().expenseService;
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _expenseService.getAllExpenses();
      if (!mounted) return;
      setState(() {
        _allExpenses = expenses;
        _filterExpenses();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading expenses: $e')));
    }
  }

  void _filterExpenses() {
    if (_selectedFilter == 'All') {
      _filteredExpenses = List.from(_allExpenses);
    } else {
      _filteredExpenses = _allExpenses
          .where((expense) => expense.category == _selectedFilter)
          .toList();
    }
    _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _deleteExpense(String expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      if (!mounted) return;
      setState(() {
        _allExpenses.removeWhere((expense) => expense.id == expenseId);
        _filterExpenses();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting expense: $e')));
    }
  }

  void _onFilterChanged(String category) {
    setState(() {
      _selectedFilter = category;
      _filterExpenses();
    });
  }

  double _calculateTotal() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterSection(context),
                Expanded(child: _buildExpenseList(context)),
                if (_filteredExpenses.isNotEmpty) _buildTotalSection(context),
              ],
            ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
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
                  selected: _selectedFilter == category,
                  label: Text(category),
                  onSelected: (_) => _onFilterChanged(category),
                  selectedColor: Colors.blue.shade800,
                  labelStyle: TextStyle(
                    color: _selectedFilter == category
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

  Widget _buildExpenseList(BuildContext context) {
    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              'Start adding expenses to see them here',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _filteredExpenses.length,
        itemBuilder: (context, index) =>
            _buildExpenseCard(context, _filteredExpenses[index]),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    final icon = AppConstants.categoryIcons[expense.category] ?? Icons.category;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteExpense(expense.id),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
              '-\$${expense.amount.toStringAsFixed(2)}',
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

  Widget _buildTotalSection(BuildContext context) {
    final total = _calculateTotal();

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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '-\$${total.toStringAsFixed(2)}',
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
