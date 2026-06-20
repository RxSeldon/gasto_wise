import 'package:flutter/material.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  // Sample expense data
  List<HistoryExpenseItem> allExpenses = [
    HistoryExpenseItem(
      id: '1',
      category: 'Food',
      amount: 45.50,
      date: DateTime(2026, 6, 20),
      description: 'Lunch at cafe',
      icon: '🍔',
    ),
    HistoryExpenseItem(
      id: '2',
      category: 'Transportation',
      amount: 30.00,
      date: DateTime(2026, 6, 19),
      description: 'Gas',
      icon: '🚗',
    ),
    HistoryExpenseItem(
      id: '3',
      category: 'Shopping',
      amount: 125.00,
      date: DateTime(2026, 6, 18),
      description: 'New shoes',
      icon: '🛍️',
    ),
    HistoryExpenseItem(
      id: '4',
      category: 'Entertainment',
      amount: 50.00,
      date: DateTime(2026, 6, 17),
      description: 'Movie tickets',
      icon: '🎬',
    ),
    HistoryExpenseItem(
      id: '5',
      category: 'Food',
      amount: 28.75,
      date: DateTime(2026, 6, 17),
      description: 'Dinner',
      icon: '🍔',
    ),
    HistoryExpenseItem(
      id: '6',
      category: 'Bills',
      amount: 150.00,
      date: DateTime(2026, 6, 15),
      description: 'Internet bill',
      icon: '💳',
    ),
    HistoryExpenseItem(
      id: '7',
      category: 'School',
      amount: 200.00,
      date: DateTime(2026, 6, 14),
      description: 'Books',
      icon: '📚',
    ),
    HistoryExpenseItem(
      id: '8',
      category: 'Others',
      amount: 15.50,
      date: DateTime(2026, 6, 13),
      description: 'Coffee',
      icon: '📌',
    ),
  ];

  String _selectedFilter = 'All';
  late List<HistoryExpenseItem> _filteredExpenses;

  @override
  void initState() {
    super.initState();
    _filteredExpenses = allExpenses;
  }

  void _filterExpenses(String category) {
    setState(() {
      _selectedFilter = category;
      if (category == 'All') {
        _filteredExpenses = allExpenses;
      } else {
        _filteredExpenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();
      }
    });
  }

  void _deleteExpense(String id) {
    setState(() {
      allExpenses.removeWhere((expense) => expense.id == id);
      _filterExpenses(_selectedFilter);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  double _calculateTotal() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filteredExpenses.length} transactions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Food'),
                        _buildFilterChip('Transportation'),
                        _buildFilterChip('Shopping'),
                        _buildFilterChip('Bills'),
                        _buildFilterChip('School'),
                        _buildFilterChip('Entertainment'),
                        _buildFilterChip('Others'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expenses List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _filteredExpenses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredExpenses.length,
                      itemBuilder: (context, index) {
                        return _buildExpenseCard(_filteredExpenses[index]);
                      },
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    bool isSelected = _selectedFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) {
          _filterExpenses(category);
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade800,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade800 : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(HistoryExpenseItem expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Category Icon
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(expense.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // Expense Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expense.description.isEmpty
                        ? _formatDate(expense.date)
                        : expense.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  if (expense.description.isNotEmpty)
                    Text(
                      _formatDate(expense.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            // Amount and Delete Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _deleteExpense(expense.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category or add new expenses',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HistoryExpenseItem {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String icon;

  HistoryExpenseItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.icon,
  });
}
