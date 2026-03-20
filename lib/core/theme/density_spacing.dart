import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/ui_density.dart';

/// ThemeExtension providing density-scaled spacing values.
///
/// Obtain via `Theme.of(context).extension<DensitySpacing>()`.
class DensitySpacing extends ThemeExtension<DensitySpacing> {
  const DensitySpacing({required this.scale});

  factory DensitySpacing.fromDensity(UiDensity density) => DensitySpacing(scale: density.scaleFactor);

  /// The multiplier applied to all spacing values (0.75 / 1.0 / 1.25).
  final double scale;

  double get xs => 4.0 * scale;
  double get sm => 8.0 * scale;
  double get md => 16.0 * scale;
  double get lg => 24.0 * scale;
  double get xl => 32.0 * scale;
  double get xxl => 48.0 * scale;

  @override
  DensitySpacing copyWith({double? scale}) => DensitySpacing(scale: scale ?? this.scale);

  @override
  DensitySpacing lerp(ThemeExtension<DensitySpacing>? other, double t) {
    if (other is! DensitySpacing) return this;
    return DensitySpacing(scale: scale + (other.scale - scale) * t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DensitySpacing && runtimeType == other.runtimeType && scale == other.scale;

  @override
  int get hashCode => scale.hashCode;
}
