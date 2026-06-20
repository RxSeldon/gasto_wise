import '../constants/app_constants.dart';

// Validation service - Single Responsibility: handles all validation logic
abstract class IValidationService {
  String? validateEmail(String email);
  String? validatePassword(String password);
  String? validateAmount(String amount);
  String? validateName(String name);
  bool isValidEmail(String email);
}

class ValidationService implements IValidationService {
  @override
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  @override
  String? validateAmount(String amount) {
    if (amount.isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(amount);
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  @override
  String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
