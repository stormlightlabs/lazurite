// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dmsRepository)
final dmsRepositoryProvider = DmsRepositoryProvider._();

final class DmsRepositoryProvider
    extends $FunctionalProvider<DmsRepository, DmsRepository, DmsRepository>
    with $Provider<DmsRepository> {
  DmsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dmsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dmsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DmsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DmsRepository create(Ref ref) {
    return dmsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DmsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DmsRepository>(value),
    );
  }
}

String _$dmsRepositoryHash() => r'c7fa4bcb331b61a2222d11eaca09cbceec05b7b8';

@ProviderFor(outboxRepository)
final outboxRepositoryProvider = OutboxRepositoryProvider._();

final class OutboxRepositoryProvider
    extends $FunctionalProvider<OutboxRepository, OutboxRepository, OutboxRepository>
    with $Provider<OutboxRepository> {
  OutboxRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxRepositoryHash();

  @$internal
  @override
  $ProviderElement<OutboxRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxRepository create(Ref ref) {
    return outboxRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxRepository>(value),
    );
  }
}

String _$outboxRepositoryHash() => r'49973f0d95b8739001506afcede74bc7eb1ba8e8';
