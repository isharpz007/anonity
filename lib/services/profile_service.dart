import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProfileService {
  ProfileService._();
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<AppProfile?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (row == null) return null;
    return AppProfile.fromMap(row);
  }

  static Future<void> updateBio(String bio) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in.');
    await _client.from('profiles').update({'bio': bio}).eq('id', userId);
  }
}
