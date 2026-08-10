import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color + type system for Anonity.
/// Matches the dark, purple-accented mockup: near-black backgrounds,
/// violet/indigo primary accent, soft card surfaces, and three
/// section-tag colors (Spicy / Relationship / Work).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0A10);
  static const Color surface = Color(0xFF15131C);
  static const Color surfaceElevated = Color(0xFF1C1926);
  static const Color border = Color(0xFF2A2733);

  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryDim = Color(0xFF5B3FD9);
  static const Color primaryGlow = Color(0xFF9B7FFF);

  static const Color textPrimary = Color(0xFFF5F3FA);
  static const Color textSecondary = Color(0xFFA6A1B5);
  static const Color textMuted = Color(0xFF6E697D);

  // True light-mode palette. Previously _buildLight() reused the dark
  // background/surface/text colors below, so "light mode" rendered as
  // dark mode with near-white text on a near-black background.
  static const Color lightBackground = Color(0xFFFAF9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF2EFFA);
  static const Color lightSurfaceContainerHigh = Color(0xFFECE7F7);
  static const Color lightSurfaceContainerHighest = Color(0xFFE7E1F7);
  static const Color lightBorder = Color(0xFFE3DFEE);
  static const Color lightOutlineVariant = Color(0xFFDAD4EA);
  static const Color lightTextPrimary = Color(0xFF1C1A24);
  static const Color lightTextSecondary = Color(0xFF6E697D);
  static const Color lightTextMuted = Color(0xFF938DA3);

  static const Color spicy = Color(0xFFE0466E);
  static const Color relationship = Color(0xFFB84B8C);
  static const Color work = Color(0xFF3E8FC9);

  static const Color like = Color(0xFFE0466E);
  static const Color success = Color(0xFF4CD787);

  // Light, lavender-tinted "post card" palette matching the Anonity
  // feed-card mockup. Used specifically by PostCard so cards read as
  // light chips on the dark app background, independent of app theme.
  static const Color postCard = Color(0xFFF4F1FC);
  static const Color postCardBorder = Color(0xFFE7E1F7);
  static const Color postCardTextPrimary = Color(0xFF221E2E);
  static const Color postCardTextSecondary = Color(0xFF8B85A0);
  static const Color tagChipBg = Color(0xFFE9E2FB);
  static const Color tagChipText = Color(0xFF5B4B8A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B6BFF), Color(0xFF6A45E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static final ThemeData dark = _buildDark();
  static final ThemeData light = _buildLight();

  static ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
      // Make sure emoji glyphs (avatars, ellipsis, etc.) render even
      // when Inter doesn't cover them — falls back to the bundled
      // NotoColorEmoji font and silences the "missing characters"
      // warning printed at startup.
      fontFamilyFallback: const ['NotoColorEmoji'],
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.primaryGlow,
        surface: AppColors.surface,
        error: AppColors.spicy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryGlow),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData _buildLight() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
      // Same emoji-fallback as the dark theme — see _buildDark.
      fontFamilyFallback: const ['NotoColorEmoji'],
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primaryGlow,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightOutlineVariant,
        shadow: Colors.black,
        error: AppColors.spicy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceElevated,
        hintStyle:
            const TextStyle(color: AppColors.lightTextMuted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.lightBorder),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryDim),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.lightSurfaceElevated,
        contentTextStyle: TextStyle(color: AppColors.lightTextPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Returns the accent color for a post/group section tag.
Color sectionColor(String section) {
  switch (section.toLowerCase()) {
    case 'spicy':
      return AppColors.spicy;
    case 'relationship':
      return AppColors.relationship;
    case 'work':
      return AppColors.work;
    default:
      return AppColors.primary;
  }
}

String sectionEmoji(String section) {
  switch (section.toLowerCase()) {
    case 'spicy':
      return '🌶️';
    case 'relationship':
      return '💗';
    case 'work':
      return '💼';
    default:
      return '';
  }
}