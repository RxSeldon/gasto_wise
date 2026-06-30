import 'package:gasto_wise/services/validation_service.dart';

// Manual mock - allows tests to control validation outcomes independently
class MockValidationService implements IValidationService {
  final String? emailError;
  final String? passwordError;
  final String? usernameError;
  final bool emailValid;

  const MockValidationService({
    this.emailError,
    this.passwordError,
    this.usernameError,
    this.emailValid = true,
  });

  @override
  String? validateEmail(String email) => emailError;

  @override
  String? validatePassword(String password) => passwordError;

  @override
  String? validateAmount(String amount) => null;

  @override
  String? validateName(String name) => null;

  @override
  String? validateUsername(String username) => usernameError;

  @override
  bool isValidEmail(String email) => emailValid;
}
