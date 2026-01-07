// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences instance.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences instance.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with $FutureModifier<SharedPreferences>, $FutureProvider<SharedPreferences> {
  /// Provider for SharedPreferences instance.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

/// Provider for HandleStorage.

@ProviderFor(handleStorage)
final handleStorageProvider = HandleStorageProvider._();

/// Provider for HandleStorage.

final class HandleStorageProvider
    extends $FunctionalProvider<AsyncValue<HandleStorage>, HandleStorage, FutureOr<HandleStorage>>
    with $FutureModifier<HandleStorage>, $FutureProvider<HandleStorage> {
  /// Provider for HandleStorage.
  HandleStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'handleStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$handleStorageHash();

  @$internal
  @override
  $FutureProviderElement<HandleStorage> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HandleStorage> create(Ref ref) {
    return handleStorage(ref);
  }
}

String _$handleStorageHash() => r'219103f0d7a338e44fd993c11f18e11d2434979f';
