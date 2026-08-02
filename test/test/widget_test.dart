// Smoke test for the Anonity app.
//
// Verifies the app boots to the Splash Screen and shows the wordmark
// and both entry-point buttons (Log In / Create Account).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anonity/main.dart';

void main() {
  testWidgets('App boots to Splash Screen with entry actions', (WidgetTester tester) async {
    await tester.pumpWidget(const AnonityApp());
    await tester.pumpAndSettle();

    // Wordmark is split into two Text widgets ('Anon' + 'ity').
    expect(find.text('Anon'), findsOneWidget);
    expect(find.text('ity'), findsOneWidget);
    expect(find.text('Speak freely. Stay anonymous.'), findsOneWidget);

    // Entry-point buttons.
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Create Account'), findsOneWidget);
  });

  testWidgets('Tapping Log In navigates to the Login Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AnonityApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back 👋'), findsOneWidget);
  });
}
