import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IBudgetService _budgetService;

  User _user = const User(
    id: '1',
    name: 'Juan Dela Cruz',
    email: 'juan@example.com',
    phone: '+63 912 345 6789',
  );
  double _monthlyBudget = 0.0;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String? _errorMessage;
  String? _successMessage;

  ProfileViewModel({
    required IAuthService authService,
    required IBudgetService budgetService,
  })  : _authService = authService,
        _budgetService = budgetService;

  User get user => _user;
  double get monthlyBudget => _monthlyBudget;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
  }

  Future<void> loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
      }
      final budget = await _budgetService.getMonthlyBudget();
      _monthlyBudget = budget;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading user: $e';
      notifyListeners();
    }
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
  }

  bool updateBudget(String budgetText) {
    final newBudget = double.tryParse(budgetText);
    if (newBudget != null && newBudget > 0) {
      _monthlyBudget = newBudget;
      _budgetService.setMonthlyBudget(newBudget);
      _successMessage = 'Monthly budget updated successfully';
      notifyListeners();
      return true;
    }
    _errorMessage = 'Please enter a valid amount';
    notifyListeners();
    return false;
  }

  Future<bool> logout() async {
    try {
      await _authService.logout();
      return true;
    } catch (e) {
      _errorMessage = 'Logout error: $e';
      notifyListeners();
      return false;
    }
  }
}
