import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/catppuccin_theme.dart';
import 'package:lazurite/core/theme/nord_theme.dart';
import 'package:lazurite/core/theme/oxocarbon_theme.dart';
import 'package:lazurite/core/theme/rose_pine_theme.dart';

enum AppThemePalette { oxocarbon, catppuccin, nord, rosePine }

enum AppThemeVariant { light, dark }

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(AppThemePalette palette, AppThemeVariant variant) {
    switch (palette) {
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
      case 'oxocarbon':
        return AppThemePalette.oxocarbon;
      case 'catppuccin':
        return AppThemePalette.catppuccin;
      case 'nord':
        return AppThemePalette.nord;
      case 'rosePine':
        return AppThemePalette.rosePine;
      default:
        return AppThemePalette.oxocarbon;
    }
  }

  static String paletteToString(AppThemePalette palette) {
    switch (palette) {
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
}
