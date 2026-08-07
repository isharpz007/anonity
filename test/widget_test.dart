// Smoke test for the Anonity app.
//
// AnonityApp now talks to Supabase (auth state, session), so it needs
// Supabase initialized before the widget tree builds — same as main().
// We point it at dummy credentials; no real network call happens just
// from building the Splash/Login screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anonity/main.dart';
import 'package:anonity/theme/theme_manager.dart';

Widget _buildTestApp() {
  final themeController = ThemeController();

  return ThemeControllerProvider(
    notifier: themeController,
    child: const AnonityApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://YOUR_PROJECT_REF.supabase.co',
      publishableKey: 'test-anon-key',
      debug: false,
    );
  });

  testWidgets('App boots to Splash Screen with entry actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Anon'), findsOneWidget);
    expect(find.text('ity'), findsOneWidget);
    expect(find.text('Speak freely. Stay anonymous.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
    expect(
        find.widgetWithText(OutlinedButton, 'Create Account'), findsOneWidget);
  });

  testWidgets('Tapping Log In navigates to the Login Screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
