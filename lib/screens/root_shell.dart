import 'package:flutter/material.dart';
import '../widgets/anonity_bottom_nav.dart';
import 'home_feed_screen.dart';
import 'groups_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';

/// Hosts the four tab destinations plus the center "create post" action,
/// matching the bottom nav shown across screens 4, 5, 7, and 9 of the mockup.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0; // 0 Home, 1 Groups, 3 Explore, 4 Profile (2 is the modal)

  final _pages = const [
    HomeFeedScreen(embedded: true),
    GroupsScreen(embedded: true),
    SizedBox.shrink(),
    ExploreScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreatePostScreen(), fullscreenDialog: true),
      );
      return;
    }
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: AnonityBottomNav(currentIndex: _tab, onTap: _onNavTap),
    );
  }
}
