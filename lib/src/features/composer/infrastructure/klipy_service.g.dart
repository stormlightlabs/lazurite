// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'klipy_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for interacting with Klipy API.
///
/// Provides methods for searching GIFs and getting trending GIFs.
/// The API key should be configured securely via environment variables.
/// Obtain your API key from https://partner.klipy.com

@ProviderFor(klipyService)
final klipyServiceProvider = KlipyServiceProvider._();

/// Service for interacting with Klipy API.
///
/// Provides methods for searching GIFs and getting trending GIFs.
/// The API key should be configured securely via environment variables.
/// Obtain your API key from https://partner.klipy.com

final class KlipyServiceProvider
    extends $FunctionalProvider<KlipyService, KlipyService, KlipyService>
    with $Provider<KlipyService> {
  /// Service for interacting with Klipy API.
  ///
  /// Provides methods for searching GIFs and getting trending GIFs.
  /// The API key should be configured securely via environment variables.
  /// Obtain your API key from https://partner.klipy.com
  KlipyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'klipyServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$klipyServiceHash();

  @$internal
  @override
  $ProviderElement<KlipyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KlipyService create(Ref ref) {
    return klipyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KlipyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KlipyService>(value),
    );
  }
}

String _$klipyServiceHash() => r'b1b2821189fcb6c0381d1bad49150cb20bb6d049';
