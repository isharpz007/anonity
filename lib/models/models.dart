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
  final String section; // 'Spicy' / 'Relationship' / 'Work' / ''
  final String content;
  final int commentsCount;
  final int repostsCount;
  final int likesCount;
  final DateTime createdAt;
  final bool likedByMe;

  const AppPost({
    required this.id,
    required this.authorId,
    required this.isAnonymous,
    required this.section,
    required this.content,
    required this.commentsCount,
    required this.repostsCount,
    required this.likesCount,
    required this.createdAt,
    this.authorUsername,
    this.likedByMe = false,
  });

  factory AppPost.fromMap(Map<String, dynamic> map, {bool likedByMe = false}) {
    // profiles may come back as a nested map when the query joins it.
    final profile = map['profiles'];
    return AppPost(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      authorUsername: profile is Map ? profile['username'] as String? : null,
      isAnonymous: map['is_anonymous'] as bool? ?? true,
      section: (map['section'] as String?) ?? '',
      content: map['content'] as String? ?? '',
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      repostsCount: (map['reposts_count'] as num?)?.toInt() ?? 0,
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      likedByMe: likedByMe,
    );
  }

  String get handle => '@${authorUsername ?? 'anon_user'}';

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class AppGroup {
  final String id;
  final String name;
  final String emoji;
  final bool isPrivate;
  final String description;
  final int memberCount;
  final int? unreadCount;

  const AppGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isPrivate,
    required this.description,
    this.memberCount = 0,
    this.unreadCount,
  });

  factory AppGroup.fromMap(Map<String, dynamic> map, {int memberCount = 0}) => AppGroup(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '💬',
        isPrivate: map['is_private'] as bool? ?? true,
        description: map['description'] as String? ?? '',
        memberCount: memberCount,
      );

  String get memberCountLabel {
    if (memberCount >= 1000) return '${(memberCount / 1000).toStringAsFixed(1)}K members';
    return '$memberCount members';
  }
}

class GroupMessage {
  final String id;
  final String authorId;
  final String? authorUsername;
  final String content;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const GroupMessage({
    required this.id,
    required this.authorId,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.authorUsername,
  });

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'];
    return GroupMessage(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      authorUsername: profile is Map ? profile['username'] as String? : null,
      content: map['content'] as String? ?? '',
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get author => authorUsername ?? 'member';

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
