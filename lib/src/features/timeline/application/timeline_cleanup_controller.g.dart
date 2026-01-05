// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_cleanup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages cache cleanup for timeline items.
///
/// Listens to app lifecycle changes and triggers [TimelineRepository.cleanupCache]
/// when the app is resumed or on startup.

@ProviderFor(timelineCleanupController)
final timelineCleanupControllerProvider = TimelineCleanupControllerProvider._();

/// Controller that manages cache cleanup for timeline items.
///
/// Listens to app lifecycle changes and triggers [TimelineRepository.cleanupCache]
/// when the app is resumed or on startup.

final class TimelineCleanupControllerProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Controller that manages cache cleanup for timeline items.
  ///
  /// Listens to app lifecycle changes and triggers [TimelineRepository.cleanupCache]
  /// when the app is resumed or on startup.
  TimelineCleanupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineCleanupControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineCleanupControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return timelineCleanupController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$timelineCleanupControllerHash() =>
    r'667638f13eba96955f77f35b50bcc619ef50f8d5';
