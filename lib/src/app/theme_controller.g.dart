// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the list of available theme packs.

@ProviderFor(availableThemePacks)
final availableThemePacksProvider = AvailableThemePacksProvider._();

/// Provides the list of available theme packs.

final class AvailableThemePacksProvider
    extends $FunctionalProvider<List<ThemePack>, List<ThemePack>, List<ThemePack>>
    with $Provider<List<ThemePack>> {
  /// Provides the list of available theme packs.
  AvailableThemePacksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableThemePacksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableThemePacksHash();

  @$internal
  @override
  $ProviderElement<List<ThemePack>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ThemePack> create(Ref ref) {
    return availableThemePacks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ThemePack> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ThemePack>>(value),
    );
  }
}

String _$availableThemePacksHash() => r'b9d693e0186fc9513e549dcc48aaafecbbf42099';

/// Provides access to the LocalSettingsDao.

@ProviderFor(localSettingsDao)
final localSettingsDaoProvider = LocalSettingsDaoProvider._();

/// Provides access to the LocalSettingsDao.

final class LocalSettingsDaoProvider
    extends $FunctionalProvider<LocalSettingsDao, LocalSettingsDao, LocalSettingsDao>
    with $Provider<LocalSettingsDao> {
  /// Provides access to the LocalSettingsDao.
  LocalSettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localSettingsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localSettingsDaoHash();

  @$internal
  @override
  $ProviderElement<LocalSettingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalSettingsDao create(Ref ref) {
    return localSettingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalSettingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalSettingsDao>(value),
    );
  }
}

String _$localSettingsDaoHash() => r'69d5af5ab1824d3055273a5b43dbc9561295992b';

/// Controls the app theme with pack selection and persistence.

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// Controls the app theme with pack selection and persistence.
final class ThemeControllerProvider extends $NotifierProvider<ThemeController, ThemeState> {
  /// Controls the app theme with pack selection and persistence.
  ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeState>(value),
    );
  }
}

String _$themeControllerHash() => r'7d678caa471ef68ad4b065d0046df8bcafec6c74';

/// Controls the app theme with pack selection and persistence.

abstract class _$ThemeController extends $Notifier<ThemeState> {
  ThemeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeState, ThemeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeState, ThemeState>,
              ThemeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
