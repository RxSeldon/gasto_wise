import 'package:gasto_wise/models/models.dart';
import 'package:gasto_wise/services/auth_service.dart';

// Manual mock - Dependency Inversion Principle: depends on IAuthService abstraction
class MockAuthService implements IAuthService {
  final bool shouldSucceed;
  final String? errorToThrow;

  const MockAuthService({
    this.shouldSucceed = true,
    this.errorToThrow,
  });

  static const _testUser = User(
    id: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
    phone: '',
  );

  @override
  Future<User?> login(String email, String password) async {
    if (errorToThrow != null) throw Exception(errorToThrow);
    return shouldSucceed ? _testUser : null;
  }

  @override
  Future<User?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return shouldSucceed ? _testUser : null;
  }

  @override
  Future<void> resendSignUpConfirmation(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isLoggedIn() async => false;
}
