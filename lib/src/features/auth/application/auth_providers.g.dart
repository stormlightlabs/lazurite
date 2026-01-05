// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'a4f75721472cf77465bf47f759c90de5ca30856e';

@ProviderFor(sessionStorage)
final sessionStorageProvider = SessionStorageProvider._();

final class SessionStorageProvider
    extends $FunctionalProvider<SessionStorage, SessionStorage, SessionStorage>
    with $Provider<SessionStorage> {
  SessionStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStorageHash();

  @$internal
  @override
  $ProviderElement<SessionStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionStorage create(Ref ref) {
    return sessionStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStorage>(value),
    );
  }
}

String _$sessionStorageHash() => r'7f22871707fb4b3eea41742c80279e67b673f580';

@ProviderFor(authSupportDio)
final authSupportDioProvider = AuthSupportDioProvider._();

final class AuthSupportDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  AuthSupportDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSupportDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSupportDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return authSupportDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$authSupportDioHash() => r'cd2e5e87f63e34ee08ada5ab37908f10357a4d50';

@ProviderFor(identityRepository)
final identityRepositoryProvider = IdentityRepositoryProvider._();

final class IdentityRepositoryProvider
    extends
        $FunctionalProvider<
          IdentityRepository,
          IdentityRepository,
          IdentityRepository
        >
    with $Provider<IdentityRepository> {
  IdentityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityRepositoryHash();

  @$internal
  @override
  $ProviderElement<IdentityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IdentityRepository create(Ref ref) {
    return identityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityRepository>(value),
    );
  }
}

String _$identityRepositoryHash() =>
    r'610d18b70c1662d3db4749898e54094197d4fa45';

@ProviderFor(dpopNonceStore)
final dpopNonceStoreProvider = DpopNonceStoreProvider._();

final class DpopNonceStoreProvider
    extends $FunctionalProvider<DPoPNonceStore, DPoPNonceStore, DPoPNonceStore>
    with $Provider<DPoPNonceStore> {
  DpopNonceStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dpopNonceStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dpopNonceStoreHash();

  @$internal
  @override
  $ProviderElement<DPoPNonceStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DPoPNonceStore create(Ref ref) {
    return dpopNonceStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DPoPNonceStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DPoPNonceStore>(value),
    );
  }
}

String _$dpopNonceStoreHash() => r'41637ad5cd21210697f095006b0dd4bb0c0daef6';

@ProviderFor(oauthClient)
final oauthClientProvider = OauthClientProvider._();

final class OauthClientProvider
    extends $FunctionalProvider<OAuthClient, OAuthClient, OAuthClient>
    with $Provider<OAuthClient> {
  OauthClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oauthClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oauthClientHash();

  @$internal
  @override
  $ProviderElement<OAuthClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OAuthClient create(Ref ref) {
    return oauthClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OAuthClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OAuthClient>(value),
    );
  }
}

String _$oauthClientHash() => r'0b88d7a031ca6aa7d539603ef166c38d3a1137b3';

@ProviderFor(serverMetadataRepository)
final serverMetadataRepositoryProvider = ServerMetadataRepositoryProvider._();

final class ServerMetadataRepositoryProvider
    extends
        $FunctionalProvider<
          ServerMetadataRepository,
          ServerMetadataRepository,
          ServerMetadataRepository
        >
    with $Provider<ServerMetadataRepository> {
  ServerMetadataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverMetadataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverMetadataRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServerMetadataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerMetadataRepository create(Ref ref) {
    return serverMetadataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerMetadataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerMetadataRepository>(value),
    );
  }
}

String _$serverMetadataRepositoryHash() =>
    r'68adaa79c66df4c1af4e5097063f05542deb2675';

@ProviderFor(oauthBrowserCallback)
final oauthBrowserCallbackProvider = OauthBrowserCallbackProvider._();

final class OauthBrowserCallbackProvider
    extends
        $FunctionalProvider<
          OAuthBrowserCallback?,
          OAuthBrowserCallback?,
          OAuthBrowserCallback?
        >
    with $Provider<OAuthBrowserCallback?> {
  OauthBrowserCallbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oauthBrowserCallbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oauthBrowserCallbackHash();

  @$internal
  @override
  $ProviderElement<OAuthBrowserCallback?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OAuthBrowserCallback? create(Ref ref) {
    return oauthBrowserCallback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OAuthBrowserCallback? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OAuthBrowserCallback?>(value),
    );
  }
}

String _$oauthBrowserCallbackHash() =>
    r'a9d0a5ea8491f7c13cc261728398c9c3bf7080c1';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'b1e8bc3a4d29b9c77445091055bc4c5f2e73069f';

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'dbda52499efed00533eed6dd50ab9cc8f143892b';

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
