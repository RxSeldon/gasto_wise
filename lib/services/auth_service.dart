import '../models/models.dart';

// Authentication service - Single Responsibility: handles auth operations
abstract class IAuthService {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}

class AuthService implements IAuthService {
  User? _currentUser;

  @override
  Future<User?> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock authentication - in real app, would call API
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '1',
        name: 'Juan Dela Cruz',
        email: email,
        phone: '+63 912 345 6789',
      );
      return _currentUser;
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }
}
