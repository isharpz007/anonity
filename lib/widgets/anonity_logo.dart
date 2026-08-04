import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared path to the app logo, used directly via Image.asset
/// wherever the brand mark appears (see pubspec.yaml assets:).
const String kAnonityLogoAsset = 'assets/images/logo.png';

class SectionTag extends StatelessWidget {
  final String section;
  final EdgeInsets padding;
  const SectionTag({
    super.key,
    required this.section,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    final color = sectionColor(section);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$section ${sectionEmoji(section)}',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
