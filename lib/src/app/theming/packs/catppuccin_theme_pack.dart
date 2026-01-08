import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Catppuccin color palette values.
///
/// Catppuccin is a community-driven pastel theme with 4 flavors:
/// - Latte (light)
/// - Frappé, Macchiato, Mocha (dark variants, increasing contrast)
///
/// See: https://catppuccin.com/palette
///
/// Latte - Light
/// Frappé - Dark - Lightest
/// Macchiato - Dark - Medium
/// Mocha - Dark - Darkest
abstract final class CatppuccinPalette {
  // ─────────────────────────────────────────────────────────────────────────
  // Latte (Light)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color latteBase = Color(0xFFEFF1F5);
  static const Color latteMantle = Color(0xFFE6E9EF);
  static const Color latteCrust = Color(0xFFDCE0E8);
  static const Color latteSurface0 = Color(0xFFCCD0DA);
  static const Color latteSurface1 = Color(0xFFBCC0CC);
  static const Color latteSurface2 = Color(0xFFACB0BE);
  static const Color latteOverlay0 = Color(0xFF9CA0B0);
  static const Color latteOverlay1 = Color(0xFF8C8FA1);
  static const Color latteOverlay2 = Color(0xFF7C7F93);
  static const Color latteText = Color(0xFF4C4F69);
  static const Color latteSubtext1 = Color(0xFF5C5F77);
  static const Color latteSubtext0 = Color(0xFF6C6F85);

  static const Color latteMauve = Color(0xFF8839EF);
  static const Color lattePink = Color(0xFFEA76CB);
  static const Color latteTeal = Color(0xFF179299);
  static const Color latteRed = Color(0xFFD20F39);
  static const Color latteBlue = Color(0xFF1E66F5);
  static const Color latteLavender = Color(0xFF7287FD);

  static const Color frappeBase = Color(0xFF303446);
  static const Color frappeMantle = Color(0xFF292C3C);
  static const Color frappeCrust = Color(0xFF232634);
  static const Color frappeSurface0 = Color(0xFF414559);
  static const Color frappeSurface1 = Color(0xFF51576D);
  static const Color frappeSurface2 = Color(0xFF626880);
  static const Color frappeOverlay0 = Color(0xFF737994);
  static const Color frappeOverlay1 = Color(0xFF838BA7);
  static const Color frappeOverlay2 = Color(0xFF949CBB);
  static const Color frappeText = Color(0xFFC6D0F5);
  static const Color frappeSubtext1 = Color(0xFFB5BFE2);
  static const Color frappeSubtext0 = Color(0xFFA5ADCE);

  static const Color frappeMauve = Color(0xFFCA9EE6);
  static const Color frappePink = Color(0xFFF4B8E4);
  static const Color frappeTeal = Color(0xFF81C8BE);
  static const Color frappeRed = Color(0xFFE78284);
  static const Color frappeBlue = Color(0xFF8CAAEE);
  static const Color frappeLavender = Color(0xFFBABBF1);

  static const Color macchiatoBase = Color(0xFF24273A);
  static const Color macchiatoMantle = Color(0xFF1E2030);
  static const Color macchiatoCrust = Color(0xFF181926);
  static const Color macchiatoSurface0 = Color(0xFF363A4F);
  static const Color macchiatoSurface1 = Color(0xFF494D64);
  static const Color macchiatoSurface2 = Color(0xFF5B6078);
  static const Color macchiatoOverlay0 = Color(0xFF6E738D);
  static const Color macchiatoOverlay1 = Color(0xFF8087A2);
  static const Color macchiatoOverlay2 = Color(0xFF939AB7);
  static const Color macchiatoText = Color(0xFFCAD3F5);
  static const Color macchiatoSubtext1 = Color(0xFFB8C0E0);
  static const Color macchiatoSubtext0 = Color(0xFFA5ADCB);

  static const Color macchiatoMauve = Color(0xFFC6A0F6);
  static const Color macchiatoPink = Color(0xFFF5BDE6);
  static const Color macchiatoTeal = Color(0xFF8BD5CA);
  static const Color macchiatoRed = Color(0xFFED8796);
  static const Color macchiatoBlue = Color(0xFF8AADF4);
  static const Color macchiatoLavender = Color(0xFFB7BDF8);

  static const Color mochaBase = Color(0xFF1E1E2E);
  static const Color mochaMantle = Color(0xFF181825);
  static const Color mochaCrust = Color(0xFF11111B);
  static const Color mochaSurface0 = Color(0xFF313244);
  static const Color mochaSurface1 = Color(0xFF45475A);
  static const Color mochaSurface2 = Color(0xFF585B70);
  static const Color mochaOverlay0 = Color(0xFF6C7086);
  static const Color mochaOverlay1 = Color(0xFF7F849C);
  static const Color mochaOverlay2 = Color(0xFF9399B2);
  static const Color mochaText = Color(0xFFCDD6F4);
  static const Color mochaSubtext1 = Color(0xFFBAC2DE);
  static const Color mochaSubtext0 = Color(0xFFA6ADC8);

  static const Color mochaMauve = Color(0xFFCBA6F7);
  static const Color mochaPink = Color(0xFFF5C2E7);
  static const Color mochaTeal = Color(0xFF94E2D5);
  static const Color mochaRed = Color(0xFFF38BA8);
  static const Color mochaBlue = Color(0xFF89B4FA);
  static const Color mochaLavender = Color(0xFFB4BEFE);
}

/// Latte (light) theme spec.
const catppuccinLatteSpec = ThemeSpec(
  surfaceDim: CatppuccinPalette.latteSurface1,
  surface: CatppuccinPalette.latteBase,
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: CatppuccinPalette.latteMantle,
  surfaceContainer: CatppuccinPalette.latteCrust,
  surfaceContainerHigh: CatppuccinPalette.latteSurface0,
  surfaceContainerHighest: CatppuccinPalette.latteSurface1,

  onSurface: CatppuccinPalette.latteText,
  onSurfaceVariant: CatppuccinPalette.latteSubtext0,

  outline: CatppuccinPalette.latteOverlay1,
  outlineVariant: CatppuccinPalette.latteSurface2,

  primary: CatppuccinPalette.latteMauve,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE8DEFF),
  onPrimaryContainer: Color(0xFF21005D),

  secondary: CatppuccinPalette.lattePink,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFD8F0),
  onSecondaryContainer: Color(0xFF3E001F),

  tertiary: CatppuccinPalette.latteTeal,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFB2F5EA),
  onTertiaryContainer: Color(0xFF00201C),

  error: CatppuccinPalette.latteRed,
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  inverseSurface: CatppuccinPalette.mochaBase,
  onInverseSurface: CatppuccinPalette.mochaText,
  inversePrimary: CatppuccinPalette.mochaMauve,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Frappé (dark) theme spec.
const catppuccinFrappeSpec = ThemeSpec(
  surfaceDim: CatppuccinPalette.frappeCrust,
  surface: CatppuccinPalette.frappeBase,
  surfaceBright: CatppuccinPalette.frappeSurface2,
  surfaceContainerLowest: CatppuccinPalette.frappeCrust,
  surfaceContainerLow: CatppuccinPalette.frappeMantle,
  surfaceContainer: CatppuccinPalette.frappeBase,
  surfaceContainerHigh: CatppuccinPalette.frappeSurface0,
  surfaceContainerHighest: CatppuccinPalette.frappeSurface1,

  onSurface: CatppuccinPalette.frappeText,
  onSurfaceVariant: CatppuccinPalette.frappeSubtext0,

  outline: CatppuccinPalette.frappeOverlay1,
  outlineVariant: CatppuccinPalette.frappeSurface2,

  primary: CatppuccinPalette.frappeMauve,
  onPrimary: Color(0xFF21005D),
  primaryContainer: Color(0xFF4F378B),
  onPrimaryContainer: Color(0xFFE8DEFF),

  secondary: CatppuccinPalette.frappePink,
  onSecondary: Color(0xFF3E001F),
  secondaryContainer: Color(0xFF5C2945),
  onSecondaryContainer: Color(0xFFFFD8F0),

  tertiary: CatppuccinPalette.frappeTeal,
  onTertiary: Color(0xFF00201C),
  tertiaryContainer: Color(0xFF00574E),
  onTertiaryContainer: Color(0xFFB2F5EA),

  error: CatppuccinPalette.frappeRed,
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  inverseSurface: CatppuccinPalette.latteBase,
  onInverseSurface: CatppuccinPalette.latteText,
  inversePrimary: CatppuccinPalette.latteMauve,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Macchiato (dark) theme spec.
const catppuccinMacchiatoSpec = ThemeSpec(
  surfaceDim: CatppuccinPalette.macchiatoCrust,
  surface: CatppuccinPalette.macchiatoBase,
  surfaceBright: CatppuccinPalette.macchiatoSurface2,
  surfaceContainerLowest: CatppuccinPalette.macchiatoCrust,
  surfaceContainerLow: CatppuccinPalette.macchiatoMantle,
  surfaceContainer: CatppuccinPalette.macchiatoBase,
  surfaceContainerHigh: CatppuccinPalette.macchiatoSurface0,
  surfaceContainerHighest: CatppuccinPalette.macchiatoSurface1,

  onSurface: CatppuccinPalette.macchiatoText,
  onSurfaceVariant: CatppuccinPalette.macchiatoSubtext0,

  outline: CatppuccinPalette.macchiatoOverlay1,
  outlineVariant: CatppuccinPalette.macchiatoSurface2,

  primary: CatppuccinPalette.macchiatoMauve,
  onPrimary: Color(0xFF21005D),
  primaryContainer: Color(0xFF4F378B),
  onPrimaryContainer: Color(0xFFE8DEFF),

  secondary: CatppuccinPalette.macchiatoPink,
  onSecondary: Color(0xFF3E001F),
  secondaryContainer: Color(0xFF5C2945),
  onSecondaryContainer: Color(0xFFFFD8F0),

  tertiary: CatppuccinPalette.macchiatoTeal,
  onTertiary: Color(0xFF00201C),
  tertiaryContainer: Color(0xFF00574E),
  onTertiaryContainer: Color(0xFFB2F5EA),

  error: CatppuccinPalette.macchiatoRed,
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  inverseSurface: CatppuccinPalette.latteBase,
  onInverseSurface: CatppuccinPalette.latteText,
  inversePrimary: CatppuccinPalette.latteMauve,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Mocha (dark) theme spec.
const catppuccinMochaSpec = ThemeSpec(
  surfaceDim: CatppuccinPalette.mochaCrust,
  surface: CatppuccinPalette.mochaBase,
  surfaceBright: CatppuccinPalette.mochaSurface2,
  surfaceContainerLowest: CatppuccinPalette.mochaCrust,
  surfaceContainerLow: CatppuccinPalette.mochaMantle,
  surfaceContainer: CatppuccinPalette.mochaBase,
  surfaceContainerHigh: CatppuccinPalette.mochaSurface0,
  surfaceContainerHighest: CatppuccinPalette.mochaSurface1,

  onSurface: CatppuccinPalette.mochaText,
  onSurfaceVariant: CatppuccinPalette.mochaSubtext0,

  outline: CatppuccinPalette.mochaOverlay1,
  outlineVariant: CatppuccinPalette.mochaSurface2,

  primary: CatppuccinPalette.mochaMauve,
  onPrimary: Color(0xFF21005D),
  primaryContainer: Color(0xFF4F378B),
  onPrimaryContainer: Color(0xFFE8DEFF),

  secondary: CatppuccinPalette.mochaPink,
  onSecondary: Color(0xFF3E001F),
  secondaryContainer: Color(0xFF5C2945),
  onSecondaryContainer: Color(0xFFFFD8F0),

  tertiary: CatppuccinPalette.mochaTeal,
  onTertiary: Color(0xFF00201C),
  tertiaryContainer: Color(0xFF00574E),
  onTertiaryContainer: Color(0xFFB2F5EA),

  error: CatppuccinPalette.mochaRed,
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  inverseSurface: CatppuccinPalette.latteBase,
  onInverseSurface: CatppuccinPalette.latteText,
  inversePrimary: CatppuccinPalette.latteMauve,

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

/// Latte (light) variant.
final catppuccinLatteVariant = ThemeVariant(
  id: 'catppuccin-latte',
  name: 'Latte',
  brightness: Brightness.light,
  spec: catppuccinLatteSpec,
  derivedScheme: _deriveColorScheme(catppuccinLatteSpec, Brightness.light),
);

/// Frappé (dark) variant.
final catppuccinFrappeVariant = ThemeVariant(
  id: 'catppuccin-frappe',
  name: 'Frappé',
  brightness: Brightness.dark,
  spec: catppuccinFrappeSpec,
  derivedScheme: _deriveColorScheme(catppuccinFrappeSpec, Brightness.dark),
);

/// Macchiato (dark) variant.
final catppuccinMacchiatoVariant = ThemeVariant(
  id: 'catppuccin-macchiato',
  name: 'Macchiato',
  brightness: Brightness.dark,
  spec: catppuccinMacchiatoSpec,
  derivedScheme: _deriveColorScheme(catppuccinMacchiatoSpec, Brightness.dark),
);

/// Mocha (dark) variant.
final catppuccinMochaVariant = ThemeVariant(
  id: 'catppuccin-mocha',
  name: 'Mocha',
  brightness: Brightness.dark,
  spec: catppuccinMochaSpec,
  derivedScheme: _deriveColorScheme(catppuccinMochaSpec, Brightness.dark),
);

/// Catppuccin theme pack with all 4 flavors.
final catppuccinPack = ThemePack(
  id: 'catppuccin',
  name: 'Catppuccin',
  author: 'Catppuccin',
  variants: [
    catppuccinLatteVariant,
    catppuccinFrappeVariant,
    catppuccinMacchiatoVariant,
    catppuccinMochaVariant,
  ],
);
