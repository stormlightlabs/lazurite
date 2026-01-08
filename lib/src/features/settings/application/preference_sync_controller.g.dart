// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages automatic background synchronization of Bluesky preferences.
///
/// Listens to app lifecycle changes and triggers preference sync when the app is resumed
/// or when the user logs in. Also processes the preference sync queue to retry failed updates.

@ProviderFor(preferenceSyncController)
final preferenceSyncControllerProvider = PreferenceSyncControllerProvider._();

/// Controller that manages automatic background synchronization of Bluesky preferences.
///
/// Listens to app lifecycle changes and triggers preference sync when the app is resumed
/// or when the user logs in. Also processes the preference sync queue to retry failed updates.

final class PreferenceSyncControllerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Controller that manages automatic background synchronization of Bluesky preferences.
  ///
  /// Listens to app lifecycle changes and triggers preference sync when the app is resumed
  /// or when the user logs in. Also processes the preference sync queue to retry failed updates.
  PreferenceSyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceSyncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferenceSyncControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return preferenceSyncController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$preferenceSyncControllerHash() => r'305b3f9687000b6b52bcb4da4ea77629f45d66bb';
