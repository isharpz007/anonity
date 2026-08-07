import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../widgets/app_feedback.dart';

/// Post card matching the Anonity feed mockup: a light lavender card
/// with tag chips, an illustrated anon avatar, an expandable content
/// block, and a two-stat reaction/views row.
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
  bool _expanded = false;

  // A post is only truncated if it's long enough that 3 lines would
  // meaningfully cut it off. This is a length heuristic rather than an
  // exact line-measurement, which keeps the card lightweight.
  bool get _isLong => widget.post.content.length > 150;

  Future<void> _toggleLike() async {
    if (_busy) return;
    if (!AuthService.isLoggedIn) {
      showToast(context, 'Log in to react to posts.');
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
      showToast(context, 'Could not update reaction. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.postCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.postCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [for (final tag in post.tags) _TagChip(label: tag)],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnonAvatar(seed: post.authorId),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.isAnonymous
                          ? 'Anonymous ${_anonNumber(post.authorId)}'
                          : (post.authorUsername ??
                              post.handle.replaceFirst('@', '')),
                      style: const TextStyle(
                        color: AppColors.postCardTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: AppColors.postCardTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContent(),
          const SizedBox(height: 14),
          Row(
            children: [
              _ReactionStat(
                icon: liked
                    ? Icons.emoji_emotions_rounded
                    : Icons.emoji_emotions_outlined,
                count: likeCount,
                active: liked,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 20),
              _ReactionStat(
                icon: Icons.remove_red_eye_outlined,
                count: post.viewsCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = widget.post.content;
    const style = TextStyle(
      color: AppColors.postCardTextPrimary,
      fontSize: 14.5,
      height: 1.4,
    );

    if (_expanded || !_isLong) {
      return GestureDetector(
        onTap: _isLong ? () => setState(() => _expanded = false) : null,
        child: RichText(
          text: TextSpan(
            style: style,
            children: [
              TextSpan(text: content),
              if (_isLong)
                const TextSpan(
                  text: '  less',
                  style: TextStyle(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Collapsed: clip to 3 lines and overlay a tappable "...more" in
    // the bottom-right corner, faded in from the card background so
    // it reads as part of the text rather than a separate control.
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: Stack(
        children: [
          Text(
            content,
            style: style,
            maxLines: 3,
            overflow: TextOverflow.clip,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00F4F1FC), AppColors.postCard],
                  stops: [0, 0.35],
                ),
              ),
              child: const Text(
                '...more',
                style: TextStyle(
                  color: AppColors.primaryDim,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Deterministic 3-digit-ish number so the same anonymous author
/// always shows the same "Anonymous ###" label within a session.
int _anonNumber(String seed) => 100 + (seed.hashCode.abs() % 900);

/// Small illustrated-style avatar: a soft pastel circle with a face
/// emoji, chosen deterministically from the author id so the same
/// anonymous author gets a consistent look across posts.
class _AnonAvatar extends StatelessWidget {
  final String seed;
  const _AnonAvatar({required this.seed});

  static const _palette = [
    Color(0xFFFFD9B3),
    Color(0xFFC9E4FF),
    Color(0xFFFFC9DE),
    Color(0xFFD3F0D3),
    Color(0xFFFFE9A8),
    Color(0xFFD8D2FF),
  ];
  static const _faces = ['🐻', '🦊', '🐼', '🦉', '🐸', '🐨', '🐵', '🐰'];

  @override
  Widget build(BuildContext context) {
    final hash = seed.isEmpty ? 0 : seed.hashCode.abs();
    final bg = _palette[hash % _palette.length];
    final face = _faces[hash % _faces.length];
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(face, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final emoji = sectionEmoji(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tagChipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emoji.isNotEmpty ? '$label $emoji' : label,
        style: const TextStyle(
          color: AppColors.tagChipText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReactionStat extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback? onTap;
  const _ReactionStat({
    required this.icon,
    required this.count,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppColors.like : AppColors.postCardTextSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}