import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import 'anonity_logo.dart';

class PostCard extends StatefulWidget {
  final AppPost post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool liked = widget.post.likedByMe;
  late int likeCount = widget.post.likesCount;
  bool _busy = false;

  Future<void> _toggleLike() async {
    if (_busy) return;
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to like posts.')),
      );
      return;
    }
    final wasLiked = liked;
    // Optimistic update, rolled back if the request fails.
    setState(() {
      liked = !liked;
      likeCount += liked ? 1 : -1;
      _busy = true;
    });
    try {
      await PostService.toggleLike(widget.post.id, currentlyLiked: wasLiked);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        liked = wasLiked;
        likeCount += wasLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              Image.asset(kAnonityLogoAsset, width: 34, height: 34),
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
              _StatAction(icon: Icons.mode_comment_outlined, count: post.commentsCount, onTap: () {}),
              const SizedBox(width: 22),
              _StatAction(icon: Icons.repeat_rounded, count: post.repostsCount, onTap: () {}),
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
