import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';
import 'package:lazurite/src/infrastructure/db/daos/animation_preferences_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animation_controller.g.dart';

/// Keys for persisted animation settings.
abstract final class AnimationSettingsKeys {
  /// Animation mode setting.
  static const mode = AnimationPreferenceKeys.mode;

  /// Speed multiplier setting.
  static const speedMultiplier = AnimationPreferenceKeys.speedMultiplier;
}

/// State for the animation controller.
class AnimationState {
  const AnimationState({this.preferences = AnimationPreferences.defaults, this.isLoading = true});

  /// The current animation preferences.
  final AnimationPreferences preferences;

  /// Whether the controller is still loading persisted settings.
  final bool isLoading;

  /// Creates a copy with the given fields replaced.
  AnimationState copyWith({AnimationPreferences? preferences, bool? isLoading}) {
    return AnimationState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Convenience accessor for animation mode.
  AnimationMode get mode => preferences.mode;

  /// Convenience accessor for speed multiplier.
  double get speedMultiplier => preferences.speedMultiplier;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimationState &&
        other.preferences == preferences &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(preferences, isLoading);
}

/// Provides the animation preferences DAO.
@Riverpod(keepAlive: true)
AnimationPreferencesDao animationPreferencesDao(Ref ref) {
  return ref.watch(appDatabaseProvider).animationPreferencesDao;
}

/// Controls app animations with mode and speed settings.
///
/// Features:
/// - Animation mode (full/reduced/minimal/system)
/// - Speed multiplier (0.5x to 2.0x)
/// - Platform accessibility integration (respects reduce motion)
/// - Persisted settings via Drift
@Riverpod(keepAlive: true)
class AnimationController extends _$AnimationController {
  AnimationPreferencesDao get _dao => ref.read(animationPreferencesDaoProvider);

  @override
  AnimationState build() {
    _loadPersistedSettings();
    return const AnimationState();
  }

  /// Loads persisted settings from the database.
  Future<void> _loadPersistedSettings() async {
    final modeStr = await _dao.get(AnimationSettingsKeys.mode);
    final speedStr = await _dao.get(AnimationSettingsKeys.speedMultiplier);

    final mode = _parseAnimationMode(modeStr) ?? AnimationMode.system;
    final speed = _parseSpeedMultiplier(speedStr) ?? 1.0;

    state = AnimationState(
      preferences: AnimationPreferences(mode: mode, speedMultiplier: speed),
      isLoading: false,
    );
  }

  /// Sets the animation mode and persists to database.
  Future<void> setMode(AnimationMode mode) async {
    state = state.copyWith(preferences: state.preferences.copyWith(mode: mode));
    await _dao.set(AnimationSettingsKeys.mode, mode.name);
  }

  /// Sets the speed multiplier and persists to database.
  ///
  /// The value is clamped to the valid range (0.5 to 2.0).
  Future<void> setSpeedMultiplier(double multiplier) async {
    final clampedMultiplier = multiplier.clamp(
      AnimationPreferences.minSpeedMultiplier,
      AnimationPreferences.maxSpeedMultiplier,
    );

    state = state.copyWith(
      preferences: state.preferences.copyWith(speedMultiplier: clampedMultiplier),
    );
    await _dao.set(AnimationSettingsKeys.speedMultiplier, clampedMultiplier.toString());
  }

  /// Gets the effective duration for an animation, respecting mode and platform settings.
  ///
  /// Use this to calculate actual animation durations at runtime.
  Duration getEffectiveDuration(Duration baseDuration, {required bool platformReduceMotion}) {
    return state.preferences.getEffectiveDuration(
      baseDuration,
      platformReduceMotion: platformReduceMotion,
    );
  }

  /// Resolves the effective animation mode considering platform accessibility.
  AnimationMode resolveMode({required bool platformReduceMotion}) {
    return state.preferences.resolveMode(platformReduceMotion: platformReduceMotion);
  }

  /// Whether animations should be completely disabled.
  bool shouldDisableAnimations({required bool platformReduceMotion}) {
    return state.preferences.shouldDisableAnimations(platformReduceMotion: platformReduceMotion);
  }

  /// Resets all animation preferences to defaults.
  Future<void> resetToDefaults() async {
    state = const AnimationState(preferences: AnimationPreferences.defaults, isLoading: false);
    await _dao.clearAll();
  }

  /// Parses an animation mode from its string representation.
  AnimationMode? _parseAnimationMode(String? value) {
    if (value == null) return null;
    return AnimationMode.values.where((m) => m.name == value).firstOrNull;
  }

  /// Parses a speed multiplier from its string representation.
  double? _parseSpeedMultiplier(String? value) {
    if (value == null) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    return parsed.clamp(
      AnimationPreferences.minSpeedMultiplier,
      AnimationPreferences.maxSpeedMultiplier,
    );
  }
}
