// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the animation preferences DAO.

@ProviderFor(animationPreferencesDao)
final animationPreferencesDaoProvider = AnimationPreferencesDaoProvider._();

/// Provides the animation preferences DAO.

final class AnimationPreferencesDaoProvider
    extends
        $FunctionalProvider<
          AnimationPreferencesDao,
          AnimationPreferencesDao,
          AnimationPreferencesDao
        >
    with $Provider<AnimationPreferencesDao> {
  /// Provides the animation preferences DAO.
  AnimationPreferencesDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animationPreferencesDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animationPreferencesDaoHash();

  @$internal
  @override
  $ProviderElement<AnimationPreferencesDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimationPreferencesDao create(Ref ref) {
    return animationPreferencesDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimationPreferencesDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimationPreferencesDao>(value),
    );
  }
}

String _$animationPreferencesDaoHash() => r'94280f75d87cba2e446d24705b57bbc5e405345a';

/// Controls app animations with mode and speed settings.
///
/// Features:
/// - Animation mode (full/reduced/minimal/system)
/// - Speed multiplier (0.5x to 2.0x)
/// - Platform accessibility integration (respects reduce motion)
/// - Persisted settings via Drift

@ProviderFor(AnimationController)
final animationControllerProvider = AnimationControllerProvider._();

/// Controls app animations with mode and speed settings.
///
/// Features:
/// - Animation mode (full/reduced/minimal/system)
/// - Speed multiplier (0.5x to 2.0x)
/// - Platform accessibility integration (respects reduce motion)
/// - Persisted settings via Drift
final class AnimationControllerProvider
    extends $NotifierProvider<AnimationController, AnimationState> {
  /// Controls app animations with mode and speed settings.
  ///
  /// Features:
  /// - Animation mode (full/reduced/minimal/system)
  /// - Speed multiplier (0.5x to 2.0x)
  /// - Platform accessibility integration (respects reduce motion)
  /// - Persisted settings via Drift
  AnimationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animationControllerHash();

  @$internal
  @override
  AnimationController create() => AnimationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimationState>(value),
    );
  }
}

String _$animationControllerHash() => r'4e6a5bbd4e204a22d012ae871bb2c611ec011e6d';

/// Controls app animations with mode and speed settings.
///
/// Features:
/// - Animation mode (full/reduced/minimal/system)
/// - Speed multiplier (0.5x to 2.0x)
/// - Platform accessibility integration (respects reduce motion)
/// - Persisted settings via Drift

abstract class _$AnimationController extends $Notifier<AnimationState> {
  AnimationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AnimationState, AnimationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnimationState, AnimationState>,
              AnimationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
