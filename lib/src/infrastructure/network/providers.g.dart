// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides public Dio client for unauthenticated API access.
///
/// This client is configured for public AppView at public.api.bsky.app.

@ProviderFor(dioPublic)
final dioPublicProvider = DioPublicProvider._();

/// Provides public Dio client for unauthenticated API access.
///
/// This client is configured for public AppView at public.api.bsky.app.

final class DioPublicProvider extends $FunctionalProvider<Dio, Dio, Dio> with $Provider<Dio> {
  /// Provides public Dio client for unauthenticated API access.
  ///
  /// This client is configured for public AppView at public.api.bsky.app.
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
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioPublic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Dio>(value));
  }
}

String _$dioPublicHash() => r'8cd2cec19a9467acff85cb22fdeacd0901083983';

/// Provides PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.

@ProviderFor(dioPds)
final dioPdsProvider = DioPdsProvider._();

/// Provides PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.

final class DioPdsProvider extends $FunctionalProvider<Dio?, Dio?, Dio?> with $Provider<Dio?> {
  /// Provides PDS Dio client for authenticated API access.
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
  $ProviderElement<Dio?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Dio? create(Ref ref) {
    return dioPds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Dio?>(value));
  }
}

String _$dioPdsHash() => r'2b6f8e6923ea0958923eafb15abf32396c36700d';

/// Provides video service Dio client for uploads.
///
/// This client uses service auth tokens instead of session tokens.

@ProviderFor(dioVideoService)
final dioVideoServiceProvider = DioVideoServiceProvider._();

/// Provides video service Dio client for uploads.
///
/// This client uses service auth tokens instead of session tokens.

final class DioVideoServiceProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides video service Dio client for uploads.
  ///
  /// This client uses service auth tokens instead of session tokens.
  DioVideoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioVideoServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioVideoServiceHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioVideoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Dio>(value));
  }
}

String _$dioVideoServiceHash() => r'35fad9f27769840636716b14bdb28c3b43634b52';

/// Provides Tenor API Dio client for GIF search.
///
/// This client is used for GIF search and selection from Tenor.

@ProviderFor(dioTenor)
final dioTenorProvider = DioTenorProvider._();

/// Provides Tenor API Dio client for GIF search.
///
/// This client is used for GIF search and selection from Tenor.

final class DioTenorProvider extends $FunctionalProvider<Dio, Dio, Dio> with $Provider<Dio> {
  /// Provides Tenor API Dio client for GIF search.
  ///
  /// This client is used for GIF search and selection from Tenor.
  DioTenorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioTenorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioTenorHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioTenor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Dio>(value));
  }
}

String _$dioTenorHash() => r'a2e99a8a8c47829fb3aefdc8d7cdc098ead2c517';

/// Provides XRPC client for making API requests.
///
/// This client automatically routes requests to correct host
/// based on endpoint metadata in the registry.

@ProviderFor(xrpcClient)
final xrpcClientProvider = XrpcClientProvider._();

/// Provides XRPC client for making API requests.
///
/// This client automatically routes requests to correct host
/// based on endpoint metadata in the registry.

final class XrpcClientProvider extends $FunctionalProvider<XrpcClient, XrpcClient, XrpcClient>
    with $Provider<XrpcClient> {
  /// Provides XRPC client for making API requests.
  ///
  /// This client automatically routes requests to correct host
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

String _$xrpcClientHash() => r'79a74523bf3f31a57602964b3989d6690bdd4903';
