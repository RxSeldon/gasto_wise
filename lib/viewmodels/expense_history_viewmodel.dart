import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/expense_service.dart';

class ExpenseHistoryViewModel extends ChangeNotifier {
  final IExpenseService _expenseService;

  String _selectedFilter = 'All';
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  ExpenseHistoryViewModel({required IExpenseService expenseService})
      : _expenseService = expenseService;

  String get selectedFilter => _selectedFilter;
  List<Expense> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  double get filteredTotal =>
      _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final expenses = await _expenseService.getAllExpenses();
      _allExpenses = expenses;
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading expenses: $e';
      notifyListeners();
    }
  }

  void setFilter(String category) {
    _selectedFilter = category;
    _applyFilter();
    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      _allExpenses.removeWhere((expense) => expense.id == expenseId);
      _applyFilter();
      _successMessage = 'Expense deleted successfully';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting expense: $e';
      notifyListeners();
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredExpenses = List.from(_allExpenses);
    } else {
      _filteredExpenses = _allExpenses
          .where((expense) => expense.category == _selectedFilter)
          .toList();
    }
    _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
  }
}
