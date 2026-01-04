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
    r'38ca9e5b495eecbd5c25af2f3968a92b89f90c30';

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

String _$oauthClientHash() => r'5c4f5fd51c2d9f1936f004fba9dc1fa4b362e6ec';

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

String _$authRepositoryHash() => r'222b481dbbb37e89b231cb9dca97c4bca6aee1cf';

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

String _$authNotifierHash() => r'7c43fda3297d4acf5c2be74c05487b5c4ca03833';

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
