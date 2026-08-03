/// Supabase project credentials.
///
/// Get these from your Supabase project dashboard:
///   Project Settings -> API -> Project URL / anon public key
///
/// IMPORTANT: the "anon" key is safe to ship in a client app (that's
/// what it's for) — but never put your "service_role" key here.
/// Row Level Security (see supabase/schema.sql) is what actually
/// protects your data, not keeping this key secret.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String anonKey = 'YOUR_ANON_PUBLIC_KEY';
}
