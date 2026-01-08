// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'8c69eb46d45206533c176c88a926608e79ca927d';

/// Provides the app's [GoRouter] instance.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Provides the app's [GoRouter] instance.

final class GoRouterProvider extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the app's [GoRouter] instance.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GoRouter>(value));
  }
}

String _$goRouterHash() => r'0f11f06525444b252219f9683a0bddc514a3daa3';

/// Provides the local preferences repository for managing on-device settings.
///
/// This repository handles local app preferences that don't sync with Bluesky,
/// such as theme mode, font scale, and other UI preferences.

@ProviderFor(localPreferencesRepository)
final localPreferencesRepositoryProvider = LocalPreferencesRepositoryProvider._();

/// Provides the local preferences repository for managing on-device settings.
///
/// This repository handles local app preferences that don't sync with Bluesky,
/// such as theme mode, font scale, and other UI preferences.

final class LocalPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          LocalPreferencesRepository,
          LocalPreferencesRepository,
          LocalPreferencesRepository
        >
    with $Provider<LocalPreferencesRepository> {
  /// Provides the local preferences repository for managing on-device settings.
  ///
  /// This repository handles local app preferences that don't sync with Bluesky,
  /// such as theme mode, font scale, and other UI preferences.
  LocalPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalPreferencesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalPreferencesRepository create(Ref ref) {
    return localPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalPreferencesRepository>(value),
    );
  }
}

String _$localPreferencesRepositoryHash() => r'22a9fb73d3a0501795ddaf0165efa12512fac8a7';

/// Provides the custom theme repository for managing user-created themes.

@ProviderFor(customThemeRepository)
final customThemeRepositoryProvider = CustomThemeRepositoryProvider._();

/// Provides the custom theme repository for managing user-created themes.

final class CustomThemeRepositoryProvider
    extends
        $FunctionalProvider<CustomThemeRepository, CustomThemeRepository, CustomThemeRepository>
    with $Provider<CustomThemeRepository> {
  /// Provides the custom theme repository for managing user-created themes.
  CustomThemeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customThemeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customThemeRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomThemeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomThemeRepository create(Ref ref) {
    return customThemeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomThemeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomThemeRepository>(value),
    );
  }
}

String _$customThemeRepositoryHash() => r'8bb2ee308687db010816d8d0bb41425da0d2c416';
