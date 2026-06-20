import '../models/models.dart';
import 'expense_repository.dart';

abstract class IBudgetService {
  Future<BudgetInfo> getBudgetInfo();
  Future<double> getTotalExpenses();
  Future<double> getRemainingBudget();
  Future<double> getBudgetPercentage();
}

class BudgetService implements IBudgetService {
  final IExpenseRepository _expenseRepository;
  final double _monthlyBudget;

  BudgetService({
    required IExpenseRepository expenseRepository,
    double monthlyBudget = 5000.0,
  }) : _expenseRepository = expenseRepository,
       _monthlyBudget = monthlyBudget;

  @override
  Future<BudgetInfo> getBudgetInfo() async {
    final totalExpenses = await _expenseRepository.getTotalExpenses();
    return BudgetInfo(
      totalBudget: _monthlyBudget,
      totalExpenses: totalExpenses,
      month: DateTime.now(),
    );
  }

  @override
  Future<double> getTotalExpenses() => _expenseRepository.getTotalExpenses();

  @override
  Future<double> getRemainingBudget() async {
    final budgetInfo = await getBudgetInfo();
    return budgetInfo.remainingBudget;
  }

  @override
  Future<double> getBudgetPercentage() async {
    final budgetInfo = await getBudgetInfo();
    return budgetInfo.usagePercentage;
  }
}

abstract class IExpenseService {
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getRecentExpenses({int limit = 4});
  Future<List<Expense>> getExpensesByCategory(String category);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class ExpenseService implements IExpenseService {
  final IExpenseRepository _repository;

  ExpenseService({required IExpenseRepository repository})
    : _repository = repository;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final expenses = await _repository.getAllExpenses();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<List<Expense>> getRecentExpenses({int limit = 4}) async {
    final expenses = await getAllExpenses();
    return expenses.take(limit).toList(growable: false);
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final expenses = await _repository.getExpensesByCategory(category);
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> addExpense(Expense expense) async {
    if (expense.amount <= 0) {
      throw ArgumentError.value(expense.amount, 'amount', 'Must be greater than 0');
    }
    await _repository.addExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) => _repository.deleteExpense(id);
}
