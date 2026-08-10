import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class CommentService {
  static final _client = Supabase.instance.client;

  static Future<List<AppComment>> fetchComments(String postId) async {
    final rows = await _client
        .from('comments')
        .select('*, profiles!comments_author_id_fkey(username)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return rows.map<AppComment>((r) => AppComment.fromMap(r)).toList();
  }

  static Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to reply.');
    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      // Comments follow the same anonymous-by-default identity as
      // the rest of Anonity — no separate toggle, matching how
      // replying works elsewhere in the app.
      'is_anonymous': true,
      'content': content,
    });
  }
}
