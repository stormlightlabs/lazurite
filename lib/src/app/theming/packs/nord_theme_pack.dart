import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Nord color palette values.
///
/// Nord is an arctic, north-bluish color palette with 16 colors across
/// 4 categories: Polar Night, Snow Storm, Frost, and Aurora.
///
/// See: https://nordtheme.com
///
/// Polar Night - Dark backgrounds
/// Snow Storm - Light text/backgrounds
/// Frost - Bluish accents
/// Aurora - Colorful accents
abstract final class NordPalette {
  static const Color nord0 = Color(0xFF2E3440);
  static const Color nord1 = Color(0xFF3B4252);
  static const Color nord2 = Color(0xFF434C5E);
  static const Color nord3 = Color(0xFF4C566A);

  static const Color nord4 = Color(0xFFD8DEE9);
  static const Color nord5 = Color(0xFFE5E9F0);
  static const Color nord6 = Color(0xFFECEFF4);

  static const Color nord7 = Color(0xFF8FBCBB);
  static const Color nord8 = Color(0xFF88C0D0);
  static const Color nord9 = Color(0xFF81A1C1);
  static const Color nord10 = Color(0xFF5E81AC);

  static const Color nord11 = Color(0xFFBF616A);
  static const Color nord12 = Color(0xFFD08770);
  static const Color nord13 = Color(0xFFEBCB8B);
  static const Color nord14 = Color(0xFFA3BE8C);
  static const Color nord15 = Color(0xFFB48EAD);
}

/// Nord Dark theme spec.
const nordDarkSpec = ThemeSpec(
  surfaceDim: Color(0xFF242933),
  surface: NordPalette.nord0,
  surfaceBright: NordPalette.nord3,
  surfaceContainerLowest: Color(0xFF1D2128),
  surfaceContainerLow: NordPalette.nord1,
  surfaceContainer: Color(0xFF3E4555),
  surfaceContainerHigh: NordPalette.nord2,
  surfaceContainerHighest: NordPalette.nord3,

  onSurface: NordPalette.nord6,
  onSurfaceVariant: NordPalette.nord4,

  outline: NordPalette.nord3,
  outlineVariant: NordPalette.nord2,

  primary: NordPalette.nord8,
  onPrimary: NordPalette.nord0,
  primaryContainer: Color(0xFF2A5260),
  onPrimaryContainer: Color(0xFFD0F0F8),

  secondary: NordPalette.nord9,
  onSecondary: NordPalette.nord0,
  secondaryContainer: Color(0xFF3B5068),
  onSecondaryContainer: Color(0xFFD8E4F0),

  tertiary: NordPalette.nord10,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF284560),
  onTertiaryContainer: Color(0xFFD0E0F0),

  error: NordPalette.nord11,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF5C2B30),
  onErrorContainer: Color(0xFFFFDADA),

  inverseSurface: NordPalette.nord5,
  onInverseSurface: NordPalette.nord1,
  inversePrimary: Color(0xFF406A78),

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Nord Light theme spec.
const nordLightSpec = ThemeSpec(
  surfaceDim: NordPalette.nord4,
  surface: NordPalette.nord6,
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: NordPalette.nord5,
  surfaceContainer: NordPalette.nord4,
  surfaceContainerHigh: Color(0xFFCDD4E0),
  surfaceContainerHighest: Color(0xFFC0C8D8),

  onSurface: NordPalette.nord0,
  onSurfaceVariant: NordPalette.nord3,

  outline: NordPalette.nord3,
  outlineVariant: NordPalette.nord4,

  primary: NordPalette.nord10,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD0E4F0),
  onPrimaryContainer: Color(0xFF1A3548),

  secondary: NordPalette.nord9,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD8E4F0),
  onSecondaryContainer: Color(0xFF203040),

  tertiary: NordPalette.nord7,
  onTertiary: Color(0xFF003530),
  tertiaryContainer: Color(0xFFC8E8E6),
  onTertiaryContainer: Color(0xFF084540),

  error: NordPalette.nord11,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDADA),
  onErrorContainer: Color(0xFF410002),

  inverseSurface: NordPalette.nord1,
  onInverseSurface: NordPalette.nord5,
  inversePrimary: NordPalette.nord8,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

ColorScheme _deriveColorScheme(ThemeSpec spec, Brightness brightness) {
  return ColorScheme(
    brightness: brightness,
    primary: spec.primary!,
    onPrimary: spec.onPrimary!,
    primaryContainer: spec.primaryContainer!,
    onPrimaryContainer: spec.onPrimaryContainer!,
    secondary: spec.secondary!,
    onSecondary: spec.onSecondary!,
    secondaryContainer: spec.secondaryContainer!,
    onSecondaryContainer: spec.onSecondaryContainer!,
    tertiary: spec.tertiary!,
    onTertiary: spec.onTertiary!,
    tertiaryContainer: spec.tertiaryContainer!,
    onTertiaryContainer: spec.onTertiaryContainer!,
    error: spec.error!,
    onError: spec.onError!,
    errorContainer: spec.errorContainer!,
    onErrorContainer: spec.onErrorContainer!,
    surface: spec.surface!,
    onSurface: spec.onSurface!,
    onSurfaceVariant: spec.onSurfaceVariant!,
    surfaceDim: spec.surfaceDim!,
    surfaceBright: spec.surfaceBright!,
    surfaceContainerLowest: spec.surfaceContainerLowest!,
    surfaceContainerLow: spec.surfaceContainerLow!,
    surfaceContainer: spec.surfaceContainer!,
    surfaceContainerHigh: spec.surfaceContainerHigh!,
    surfaceContainerHighest: spec.surfaceContainerHighest!,
    outline: spec.outline!,
    outlineVariant: spec.outlineVariant!,
    inverseSurface: spec.inverseSurface!,
    onInverseSurface: spec.onInverseSurface!,
    inversePrimary: spec.inversePrimary!,
    scrim: spec.scrim!,
    shadow: spec.shadow!,
  );
}

/// Nord Dark variant.
final nordDarkVariant = ThemeVariant(
  id: 'nord-dark',
  name: 'Dark',
  brightness: Brightness.dark,
  spec: nordDarkSpec,
  derivedScheme: _deriveColorScheme(nordDarkSpec, Brightness.dark),
);

/// Nord Light variant.
final nordLightVariant = ThemeVariant(
  id: 'nord-light',
  name: 'Light',
  brightness: Brightness.light,
  spec: nordLightSpec,
  derivedScheme: _deriveColorScheme(nordLightSpec, Brightness.light),
);

/// Nord theme pack with dark and light variants.
final nordPack = ThemePack(
  id: 'nord',
  name: 'Nord',
  author: 'Arctic Ice Studio',
  variants: [nordDarkVariant, nordLightVariant],
);
