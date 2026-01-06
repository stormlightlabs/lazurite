import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Represents a collection of theme variants (e.g., "Oxocarbon" pack).
///
/// A theme pack is a cohesive design system with one or more brightness
/// variants. Packs have metadata (name, author) and provide convenient
/// accessors for light and dark variants.
class ThemePack {
  const ThemePack({required this.id, required this.name, this.author, required this.variants});

  /// Unique identifier for this pack (e.g., 'oxocarbon').
  final String id;

  /// Display name for the pack (e.g., 'Oxocarbon').
  final String name;

  /// Optional author/source attribution.
  final String? author;

  /// The variants included in this pack.
  final List<ThemeVariant> variants;

  /// Returns the first light variant, or null if none exists.
  ThemeVariant? get lightVariant =>
      variants.where((v) => v.brightness == Brightness.light).firstOrNull;

  /// Returns the first dark variant, or null if none exists.
  ThemeVariant? get darkVariant =>
      variants.where((v) => v.brightness == Brightness.dark).firstOrNull;

  /// Returns a variant by ID, or null if not found.
  ThemeVariant? getVariant(String id) => variants.where((v) => v.id == id).firstOrNull;

  /// Returns a variant by brightness, preferring an exact match.
  ThemeVariant? getVariantForBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? darkVariant : lightVariant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePack &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          author == other.author &&
          _listEquals(variants, other.variants);

  @override
  int get hashCode => Object.hash(id, name, author, Object.hashAll(variants));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
