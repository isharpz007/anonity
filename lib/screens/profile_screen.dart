import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0; // Posts / Replies / Bookmarks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Center(
            child: Column(
              children: [
                const AnonityMask(size: 84),
                const SizedBox(height: 12),
                const Text('Anonymous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Text('@anon_user', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                const Text('Speak freely. Stay anonymous.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _StatColumn(value: '128', label: 'Posts'),
              _StatColumn(value: '12', label: 'Groups'),
              _StatColumn(value: '1.2K', label: 'Likes'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _Tab(label: 'Posts', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                _Tab(label: 'Replies', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                _Tab(label: 'Bookmarks', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0)
            for (final p in profilePosts) PostCard(post: p)
          else
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  _tab == 1 ? 'No replies yet.' : 'No bookmarks yet.',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
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
                fontSize: 12.5,
              )),
        ),
      ),
    );
  }
}
