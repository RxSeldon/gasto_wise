import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/expense_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final IExpenseService _expenseService;
  final IBudgetService _budgetService;

  double _totalBudget = 0;
  double _totalExpenses = 0;
  double _budgetPercentage = 0;
  List<Expense> _recentExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  DashboardViewModel({
    required IExpenseService expenseService,
    required IBudgetService budgetService,
  })  : _expenseService = expenseService,
        _budgetService = budgetService;

  double get totalBudget => _totalBudget;
  double get totalExpenses => _totalExpenses;
  double get budgetPercentage => _budgetPercentage;
  double get remainingBudget => _totalBudget - _totalExpenses;
  List<Expense> get recentExpenses => _recentExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearMessages() {
    _errorMessage = null;
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final budgetInfo = await _budgetService.getBudgetInfo();
      final recentExpenses = await _expenseService.getRecentExpenses();

      _totalBudget = budgetInfo.totalBudget;
      _totalExpenses = budgetInfo.totalExpenses;
      _budgetPercentage = budgetInfo.usagePercentage;
      _recentExpenses = recentExpenses;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading dashboard: $e';
      notifyListeners();
    }
  }

  Future<bool> updateBudget(String budgetText) async {
    final newBudget = double.tryParse(budgetText);
    if (newBudget == null || newBudget < 0) return false;

    try {
      await _budgetService.setMonthlyBudget(newBudget);
      await loadDashboardData();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating budget: $e';
      notifyListeners();
      return false;
    }
  }
}
