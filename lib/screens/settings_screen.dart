import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';
import '../services/auth_service.dart';
import 'display_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Log out?'),
        content:
            const Text("You'll need to log back in to see your feed again."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.signOut();
      // AuthGate in main.dart listens for this and swaps back to SplashScreen.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Image.asset(kAnonityLogoAsset, width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectionCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.onSurface),
                  title: const Text('App Display',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Theme mode, appearance, and colors.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const DisplaySettingsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent),
                  title: const Text('Log Out',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent)),
                  onTap: _confirmSignOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SelectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}