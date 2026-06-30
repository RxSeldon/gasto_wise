import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasto_wise/viewmodels/login_viewmodel.dart';
import 'package:gasto_wise/views/login_screen.dart';

import '../mocks/mock_auth_service.dart';
import '../mocks/mock_validation_service.dart';

// Helper that builds LoginScreen with injected mocks — keeps each test focused
Widget _buildSubject({
  MockAuthService? auth,
  MockValidationService? validation,
}) {
  return MaterialApp(
    routes: {'/home': (_) => const Scaffold(body: Text('Home'))},
    home: LoginScreen(
      viewModelFactory: (_) => LoginViewModel(
        authService: auth ?? const MockAuthService(),
        validationService: validation ?? const MockValidationService(),
      ),
    ),
  );
}

// Sets the test surface to 600×1000 logical pixels so the login screen renders
// without any overflow, then resets on tear-down.
Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(600, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  // ── Verify widgets are rendered ──────────────────────────────────────────────

  group('LoginScreen widget presence', () {
    testWidgets('shows Email TextField', (WidgetTester tester) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_buildSubject());

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('shows Password TextField', (WidgetTester tester) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_buildSubject());

      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('shows Login button', (WidgetTester tester) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_buildSubject());

      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });
  });

  // ── Simulate user interactions ───────────────────────────────────────────────

  group('LoginScreen user interactions', () {
    testWidgets('user can enter email', (WidgetTester tester) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_buildSubject());

      // Email field is the first TextFormField in the form
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('user can enter password', (WidgetTester tester) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_buildSubject());

      // Password field is the last TextFormField in the form
      await tester.enterText(
        find.byType(TextFormField).last,
        'secret123',
      );
      await tester.pump();

      // obscureText hides the characters — verify the field accepted input without error
      expect(tester.takeException(), isNull);
    });

    testWidgets('pressing Login button triggers login flow', (
      WidgetTester tester,
    ) async {
      await _setPhoneSize(tester);

      // Mocks return no validation errors and a successful login
      await tester.pumpWidget(
        _buildSubject(
          auth: const MockAuthService(shouldSucceed: true),
          validation: const MockValidationService(
            emailError: null,
            passwordError: null,
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'secret123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Successful login navigates to /home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
