import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The masked-cat glyph used throughout the app as the brand mark
/// and as the default "anonymous" avatar.
class AnonityMask extends StatelessWidget {
  final double size;
  final bool glow;
  const AnonityMask({super.key, this.size = 48, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(painter: _CatMaskPainter(), size: Size.square(size)),
    );
  }
}

class _CatMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.15, h * 0.35)
      ..quadraticBezierTo(w * 0.05, h * 0.55, w * 0.15, h * 0.75)
      ..quadraticBezierTo(w * 0.3, h * 0.95, w * 0.5, h * 0.85)
      ..quadraticBezierTo(w * 0.7, h * 0.95, w * 0.85, h * 0.75)
      ..quadraticBezierTo(w * 0.95, h * 0.55, w * 0.85, h * 0.35)
      ..close();
    canvas.drawPath(path, paint);

    final bg = Paint()..color = AppColors.primaryDim;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.28, h * 0.2),
      bg,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.54, h * 0.42, w * 0.28, h * 0.2),
      bg,
    );

    final dot = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.03, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
        color: color.withOpacity(0.18),
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
