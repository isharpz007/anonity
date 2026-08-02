import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PostService {
  PostService._();
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetches recent posts, optionally filtered by section
  /// ('Spicy' / 'Relationship' / 'Work'). Pass null for all sections.
  static Future<List<AppPost>> fetchFeed({String? section, int limit = 30}) async {
    var query = _client
        .from('posts')
        .select('*, profiles(username)')
        .order('created_at', ascending: false)
        .limit(limit);

    final rows = section == null
        ? await query
        : await _client
            .from('posts')
            .select('*, profiles(username)')
            .eq('section', section)
            .order('created_at', ascending: false)
            .limit(limit);

    final userId = currentUserId();
    final posts = <AppPost>[];
    for (final row in rows) {
      bool liked = false;
      if (userId != null) {
        final likeRow = await _client
            .from('likes')
            .select()
            .eq('post_id', row['id'] as String)
            .eq('user_id', userId)
            .maybeSingle();
        liked = likeRow != null;
      }
      posts.add(AppPost.fromMap(row, likedByMe: liked));
    }
    return posts;
  }

  /// Trending = most-liked in the last few days. Simple client-side
  /// version; move to a Postgres view/RPC later if this gets slow.
  static Future<List<AppPost>> fetchTrending({int limit = 10}) async {
    final rows = await _client
        .from('posts')
        .select('*, profiles(username)')
        .order('likes_count', ascending: false)
        .limit(limit);
    return rows.map<AppPost>((r) => AppPost.fromMap(r)).toList();
  }

  static Future<List<AppPost>> fetchPostsByUser(String userId) async {
    final rows = await _client
        .from('posts')
        .select('*, profiles(username)')
        .eq('author_id', userId)
        .order('created_at', ascending: false);
    return rows.map<AppPost>((r) => AppPost.fromMap(r)).toList();
  }

  static Future<void> createPost({
    required String content,
    required bool isAnonymous,
    String? section,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to post.');
    await _client.from('posts').insert({
      'author_id': userId,
      'content': content,
      'is_anonymous': isAnonymous,
      'section': section,
    });
  }

  static Future<void> toggleLike(String postId, {required bool currentlyLiked}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to like a post.');
    if (currentlyLiked) {
      await _client.from('likes').delete().eq('post_id', postId).eq('user_id', userId);
    } else {
      await _client.from('likes').insert({'post_id': postId, 'user_id': userId});
    }
  }

  static Future<int> fetchSectionPostCount(String section) async {
    final rows = await _client.from('posts').select('id').eq('section', section);
    return rows.length;
  }

  static Future<List<AppPost>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _client
        .from('posts')
        .select('*, profiles(username)')
        .ilike('content', '%$query%')
        .order('created_at', ascending: false)
        .limit(30);
    return rows.map<AppPost>((r) => AppPost.fromMap(r)).toList();
  }
}

/// Small helper so PostService doesn't need to import AuthService
/// (avoids a circular import while keeping fetchFeed self-contained).
String? currentUserId() => Supabase.instance.client.auth.currentUser?.id;
