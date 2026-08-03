import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/root_shell.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  final themeController = ThemeController();
  await themeController.loadPreferences();
  runApp(ThemeControllerProvider(
      notifier: themeController, child: const AnonityApp()));
}

class AnonityApp extends StatelessWidget {
  const AnonityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerProvider.of(context);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Anonity',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: AppTheme.light.copyWith(
            colorScheme: themeController.resolveColorScheme(
                Brightness.light, lightDynamic, darkDynamic),
            extensions: [
              AppThemeExtras(accentGradient: themeController.accentGradient),
            ],
          ),
          darkTheme: AppTheme.dark.copyWith(
            colorScheme: themeController.resolveColorScheme(
                Brightness.dark, lightDynamic, darkDynamic),
            extensions: [
              AppThemeExtras(accentGradient: themeController.accentGradient),
            ],
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Routes straight to the app shell if a session already exists
/// (e.g. returning user with a stored session), otherwise shows
/// the Splash -> Login/Create Account flow.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.onAuthStateChange,
      initialData: null,
      builder: (context, snapshot) {
        final loggedIn = AuthService.isLoggedIn;
        return loggedIn ? const RootShell() : const SplashScreen();
      },
    );
  }
}
