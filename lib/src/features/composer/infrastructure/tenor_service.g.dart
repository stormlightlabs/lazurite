// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenor_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for interacting with Tenor API.
///
/// Provides methods for searching GIFs and getting featured/trending GIFs.
/// The API key should be configured securely via environment variables.

@ProviderFor(tenorService)
final tenorServiceProvider = TenorServiceProvider._();

/// Service for interacting with Tenor API.
///
/// Provides methods for searching GIFs and getting featured/trending GIFs.
/// The API key should be configured securely via environment variables.

final class TenorServiceProvider
    extends $FunctionalProvider<TenorService, TenorService, TenorService>
    with $Provider<TenorService> {
  /// Service for interacting with Tenor API.
  ///
  /// Provides methods for searching GIFs and getting featured/trending GIFs.
  /// The API key should be configured securely via environment variables.
  TenorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenorServiceHash();

  @$internal
  @override
  $ProviderElement<TenorService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TenorService create(Ref ref) {
    return tenorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TenorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TenorService>(value),
    );
  }
}

String _$tenorServiceHash() => r'4296b779d4b198c7cc9b1555f00a91309d4ac8af';
