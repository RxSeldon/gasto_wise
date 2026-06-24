import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/models.dart';

// Authentication service - Single Responsibility: handles auth operations
abstract class IAuthService {
  Future<User?> login(String email, String password);
  Future<User?> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}

class AuthService implements IAuthService {
  final supabase.SupabaseClient? _providedClient;

  AuthService({supabase.SupabaseClient? client}) : _providedClient = client;

  supabase.SupabaseClient get _client =>
      _providedClient ?? supabase.Supabase.instance.client;

  @override
  Future<User?> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final supabaseUser = response.user;
    if (supabaseUser == null) return null;
    final user = _mapUser(supabaseUser);
    await _ensureUserProfile(user);
    return user;
  }

  @override
  Future<User?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    final supabaseUser = response.user;
    if (supabaseUser == null) return null;
    final user = _mapUser(supabaseUser);
    if (response.session != null) {
      await _ensureUserProfile(user);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;
    return _mapUser(supabaseUser);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _client.auth.currentUser != null;
  }

  User _mapUser(supabase.User user) {
    final metadata = user.userMetadata ?? {};
    final name = metadata['name']?.toString() ??
        metadata['full_name']?.toString() ??
        user.email?.split('@').first ??
        'GastoWise User';

    return User(
      id: user.id,
      name: name,
      email: user.email ?? '',
      phone: user.phone ?? '',
    );
  }

  Future<void> _ensureUserProfile(User user) async {
    await _client.from('users').upsert({
      'id': user.id,
      'full_name': user.name,
      'email': user.email,
    }, onConflict: 'id');
  }
}
