import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';

/// Derives a full [ColorScheme] from a [ThemeSpec] and brightness.
///
/// This function fills in any missing values from the spec with sensible
/// defaults based on the brightness. It is used by theme packs to create
/// their pre-computed ColorSchemes and by custom themes to apply overrides.
ColorScheme deriveColorScheme(ThemeSpec spec, Brightness brightness) {
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
