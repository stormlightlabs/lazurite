// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages automatic background synchronization of feeds.
///
/// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume] when the
/// app is resumed.

@ProviderFor(feedSyncController)
final feedSyncControllerProvider = FeedSyncControllerProvider._();

/// Controller that manages automatic background synchronization of feeds.
///
/// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume] when the
/// app is resumed.

final class FeedSyncControllerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Controller that manages automatic background synchronization of feeds.
  ///
  /// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume] when the
  /// app is resumed.
  FeedSyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedSyncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedSyncControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return feedSyncController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$feedSyncControllerHash() => r'a6ef5c6d7e5ee562e735cf8ba62d237f824e93e4';
