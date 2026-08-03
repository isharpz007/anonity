import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/app_feedback.dart';
import '../services/auth_service.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() => _error = null);
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signIn(emailOrUsername: email, password: password);
      if (!mounted) return;
      // AuthGate (in main.dart) listens for the auth state change and
      // swaps to RootShell automatically — just pop back to it.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      print('❌ Login failed: ${e.message}');
      setState(() => _error = e.message);
    } catch (e) {
      print('❌ Login error: $e');
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _socialComingSoon() {
    showToast(context, 'Social login coming soon — use email for now.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Welcome back 👋',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Log in to continue to Anonity',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 28),
              Center(
                  child: Image.asset(kAnonityLogoAsset, width: 56, height: 56)),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AppColors.textMuted),
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textMuted),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null) InlineError(message: _error!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Log In'),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or continue with',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      onTap: _socialComingSoon),
                  _SocialButton(
                      icon: Icons.apple_rounded, onTap: _socialComingSoon),
                  _SocialButton(
                      icon: Icons.chat_bubble_rounded,
                      onTap: _socialComingSoon),
                ],
              ),
              const SizedBox(height: 26),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const CreateAccountScreen()),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
