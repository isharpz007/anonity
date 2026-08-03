import 'package:flutter/material.dart';
import '../widgets/anonity_bottom_nav.dart';
import 'home_feed_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';

/// Hosts the main tab destinations plus the center "create post" action.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0; // 0 Home, 1 Create, 2 Explore, 3 Profile

  final _pages = const [
    HomeFeedScreen(embedded: true),
    SizedBox.shrink(),
    ExploreScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const CreatePostScreen(), fullscreenDialog: true),
      );
      return;
    }
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar:
          AnonityBottomNav(currentIndex: _tab, onTap: _onNavTap),
    );
  }
}
