import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PostService {
  PostService._();
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetches recent posts, optionally filtered by section
  /// ('Spicy' / 'Relationship' / 'Work'). Pass null for all sections.
  ///
  /// Each row is wrapped in its own try/catch so a single malformed
  /// row (missing created_at, broken profile join, etc.) doesn't
  /// take down the whole feed — the bad row is skipped and the rest
  /// still render.
  static Future<List<AppPost>> fetchFeed({String? section, int limit = 30}) async {
    final rows = section == null
        ? await _client
            .from('posts')
            .select('*, profiles!posts_author_id_fkey(username)')
            .order('created_at', ascending: false)
            .limit(limit)
        : await _client
            .from('posts')
            .select('*, profiles!posts_author_id_fkey(username)')
            .eq('section', section)
            .order('created_at', ascending: false)
            .limit(limit);

    final userId = currentUserId();

    // Batch the "did I like this post" check into a single query for
    // all post ids on this page, instead of one query per post (that
    // was an N+1 — up to `limit` sequential round trips before the
    // feed could render). Best-effort: if this one query fails, we
    // fall back to "not liked" for everything rather than losing the
    // feed.
    Set<String> likedPostIds = const {};
    if (userId != null && rows.isNotEmpty) {
      try {
        final postIds = rows.map((r) => r['id'] as String).toList();
        final likeRows = await _client
            .from('likes')
            .select('post_id')
            .eq('user_id', userId)
            .inFilter('post_id', postIds);
        likedPostIds =
            likeRows.map((r) => r['post_id'] as String).toSet();
      } catch (_) {
        likedPostIds = const {};
      }
    }

    final posts = <AppPost>[];
    for (final row in rows) {
      try {
        final liked = likedPostIds.contains(row['id']);
        posts.add(AppPost.fromMap(row, likedByMe: liked));
      } catch (e) {
        // Skip the one bad row; keep the rest of the feed alive.
        debugPrint('Skipping malformed post row: $e');
      }
    }
    return posts;
  }

  /// Trending = most-liked in the last few days. Simple client-side
  /// version; move to a Postgres view/RPC later if this gets slow.
  static Future<List<AppPost>> fetchTrending({int limit = 10}) async {
    final rows = await _client
        .from('posts')
        .select('*, profiles!posts_author_id_fkey(username)')
        .order('likes_count', ascending: false)
        .limit(limit);
    final out = <AppPost>[];
    for (final r in rows) {
      try {
        out.add(AppPost.fromMap(r));
      } catch (e) {
        debugPrint('Skipping malformed trending row: $e');
      }
    }
    return out;
  }

  static Future<List<AppPost>> fetchPostsByUser(String userId) async {
    final rows = await _client
        .from('posts')
        .select('*, profiles!posts_author_id_fkey(username)')
        .eq('author_id', userId)
        .order('created_at', ascending: false);
    final out = <AppPost>[];
    for (final r in rows) {
      try {
        out.add(AppPost.fromMap(r));
      } catch (e) {
        debugPrint('Skipping malformed user post row: $e');
      }
    }
    return out;
  }

  /// Creates a post with one or more tags (e.g. ['Emotions', 'Sex']).
  /// `section` is still written alongside `tags` (as the first tag)
  /// so the existing 'Spicy' / 'Relationship' / 'Work' feed-tab
  /// filtering in fetchFeed keeps working unchanged. Requires a
  /// `tags text[]` column on `posts` — see note below.
  static Future<void> createPost({
    required String content,
    required bool isAnonymous,
    List<String> tags = const [],
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to post.');
    final cleanTags =
        tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    await _client.from('posts').insert({
      'author_id': userId,
      'content': content,
      'is_anonymous': isAnonymous,
      'tags': cleanTags,
      'section': cleanTags.isNotEmpty ? cleanTags.first : null,
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
        .select('*, profiles!posts_author_id_fkey(username)')
        .ilike('content', '%$query%')
        .order('created_at', ascending: false)
        .limit(30);
    final out = <AppPost>[];
    for (final r in rows) {
      try {
        out.add(AppPost.fromMap(r));
      } catch (e) {
        debugPrint('Skipping malformed search result: $e');
      }
    }
    return out;
  }
}

/// Small helper so PostService doesn't need to import AuthService
/// (avoids a circular import while keeping fetchFeed self-contained).
String? currentUserId() => Supabase.instance.client.auth.currentUser?.id;