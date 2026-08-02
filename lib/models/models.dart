class AppPost {
  final String id;
  final String handle;
  final bool isAnonymous;
  final String timeAgo;
  final String section; // Spicy / Relationship / Work / ''
  final String content;
  final int comments;
  final int reposts;
  final int likes;

  const AppPost({
    required this.id,
    required this.handle,
    required this.isAnonymous,
    required this.timeAgo,
    required this.section,
    required this.content,
    required this.comments,
    required this.reposts,
    required this.likes,
  });
}

class AppGroup {
  final String id;
  final String name;
  final String emoji;
  final bool isPrivate;
  final String memberCount;
  final String description;
  final int? unreadCount;

  const AppGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isPrivate,
    required this.memberCount,
    required this.description,
    this.unreadCount,
  });
}

class GroupMessage {
  final String author;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;

  const GroupMessage({
    required this.author,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
  });
}

// ---- Mock data, mirroring the mockup screens ----

final List<AppPost> mockFeedPosts = [
  const AppPost(
    id: 'p1',
    handle: '@shadow_22',
    isAnonymous: false,
    timeAgo: '2h',
    section: 'Spicy',
    content: 'Unpopular opinion: Sometimes the truth hurts but silence hurts more.',
    comments: 24,
    reposts: 68,
    likes: 189,
  ),
  const AppPost(
    id: 'p2',
    handle: '@latenight',
    isAnonymous: false,
    timeAgo: '4h',
    section: 'Relationship',
    content: 'The right person will never make you feel like you have to compete for their attention.',
    comments: 15,
    reposts: 52,
    likes: 142,
  ),
];

final List<AppPost> mockTrendingPosts = [
  const AppPost(
    id: 't1',
    handle: '@fiery_anon',
    isAnonymous: false,
    timeAgo: '3h',
    section: 'Spicy',
    content: "What's the most overrated thing people are obsessed with?",
    comments: 89,
    reposts: 0,
    likes: 0,
  ),
  const AppPost(
    id: 't2',
    handle: '@heart_confused',
    isAnonymous: false,
    timeAgo: '5h',
    section: 'Relationship',
    content: 'Is it okay to break up via text?',
    comments: 63,
    reposts: 0,
    likes: 0,
  ),
];

final List<AppGroup> myGroups = [
  const AppGroup(
    id: 'g1',
    name: 'Late Night Venting',
    emoji: '🌙',
    isPrivate: true,
    memberCount: '2.1K members',
    description: 'A safe space to vent and release.',
    unreadCount: 12,
  ),
  const AppGroup(
    id: 'g2',
    name: 'Hustlers Club',
    emoji: '💼',
    isPrivate: true,
    memberCount: '3.8K members',
    description: 'Connect. Learn. Grow.',
    unreadCount: 25,
  ),
  const AppGroup(
    id: 'g3',
    name: 'Anonymous Talk',
    emoji: '💬',
    isPrivate: true,
    memberCount: '1.9K members',
    description: 'Talk about anything. Anonymously.',
    unreadCount: 7,
  ),
  const AppGroup(
    id: 'g4',
    name: 'Spicy Society',
    emoji: '🌶️',
    isPrivate: false,
    memberCount: '6.2K members',
    description: 'No limits. No regrets.',
    unreadCount: 18,
  ),
];

final List<GroupMessage> hustlersClubFeed = [
  const GroupMessage(
    author: 'GrindMode',
    timeAgo: '2h ago',
    content: 'Just landed a new client! Consistency really pays off.',
    likes: 24,
    comments: 12,
  ),
  const GroupMessage(
    author: 'MoneyMoves',
    timeAgo: '4h ago',
    content: "Best productivity hack you've discovered?",
    likes: 37,
    comments: 29,
  ),
];

final List<AppPost> profilePosts = [
  const AppPost(
    id: 'pr1',
    handle: '@anon_user',
    isAnonymous: true,
    timeAgo: '2h',
    section: '',
    content: 'The older I get, the more I realize silence is power.',
    comments: 18,
    reposts: 42,
    likes: 103,
  ),
  const AppPost(
    id: 'pr2',
    handle: '@anon_user',
    isAnonymous: true,
    timeAgo: '1d',
    section: '',
    content: 'Some people will never like you, and that is okay.',
    comments: 21,
    reposts: 63,
    likes: 156,
  ),
  const AppPost(
    id: 'pr3',
    handle: '@anon_user',
    isAnonymous: true,
    timeAgo: '2d',
    section: '',
    content: 'Protect your peace at all costs.',
    comments: 9,
    reposts: 31,
    likes: 88,
  ),
];
