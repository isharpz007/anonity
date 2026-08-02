import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';

class ExploreScreen extends StatelessWidget {
  final bool embedded;
  const ExploreScreen({super.key, this.embedded = false});

  static const _sections = [
    {'title': 'Spicy', 'sub': 'No filters.\nSay it how it is.', 'members': '12.4K members'},
    {'title': 'Relationship', 'sub': 'Love, dating,\nand everything in between.', 'members': '8.7K members'},
    {'title': 'Work', 'sub': 'Career, hustles,\nand money talks.', 'members': '9.1K members'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              hintText: 'Search posts, users, or groups...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Popular Sections', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final s = _sections[i];
                final title = s['title']!;
                final color = sectionColor(title);
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$title ${sectionEmoji(title)}',
                          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(s['sub']!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
                      const Spacer(),
                      Text(s['members']!,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trending Posts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < mockTrendingPosts.length; i++) _TrendingRow(index: i + 1, post: mockTrendingPosts[i]),
        ],
      ),
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
            child: Text('$index', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          const AnonityMask(size: 34, glow: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionTag(section: post.section, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(post.content, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${post.handle} · ${post.timeAgo}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                    const SizedBox(width: 12),
                    const Icon(Icons.mode_comment_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${post.comments}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
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
