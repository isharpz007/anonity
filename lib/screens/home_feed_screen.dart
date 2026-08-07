import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/app_feedback.dart';
import '../services/post_service.dart';
import 'create_post_screen.dart';
// import 'settings_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  final bool embedded;
  const HomeFeedScreen({super.key, this.embedded = false});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final List<String> _tabs = const [
    'For You',
    'Following',
    'Spicy',
    'Relationship',
    'Work'
  ];
  int _tabIndex = 0;

  late Future<List<AppPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = PostService.fetchFeed();
  }

  void _loadPosts() {
    final section = _tabIndex >= 2 ? _tabs[_tabIndex] : null;
    setState(() {
      _postsFuture = PostService.fetchFeed(section: section);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(kAnonityLogoAsset, width: 30, height: 30),
            const SizedBox(width: 8),
            const Text('Anonity',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _tabIndex;
                final label = _tabs[i];
                final hasSection = i >= 2;
                return ChoiceChip(
                  label: Text(
                    hasSection ? '$label ${sectionEmoji(label)}' : label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _tabIndex = i);
                    _loadPosts();
                  },
                  selectedColor: hasSection
                      ? sectionColor(label)
                      : const Color.fromARGB(255, 92, 239, 255),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadPosts(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const CreatePostScreen(),
                            fullscreenDialog: true),
                      );
                      _loadPosts();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Image.asset(kAnonityLogoAsset, width: 32, height: 32),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text("What's on your mind?",
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded,
                                size: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<AppPost>>(
                    future: _postsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SkeletonPulse(
                          child: Column(
                            children: [
                              SkeletonPostCard(),
                              SkeletonPostCard(),
                              SkeletonPostCard(),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: InlineErrorState(
                            message: friendlyError(snapshot.error!),
                            onRetry: _loadPosts,
                          ),
                        );
                      }
                      final posts = snapshot.data ?? [];
                      if (posts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text('No posts yet in ${_tabs[_tabIndex]}.',
                                style: const TextStyle(
                                    color: AppColors.textMuted)),
                          ),
                        );
                      }
                      return Column(children: [
                        for (final post in posts) PostCard(post: post)
                      ]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
