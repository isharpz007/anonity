import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/app_feedback.dart';
import '../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _section;
  bool _anonymous = true;
  bool _posting = false;
  String? _error;
  static const int _maxLen = 500;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _posting) return;
    setState(() {
      _posting = true;
      _error = null;
    });
    try {
      await PostService.createPost(
        content: content,
        isAnonymous: _anonymous,
        section: _section,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showToast(context,
          _anonymous ? 'Posted anonymously to Anonity.' : 'Posted to Anonity.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _posting = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final len = _controller.text.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            Image.asset(kAnonityLogoAsset, width: 26, height: 26),
            const SizedBox(width: 8),
            Text(_anonymous ? 'Anonymous' : 'You',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const Icon(Icons.expand_more_rounded,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
      // Everything above the bottom action bar scrolls, so when the
      // keyboard opens the text field's caret stays visible instead of
      // being squeezed off-screen.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLength: _maxLen,
                      minLines: 6,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        counterText: '',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('$len/$_maxLen',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ),
                    const Divider(height: 24),
                    const Text('Choose Section',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final s in const [
                          'Spicy',
                          'Relationship',
                          'Work'
                        ]) ...[
                          Expanded(
                              child: _SectionChoice(
                            label: s,
                            selected: _section == s,
                            onTap: () => setState(
                                () => _section = _section == s ? null : s),
                          )),
                          if (s != 'Work') const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 25),
                    _OptionRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Anonymous',
                      trailing: Switch(
                        value: _anonymous,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) => setState(() => _anonymous = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pinned action bar — stays just above the keyboard.
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: InlineError(message: _error!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.image_outlined,
                          color: AppColors.textMuted),
                      onPressed: () {}),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _posting ? null : _post,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(96, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                    ),
                    child: _posting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SectionChoice(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = sectionColor(label);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.9)
              : color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: selected ? 1 : 0.4)),
        ),
        child: Text(
          '$label ${sectionEmoji(label)}',
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  const _OptionRow({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
