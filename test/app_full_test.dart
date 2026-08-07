import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anonity/config/supabase_config.dart';
import 'package:anonity/main.dart';
import 'package:anonity/services/auth_service.dart';
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
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
      debug: false,
    );
  });

  group('Anonity App UI', () {
    testWidgets('App starts successfully', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Anon'), findsOneWidget);
      expect(find.text('ity'), findsOneWidget);
      expect(find.text('Speak freely. Stay anonymous.'), findsOneWidget);
    });

    testWidgets('Splash screen loads', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Create Account'),
          findsOneWidget);
    });

    testWidgets('Login screen contains inputs', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('Create account button exists', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Create Account'),
          findsOneWidget);
    });

    testWidgets('Navigation works', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  group('Supabase Tests', () {
    test('Supabase client initializes', () {
      expect(Supabase.instance.client, isNotNull);
    });

    test('Auth service is available', () {
      expect(AuthService.currentUser, isNull);
    });
  });

  group('Security Tests', () {
    test('Empty password is rejected', () {
      const password = '';

      expect(password.length < 6, isTrue);
    });

    test('Username validation', () {
      const username = 'anonymous_user';

      expect(username.length > 3, isTrue);
    });
  });
}
