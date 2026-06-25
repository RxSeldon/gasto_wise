import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/models.dart';
import '../repositories/expense_repository.dart';

abstract class IBudgetService {
  Future<BudgetInfo> getBudgetInfo();
  Future<double> getTotalExpenses();
  Future<double> getRemainingBudget();
  Future<double> getBudgetPercentage();
  Future<double> getMonthlyBudget();
  Future<void> setMonthlyBudget(double amount);
}

class BudgetService implements IBudgetService {
  final IExpenseRepository _expenseRepository;
  final supabase.SupabaseClient? _providedClient;
  final double _monthlyBudget;

  BudgetService({
    required IExpenseRepository expenseRepository,
    supabase.SupabaseClient? client,
    double monthlyBudget = 0.0,
  }) : _expenseRepository = expenseRepository,
       _providedClient = client,
       _monthlyBudget = monthlyBudget;

  supabase.SupabaseClient get _client =>
      _providedClient ?? supabase.Supabase.instance.client;

  @override
  Future<BudgetInfo> getBudgetInfo() async {
    final totalExpenses = await _expenseRepository.getTotalExpenses();
    final monthlyBudget = await getMonthlyBudget();
    return BudgetInfo(
      totalBudget: monthlyBudget,
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

  @override
  Future<double> getMonthlyBudget() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return _monthlyBudget;

    final row = await _client
        .from('budgets')
        .select('budget_amount')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return _monthlyBudget;
    final amount = row['budget_amount'];
    return amount is num ? amount.toDouble() : double.parse(amount.toString());
  }

  @override
  Future<void> setMonthlyBudget(double amount) async {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Must not be negative');
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be logged in to save a budget.');
    }

    final row = await _client
        .from('budgets')
        .select('id')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      await _client.from('budgets').insert({
        'user_id': userId,
        'budget_amount': amount,
      });
      return;
    }

    await _client
        .from('budgets')
        .update({'budget_amount': amount})
        .eq('id', row['id'])
        .eq('user_id', userId);
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
      throw ArgumentError.value(
        expense.amount,
        'amount',
        'Must be greater than 0',
      );
    }
    await _repository.addExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) => _repository.deleteExpense(id);
}
