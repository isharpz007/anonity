import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth. Screens call these instead of
/// touching Supabase.instance.client directly.
class AuthService {
  AuthService._();
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  /// Emits every time auth state changes (sign in, sign out, token refresh).
  /// Used by main.dart to route between Splash/Login and the app shell.
  static Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  static Future<void> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    // The mockup's "Email or username" field: if it looks like an email,
    // sign in directly; otherwise look up the email behind that username.
    String email = emailOrUsername;
    if (!emailOrUsername.contains('@')) {
      final row = await _client
          .from('profiles')
          .select('id')
          .eq('username', emailOrUsername)
          .maybeSingle();
      if (row == null) {
        throw const AuthException('No account found with that username.');
      }
      // Supabase client-side can't look up another user's email directly;
      // usernames should be encouraged to sign in with email instead, or
      // you can store email on the profile row (not recommended) or add
      // an Edge Function that resolves username -> email server-side.
      throw const AuthException('Please sign in with your email instead of username.');
    }
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() => _client.auth.signOut();
}
