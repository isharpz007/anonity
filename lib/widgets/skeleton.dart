import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Wraps a tree of [SkeletonBone]s in a slow, looping opacity pulse
/// so a loading layout visibly reads as "loading" rather than a
/// static gray mockup. Wrap one of these around each screen's
/// skeleton layout (not around individual bones).
class SkeletonPulse extends StatefulWidget {
  final Widget child;
  const SkeletonPulse({super.key, required this.child});

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _opacity = Tween<double>(begin: 1, end: 0.4).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(opacity: _opacity.value, child: child),
      child: widget.child,
    );
  }
}

/// A single skeleton placeholder "bone" — a solid rounded rectangle
/// standing in for a line of text, an avatar, or an image while real
/// content loads. Use inside a [SkeletonPulse].
class SkeletonBone extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const SkeletonBone({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  /// Circular bone — for avatar-shaped placeholders.
  const SkeletonBone.circle({super.key, double size = 40})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: borderRadius),
    );
  }
}

/// Skeleton standing in for a [PostCard] — used on Home Feed, Profile,
/// and anywhere else real posts are about to appear.
class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBone.circle(size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBone(width: 90, height: 12),
                    SizedBox(height: 6),
                    SkeletonBone(width: 130, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SkeletonBone(height: 12),
          const SizedBox(height: 8),
          const SkeletonBone(height: 12),
          const SizedBox(height: 8),
          SkeletonBone(width: MediaQuery.of(context).size.width * 0.4, height: 12),
          const SizedBox(height: 14),
          Row(
            children: const [
              SkeletonBone(width: 36, height: 11),
              SizedBox(width: 22),
              SkeletonBone(width: 36, height: 11),
              SizedBox(width: 22),
              SkeletonBone(width: 36, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton standing in for a group tile on the Groups screen.
class SkeletonGroupTile extends StatelessWidget {
  const SkeletonGroupTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SkeletonBone(width: 46, height: 46, borderRadius: BorderRadius.all(Radius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBone(width: 120, height: 13),
                SizedBox(height: 8),
                SkeletonBone(width: 90, height: 10),
                SizedBox(height: 8),
                SkeletonBone(width: 180, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton standing in for a group chat message tile.
class SkeletonGroupMessage extends StatelessWidget {
  const SkeletonGroupMessage({super.key});

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
            children: const [
              SkeletonBone.circle(size: 28),
              SizedBox(width: 8),
              SkeletonBone(width: 80, height: 11),
              SizedBox(width: 8),
              SkeletonBone(width: 40, height: 10),
            ],
          ),
          const SizedBox(height: 10),
          const SkeletonBone(height: 11),
          const SizedBox(height: 6),
          SkeletonBone(width: MediaQuery.of(context).size.width * 0.5, height: 11),
        ],
      ),
    );
  }
}

/// Skeleton standing in for the Explore "Popular Sections" card.
class SkeletonSectionCard extends StatelessWidget {
  const SkeletonSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBone(width: 70, height: 13),
          SizedBox(height: 10),
          SkeletonBone(height: 10),
          SizedBox(height: 6),
          SkeletonBone(width: 90, height: 10),
          Spacer(),
          SkeletonBone(width: 60, height: 10),
        ],
      ),
    );
  }
}

/// Skeleton standing in for an Explore "Trending Posts" row.
class SkeletonTrendingRow extends StatelessWidget {
  const SkeletonTrendingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          const SizedBox(width: 8),
          const SkeletonBone.circle(size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBone(width: 60, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                SizedBox(height: 8),
                SkeletonBone(height: 12),
                SizedBox(height: 6),
                SkeletonBone(width: 100, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton standing in for the Profile screen header + stats.
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: const [
              SkeletonBone.circle(size: 84),
              SizedBox(height: 14),
              SkeletonBone(width: 120, height: 15),
              SizedBox(height: 8),
              SkeletonBone(width: 90, height: 11),
              SizedBox(height: 10),
              SkeletonBone(width: 200, height: 11),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) => Column(
              children: const [
                SkeletonBone(width: 30, height: 15),
                SizedBox(height: 6),
                SkeletonBone(width: 44, height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
