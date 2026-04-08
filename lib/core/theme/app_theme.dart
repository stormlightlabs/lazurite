import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/catppuccin_theme.dart';
import 'package:lazurite/core/theme/lazurite_theme.dart';
import 'package:lazurite/core/theme/nord_theme.dart';
import 'package:lazurite/core/theme/oxocarbon_theme.dart';
import 'package:lazurite/core/theme/rose_pine_theme.dart';

enum AppThemePalette { lazurite, oxocarbon, catppuccin, nord, rosePine }

enum AppThemeVariant { light, dark }

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(AppThemePalette palette, AppThemeVariant variant) {
    switch (palette) {
      case AppThemePalette.lazurite:
        return variant == AppThemeVariant.light ? LazuriteTheme.light() : LazuriteTheme.dark();
      case AppThemePalette.oxocarbon:
        return variant == AppThemeVariant.light ? OxocarbonTheme.light() : OxocarbonTheme.dark();
      case AppThemePalette.catppuccin:
        return variant == AppThemeVariant.light ? CatppuccinTheme.light() : CatppuccinTheme.dark();
      case AppThemePalette.nord:
        return variant == AppThemeVariant.light ? NordTheme.light() : NordTheme.dark();
      case AppThemePalette.rosePine:
        return variant == AppThemeVariant.light ? RosePineTheme.light() : RosePineTheme.dark();
    }
  }

  static String getPaletteName(AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.lazurite:
        return 'Lazurite';
      case AppThemePalette.oxocarbon:
        return 'Oxocarbon';
      case AppThemePalette.catppuccin:
        return 'Catppuccin';
      case AppThemePalette.nord:
        return 'Nord';
      case AppThemePalette.rosePine:
        return 'Rosé Pine';
    }
  }

  static String getVariantName(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.light:
        return 'Light';
      case AppThemeVariant.dark:
        return 'Dark';
    }
  }

  static AppThemePalette parsePalette(String? value) {
    switch (value) {
      case 'lazurite':
        return AppThemePalette.lazurite;
      case 'oxocarbon':
        return AppThemePalette.oxocarbon;
      case 'catppuccin':
        return AppThemePalette.catppuccin;
      case 'nord':
        return AppThemePalette.nord;
      case 'rosePine':
        return AppThemePalette.rosePine;
      default:
        return AppThemePalette.lazurite;
    }
  }

  static String paletteToString(AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.lazurite:
        return 'lazurite';
      case AppThemePalette.oxocarbon:
        return 'oxocarbon';
      case AppThemePalette.catppuccin:
        return 'catppuccin';
      case AppThemePalette.nord:
        return 'nord';
      case AppThemePalette.rosePine:
        return 'rosePine';
    }
  }

  static AppThemeVariant parseVariant(String? value) {
    switch (value) {
      case 'light':
        return AppThemeVariant.light;
      case 'dark':
        return AppThemeVariant.dark;
      default:
        return AppThemeVariant.dark;
    }
  }

  static String variantToString(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.light:
        return 'light';
      case AppThemeVariant.dark:
        return 'dark';
    }
  }

  static List<Color> getSwatchColors(AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.lazurite:
        return const [Color(0xFF7dafff), Color(0xFF0b63d1), Color(0xFF0073de), Color(0xFFff8080)];
      case AppThemePalette.oxocarbon:
        return const [Color(0xFF78a9ff), Color(0xFFbe95ff), Color(0xFF08bdba), Color(0xFFee5396)];
      case AppThemePalette.catppuccin:
        return const [Color(0xFFb4befe), Color(0xFFcba6f7), Color(0xFF74c7ec), Color(0xFFf5c2e7)];
      case AppThemePalette.nord:
        return const [Color(0xFF88c0d0), Color(0xFFa3be8c), Color(0xFFebcb8b), Color(0xFFb48ead)];
      case AppThemePalette.rosePine:
        return const [Color(0xFFebbcba), Color(0xFFc4a7e7), Color(0xFF9ccfd8), Color(0xFFf6c177)];
    }
  }
}
