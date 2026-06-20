import '../models/models.dart';

abstract class IExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<Expense?> getExpenseById(String id);
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> getExpensesByCategory(String category);
  Future<double> getTotalExpenses();
}

class MockExpenseRepository implements IExpenseRepository {
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      category: 'Food',
      amount: 45.50,
      date: DateTime(2026, 6, 20),
      description: 'Lunch at cafe',
    ),
    Expense(
      id: '2',
      category: 'Transportation',
      amount: 30.00,
      date: DateTime(2026, 6, 19),
      description: 'Gas',
    ),
    Expense(
      id: '3',
      category: 'Shopping',
      amount: 125.00,
      date: DateTime(2026, 6, 18),
      description: 'New shoes',
    ),
    Expense(
      id: '4',
      category: 'Entertainment',
      amount: 50.00,
      date: DateTime(2026, 6, 17),
      description: 'Movie tickets',
    ),
    Expense(
      id: '5',
      category: 'Food',
      amount: 28.75,
      date: DateTime(2026, 6, 17),
      description: 'Dinner',
    ),
    Expense(
      id: '6',
      category: 'Bills',
      amount: 150.00,
      date: DateTime(2026, 6, 15),
      description: 'Internet bill',
    ),
    Expense(
      id: '7',
      category: 'School',
      amount: 200.00,
      date: DateTime(2026, 6, 14),
      description: 'Books',
    ),
    Expense(
      id: '8',
      category: 'Others',
      amount: 15.50,
      date: DateTime(2026, 6, 13),
      description: 'Coffee',
    ),
  ];

  @override
  Future<List<Expense>> getAllExpenses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Expense>.from(_expenses);
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index == -1) return null;
    return _expenses[index];
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) return;
    _expenses[index] = expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _expenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category.isEmpty) return List<Expense>.from(_expenses);
    return _expenses.where((expense) => expense.category == category).toList();
  }

  @override
  Future<double> getTotalExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }
}
