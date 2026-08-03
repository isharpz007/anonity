// Smoke test for the Anonity app.
//
// AnonityApp now talks to Supabase (auth state, session), so it needs
// Supabase initialized before the widget tree builds — same as main().
// We point it at dummy credentials; no real network call happens just
// from building the Splash/Login screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anonity/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://YOUR_PROJECT_REF.supabase.co',
      anonKey: 'test-anon-key',
      debug: false,
    );
  });

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
