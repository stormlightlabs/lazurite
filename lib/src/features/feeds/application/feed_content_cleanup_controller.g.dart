// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_content_cleanup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages cache cleanup for feed content items.
///
/// Listens to app lifecycle changes and triggers [FeedContentRepository.cleanupCache]
/// when the app is resumed or on startup.

@ProviderFor(feedContentCleanupController)
final feedContentCleanupControllerProvider = FeedContentCleanupControllerProvider._();

/// Controller that manages cache cleanup for feed content items.
///
/// Listens to app lifecycle changes and triggers [FeedContentRepository.cleanupCache]
/// when the app is resumed or on startup.

final class FeedContentCleanupControllerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Controller that manages cache cleanup for feed content items.
  ///
  /// Listens to app lifecycle changes and triggers [FeedContentRepository.cleanupCache]
  /// when the app is resumed or on startup.
  FeedContentCleanupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedContentCleanupControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedContentCleanupControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return feedContentCleanupController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$feedContentCleanupControllerHash() => r'721c568678ab6838264702798fcb43a441122d06';
