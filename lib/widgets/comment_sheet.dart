import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';
import 'anonity_logo.dart';
import 'skeleton.dart';
import 'app_feedback.dart';

/// Opens the reply sheet for [post] — shows the post being replied
/// to, existing replies, and a composer at the bottom, similar to
/// tapping the comment icon on X. Calls [onCommentPosted] with the
/// new total comment count once a reply is successfully posted, so
/// the calling PostCard can update its own count without a refetch.
Future<void> showCommentSheet(
  BuildContext context,
  AppPost post, {
  required ValueChanged<int> onCommentPosted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // surfaceElevated sits one step brighter than `surface` so the
    // sheet clearly lifts off the page underneath, while the embedded
    // post preview below uses `surface` to read as a darker nested
    // card within it. Using `background` here made the whole sheet
    // visually fuse with the screen and feel unreadably dark.
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CommentSheet(post: post, onCommentPosted: onCommentPosted),
  );
}

class _CommentSheet extends StatefulWidget {
  final AppPost post;
  final ValueChanged<int> onCommentPosted;
  const _CommentSheet({required this.post, required this.onCommentPosted});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  late Future<List<AppComment>> _commentsFuture;
  final _controller = TextEditingController();
  int _commentCount = 0;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.commentsCount;
    _commentsFuture = CommentService.fetchComments(widget.post.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _commentsFuture = CommentService.fetchComments(widget.post.id));
  }

  Future<void> _send() async {
    if (!AuthService.isLoggedIn) {
      showToast(context, 'Log in to reply.');
      return;
    }
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await CommentService.addComment(postId: widget.post.id, content: content);
      _controller.clear();
      setState(() => _commentCount += 1);
      widget.onCommentPosted(_commentCount);
      _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Padding(
      // Shifts the whole sheet up above the keyboard instead of
      // letting the keyboard cover the composer.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Replies',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  // Compact, non-interactive preview of the post being
                  // replied to — gives replies context, same as X shows
                  // the original tweet above its replies. Uses
                  // `background` (one step darker than the sheet's
                  // `surfaceElevated`) so the preview visually nests
                  // inside the sheet instead of looking identical to it.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(kAnonityLogoAsset, width: 26, height: 26),
                            const SizedBox(width: 8),
                            Text(post.isAnonymous ? 'Anonymous' : post.handle.replaceFirst('@', ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(width: 6),
                            Text(post.timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(post.content,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.35,
                              color: AppColors.textPrimary,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<AppComment>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SkeletonPulse(
                          child: Column(
                            children: [
                              _SkeletonCommentRow(),
                              SizedBox(height: 16),
                              _SkeletonCommentRow(),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return InlineErrorState(message: friendlyError(snapshot.error!), onRetry: _reload);
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text('No replies yet — be the first.',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                        );
                      }
                      return Column(children: [for (final c in comments) _CommentTile(comment: c)]);
                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) InlineError(message: _error!),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(kAnonityLogoAsset, width: 28, height: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              hintText: 'Post your reply',
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _sending
                              ? const SizedBox(
                                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send_rounded, color: AppColors.primary),
                          onPressed: _sending ? null : _send,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final AppComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    // Each comment sits on its own lightly-tinted card so the rows
    // read as separate messages instead of a continuous wall of text
    // against the sheet background. Slightly brighter than the
    // sheet's `surfaceElevated` so it visibly pops forward.
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(kAnonityLogoAsset, width: 28, height: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.isAnonymous ? 'Anonymous' : (comment.authorUsername ?? 'anon_user'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(comment.timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton standing in for a comment row while the real list loads —
/// mirrors the [AppComment] tile layout (avatar + name + body lines).
class _SkeletonCommentRow extends StatelessWidget {
  const _SkeletonCommentRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBone.circle(size: 28),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBone(width: 90, height: 12),
              SizedBox(height: 8),
              SkeletonBone(height: 12),
              SizedBox(height: 6),
              SkeletonBone(width: 200, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
