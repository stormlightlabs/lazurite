import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';

/// A single brightness variant within a theme pack.
///
/// Contains the [ThemeSpec] palette definition and a pre-computed [ColorScheme] derived from that
/// spec.
/// This allows theme packs to define multiple variants (e.g., light, dark, OLED) that share the
/// same pack identity but differ in brightness and color values.
class ThemeVariant {
  const ThemeVariant({
    required this.id,
    required this.name,
    required this.brightness,
    required this.spec,
    required this.derivedScheme,
  });

  /// Unique identifier for this variant (e.g., 'oxocarbon-dark').
  final String id;

  /// Display name for the variant (e.g., 'Dark').
  final String name;

  /// The brightness of this variant.
  final Brightness brightness;

  /// The color palette specification.
  final ThemeSpec spec;

  /// Pre-computed ColorScheme derived from the spec.
  final ColorScheme derivedScheme;

  /// Whether this is a dark theme variant.
  bool get isDark => brightness == Brightness.dark;

  /// Whether this is a light theme variant.
  bool get isLight => brightness == Brightness.light;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeVariant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          brightness == other.brightness &&
          spec == other.spec &&
          derivedScheme == other.derivedScheme;

  @override
  int get hashCode => Object.hash(id, name, brightness, spec, derivedScheme);
}
