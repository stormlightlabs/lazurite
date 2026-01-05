// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the public Dio client for unauthenticated API access.
///
/// This client is configured for the public AppView at public.api.bsky.app.

@ProviderFor(dioPublic)
final dioPublicProvider = DioPublicProvider._();

/// Provides the public Dio client for unauthenticated API access.
///
/// This client is configured for the public AppView at public.api.bsky.app.

final class DioPublicProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides the public Dio client for unauthenticated API access.
  ///
  /// This client is configured for the public AppView at public.api.bsky.app.
  DioPublicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioPublicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioPublicHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioPublic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioPublicHash() => r'b7ad12dfcf7bebb3ca8f836e21c9c41e9a698edc';

/// Provides the PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.

@ProviderFor(dioPds)
final dioPdsProvider = DioPdsProvider._();

/// Provides the PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.

final class DioPdsProvider extends $FunctionalProvider<Dio?, Dio?, Dio?>
    with $Provider<Dio?> {
  /// Provides the PDS Dio client for authenticated API access.
  ///
  /// This requires a logged-in user with a resolved PDS URL.
  /// Returns null if no user is logged in.
  DioPdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioPdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioPdsHash();

  @$internal
  @override
  $ProviderElement<Dio?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio? create(Ref ref) {
    return dioPds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio?>(value),
    );
  }
}

String _$dioPdsHash() => r'd1e9b53f22f3cdf12fa0cafcbc26908b1f10b36d';

/// Provides the XRPC client for making API requests.
///
/// This client automatically routes requests to the correct host
/// based on endpoint metadata in the registry.

@ProviderFor(xrpcClient)
final xrpcClientProvider = XrpcClientProvider._();

/// Provides the XRPC client for making API requests.
///
/// This client automatically routes requests to the correct host
/// based on endpoint metadata in the registry.

final class XrpcClientProvider
    extends $FunctionalProvider<XrpcClient, XrpcClient, XrpcClient>
    with $Provider<XrpcClient> {
  /// Provides the XRPC client for making API requests.
  ///
  /// This client automatically routes requests to the correct host
  /// based on endpoint metadata in the registry.
  XrpcClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xrpcClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xrpcClientHash();

  @$internal
  @override
  $ProviderElement<XrpcClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  XrpcClient create(Ref ref) {
    return xrpcClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XrpcClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XrpcClient>(value),
    );
  }
}

String _$xrpcClientHash() => r'4ec8f0d6844e8e90a91e296d11890622c40dfc2a';
