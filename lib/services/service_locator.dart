import '../utils/app_constants.dart';
import '../repositories/expense_repository.dart';
import 'auth_service.dart';
import 'expense_service.dart';
import 'validation_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  late final IExpenseRepository _expenseRepository;
  late final IExpenseService _expenseService;
  late final IBudgetService _budgetService;
  late final IValidationService _validationService;
  late final IAuthService _authService;
  bool _isSetup = false;

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  void setupServices() {
    if (_isSetup) return;

    _expenseRepository = SupabaseExpenseRepository();
    _expenseService = ExpenseService(repository: _expenseRepository);
    _budgetService = BudgetService(
      expenseRepository: _expenseRepository,
      monthlyBudget: AppConstants.defaultBudget,
    );
    _validationService = ValidationService();
    _authService = AuthService();
    _isSetup = true;
  }

  IExpenseRepository get expenseRepository => _expenseRepository;
  IExpenseService get expenseService => _expenseService;
  IBudgetService get budgetService => _budgetService;
  IValidationService get validationService => _validationService;
  IAuthService get authService => _authService;
}
