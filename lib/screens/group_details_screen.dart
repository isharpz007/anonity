import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';

class GroupDetailsScreen extends StatefulWidget {
  final AppGroup group;
  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int _tab = 0; // Feed / Members / About

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Text('${g.name} ${g.emoji}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${g.isPrivate ? "Private Group" : "Public Group"} · ${g.memberCount}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                height: 34,
                width: 96,
                child: Stack(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Positioned(
                        left: i * 20.0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceElevated,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.person, size: 15, color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('Invite'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _Tab(label: 'Feed', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                _Tab(label: 'Members', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                _Tab(label: 'About', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0) ..._buildFeed(g) else if (_tab == 1) _buildMembers() else _buildAbout(g),
        ],
      ),
    );
  }

  List<Widget> _buildFeed(AppGroup g) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const AnonityMask(size: 30, glow: false),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Share something with the group...',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      for (final m in hustlersClubFeed) _GroupMessageTile(message: m),
    ];
  }

  Widget _buildMembers() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Text('${widget.group.memberCount} in this group.',
            style: const TextStyle(color: AppColors.textMuted)),
      ),
    );
  }

  Widget _buildAbout(AppGroup g) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About this group', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(g.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4)),
          const SizedBox(height: 12),
          Text('${g.isPrivate ? "Private" : "Public"} · ${g.memberCount}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

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
                fontSize: 13,
              )),
        ),
      ),
    );
  }
}

class _GroupMessageTile extends StatelessWidget {
  final GroupMessage message;
  const _GroupMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnonityMask(size: 28, glow: false),
              const SizedBox(width: 8),
              Text(message.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              Text(message.timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(message.content, style: const TextStyle(fontSize: 13.5, height: 1.35)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text('${message.likes}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(width: 18),
              const Icon(Icons.mode_comment_outlined, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text('${message.comments}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
