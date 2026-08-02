import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'anonity_logo.dart';

class PostCard extends StatefulWidget {
  final AppPost post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  late int likeCount = widget.post.likes;

  void _toggleLike() {
    setState(() {
      liked = !liked;
      likeCount += liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnonityMask(size: 34, glow: false),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.isAnonymous ? 'Anonymous' : post.handle.replaceFirst('@', ''),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${post.handle} · ${post.timeAgo}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (post.section.isNotEmpty) SectionTag(section: post.section),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 14.5, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatAction(icon: Icons.mode_comment_outlined, count: post.comments, onTap: () {}),
              const SizedBox(width: 22),
              _StatAction(icon: Icons.repeat_rounded, count: post.reposts, onTap: () {}),
              const SizedBox(width: 22),
              _StatAction(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                count: likeCount,
                color: liked ? AppColors.like : null,
                onTap: _toggleLike,
              ),
              const Spacer(),
              Icon(Icons.ios_share_rounded, size: 17, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatAction extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback onTap;
  const _StatAction({required this.icon, required this.count, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: c),
          const SizedBox(width: 5),
          Text('$count', style: TextStyle(color: c, fontSize: 12.5)),
        ],
      ),
    );
  }
}
