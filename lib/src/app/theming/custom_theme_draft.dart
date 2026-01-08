import 'dart:convert';
import 'dart:ui';

/// Typography scale options for custom themes.
///
/// Controls the overall text size multiplier applied to the theme.
enum TypographyScale {
  /// Smaller text (-10% from baseline).
  small,

  /// Default text size.
  normal,

  /// Larger text (+10% from baseline).
  large;

  /// Returns the scale factor for this typography scale.
  double get scaleFactor => switch (this) {
    TypographyScale.small => 0.9,
    TypographyScale.normal => 1.0,
    TypographyScale.large => 1.1,
  };

  /// Parses a string to a [TypographyScale], defaulting to [normal].
  static TypographyScale fromString(String? value) => switch (value) {
    'small' => TypographyScale.small,
    'large' => TypographyScale.large,
    _ => TypographyScale.normal,
  };
}

/// Subset of ThemeSpec roles that users can customize.
///
/// These roles are the most impactful for theme personalization while
/// maintaining visual hierarchy integrity. All other roles are derived
/// from the base pack.
class ThemeRoleOverrides {
  /// Creates overrides from JSON map.
  factory ThemeRoleOverrides.fromJson(Map<String, dynamic> json) {
    return ThemeRoleOverrides(
      primary: _colorFromHex(json['primary'] as String?),
      secondary: _colorFromHex(json['secondary'] as String?),
      tertiary: _colorFromHex(json['tertiary'] as String?),
      surface: _colorFromHex(json['surface'] as String?),
      surfaceContainerLow: _colorFromHex(json['surfaceContainerLow'] as String?),
      surfaceContainerHigh: _colorFromHex(json['surfaceContainerHigh'] as String?),
      outlineVariant: _colorFromHex(json['outlineVariant'] as String?),
    );
  }
  const ThemeRoleOverrides({
    this.primary,
    this.secondary,
    this.tertiary,
    this.surface,
    this.surfaceContainerLow,
    this.surfaceContainerHigh,
    this.outlineVariant,
  });

  /// Primary accent color override.
  final Color? primary;

  /// Secondary accent color override.
  final Color? secondary;

  /// Tertiary accent color override.
  final Color? tertiary;

  /// Surface background color override.
  final Color? surface;

  /// Low container surface override (for cards).
  final Color? surfaceContainerLow;

  /// High container surface override (for elevated elements).
  final Color? surfaceContainerHigh;

  /// Subtle outline/divider color override.
  final Color? outlineVariant;

  /// Returns true if any overrides are set.
  bool get hasOverrides =>
      primary != null ||
      secondary != null ||
      tertiary != null ||
      surface != null ||
      surfaceContainerLow != null ||
      surfaceContainerHigh != null ||
      outlineVariant != null;

  /// Creates an empty overrides instance.
  static const ThemeRoleOverrides empty = ThemeRoleOverrides();

  /// Converts overrides to JSON map.
  Map<String, dynamic> toJson() => {
    if (primary != null) 'primary': _colorToHex(primary!),
    if (secondary != null) 'secondary': _colorToHex(secondary!),
    if (tertiary != null) 'tertiary': _colorToHex(tertiary!),
    if (surface != null) 'surface': _colorToHex(surface!),
    if (surfaceContainerLow != null) 'surfaceContainerLow': _colorToHex(surfaceContainerLow!),
    if (surfaceContainerHigh != null) 'surfaceContainerHigh': _colorToHex(surfaceContainerHigh!),
    if (outlineVariant != null) 'outlineVariant': _colorToHex(outlineVariant!),
  };

  /// Creates a copy with updated values.
  ThemeRoleOverrides copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? surface,
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? outlineVariant,
    bool clearPrimary = false,
    bool clearSecondary = false,
    bool clearTertiary = false,
    bool clearSurface = false,
    bool clearSurfaceContainerLow = false,
    bool clearSurfaceContainerHigh = false,
    bool clearOutlineVariant = false,
  }) {
    return ThemeRoleOverrides(
      primary: clearPrimary ? null : (primary ?? this.primary),
      secondary: clearSecondary ? null : (secondary ?? this.secondary),
      tertiary: clearTertiary ? null : (tertiary ?? this.tertiary),
      surface: clearSurface ? null : (surface ?? this.surface),
      surfaceContainerLow: clearSurfaceContainerLow
          ? null
          : (surfaceContainerLow ?? this.surfaceContainerLow),
      surfaceContainerHigh: clearSurfaceContainerHigh
          ? null
          : (surfaceContainerHigh ?? this.surfaceContainerHigh),
      outlineVariant: clearOutlineVariant ? null : (outlineVariant ?? this.outlineVariant),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeRoleOverrides &&
          runtimeType == other.runtimeType &&
          primary == other.primary &&
          secondary == other.secondary &&
          tertiary == other.tertiary &&
          surface == other.surface &&
          surfaceContainerLow == other.surfaceContainerLow &&
          surfaceContainerHigh == other.surfaceContainerHigh &&
          outlineVariant == other.outlineVariant;

  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    tertiary,
    surface,
    surfaceContainerLow,
    surfaceContainerHigh,
    outlineVariant,
  );
}

/// Represents a user-customized theme based on an existing pack.
///
/// Custom themes store role overrides that are merged with a base pack's spec at runtime.
/// This allows users to personalize themes while maintaining visual consistency through
/// the derived roles.
class CustomThemeDraft {
  /// Creates a new custom theme draft with a generated ID.
  factory CustomThemeDraft.create({
    required String name,
    required String basePackId,
    ThemeRoleOverrides overrides = ThemeRoleOverrides.empty,
    TypographyScale typographyScale = TypographyScale.normal,
  }) {
    final now = DateTime.now();
    return CustomThemeDraft(
      id: 'custom-${now.millisecondsSinceEpoch}',
      name: name,
      basePackId: basePackId,
      overrides: overrides,
      typographyScale: typographyScale,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a custom theme from JSON map.
  ///
  /// Throws [FormatException] if the JSON is invalid.
  factory CustomThemeDraft.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;
    if (version > schemaVersion) {
      throw FormatException('Unsupported schema version: $version');
    }

    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final basePackId = json['basePack'] as String?;

    if (id == null || id.isEmpty) {
      throw const FormatException('Missing or empty id');
    }
    if (name == null || name.isEmpty) {
      throw const FormatException('Missing or empty name');
    }
    if (basePackId == null || basePackId.isEmpty) {
      throw const FormatException('Missing or empty basePack');
    }

    final overridesJson = json['overrides'] as Map<String, dynamic>? ?? {};
    final typography = json['typography'] as String?;
    final createdAtStr = json['createdAt'] as String?;
    final updatedAtStr = json['updatedAt'] as String?;

    final now = DateTime.now();

    return CustomThemeDraft(
      id: id,
      name: name,
      basePackId: basePackId,
      overrides: ThemeRoleOverrides.fromJson(overridesJson),
      typographyScale: TypographyScale.fromString(typography),
      createdAt: createdAtStr != null ? DateTime.parse(createdAtStr) : now,
      updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : now,
    );
  }

  /// Parses a JSON string to a [CustomThemeDraft].
  ///
  /// Throws [FormatException] if the JSON is invalid.
  factory CustomThemeDraft.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CustomThemeDraft.fromJson(json);
  }
  const CustomThemeDraft({
    required this.id,
    required this.name,
    required this.basePackId,
    this.overrides = ThemeRoleOverrides.empty,
    this.typographyScale = TypographyScale.normal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for this custom theme.
  final String id;

  /// User-provided name for the theme.
  final String name;

  /// ID of the base theme pack this customization is based on.
  final String basePackId;

  /// Color role overrides to apply on top of the base pack.
  final ThemeRoleOverrides overrides;

  /// Typography scale preference.
  final TypographyScale typographyScale;

  /// When this theme was first created.
  final DateTime createdAt;

  /// When this theme was last modified.
  final DateTime updatedAt;

  /// JSON schema version for import/export.
  static const int schemaVersion = 1;

  /// Converts this theme to a JSON map.
  Map<String, dynamic> toJson() => {
    'version': schemaVersion,
    'id': id,
    'name': name,
    'basePack': basePackId,
    'overrides': overrides.toJson(),
    'typography': typographyScale.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Converts this theme to a JSON string.
  String toJsonString({bool pretty = false}) {
    final encoder = pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    return encoder.convert(toJson());
  }

  /// Creates a copy with updated values.
  CustomThemeDraft copyWith({
    String? id,
    String? name,
    String? basePackId,
    ThemeRoleOverrides? overrides,
    TypographyScale? typographyScale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomThemeDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      basePackId: basePackId ?? this.basePackId,
      overrides: overrides ?? this.overrides,
      typographyScale: typographyScale ?? this.typographyScale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomThemeDraft &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          basePackId == other.basePackId &&
          overrides == other.overrides &&
          typographyScale == other.typographyScale;

  @override
  int get hashCode => Object.hash(id, name, basePackId, overrides, typographyScale);

  @override
  String toString() => 'CustomThemeDraft(id: $id, name: $name, basePack: $basePackId)';
}

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleanHex = hex.replaceFirst('#', '');
  if (cleanHex.length != 6 && cleanHex.length != 8) return null;
  final intValue = int.tryParse(cleanHex, radix: 16);
  if (intValue == null) return null;

  if (cleanHex.length == 6) {
    return Color(0xFF000000 | intValue);
  }
  return Color(intValue);
}

String _colorToHex(Color color) {
  final argb = color.toARGB32();
  return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
