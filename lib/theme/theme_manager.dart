import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

enum AppBrightnessChoice { system, light, dark }

enum AppThemeChoice { systemColors, customGradient, defaultBrand }

extension AppBrightnessChoiceX on AppBrightnessChoice {
  String get storageKey {
    switch (this) {
      case AppBrightnessChoice.light:
        return 'light';
      case AppBrightnessChoice.dark:
        return 'dark';
      case AppBrightnessChoice.system:
      default:
        return 'system';
    }
  }

  String get label {
    switch (this) {
      case AppBrightnessChoice.light:
        return 'Light mode';
      case AppBrightnessChoice.dark:
        return 'Dark mode';
      case AppBrightnessChoice.system:
      default:
        return 'System mode';
    }
  }

  static AppBrightnessChoice fromStorage(String value) {
    switch (value) {
      case 'light':
        return AppBrightnessChoice.light;
      case 'dark':
        return AppBrightnessChoice.dark;
      default:
        return AppBrightnessChoice.system;
    }
  }
}

extension AppThemeChoiceX on AppThemeChoice {
  String get storageKey {
    switch (this) {
      case AppThemeChoice.systemColors:
        return 'system_colors';
      case AppThemeChoice.customGradient:
        return 'custom_gradient';
      case AppThemeChoice.defaultBrand:
      default:
        return 'default_brand';
    }
  }

  String get label {
    switch (this) {
      case AppThemeChoice.systemColors:
        return 'System Theme Colors';
      case AppThemeChoice.customGradient:
        return 'Custom Gradient';
      case AppThemeChoice.defaultBrand:
      default:
        return 'Default App Theme';
    }
  }
}

class AppThemeExtras extends ThemeExtension<AppThemeExtras> {
  final LinearGradient accentGradient;

  const AppThemeExtras({required this.accentGradient});

  @override
  AppThemeExtras copyWith({LinearGradient? accentGradient}) {
    return AppThemeExtras(
        accentGradient: accentGradient ?? this.accentGradient);
  }

  @override
  AppThemeExtras lerp(ThemeExtension<AppThemeExtras>? other, double t) {
    if (other is! AppThemeExtras) return this;
    return AppThemeExtras(
      accentGradient: LinearGradient(
        colors: List<Color>.generate(
          accentGradient.colors.length,
          (index) =>
              Color.lerp(accentGradient.colors[index],
                  other.accentGradient.colors[index], t) ??
              accentGradient.colors[index],
        ),
        begin: AlignmentGeometry.lerp(
                accentGradient.begin, other.accentGradient.begin, t) ??
            accentGradient.begin,
        end: AlignmentGeometry.lerp(
                accentGradient.end, other.accentGradient.end, t) ??
            accentGradient.end,
      ),
    );
  }
}

class ThemeController extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode_choice';
  static const _themeChoiceKey = 'theme_choice';
  static const _customColor1Key = 'custom_color_1';
  static const _customColor2Key = 'custom_color_2';
  static const _customColor3Key = 'custom_color_3';

  AppBrightnessChoice brightnessChoice = AppBrightnessChoice.system;
  AppThemeChoice themeChoice = AppThemeChoice.defaultBrand;
  final List<Color> customGradientColors = [
    Color(0xFF8B6BFF),
    Color(0xFF6A45E8)
  ];

  bool get isSystemMode => brightnessChoice == AppBrightnessChoice.system;
  ThemeMode get themeMode {
    switch (brightnessChoice) {
      case AppBrightnessChoice.light:
        return ThemeMode.light;
      case AppBrightnessChoice.dark:
        return ThemeMode.dark;
      case AppBrightnessChoice.system:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue =
        prefs.getString(_themeModeKey) ?? AppBrightnessChoice.system.storageKey;
    final themeChoiceValue = prefs.getString(_themeChoiceKey) ??
        AppThemeChoice.defaultBrand.storageKey;
    brightnessChoice = AppBrightnessChoiceX.fromStorage(themeModeValue);
    themeChoice = AppThemeChoice.values.firstWhere(
      (choice) => choice.storageKey == themeChoiceValue,
      orElse: () => AppThemeChoice.defaultBrand,
    );

    customGradientColors[0] =
        Color(prefs.getInt(_customColor1Key) ?? customGradientColors[0].value);
    customGradientColors[1] =
        Color(prefs.getInt(_customColor2Key) ?? customGradientColors[1].value);
    final customColor3Value = prefs.getInt(_customColor3Key);
    if (customColor3Value != null) {
      if (customGradientColors.length < 3) {
        customGradientColors.add(Color(customColor3Value));
      } else {
        customGradientColors[2] = Color(customColor3Value);
      }
    } else {
      if (customGradientColors.length > 2) {
        customGradientColors.removeRange(2, customGradientColors.length);
      }
    }

    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, brightnessChoice.storageKey);
    await prefs.setString(_themeChoiceKey, themeChoice.storageKey);
    await prefs.setInt(_customColor1Key, customGradientColors[0].value);
    await prefs.setInt(_customColor2Key, customGradientColors[1].value);
    if (customGradientColors.length >= 3) {
      await prefs.setInt(_customColor3Key, customGradientColors[2].value);
    } else {
      await prefs.remove(_customColor3Key);
    }
  }

  void setBrightnessChoice(AppBrightnessChoice choice) {
    brightnessChoice = choice;
    notifyListeners();
    savePreferences();
  }

  void setThemeChoice(AppThemeChoice choice) {
    themeChoice = choice;
    notifyListeners();
    savePreferences();
  }

  void updateCustomColor(int index, Color color) {
    if (index < 0 || index >= customGradientColors.length) return;
    customGradientColors[index] = color;
    notifyListeners();
    savePreferences();
  }

  void addCustomColor(Color color) {
    if (customGradientColors.length >= 4) return;
    customGradientColors.add(color);
    notifyListeners();
    savePreferences();
  }

  void removeCustomColor(int index) {
    if (customGradientColors.length <= 2) return;
    customGradientColors.removeAt(index);
    notifyListeners();
    savePreferences();
  }

  LinearGradient get accentGradient {
    if (themeChoice == AppThemeChoice.customGradient) {
      return LinearGradient(
        colors: List<Color>.from(customGradientColors),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.primaryGradient;
  }

  ColorScheme resolveColorScheme(
    Brightness brightness,
    ColorScheme? dynamicLight,
    ColorScheme? dynamicDark,
  ) {
    final dynamicScheme =
        brightness == Brightness.light ? dynamicLight : dynamicDark;
    if (themeChoice == AppThemeChoice.systemColors && dynamicScheme != null) {
      return dynamicScheme;
    }

    return brightness == Brightness.light
        ? AppTheme.light.colorScheme
        : AppTheme.dark.colorScheme;
  }
}

class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider(
      {super.key, required ThemeController notifier, required Widget child})
      : super(notifier: notifier, child: child);

  static ThemeController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null,
        'ThemeControllerProvider is missing from the widget tree.');
    return provider!.notifier!;
  }
}
