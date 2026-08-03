import 'package:flutter/material.dart';

import '../theme/theme_manager.dart';
import '../widgets/anonity_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _swatchColors = [
    Color(0xFF8B6BFF),
    Color(0xFF6A45E8),
    Color(0xFF22C1C3),
    Color(0xFFFB8C00),
    Color(0xFFEF476F),
    Color(0xFF3A86FF),
    Color(0xFF845EC2),
    Color(0xFFFFD700),
  ];

  late ThemeController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ThemeControllerProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
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
                const Text('Display & Appearance',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ThemePreviewCard(controller: controller),
                const SizedBox(height: 20),
                _SectionHeader(title: 'Theme mode'),
                _SelectionCard(
                  children: AppBrightnessChoice.values
                      .map((choice) => RadioListTile<AppBrightnessChoice>(
                            visualDensity: VisualDensity.compact,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(choice.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              choice == AppBrightnessChoice.system
                                  ? 'Match the device setting.'
                                  : 'Use ${choice.label.toLowerCase()} across the app.',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            value: choice,
                            groupValue: controller.brightnessChoice,
                            onChanged: (choice) {
                              if (choice != null) {
                                controller.setBrightnessChoice(choice);
                              }
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Appearance'),
                _SelectionCard(
                  children: AppThemeChoice.values
                      .map((choice) => RadioListTile<AppThemeChoice>(
                            visualDensity: VisualDensity.compact,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(choice.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              choice == AppThemeChoice.systemColors
                                  ? 'Auto-match your phone’s dynamic palette.'
                                  : choice == AppThemeChoice.customGradient
                                      ? 'Choose your own gradient colors.'
                                      : 'Restore the original brand styling.',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            value: choice,
                            groupValue: controller.themeChoice,
                            onChanged: (choice) {
                              if (choice != null) {
                                controller.setThemeChoice(choice);
                              }
                            },
                          ))
                      .toList(),
                ),
                if (controller.themeChoice ==
                    AppThemeChoice.customGradient) ...[
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Custom gradient colors'),
                  _SelectionCard(children: [_buildGradientEditor(context)]),
                ],
                const SizedBox(height: 16),
                _SectionHeader(title: 'Live preview'),
                _SelectionCard(children: [_buildLivePreview(context)]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Tap a tile to choose a color',
              style: TextStyle(color: Colors.white.withOpacity(0.75))),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var index = 0;
                index < controller.customGradientColors.length;
                index++)
              _ColorPickerTile(
                color: controller.customGradientColors[index],
                label: 'Color ${index + 1}',
                onTap: () async {
                  final chosen = await _showColorPicker(
                      context, controller.customGradientColors[index]);
                  if (chosen != null) {
                    controller.updateCustomColor(index, chosen);
                  }
                },
              ),
            if (controller.customGradientColors.length < 4)
              _AddColorTile(onTap: () {
                controller.addCustomColor(const Color(0xFF22C1C3));
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    final gradient = controller.accentGradient;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(kAnonityLogoAsset, width: 28, height: 28),
              const SizedBox(width: 10),
              const Text('Anonity',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Display & Appearance',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                SizedBox(height: 8),
                Text(
                    'Choose your favorite theme style and see the app refresh instantly.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('Live preview',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _PreviewDot(label: 'Light')),
              const SizedBox(width: 10),
              Expanded(child: _PreviewDot(label: 'Dark')),
            ],
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initial) {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Choose a color'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _swatchColors
                .map(
                  (swatch) => GestureDetector(
                    onTap: () => Navigator.of(context).pop(swatch),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: swatch,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 1.5),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final ThemeController controller;
  const _ThemePreviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appearance controls',
              style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 10),
          Text('Personalize your app theme',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.themeChoice.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                height: 32,
                width: 84,
                decoration: BoxDecoration(
                  gradient: controller.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Preview',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
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
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}

class _ColorPickerTile extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ColorPickerTile(
      {required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  LinearGradient(colors: [color.withOpacity(0.85), color]),
              border: Border.all(color: Colors.white12, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10)
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AddColorTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddColorTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white70),
        ),
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  final String label;
  const _PreviewDot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.brightness_6_rounded,
              color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
