import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../services/auth_service.dart';
import '../services/validation_service.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IValidationService _validationService;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  bool _loginSuccess = false;

  LoginViewModel({
    required IAuthService authService,
    required IValidationService validationService,
  })  : _authService = authService,
        _validationService = validationService;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get errorMessage => _errorMessage;
  bool get loginSuccess => _loginSuccess;

  String? validateEmail(String? value) =>
      _validationService.validateEmail(value ?? '');

  String? validatePassword(String? value) =>
      _validationService.validatePassword(value ?? '');

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _loginSuccess = false;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _loginSuccess = false;
    notifyListeners();

    try {
      final user = await _authService.login(email.trim(), password);

      if (user == null) {
        _errorMessage = 'Login failed: no user returned';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _loginSuccess = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      await _handleLoginError(e);
    }
  }

  Future<void> _handleLoginError(Object error) async {
    if (_isEmailNotConfirmed(error)) {
      try {
        await _authService
            .resendSignUpConfirmation(_extractEmail(error) ?? '');
      } catch (_) {}
      _errorMessage = 'Please confirm your email before signing in.';
      notifyListeners();
      return;
    }

    _errorMessage = 'Login failed: ${_readableAuthError(error)}';
    notifyListeners();
  }

  String? _extractEmail(Object error) => null;

  bool _isEmailNotConfirmed(Object error) {
    return error is supabase.AuthException &&
        (error.code == 'email_not_confirmed' ||
            error.message.toLowerCase().contains('email not confirmed'));
  }

  String _readableAuthError(Object error) {
    if (error is supabase.AuthException) {
      return error.message;
    }
    return error.toString();
  }
}
