import 'package:flutter_test/flutter_test.dart';
import 'package:gasto_wise/services/validation_service.dart';

void main() {
  // Single Responsibility: each group tests one behaviour of ValidationService
  late ValidationService sut;

  setUp(() {
    sut = ValidationService();
  });

  // ── Email validation ─────────────────────────────────────────────────────────

  group('validateEmail', () {
    test('returns null for a valid email', () {
      final result = sut.validateEmail('user@example.com');

      expect(result, isNull);
    });

    test('returns error for an invalid email format', () {
      final result = sut.validateEmail('notanemail');

      expect(result, 'Please enter a valid email');
    });

    test('returns required error for an empty email', () {
      final result = sut.validateEmail('');

      expect(result, 'Email is required');
    });
  });

  // ── Username validation (min 5 characters) ───────────────────────────────────

  group('validateUsername', () {
    test('returns null when username has at least 5 characters', () {
      final result = sut.validateUsername('johndoe');

      expect(result, isNull);
    });

    test('returns error when username has fewer than 5 characters', () {
      final result = sut.validateUsername('john');

      expect(result, 'Username must be at least 5 characters');
    });

    test('returns required error for an empty username', () {
      final result = sut.validateUsername('');

      expect(result, 'Username is required');
    });
  });
}
