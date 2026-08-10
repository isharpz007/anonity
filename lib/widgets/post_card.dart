import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../widgets/app_feedback.dart';
import 'comment_sheet.dart';

// How many characters of content to show before truncating with a
// "...more" toggle. A character count (rather than measuring actual
// line overflow) keeps this cheap and predictable across card widths.
const int _kTruncateAt = 150;

class PostCard extends StatefulWidget {
  final AppPost post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool liked = widget.post.likedByMe;
  late int likeCount = widget.post.likesCount;
  late int commentCount = widget.post.commentsCount;
  bool _busy = false;
  bool _expanded = false;

  // Reused across rebuilds so we don't create a fresh recognizer on
  // every frame. Recognizers are cheap but they accumulate listener
  // state if you keep re-binding .onTap to new closures without
  // disposing the old one — so the same instance lives for the
  // lifetime of this card.
  final TapGestureRecognizer _moreTap = TapGestureRecognizer();
  final TapGestureRecognizer _lessTap = TapGestureRecognizer();

  @override
  void dispose() {
    _moreTap.dispose();
    _lessTap.dispose();
    super.dispose();
  }

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
      showToast(context, 'Could not update. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openComments() {
    showCommentSheet(
      context,
      widget.post,
      onCommentPosted: (newCount) {
        if (mounted) setState(() => commentCount = newCount);
      },
    );
  }

  Widget _buildContent(String content) {
    const textStyle = TextStyle(
      color: AppColors.postCardTextPrimary,
      fontSize: 14.5,
      height: 1.4,
    );
    const linkStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDim,
    );
    final needsTruncation = content.length > _kTruncateAt;

    if (!needsTruncation || _expanded) {
      // Expanded view: whole content plus an inline "less" link that
      // collapses back. Re-bind the recognizer on every rebuild so
      // we always close over the current State (avoid stale `this`
      // captures after the widget is reparented).
      _lessTap.onTap = () => setState(() => _expanded = false);
      return RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: content),
            if (needsTruncation)
              TextSpan(text: '  less', style: linkStyle, recognizer: _lessTap),
          ],
        ),
      );
    }

    _moreTap.onTap = () => setState(() => _expanded = true);
    final truncated = content.substring(0, _kTruncateAt).trimRight();
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: '$truncated… '),
          TextSpan(text: 'more', style: linkStyle, recognizer: _moreTap),
        ],
      ),
    );
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
          // Tag chips (e.g. 'Emotions 🙈', 'Sex 🔥') instead of one
          // section header — shows the full multi-tag set on the post.
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
                          ? 'Anonymous ${100 + (post.authorId.isEmpty ? 0 : post.authorId.hashCode.abs() % 900)}'
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
          _buildContent(post.content),
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
                icon: Icons.mode_comment_outlined,
                count: commentCount,
                onTap: _openComments,
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
}

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
      // Pin fontFamily to NotoColorEmoji so the emoji glyph always
      // uses the bundled color-emoji font, regardless of the parent
      // text theme (which uses GoogleFonts.inter — Inter has no
      // glyph for these).
      child: Text(
        face,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: 'NotoColorEmoji',
        ),
      ),
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
