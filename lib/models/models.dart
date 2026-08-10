/// Models mapped directly to Supabase table rows.
/// Each has a fromMap() factory matching the columns in supabase/schema.sql.
library;

class AppProfile {
  final String id;
  final String username;
  final String bio;
  final String? avatarUrl;

  const AppProfile({
    required this.id,
    required this.username,
    required this.bio,
    this.avatarUrl,
  });

  factory AppProfile.fromMap(Map<String, dynamic> map) => AppProfile(
        id: map['id'] as String,
        username: map['username'] as String? ?? 'user',
        bio: map['bio'] as String? ?? '',
        avatarUrl: map['avatar_url'] as String?,
      );
}

class AppPost {
  final String id;
  final String authorId;
  final String? authorUsername; // joined from profiles, null if not fetched
  final bool isAnonymous;
  final String section; // legacy single section, kept for feed-tab filtering
  final List<String> tags; // full tag set for display, e.g. ['Emotions','Sex']
  final String content;
  final int commentsCount;
  final int likesCount;
  final int viewsCount;
  final DateTime createdAt;
  final bool likedByMe;

  const AppPost({
    required this.id,
    required this.authorId,
    required this.isAnonymous,
    required this.section,
    required this.tags,
    required this.content,
    required this.commentsCount,
    required this.likesCount,
    required this.createdAt,
    this.viewsCount = 0,
    this.authorUsername,
    this.likedByMe = false,
  });

  factory AppPost.fromMap(Map<String, dynamic> map, {bool likedByMe = false}) {
    // profiles may come back as a nested map when the query joins it.
    final profile = map['profiles'];
    // DateTime.parse is the most likely thrower (null/missing/garbage
    // created_at). Fall back to "now" so the row still renders
    // instead of nuking the whole feed. Callers should still treat
    // this as a malformed row and skip if they want.
    final createdAtRaw = map['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    final section = (map['section'] as String?) ?? '';

    // 'tags' is expected to be a Postgres text[] column and comes back
    // as a List. Fall back to wrapping the legacy single `section`
    // value so older rows / callers that never populated `tags` still
    // render at least one chip.
    final rawTags = map['tags'];
    List<String> tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const [];
    if (tags.isEmpty && section.isNotEmpty) tags = [section];

    return AppPost(
      id: (map['id'] as String?) ?? '',
      authorId: (map['author_id'] as String?) ?? '',
      authorUsername: profile is Map ? profile['username'] as String? : null,
      isAnonymous: map['is_anonymous'] as bool? ?? true,
      section: section,
      tags: tags,
      content: map['content'] as String? ?? '',
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      viewsCount: (map['views_count'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      likedByMe: likedByMe,
    );
  }

  String get handle => '@${authorUsername ?? 'anon_user'}';

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}

class AppComment {
  final String? authorUsername; // joined from profiles, null if not fetched
  final bool isAnonymous;
  final String content;
  final DateTime createdAt;

  const AppComment({
    required this.isAnonymous,
    required this.content,
    required this.createdAt,
    this.authorUsername,
  });

  factory AppComment.fromMap(Map<String, dynamic> map) {
    // profiles may come back as a nested map when the query joins it.
    final profile = map['profiles'];
    // DateTime.parse is the most likely thrower (null/missing/garbage
    // created_at). Fall back to "now" so the row still renders
    // instead of nuking the whole list.
    final createdAtRaw = map['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    return AppComment(
      authorUsername: profile is Map ? profile['username'] as String? : null,
      isAnonymous: map['is_anonymous'] as bool? ?? true,
      content: map['content'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}