import 'package:flutter/foundation.dart';

/// Animation intensity mode for the app.
///
/// Controls how animations are displayed, with accessibility considerations.
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
///
/// Controls animation intensity and speed across the application,
/// with support for accessibility settings.
@immutable
class AnimationPreferences {
  const AnimationPreferences({this.mode = AnimationMode.system, this.speedMultiplier = 1.0})
    : assert(
        speedMultiplier >= minSpeedMultiplier && speedMultiplier <= maxSpeedMultiplier,
        'Speed multiplier must be between $minSpeedMultiplier and $maxSpeedMultiplier',
      );

  /// Default animation preferences.
  static const defaults = AnimationPreferences();

  /// Minimum allowed speed multiplier.
  static const minSpeedMultiplier = 0.5;

  /// Maximum allowed speed multiplier.
  static const maxSpeedMultiplier = 2.0;

  /// The animation mode setting.
  final AnimationMode mode;

  /// Speed multiplier for animations (0.5x to 2.0x).
  ///
  /// Values < 1.0 slow down animations, values > 1.0 speed them up.
  final double speedMultiplier;

  /// Resolves the effective animation mode considering platform settings.
  ///
  /// When [mode] is [AnimationMode.system], returns [AnimationMode.reduced]
  /// if the platform requests reduced motion, otherwise [AnimationMode.full].
  AnimationMode resolveMode({required bool platformReduceMotion}) {
    if (mode == AnimationMode.system) {
      return platformReduceMotion ? AnimationMode.reduced : AnimationMode.full;
    }
    return mode;
  }

  /// Calculates the effective duration for an animation.
  ///
  /// Takes a base duration and adjusts it based on:
  /// 1. The animation mode (minimal = instant, reduced = faster)
  /// 2. The speed multiplier setting
  /// 3. Platform accessibility settings
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

  /// Creates a copy with the given fields replaced.
  AnimationPreferences copyWith({AnimationMode? mode, double? speedMultiplier}) {
    return AnimationPreferences(
      mode: mode ?? this.mode,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimationPreferences &&
        other.mode == mode &&
        other.speedMultiplier == speedMultiplier;
  }

  @override
  int get hashCode => Object.hash(mode, speedMultiplier);

  @override
  String toString() => 'AnimationPreferences(mode: $mode, speedMultiplier: $speedMultiplier)';
}
