import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

enum AppearanceMode {
  system,
  light,
  dark;

  static AppearanceMode fromState(SettingsState state) =>
      (state.useSystemTheme ? system : (state.themeVariant == AppThemeVariant.light ? light : dark));
}

class ThemePaletteRow extends StatelessWidget {
  const ThemePaletteRow({super.key, required this.palette, required this.isSelected, required this.onTap});

  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    title: Text(AppTheme.getPaletteName(palette)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in AppTheme.getSwatchColors(palette))
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        if (isSelected) ...[const SizedBox(width: 12), Icon(Icons.check, color: context.colorScheme.primary, size: 20)],
      ],
    ),
  );
}
