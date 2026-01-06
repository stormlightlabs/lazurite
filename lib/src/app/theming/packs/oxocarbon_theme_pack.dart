import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// IBM Oxocarbon-inspired color palette values.
///
/// These raw colors are mapped to M3 ColorScheme roles in the theme variants.
///
/// M3 guidance: in dark themes, higher containers are brighter
/// surfaceDim < surface < surfaceContainerLow < ... < surfaceContainerHighest
///
/// Accent: BlueSky blue
/// Secondary: Soft blue
/// Tertiary: Cyan
/// Error: Pink/magenta
abstract final class OxocarbonPalette {
  static const Color darkSurfaceDim = Color(0xFF161616);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceBright = Color(0xFF2B2B2B);
  static const Color darkSurfaceContainerLowest = Color(0xFF0D0D0D);
  static const Color darkSurfaceContainerLow = Color(0xFF212121);
  static const Color darkSurfaceContainer = Color(0xFF262626);
  static const Color darkSurfaceContainerHigh = Color(0xFF303030);
  static const Color darkSurfaceContainerHighest = Color(0xFF393939);

  static const Color lightSurfaceDim = Color(0xFFE8E8E8);
  static const Color lightSurface = Color(0xFFF2F4F8);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF6F6F6);
  static const Color lightSurfaceContainer = Color(0xFFEEEEEE);
  static const Color lightSurfaceContainerHigh = Color(0xFFE4E4E4);
  static const Color lightSurfaceContainerHighest = Color(0xFFDDE1E6);

  static const Color darkOnSurface = Color(0xFFF2F4F8);
  static const Color darkOnSurfaceVariant = Color(0xFF9DA5B4);
  static const Color lightOnSurface = Color(0xFF161616);
  static const Color lightOnSurfaceVariant = Color(0xFF525252);

  static const Color darkOutline = Color(0xFF525252);
  static const Color darkOutlineVariant = Color(0xFF393939);
  static const Color lightOutline = Color(0xFF697077);
  static const Color lightOutlineVariant = Color(0xFFDDE1E6);

  static const Color primary = Color(0xFF0085FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF003D75);
  static const Color onPrimaryContainer = Color(0xFFD1E4FF);
  static const Color primaryContainerLight = Color(0xFFD1E4FF);
  static const Color onPrimaryContainerLight = Color(0xFF001D36);

  static const Color secondary = Color(0xFF78A9FF);
  static const Color onSecondary = Color(0xFF003258);
  static const Color secondaryContainer = Color(0xFF0A4A79);
  static const Color onSecondaryContainer = Color(0xFFD1E4FF);
  static const Color secondaryContainerLight = Color(0xFFD6E3FF);
  static const Color onSecondaryContainerLight = Color(0xFF001B3E);

  static const Color tertiary = Color(0xFF33B1FF);
  static const Color onTertiary = Color(0xFF003548);
  static const Color tertiaryContainer = Color(0xFF004D67);
  static const Color onTertiaryContainer = Color(0xFFBEEAFF);
  static const Color tertiaryContainerLight = Color(0xFFB6EAFF);
  static const Color onTertiaryContainerLight = Color(0xFF001F28);

  static const Color error = Color(0xFFEE5396);
  static const Color onError = Color(0xFF690033);
  static const Color errorContainer = Color(0xFF8E0049);
  static const Color onErrorContainer = Color(0xFFFFD9E3);
  static const Color errorContainerLight = Color(0xFFFFD9E2);
  static const Color onErrorContainerLight = Color(0xFF3F0019);

  static const Color darkInverseSurface = Color(0xFFE4E2E6);
  static const Color darkOnInverseSurface = Color(0xFF313033);
  static const Color lightInverseSurface = Color(0xFF303030);
  static const Color lightOnInverseSurface = Color(0xFFF2F4F8);
  static const Color inversePrimary = Color(0xFF0068C9);
}

/// Dark Oxocarbon theme spec with full M3 surface ladder.
const oxocarbonDarkSpec = ThemeSpec(
  surfaceDim: OxocarbonPalette.darkSurfaceDim,
  surface: OxocarbonPalette.darkSurface,
  surfaceBright: OxocarbonPalette.darkSurfaceBright,
  surfaceContainerLowest: OxocarbonPalette.darkSurfaceContainerLowest,
  surfaceContainerLow: OxocarbonPalette.darkSurfaceContainerLow,
  surfaceContainer: OxocarbonPalette.darkSurfaceContainer,
  surfaceContainerHigh: OxocarbonPalette.darkSurfaceContainerHigh,
  surfaceContainerHighest: OxocarbonPalette.darkSurfaceContainerHighest,

  onSurface: OxocarbonPalette.darkOnSurface,
  onSurfaceVariant: OxocarbonPalette.darkOnSurfaceVariant,

  outline: OxocarbonPalette.darkOutline,
  outlineVariant: OxocarbonPalette.darkOutlineVariant,

  primary: OxocarbonPalette.primary,
  onPrimary: OxocarbonPalette.onPrimary,
  primaryContainer: OxocarbonPalette.primaryContainer,
  onPrimaryContainer: OxocarbonPalette.onPrimaryContainer,

  secondary: OxocarbonPalette.secondary,
  onSecondary: OxocarbonPalette.onSecondary,
  secondaryContainer: OxocarbonPalette.secondaryContainer,
  onSecondaryContainer: OxocarbonPalette.onSecondaryContainer,

  tertiary: OxocarbonPalette.tertiary,
  onTertiary: OxocarbonPalette.onTertiary,
  tertiaryContainer: OxocarbonPalette.tertiaryContainer,
  onTertiaryContainer: OxocarbonPalette.onTertiaryContainer,

  error: OxocarbonPalette.error,
  onError: OxocarbonPalette.onError,
  errorContainer: OxocarbonPalette.errorContainer,
  onErrorContainer: OxocarbonPalette.onErrorContainer,

  inverseSurface: OxocarbonPalette.darkInverseSurface,
  onInverseSurface: OxocarbonPalette.darkOnInverseSurface,
  inversePrimary: OxocarbonPalette.inversePrimary,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Light Oxocarbon theme spec with full M3 surface ladder.
const oxocarbonLightSpec = ThemeSpec(
  surfaceDim: OxocarbonPalette.lightSurfaceDim,
  surface: OxocarbonPalette.lightSurface,
  surfaceBright: OxocarbonPalette.lightSurfaceBright,
  surfaceContainerLowest: OxocarbonPalette.lightSurfaceContainerLowest,
  surfaceContainerLow: OxocarbonPalette.lightSurfaceContainerLow,
  surfaceContainer: OxocarbonPalette.lightSurfaceContainer,
  surfaceContainerHigh: OxocarbonPalette.lightSurfaceContainerHigh,
  surfaceContainerHighest: OxocarbonPalette.lightSurfaceContainerHighest,

  onSurface: OxocarbonPalette.lightOnSurface,
  onSurfaceVariant: OxocarbonPalette.lightOnSurfaceVariant,

  outline: OxocarbonPalette.lightOutline,
  outlineVariant: OxocarbonPalette.lightOutlineVariant,

  primary: OxocarbonPalette.primary,
  onPrimary: OxocarbonPalette.onPrimary,
  primaryContainer: OxocarbonPalette.primaryContainerLight,
  onPrimaryContainer: OxocarbonPalette.onPrimaryContainerLight,

  secondary: OxocarbonPalette.secondary,
  onSecondary: OxocarbonPalette.onSecondary,
  secondaryContainer: OxocarbonPalette.secondaryContainerLight,
  onSecondaryContainer: OxocarbonPalette.onSecondaryContainerLight,

  tertiary: OxocarbonPalette.tertiary,
  onTertiary: OxocarbonPalette.onTertiary,
  tertiaryContainer: OxocarbonPalette.tertiaryContainerLight,
  onTertiaryContainer: OxocarbonPalette.onTertiaryContainerLight,

  error: OxocarbonPalette.error,
  onError: OxocarbonPalette.onError,
  errorContainer: OxocarbonPalette.errorContainerLight,
  onErrorContainer: OxocarbonPalette.onErrorContainerLight,

  inverseSurface: OxocarbonPalette.lightInverseSurface,
  onInverseSurface: OxocarbonPalette.lightOnInverseSurface,
  inversePrimary: OxocarbonPalette.inversePrimary,

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);

/// Derives a full [ColorScheme] from a [ThemeSpec].
ColorScheme _deriveColorScheme(ThemeSpec spec, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return ColorScheme(
    brightness: brightness,
    primary: spec.primary ?? const Color(0xFF0085FF),
    onPrimary: spec.onPrimary ?? Colors.white,
    primaryContainer:
        spec.primaryContainer ?? (isDark ? const Color(0xFF003D75) : const Color(0xFFD1E4FF)),
    onPrimaryContainer:
        spec.onPrimaryContainer ?? (isDark ? const Color(0xFFD1E4FF) : const Color(0xFF001D36)),
    secondary: spec.secondary ?? const Color(0xFF78A9FF),
    onSecondary: spec.onSecondary ?? const Color(0xFF003258),
    secondaryContainer:
        spec.secondaryContainer ?? (isDark ? const Color(0xFF0A4A79) : const Color(0xFFD6E3FF)),
    onSecondaryContainer:
        spec.onSecondaryContainer ?? (isDark ? const Color(0xFFD1E4FF) : const Color(0xFF001B3E)),
    tertiary: spec.tertiary ?? const Color(0xFF33B1FF),
    onTertiary: spec.onTertiary ?? const Color(0xFF003548),
    tertiaryContainer:
        spec.tertiaryContainer ?? (isDark ? const Color(0xFF004D67) : const Color(0xFFB6EAFF)),
    onTertiaryContainer:
        spec.onTertiaryContainer ?? (isDark ? const Color(0xFFBEEAFF) : const Color(0xFF001F28)),
    error: spec.error ?? const Color(0xFFEE5396),
    onError: spec.onError ?? const Color(0xFF690033),
    errorContainer:
        spec.errorContainer ?? (isDark ? const Color(0xFF8E0049) : const Color(0xFFFFD9E2)),
    onErrorContainer:
        spec.onErrorContainer ?? (isDark ? const Color(0xFFFFD9E3) : const Color(0xFF3F0019)),
    surface: spec.surface ?? (isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF2F4F8)),
    onSurface: spec.onSurface ?? (isDark ? const Color(0xFFF2F4F8) : const Color(0xFF161616)),
    onSurfaceVariant:
        spec.onSurfaceVariant ?? (isDark ? const Color(0xFF9DA5B4) : const Color(0xFF525252)),
    surfaceDim: spec.surfaceDim ?? (isDark ? const Color(0xFF161616) : const Color(0xFFE8E8E8)),
    surfaceBright:
        spec.surfaceBright ?? (isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFFFFFF)),
    surfaceContainerLowest:
        spec.surfaceContainerLowest ??
        (isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF)),
    surfaceContainerLow:
        spec.surfaceContainerLow ?? (isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF6F6F6)),
    surfaceContainer:
        spec.surfaceContainer ?? (isDark ? const Color(0xFF262626) : const Color(0xFFEEEEEE)),
    surfaceContainerHigh:
        spec.surfaceContainerHigh ?? (isDark ? const Color(0xFF303030) : const Color(0xFFE4E4E4)),
    surfaceContainerHighest:
        spec.surfaceContainerHighest ??
        (isDark ? const Color(0xFF393939) : const Color(0xFFDDE1E6)),
    outline: spec.outline ?? (isDark ? const Color(0xFF525252) : const Color(0xFF697077)),
    outlineVariant:
        spec.outlineVariant ?? (isDark ? const Color(0xFF393939) : const Color(0xFFDDE1E6)),
    inverseSurface:
        spec.inverseSurface ?? (isDark ? const Color(0xFFE4E2E6) : const Color(0xFF303030)),
    onInverseSurface:
        spec.onInverseSurface ?? (isDark ? const Color(0xFF313033) : const Color(0xFFF2F4F8)),
    inversePrimary: spec.inversePrimary ?? const Color(0xFF0068C9),
    scrim: spec.scrim ?? Colors.black,
    shadow: spec.shadow ?? Colors.black,
  );
}

/// Dark Oxocarbon theme variant.
final oxocarbonDarkVariant = ThemeVariant(
  id: 'oxocarbon-dark',
  name: 'Dark',
  brightness: Brightness.dark,
  spec: oxocarbonDarkSpec,
  derivedScheme: _deriveColorScheme(oxocarbonDarkSpec, Brightness.dark),
);

/// Light Oxocarbon theme variant.
final oxocarbonLightVariant = ThemeVariant(
  id: 'oxocarbon-light',
  name: 'Light',
  brightness: Brightness.light,
  spec: oxocarbonLightSpec,
  derivedScheme: _deriveColorScheme(oxocarbonLightSpec, Brightness.light),
);

/// IBM Oxocarbon theme pack with dark and light variants.
final oxocarbonPack = ThemePack(
  id: 'oxocarbon',
  name: 'Oxocarbon',
  author: 'IBM',
  variants: [oxocarbonDarkVariant, oxocarbonLightVariant],
);
