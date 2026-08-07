import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _opacity = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacity.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(kAnonityLogoAsset, width: 130, height: 130),
                    const SizedBox(height: 28),
                    // FIX: was a bare `Row` with default mainAxisSize.max, which
                    // stayed exactly as wide as its Text children and overflowed
                    // by 1.8px on narrower screens. Wrapping in FittedBox lets it
                    // scale down to fit the available width instead of erroring,
                    // and mainAxisSize.min keeps the Row itself tight so
                    // FittedBox has something finite to scale.
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Anon',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'ity',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGlow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Speak freely. Stay anonymous.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const Spacer(flex: 4),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Log In'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}