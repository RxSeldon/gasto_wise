import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasto_wise/main.dart';
import 'package:gasto_wise/services/service_locator.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    ServiceLocator().setupServices();

    await tester.pumpWidget(const MyApp());

    expect(find.text('GastoWise'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
