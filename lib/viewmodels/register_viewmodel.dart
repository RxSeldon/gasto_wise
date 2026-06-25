import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/validation_service.dart';

enum RegisterResult { none, loggedIn, needsConfirmation, failed }

class RegisterViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IValidationService _validationService;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  RegisterResult _result = RegisterResult.none;

  RegisterViewModel({
    required IAuthService authService,
    required IValidationService validationService,
  })  : _authService = authService,
        _validationService = validationService;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  String? get errorMessage => _errorMessage;
  RegisterResult get result => _result;

  String? validateName(String? value) =>
      _validationService.validateName(value?.trim() ?? '');

  String? validateEmail(String? value) =>
      _validationService.validateEmail(value?.trim() ?? '');

  String? validatePassword(String? value) =>
      _validationService.validatePassword(value ?? '');

  String? validateConfirmPassword(String? value, String password) {
    final passwordError = _validationService.validatePassword(value ?? '');
    if (passwordError != null) return passwordError;
    if (value != password) return 'Passwords do not match';
    return null;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _result = RegisterResult.none;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _result = RegisterResult.none;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        fullName: name.trim(),
        email: email.trim(),
        password: password,
      );

      if (user == null) {
        _errorMessage = 'Registration failed';
        _result = RegisterResult.failed;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final isLoggedIn = await _authService.isLoggedIn();
      _result = isLoggedIn
          ? RegisterResult.loggedIn
          : RegisterResult.needsConfirmation;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _result = RegisterResult.failed;
      _isLoading = false;
      notifyListeners();
    }
  }
}
