import 'package:flutter/material.dart';

/// Defines color palette values which get mapped to Material 3 ColorScheme roles.
///
/// This is the core building block for themes, containing all the color values needed to construct
/// a full M3 color scheme. Optional fields allow themes to specify only what they need, with
/// sensible derivation for missing values.
class ThemeSpec {
  const ThemeSpec({
    this.surfaceDim,
    this.surface,
    this.surfaceBright,
    this.surfaceContainerLowest,
    this.surfaceContainerLow,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.surfaceContainerHighest,
    this.onSurface,
    this.onSurfaceVariant,
    this.outline,
    this.outlineVariant,
    this.primary,
    this.onPrimary,
    this.primaryContainer,
    this.onPrimaryContainer,
    this.secondary,
    this.onSecondary,
    this.secondaryContainer,
    this.onSecondaryContainer,
    this.tertiary,
    this.onTertiary,
    this.tertiaryContainer,
    this.onTertiaryContainer,
    this.error,
    this.onError,
    this.errorContainer,
    this.onErrorContainer,
    this.scrim,
    this.shadow,
    this.inverseSurface,
    this.onInverseSurface,
    this.inversePrimary,
  });

  /// Dimmest surface - used for backgrounds that need less emphasis.
  final Color? surfaceDim;

  /// Default surface color.
  final Color? surface;

  /// Brightest surface - used for elevated elements in dark themes.
  final Color? surfaceBright;

  /// Lowest container level - typically reserved for very subtle backgrounds.
  final Color? surfaceContainerLowest;

  /// Low container level - used for cards and posts.
  final Color? surfaceContainerLow;

  /// Default container level - standard component backgrounds.
  final Color? surfaceContainer;

  /// High container level - used for elevated or emphasized surfaces.
  final Color? surfaceContainerHigh;

  /// Highest container level - used for maximum elevation surfaces.
  final Color? surfaceContainerHighest;

  /// Primary text/icon color on surfaces.
  final Color? onSurface;

  /// Secondary text/icon color for less emphasis (handles, timestamps).
  final Color? onSurfaceVariant;

  /// Strong outline for emphasized boundaries.
  final Color? outline;

  /// Subtle outline for dividers and low-emphasis boundaries.
  final Color? outlineVariant;

  /// Primary accent color.
  final Color? primary;

  /// Text/icon color on primary.
  final Color? onPrimary;

  /// Primary container background.
  final Color? primaryContainer;

  /// Text/icon color on primary container.
  final Color? onPrimaryContainer;

  /// Secondary accent color.
  final Color? secondary;

  /// Text/icon color on secondary.
  final Color? onSecondary;

  /// Secondary container background.
  final Color? secondaryContainer;

  /// Text/icon color on secondary container.
  final Color? onSecondaryContainer;

  /// Tertiary accent color.
  final Color? tertiary;

  /// Text/icon color on tertiary.
  final Color? onTertiary;

  /// Tertiary container background.
  final Color? tertiaryContainer;

  /// Text/icon color on tertiary container.
  final Color? onTertiaryContainer;

  /// Error color.
  final Color? error;

  /// Text/icon color on error.
  final Color? onError;

  /// Error container background.
  final Color? errorContainer;

  /// Text/icon color on error container.
  final Color? onErrorContainer;

  /// Scrim color for modal overlays.
  final Color? scrim;

  /// Shadow color.
  final Color? shadow;

  /// Inverse surface for snackbars and tooltips.
  final Color? inverseSurface;

  /// Text/icon color on inverse surface.
  final Color? onInverseSurface;

  /// Primary color on inverse surface.
  final Color? inversePrimary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSpec &&
          runtimeType == other.runtimeType &&
          surfaceDim == other.surfaceDim &&
          surface == other.surface &&
          surfaceBright == other.surfaceBright &&
          surfaceContainerLowest == other.surfaceContainerLowest &&
          surfaceContainerLow == other.surfaceContainerLow &&
          surfaceContainer == other.surfaceContainer &&
          surfaceContainerHigh == other.surfaceContainerHigh &&
          surfaceContainerHighest == other.surfaceContainerHighest &&
          onSurface == other.onSurface &&
          onSurfaceVariant == other.onSurfaceVariant &&
          outline == other.outline &&
          outlineVariant == other.outlineVariant &&
          primary == other.primary &&
          onPrimary == other.onPrimary &&
          primaryContainer == other.primaryContainer &&
          onPrimaryContainer == other.onPrimaryContainer &&
          secondary == other.secondary &&
          onSecondary == other.onSecondary &&
          secondaryContainer == other.secondaryContainer &&
          onSecondaryContainer == other.onSecondaryContainer &&
          tertiary == other.tertiary &&
          onTertiary == other.onTertiary &&
          tertiaryContainer == other.tertiaryContainer &&
          onTertiaryContainer == other.onTertiaryContainer &&
          error == other.error &&
          onError == other.onError &&
          errorContainer == other.errorContainer &&
          onErrorContainer == other.onErrorContainer &&
          scrim == other.scrim &&
          shadow == other.shadow &&
          inverseSurface == other.inverseSurface &&
          onInverseSurface == other.onInverseSurface &&
          inversePrimary == other.inversePrimary;

  @override
  int get hashCode => Object.hashAll([
    surfaceDim,
    surface,
    surfaceBright,
    surfaceContainerLowest,
    surfaceContainerLow,
    surfaceContainer,
    surfaceContainerHigh,
    surfaceContainerHighest,
    onSurface,
    onSurfaceVariant,
    outline,
    outlineVariant,
    primary,
    onPrimary,
    primaryContainer,
    onPrimaryContainer,
    secondary,
    onSecondary,
    secondaryContainer,
    onSecondaryContainer,
    tertiary,
    onTertiary,
    tertiaryContainer,
    onTertiaryContainer,
    error,
    onError,
    errorContainer,
    onErrorContainer,
    scrim,
    shadow,
    inverseSurface,
    onInverseSurface,
    inversePrimary,
  ]);
}
