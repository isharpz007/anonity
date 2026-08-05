import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/skeleton.dart';
import '../widgets/app_feedback.dart';
import '../services/post_service.dart';

class ExploreScreen extends StatefulWidget {
  final bool embedded;
  const ExploreScreen({super.key, this.embedded = false});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _sections = [
    {'title': 'Spicy', 'sub': 'No filters.\nSay it how it is.'},
    {
      'title': 'Relationship',
      'sub': 'Love, dating,\nand everything in between.'
    },
    {'title': 'Work', 'sub': 'Career, hustles,\nand money talks.'},
  ];

  final _searchController = TextEditingController();
  late Future<List<AppPost>> _trendingFuture;
  Future<List<int>>? _sectionCountsFuture;
  Future<List<AppPost>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = PostService.fetchTrending();
    // Per-count try/catch via wait — if one section's count query
    // fails (transient blip, RLS change, etc.) we still render the
    // other two instead of blocking the whole explore page on it.
    _sectionCountsFuture = _loadSectionCounts();
  }

  Future<List<int>> _loadSectionCounts() async {
    final results = await Future.wait(
      _sections.map((s) async {
        try {
          return await PostService.fetchSectionPostCount(s['title']!);
        } catch (e) {
          debugPrint('Section count failed for ${s['title']}: $e');
          return 0;
        }
      }),
    );
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    setState(() {
      _searchFuture =
          query.trim().isEmpty ? null : PostService.searchPosts(query);
    });
  }

  void _reloadTrending() {
    setState(() => _trendingFuture = PostService.fetchTrending());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Explore',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          TextField(
            controller: _searchController,
            onSubmitted: _runSearch,
            onChanged: (v) {
              if (v.trim().isEmpty) setState(() => _searchFuture = null);
            },
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
              hintText: 'Search posts...',
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchFuture = null);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_searchFuture != null)
            _SearchResults(
              future: _searchFuture!,
              onRetry: () {
                // Re-run the last submitted query by going through
                // the same path as onSubmitted.
                _runSearch(_searchController.text);
              },
            )
          else ...[
            const Text('Popular Sections',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: FutureBuilder<List<int>>(
                future: _sectionCountsFuture,
                builder: (context, countsSnap) {
                  if (countsSnap.connectionState == ConnectionState.waiting) {
                    return const SkeletonPulse(
                      child: Row(
                        children: [
                          SkeletonSectionCard(),
                          SizedBox(width: 12),
                          SkeletonSectionCard(),
                          SizedBox(width: 12),
                          SkeletonSectionCard(),
                        ],
                      ),
                    );
                  }
                  final counts = countsSnap.data;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sections.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final s = _sections[i];
                      final title = s['title']!;
                      final color = sectionColor(title);
                      final count = counts != null ? counts[i] : null;
                      return Container(
                        width: 160,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$title ${sectionEmoji(title)}',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(s['sub']!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.3)),
                            const Spacer(),
                            Text(
                              count == null ? '…' : '$count posts',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11.5),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Trending Posts',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            FutureBuilder<List<AppPost>>(
              future: _trendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonPulse(
                    child: Column(
                      children: [
                        SkeletonTrendingRow(),
                        SkeletonTrendingRow(),
                        SkeletonTrendingRow(),
                        SkeletonTrendingRow(),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InlineErrorState(
                      message: friendlyError(snapshot.error!),
                      onRetry: _reloadTrending,
                    ),
                  );
                }
                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('No posts yet.',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < posts.length; i++)
                      _TrendingRow(index: i + 1, post: posts[i]),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final Future<List<AppPost>> future;
  final VoidCallback onRetry;
  const _SearchResults({required this.future, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppPost>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonPulse(
            child: Column(
              children: [
                SkeletonTrendingRow(),
                SkeletonTrendingRow(),
                SkeletonTrendingRow(),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: InlineErrorState(
              message: friendlyError(snapshot.error!),
              onRetry: onRetry,
            ),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
                child: Text('No matching posts.',
                    style: TextStyle(color: AppColors.textMuted))),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < results.length; i++)
              _TrendingRow(index: i + 1, post: results[i])
          ],
        );
      },
    );
  }
}

class _TrendingRow extends StatelessWidget {
  final int index;
  final AppPost post;
  const _TrendingRow({required this.index, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text('$index',
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Image.asset(kAnonityLogoAsset, width: 34, height: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.section.isNotEmpty)
                  Row(
                    children: [
                      SectionTag(
                          section: post.section,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3)),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(post.content,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${post.handle} · ${post.timeAgo}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11.5)),
                    const SizedBox(width: 12),
                    const Icon(Icons.mode_comment_outlined,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${post.commentsCount}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
