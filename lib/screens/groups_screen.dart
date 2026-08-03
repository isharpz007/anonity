import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';
import '../services/group_service.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatefulWidget {
  final bool embedded;
  const GroupsScreen({super.key, this.embedded = false});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  int _tab = 0; // 0 My Groups, 1 Discover
  late Future<List<AppGroup>> _future;

  @override
  void initState() {
    super.initState();
    _future = GroupService.fetchMyGroups();
  }

  void _reload() {
    setState(() {
      _future = _tab == 0 ? GroupService.fetchMyGroups() : GroupService.fetchDiscoverGroups();
    });
  }

  Future<void> _join(AppGroup g) async {
    try {
      await GroupService.joinGroup(g.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined ${g.name}.')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not join: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _SegButton(
                    label: 'My Groups',
                    selected: _tab == 0,
                    onTap: () {
                      setState(() => _tab = 0);
                      _reload();
                    },
                  ),
                  _SegButton(
                    label: 'Discover',
                    selected: _tab == 1,
                    onTap: () {
                      setState(() => _tab = 1);
                      _reload();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: FutureBuilder<List<AppGroup>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonPulse(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Column(
                          children: [
                            SkeletonGroupTile(),
                            SizedBox(height: 12),
                            SkeletonGroupTile(),
                            SizedBox(height: 12),
                            SkeletonGroupTile(),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text('Could not load groups.\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                      ],
                    );
                  }
                  final groups = snapshot.data ?? [];
                  if (groups.isEmpty) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text(
                              _tab == 0 ? "You haven't joined any groups yet." : 'No new groups to discover.',
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final g = groups[i];
                      return InkWell(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => GroupDetailsScreen(group: g)))
                            .then((_) => _reload()),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(g.emoji, style: const TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(g.name,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 4),
                                        if (g.isPrivate)
                                          const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textMuted),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${g.isPrivate ? "Private" : "Public"} · ${g.memberCountLabel}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(g.description,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (_tab == 1)
                                TextButton(
                                  onPressed: () => _join(g),
                                  child: const Text('Join'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
