import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'screens/splash_screen.dart';
import 'widgets/resume_splash_overlay.dart';
import 'screens/root_shell.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  // Catch every uncaught async error in the app (Future errors that
  // nobody awaited, errors inside streams, etc.). Without this, a
  // single missed .catchError can crash the isolate and the user sees
  // a blank screen instead of anything useful.
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Replace Flutter's default red error box (the one that shows
      // "If this is your code, congratulations — you've found a bug"
      // in debug, and a gray box in release) with a friendly
      // themed screen. This catches *build-phase* errors, including
      // ones from `Error.throwWithStackTrace` inside a widget tree
      // or a FutureBuilder.
      ErrorWidget.builder = (FlutterErrorDetails details) =>
          _AppErrorWidget(details: details);

      // Belt-and-braces: route the framework's own uncaught errors
      // to the same place (otherwise they just print to console
      // and the user still sees whatever broken widget was on
      // screen).
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        // Don't override the friendly ErrorWidget.builder in release
        // for legitimate widget errors — let it draw the themed page.
      };

      try {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
        );
      } catch (e, st) {
        // If Supabase itself can't initialize (bad URL, no network
        // at startup), we still want the rest of the app to render
        // so the user can at least see the splash/login screen
        // rather than a permanent blank.
        debugPrint('Supabase init failed: $e\n$st');
      }

      final themeController = ThemeController();
      try {
        await themeController.loadPreferences();
      } catch (e, st) {
        // Prefs are non-essential — fall through with defaults.
        debugPrint('Theme prefs load failed: $e\n$st');
      }

      runApp(ThemeControllerProvider(
          notifier: themeController, child: const AnonityApp()));
    },
    (Object error, StackTrace stack) {
      // Last-resort handler for errors that escaped the zone.
      // In release we swallow them so the app keeps running;
      // in debug we still print so devs see them.
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}

/// Renders inside the widget tree when a build error slips through.
/// Keeps the user on a friendly screen with a "Try Again" button
/// instead of Flutter's debug red box.
class _AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _AppErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    // In debug, keep showing Flutter's actual error widget — devs need
    // to see the red box to know what broke. Only override in release
    // (or if kReleaseMode is false but kDebugMode is also false, e.g.
    // profile mode).
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The screen hit a problem rendering. You can try again, '
                    'or come back in a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      // Rebuild the root: easiest reset without
                      // bringing in a router package is to just
                      // navigate back to the first route. If the
                      // root itself was what crashed, this won't
                      // help — but for errors inside a child route
                      // it'll recover gracefully.
                      final navigator = _rootNavigatorKey.currentState;
                      navigator?.popUntil((route) => route.isFirst);
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A navigator key that survives widget rebuilds, so the error widget
/// can pop back to root even if the MaterialApp above it threw.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
          navigatorKey: _rootNavigatorKey,
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
          home: const AppResumeSplashOverlay(child: AuthGate()),
          // Builder wraps the whole MaterialApp so any navigation that
          // throws gets caught and turned into the same friendly
          // screen, rather than Flutter's black "Navigator observer
          // error" state.
          builder: (context, child) {
            return _ErrorCatcher(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}

/// Routes between Splash -> RootShell based on the current auth state.
/// Listens to Supabase's auth state stream so sign-in / sign-out
/// swaps the tree without manual nav.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.onAuthStateChange,
      initialData: null,
      builder: (context, snapshot) {
        final loggedIn = AuthService.isLoggedIn;
        // Keep the theme controller's logged-in flag in sync so it knows
        // whether to apply the permanent pre-auth theme or the user's
        // saved dark/light/gradient choice. Scheduled after this frame
        // since it's not safe to call notifyListeners() during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ThemeControllerProvider.of(context).setLoggedIn(loggedIn);
        });
        return loggedIn ? const RootShell() : const SplashScreen();
      },
    );
  }
}

/// Wraps the child in an error boundary so a thrown widget during
/// build (e.g. an unhandled exception inside FutureBuilder's
/// `builder`, or a bad model parse) shows a recovery screen rather
/// than a permanently broken frame.
class _ErrorCatcher extends StatefulWidget {
  final Widget child;
  const _ErrorCatcher({required this.child});

  @override
  State<_ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<_ErrorCatcher> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Catch errors thrown by PlatformDispatcher / Flutter framework
    // that don't go through ErrorWidget.builder.
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error: $error\n$stack');
      if (mounted) setState(() => _error = error);
      return true; // mark as handled
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _FullScreenError(
        error: _error!,
        onReset: () => setState(() => _error = null),
      );
    }
    return widget.child;
  }
}

class _FullScreenError extends StatelessWidget {
  final Object error;
  final VoidCallback onReset;
  const _FullScreenError({required this.error, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'We hit a snag',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kDebugMode
                      ? '$error'
                      : "Something didn't load right. Please try again.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onReset,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}