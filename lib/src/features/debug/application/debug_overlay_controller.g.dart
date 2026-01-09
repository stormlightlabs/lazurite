// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_overlay_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for the debug overlay visibility and tab state.
///
/// Manages overlay visibility, active tab selection, and provides methods
/// to show, hide, and toggle the overlay.

@ProviderFor(DebugOverlayController)
final debugOverlayControllerProvider = DebugOverlayControllerProvider._();

/// Controller for the debug overlay visibility and tab state.
///
/// Manages overlay visibility, active tab selection, and provides methods
/// to show, hide, and toggle the overlay.
final class DebugOverlayControllerProvider
    extends $NotifierProvider<DebugOverlayController, DebugOverlayState> {
  /// Controller for the debug overlay visibility and tab state.
  ///
  /// Manages overlay visibility, active tab selection, and provides methods
  /// to show, hide, and toggle the overlay.
  DebugOverlayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugOverlayControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugOverlayControllerHash();

  @$internal
  @override
  DebugOverlayController create() => DebugOverlayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebugOverlayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebugOverlayState>(value),
    );
  }
}

String _$debugOverlayControllerHash() => r'66cd0c33481c75c17ba9a15d9d09340233e8e4f7';

/// Controller for the debug overlay visibility and tab state.
///
/// Manages overlay visibility, active tab selection, and provides methods
/// to show, hide, and toggle the overlay.

abstract class _$DebugOverlayController extends $Notifier<DebugOverlayState> {
  DebugOverlayState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DebugOverlayState, DebugOverlayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DebugOverlayState, DebugOverlayState>,
              DebugOverlayState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
