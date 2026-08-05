import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
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