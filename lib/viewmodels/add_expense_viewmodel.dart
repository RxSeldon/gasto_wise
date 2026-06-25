import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_constants.dart';
import '../models/models.dart';
import '../services/expense_service.dart';
import '../services/validation_service.dart';

class AddExpenseViewModel extends ChangeNotifier {
  final IExpenseService _expenseService;
  final IValidationService _validationService;

  String _selectedCategory = AppConstants.categories.first;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  AddExpenseViewModel({
    required IExpenseService expenseService,
    required IValidationService validationService,
  })  : _expenseService = expenseService,
        _validationService = validationService;

  String get selectedCategory => _selectedCategory;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  String? validateAmount(String? value) =>
      _validationService.validateAmount(value ?? '');

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
  }

  Future<bool> saveExpense({
    required String amount,
    required String description,
  }) async {
    _isLoading = true;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final newExpense = Expense(
        id: const Uuid().v4(),
        category: _selectedCategory,
        amount: double.parse(amount),
        date: _selectedDate,
        description: description.trim(),
      );

      await _expenseService.addExpense(newExpense);

      _successMessage = 'Expense added successfully';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetForm() {
    _selectedCategory = AppConstants.categories.first;
    _selectedDate = DateTime.now();
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
