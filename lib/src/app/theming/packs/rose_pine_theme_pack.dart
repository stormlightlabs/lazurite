import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Rosé Pine color palette values.
///
/// Rosé Pine is a soho vibes inspired color palette with 3 variants:
/// - Dawn (light)
/// - Main (dark)
/// - Moon (dark, higher contrast)
///
/// See: https://rosepinetheme.com
abstract final class RosePinePalette {
  static const Color mainBase = Color(0xFF191724);
  static const Color mainSurface = Color(0xFF1F1D2E);
  static const Color mainOverlay = Color(0xFF26233A);
  static const Color mainMuted = Color(0xFF6E6A86);
  static const Color mainSubtle = Color(0xFF908CAA);
  static const Color mainText = Color(0xFFE0DEF4);
  static const Color mainHighlightLow = Color(0xFF21202E);
  static const Color mainHighlightMed = Color(0xFF403D52);
  static const Color mainHighlightHigh = Color(0xFF524F67);

  static const Color mainLove = Color(0xFFEB6F92);
  static const Color mainGold = Color(0xFFF6C177);
  static const Color mainRose = Color(0xFFEBBCBA);
  static const Color mainPine = Color(0xFF31748F);
  static const Color mainFoam = Color(0xFF9CCFD8);
  static const Color mainIris = Color(0xFFC4A7E7);

  static const Color moonBase = Color(0xFF232136);
  static const Color moonSurface = Color(0xFF2A273F);
  static const Color moonOverlay = Color(0xFF393552);
  static const Color moonMuted = Color(0xFF6E6A86);
  static const Color moonSubtle = Color(0xFF908CAA);
  static const Color moonText = Color(0xFFE0DEF4);
  static const Color moonHighlightLow = Color(0xFF2A283E);
  static const Color moonHighlightMed = Color(0xFF44415A);
  static const Color moonHighlightHigh = Color(0xFF56526E);

  static const Color moonLove = Color(0xFFEB6F92);
  static const Color moonGold = Color(0xFFF6C177);
  static const Color moonRose = Color(0xFFEA9A97);
  static const Color moonPine = Color(0xFF3E8FB0);
  static const Color moonFoam = Color(0xFF9CCFD8);
  static const Color moonIris = Color(0xFFC4A7E7);

  static const Color dawnBase = Color(0xFFFAF4ED);
  static const Color dawnSurface = Color(0xFFFFFAF3);
  static const Color dawnOverlay = Color(0xFFF2E9E1);
  static const Color dawnMuted = Color(0xFF9893A5);
  static const Color dawnSubtle = Color(0xFF797593);
  static const Color dawnText = Color(0xFF575279);
  static const Color dawnHighlightLow = Color(0xFFF4EDE8);
  static const Color dawnHighlightMed = Color(0xFFDFD8D3);
  static const Color dawnHighlightHigh = Color(0xFFCECACD);

  static const Color dawnLove = Color(0xFFB4637A);
  static const Color dawnGold = Color(0xFFEA9D34);
  static const Color dawnRose = Color(0xFFD7827E);
  static const Color dawnPine = Color(0xFF286983);
  static const Color dawnFoam = Color(0xFF569486);
  static const Color dawnIris = Color(0xFF907AA9);
}

/// Rosé Pine Main (dark) theme spec.
const rosePineMainSpec = ThemeSpec(
  surfaceDim: Color(0xFF151320),
  surface: RosePinePalette.mainBase,
  surfaceBright: RosePinePalette.mainHighlightHigh,
  surfaceContainerLowest: Color(0xFF100E1A),
  surfaceContainerLow: RosePinePalette.mainSurface,
  surfaceContainer: RosePinePalette.mainOverlay,
  surfaceContainerHigh: RosePinePalette.mainHighlightMed,
  surfaceContainerHighest: RosePinePalette.mainHighlightHigh,

  onSurface: RosePinePalette.mainText,
  onSurfaceVariant: RosePinePalette.mainSubtle,

  outline: RosePinePalette.mainMuted,
  outlineVariant: RosePinePalette.mainHighlightMed,

  primary: RosePinePalette.mainRose,
  onPrimary: RosePinePalette.mainBase,
  primaryContainer: Color(0xFF5C4444),
  onPrimaryContainer: Color(0xFFF5E0DF),

  secondary: RosePinePalette.mainIris,
  onSecondary: RosePinePalette.mainBase,
  secondaryContainer: Color(0xFF4A3E5C),
  onSecondaryContainer: Color(0xFFE8DFF5),

  tertiary: RosePinePalette.mainFoam,
  onTertiary: RosePinePalette.mainBase,
  tertiaryContainer: Color(0xFF2E4F54),
  onTertiaryContainer: Color(0xFFD8F0F4),

  error: RosePinePalette.mainLove,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF5C2838),
  onErrorContainer: Color(0xFFF8D8E0),

  inverseSurface: RosePinePalette.dawnBase,
  onInverseSurface: RosePinePalette.dawnText,
  inversePrimary: RosePinePalette.dawnRose,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Rosé Pine Moon (dark) theme spec.
const rosePineMoonSpec = ThemeSpec(
  surfaceDim: Color(0xFF1D1B2E),
  surface: RosePinePalette.moonBase,
  surfaceBright: RosePinePalette.moonHighlightHigh,
  surfaceContainerLowest: Color(0xFF18162A),
  surfaceContainerLow: RosePinePalette.moonSurface,
  surfaceContainer: RosePinePalette.moonOverlay,
  surfaceContainerHigh: RosePinePalette.moonHighlightMed,
  surfaceContainerHighest: RosePinePalette.moonHighlightHigh,

  onSurface: RosePinePalette.moonText,
  onSurfaceVariant: RosePinePalette.moonSubtle,

  outline: RosePinePalette.moonMuted,
  outlineVariant: RosePinePalette.moonHighlightMed,

  primary: RosePinePalette.moonRose,
  onPrimary: RosePinePalette.moonBase,
  primaryContainer: Color(0xFF5C4040),
  onPrimaryContainer: Color(0xFFF5DCDC),

  secondary: RosePinePalette.moonIris,
  onSecondary: RosePinePalette.moonBase,
  secondaryContainer: Color(0xFF4A3E5C),
  onSecondaryContainer: Color(0xFFE8DFF5),

  tertiary: RosePinePalette.moonFoam,
  onTertiary: RosePinePalette.moonBase,
  tertiaryContainer: Color(0xFF2E4F54),
  onTertiaryContainer: Color(0xFFD8F0F4),

  error: RosePinePalette.moonLove,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF5C2838),
  onErrorContainer: Color(0xFFF8D8E0),

  inverseSurface: RosePinePalette.dawnBase,
  onInverseSurface: RosePinePalette.dawnText,
  inversePrimary: RosePinePalette.dawnRose,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Rosé Pine Dawn (light) theme spec.
const rosePineDawnSpec = ThemeSpec(
  surfaceDim: RosePinePalette.dawnHighlightMed,
  surface: RosePinePalette.dawnBase,
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: RosePinePalette.dawnSurface,
  surfaceContainer: RosePinePalette.dawnOverlay,
  surfaceContainerHigh: RosePinePalette.dawnHighlightLow,
  surfaceContainerHighest: RosePinePalette.dawnHighlightMed,

  onSurface: RosePinePalette.dawnText,
  onSurfaceVariant: RosePinePalette.dawnSubtle,

  outline: RosePinePalette.dawnMuted,
  outlineVariant: RosePinePalette.dawnHighlightMed,

  primary: RosePinePalette.dawnRose,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFF5E0DE),
  onPrimaryContainer: Color(0xFF3A2020),

  secondary: RosePinePalette.dawnIris,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE8DFF5),
  onSecondaryContainer: Color(0xFF2A2038),

  tertiary: RosePinePalette.dawnFoam,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD0E8E4),
  onTertiaryContainer: Color(0xFF0A302C),

  error: RosePinePalette.dawnLove,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFF8D8E0),
  onErrorContainer: Color(0xFF3A1018),

  inverseSurface: RosePinePalette.mainBase,
  onInverseSurface: RosePinePalette.mainText,
  inversePrimary: RosePinePalette.mainRose,

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

/// Rosé Pine Main (dark) variant.
final rosePineMainVariant = ThemeVariant(
  id: 'rose-pine-main',
  name: 'Main',
  brightness: Brightness.dark,
  spec: rosePineMainSpec,
  derivedScheme: _deriveColorScheme(rosePineMainSpec, Brightness.dark),
);

/// Rosé Pine Moon (dark) variant.
final rosePineMoonVariant = ThemeVariant(
  id: 'rose-pine-moon',
  name: 'Moon',
  brightness: Brightness.dark,
  spec: rosePineMoonSpec,
  derivedScheme: _deriveColorScheme(rosePineMoonSpec, Brightness.dark),
);

/// Rosé Pine Dawn (light) variant.
final rosePineDawnVariant = ThemeVariant(
  id: 'rose-pine-dawn',
  name: 'Dawn',
  brightness: Brightness.light,
  spec: rosePineDawnSpec,
  derivedScheme: _deriveColorScheme(rosePineDawnSpec, Brightness.light),
);

/// Rosé Pine theme pack with Main, Moon, and Dawn variants.
final rosePinePack = ThemePack(
  id: 'rose-pine',
  name: 'Rosé Pine',
  author: 'Rosé Pine',
  variants: [rosePineDawnVariant, rosePineMainVariant, rosePineMoonVariant],
);
