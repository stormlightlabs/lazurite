import 'package:freezed_annotation/freezed_annotation.dart';

part 'animation_preferences.freezed.dart';
part 'animation_preferences.g.dart';

/// Animation intensity mode for the app.
@JsonEnum()
enum AnimationMode {
  /// Full animations with all effects enabled.
  full,

  /// Reduced animations - essential transitions only.
  reduced,

  /// Minimal animations - near-instant transitions.
  minimal,

  /// Follow platform accessibility settings (reduce motion).
  system,
}

/// Animation preferences for the app.
@freezed
abstract class AnimationPreferences with _$AnimationPreferences {
  factory AnimationPreferences.fromJson(Map<String, dynamic> json) =>
      _$AnimationPreferencesFromJson(json);
  const factory AnimationPreferences({
    @Default(AnimationMode.system) AnimationMode mode,
    @Default(1.0) double speedMultiplier,
  }) = _AnimationPreferences;

  const AnimationPreferences._();

  /// Default animation preferences.
  static const defaults = AnimationPreferences();

  /// Minimum allowed speed multiplier.
  static const minSpeedMultiplier = 0.5;

  /// Maximum allowed speed multiplier.
  static const maxSpeedMultiplier = 2.0;

  @override
  Map<String, dynamic> toJson() => _$AnimationPreferencesToJson(this as _AnimationPreferences);

  /// Resolves the effective animation mode considering platform settings.
  AnimationMode resolveMode({required bool platformReduceMotion}) {
    if (mode == AnimationMode.system) {
      return platformReduceMotion ? AnimationMode.reduced : AnimationMode.full;
    }
    return mode;
  }

  /// Calculates the effective duration for an animation.
  Duration getEffectiveDuration(Duration baseDuration, {required bool platformReduceMotion}) {
    final effectiveMode = resolveMode(platformReduceMotion: platformReduceMotion);

    switch (effectiveMode) {
      case AnimationMode.minimal:
        return Duration.zero;
      case AnimationMode.reduced:
        final reducedMs = (baseDuration.inMilliseconds * 0.5 / speedMultiplier).round();
        return Duration(milliseconds: reducedMs);
      case AnimationMode.full:
      case AnimationMode.system:
        final adjustedMs = (baseDuration.inMilliseconds / speedMultiplier).round();
        return Duration(milliseconds: adjustedMs);
    }
  }

  /// Whether animations should be completely disabled.
  bool shouldDisableAnimations({required bool platformReduceMotion}) {
    final effectiveMode = resolveMode(platformReduceMotion: platformReduceMotion);
    return effectiveMode == AnimationMode.minimal;
  }
}
