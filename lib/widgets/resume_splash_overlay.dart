import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/anonity_logo.dart';

/// Wraps the app so a short branded splash animation plays every time
/// the user returns to the app — whether that's the very first cold
/// start, or coming back after backgrounding it — regardless of
/// whether they're logged in. Cold start is already handled by
/// AuthGate showing SplashScreen for logged-out users, so this only
/// needs to trigger the overlay itself on `resumed` (i.e. the app was
/// actually paused/backgrounded, not just launched).
class AppResumeSplashOverlay extends StatefulWidget {
  final Widget child;
  const AppResumeSplashOverlay({super.key, required this.child});

  @override
  State<AppResumeSplashOverlay> createState() =>
      _AppResumeSplashOverlayState();
}

class _AppResumeSplashOverlayState extends State<AppResumeSplashOverlay>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _opacity = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));

  bool _showOverlay = false;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _wasBackgrounded = true;
    } else if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      _wasBackgrounded = false;
      _playSplash();
    }
  }

  void _playSplash() {
    setState(() => _showOverlay = true);
    _controller.forward(from: 0);

    // Total overlay time: ~1.2s, matching the standalone splash screen.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          IgnorePointer(
            child: Material(
              color: AppColors.background,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacity.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(kAnonityLogoAsset, width: 130, height: 130),
                      const SizedBox(height: 28),
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Anon',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'ity',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGlow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}