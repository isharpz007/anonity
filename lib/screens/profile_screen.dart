import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/app_feedback.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/post_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileData {
  final AppProfile? profile;
  final List<AppPost> posts;
  _ProfileData({required this.profile, required this.posts});
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0; // Posts / Replies / Bookmarks
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final userId = AuthService.currentUser?.id;
    // Fetch profile and posts independently — if one fails, the
    // other still shows. A whole-screen blank because the avatar
    // service blipped is not acceptable.
    final results = await Future.wait<dynamic>([
      ProfileService.fetchCurrentProfile().catchError((e) {
        debugPrint('Profile fetch failed: $e');
        return null;
      }),
      userId == null
          ? Future.value(<AppPost>[])
          : PostService.fetchPostsByUser(userId).catchError((e) {
              debugPrint('User posts fetch failed: $e');
              return <AppPost>[];
            }),
    ]);
    return _ProfileData(
      profile: results[0] as AppProfile?,
      posts: (results[1] as List).cast<AppPost>(),
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<_ProfileData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SkeletonPulse(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    children: [
                      SkeletonProfileHeader(),
                      SizedBox(height: 26),
                      SkeletonPostCard(),
                      SkeletonPostCard(),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: InlineErrorState(
                      message: friendlyError(snapshot.error!),
                      onRetry: _reload,
                    ),
                  ),
                ],
              );
            }
            final data = snapshot.data!;
            final profile = data.profile;
            final totalLikes =
                data.posts.fold<int>(0, (sum, p) => sum + p.likesCount);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(kAnonityLogoAsset, width: 84, height: 84),
                      const SizedBox(height: 12),
                      Text(profile?.username ?? 'Anonymous',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('@${profile?.username ?? 'anon_user'}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        profile?.bio.isNotEmpty == true
                            ? profile!.bio
                            : 'Speak freely. Stay anonymous.',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(value: '${data.posts.length}', label: 'Posts'),
                    _StatColumn(value: '$totalLikes', label: 'Likes'),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _Tab(
                          label: 'Posts',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0)),
                      _Tab(
                          label: 'Replies',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1)),
                      _Tab(
                          label: 'Bookmarks',
                          selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_tab == 0)
                  if (data.posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text("You haven't posted anything yet.",
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    for (final p in data.posts) PostCard(post: p)
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        _tab == 1 ? 'No replies yet.' : 'No bookmarks yet.',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              )),
        ),
      ),
    );
  }
}