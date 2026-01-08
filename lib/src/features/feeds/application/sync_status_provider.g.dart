// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hasPendingSync)
final hasPendingSyncProvider = HasPendingSyncProvider._();

final class HasPendingSyncProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  HasPendingSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasPendingSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasPendingSyncHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return hasPendingSync(ref);
  }
}

String _$hasPendingSyncHash() => r'24d7f04743e85d3d36ec4107179db9937abd89af';
