import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// One Dark/Light color palette values.
///
/// Based on the popular Atom One Dark/Light themes.
///
/// See: https://github.com/atom/one-dark-syntax
abstract final class OneDarkPalette {
  static const Color darkBg = Color(0xFF282C34);
  static const Color darkBgHighlight = Color(0xFF2C323C);
  static const Color darkGutter = Color(0xFF4B5263);
  static const Color darkFg = Color(0xFFABB2BF);
  static const Color darkFgMuted = Color(0xFF5C6370);

  static const Color darkBlue = Color(0xFF61AFEF);
  static const Color darkCyan = Color(0xFF56B6C2);
  static const Color darkGreen = Color(0xFF98C379);
  static const Color darkMagenta = Color(0xFFC678DD);
  static const Color darkRed = Color(0xFFE06C75);
  static const Color darkDarkRed = Color(0xFFBE5046);
  static const Color darkYellow = Color(0xFFE5C07B);
  static const Color darkOrange = Color(0xFFD19A66);

  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightBgHighlight = Color(0xFFE5E5E6);
  static const Color lightGutter = Color(0xFFD4D4D4);
  static const Color lightFg = Color(0xFF383A42);
  static const Color lightFgMuted = Color(0xFFA0A1A7);

  static const Color lightBlue = Color(0xFF4078F2);
  static const Color lightCyan = Color(0xFF0184BC);
  static const Color lightGreen = Color(0xFF50A14F);
  static const Color lightMagenta = Color(0xFFA626A4);
  static const Color lightRed = Color(0xFFE45649);
  static const Color lightDarkRed = Color(0xFFCA1243);
  static const Color lightYellow = Color(0xFFC18401);
  static const Color lightOrange = Color(0xFF986801);
}

/// One Dark theme spec.
const oneDarkSpec = ThemeSpec(
  surfaceDim: Color(0xFF21252B),
  surface: OneDarkPalette.darkBg,
  surfaceBright: Color(0xFF3E4451),
  surfaceContainerLowest: Color(0xFF1D2026),
  surfaceContainerLow: OneDarkPalette.darkBgHighlight,
  surfaceContainer: Color(0xFF333842),
  surfaceContainerHigh: Color(0xFF3A3F4A),
  surfaceContainerHighest: OneDarkPalette.darkGutter,

  onSurface: OneDarkPalette.darkFg,
  onSurfaceVariant: OneDarkPalette.darkFgMuted,

  outline: OneDarkPalette.darkGutter,
  outlineVariant: Color(0xFF3E4451),

  primary: OneDarkPalette.darkBlue,
  onPrimary: Color(0xFF002B4D),
  primaryContainer: Color(0xFF1D4A6C),
  onPrimaryContainer: Color(0xFFD0E8FF),

  secondary: OneDarkPalette.darkMagenta,
  onSecondary: Color(0xFF2D004D),
  secondaryContainer: Color(0xFF5A2B7A),
  onSecondaryContainer: Color(0xFFF0D8FF),

  tertiary: OneDarkPalette.darkCyan,
  onTertiary: Color(0xFF003540),
  tertiaryContainer: Color(0xFF1A5058),
  onTertiaryContainer: Color(0xFFD0F4F8),

  error: OneDarkPalette.darkRed,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF5C2428),
  onErrorContainer: Color(0xFFFFDADA),

  inverseSurface: OneDarkPalette.lightBg,
  onInverseSurface: OneDarkPalette.lightFg,
  inversePrimary: OneDarkPalette.lightBlue,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// One Light theme spec.
const oneLightSpec = ThemeSpec(
  surfaceDim: OneDarkPalette.lightBgHighlight,
  surface: OneDarkPalette.lightBg,
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF3F3F4),
  surfaceContainer: OneDarkPalette.lightBgHighlight,
  surfaceContainerHigh: OneDarkPalette.lightGutter,
  surfaceContainerHighest: Color(0xFFC0C0C2),

  onSurface: OneDarkPalette.lightFg,
  onSurfaceVariant: Color(0xFF696C77),

  outline: OneDarkPalette.lightFgMuted,
  outlineVariant: OneDarkPalette.lightGutter,

  primary: OneDarkPalette.lightBlue,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD8E4FF),
  onPrimaryContainer: Color(0xFF001A40),

  secondary: OneDarkPalette.lightMagenta,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF0D8FF),
  onSecondaryContainer: Color(0xFF2D004D),

  tertiary: OneDarkPalette.lightCyan,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD0F4F8),
  onTertiaryContainer: Color(0xFF003540),

  error: OneDarkPalette.lightRed,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDADA),
  onErrorContainer: Color(0xFF410002),

  inverseSurface: OneDarkPalette.darkBg,
  onInverseSurface: OneDarkPalette.darkFg,
  inversePrimary: OneDarkPalette.darkBlue,

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

/// One Dark variant.
final oneDarkVariant = ThemeVariant(
  id: 'one-dark',
  name: 'Dark',
  brightness: Brightness.dark,
  spec: oneDarkSpec,
  derivedScheme: _deriveColorScheme(oneDarkSpec, Brightness.dark),
);

/// One Light variant.
final oneLightVariant = ThemeVariant(
  id: 'one-light',
  name: 'Light',
  brightness: Brightness.light,
  spec: oneLightSpec,
  derivedScheme: _deriveColorScheme(oneLightSpec, Brightness.light),
);

/// One Dark/Light theme pack.
final oneDarkPack = ThemePack(
  id: 'one-dark',
  name: 'One Dark',
  author: 'Atom',
  variants: [oneDarkVariant, oneLightVariant],
);
