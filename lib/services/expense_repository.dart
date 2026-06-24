import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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

class SupabaseExpenseRepository implements IExpenseRepository {
  final supabase.SupabaseClient? _providedClient;

  SupabaseExpenseRepository({supabase.SupabaseClient? client})
    : _providedClient = client;

  static const _tableName = 'expenses';
  static const _dateColumn = 'expense_date';

  supabase.SupabaseClient get _client =>
      _providedClient ?? supabase.Supabase.instance.client;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order(_dateColumn, ascending: false);
    return rows
        .map((row) => Expense.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final expenseId = int.tryParse(id);
    final userId = _client.auth.currentUser?.id;
    if (expenseId == null || userId == null) return null;

    final row = await _client
        .from(_tableName)
        .select()
        .eq('id', expenseId)
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Expense.fromJson(row);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _client.from(_tableName).insert(_toSupabaseJson(expense));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenseId = int.tryParse(expense.id);
    if (expenseId == null) {
      throw ArgumentError.value(expense.id, 'id', 'Must be a database id');
    }

    await _client
        .from(_tableName)
        .update(_toSupabaseJson(expense))
        .eq('id', expenseId);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenseId = int.tryParse(id);
    if (expenseId == null) return;
    await _client.from(_tableName).delete().eq('id', expenseId);
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    if (category.isEmpty) {
      return getAllExpenses();
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .eq('category', category)
        .order(_dateColumn, ascending: false);
    return rows
        .map((row) => Expense.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<double> getTotalExpenses() async {
    final expenses = await getAllExpenses();
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, dynamic> _toSupabaseJson(Expense expense) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be logged in to save expenses.');
    }

    return {
      'user_id': userId,
      'category': expense.category,
      'amount': expense.amount,
      _dateColumn: expense.date.toIso8601String().split('T').first,
      'description': expense.description,
    };
  }
}
