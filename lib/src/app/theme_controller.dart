import 'package:flutter/material.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theming/color_scheme_derivation.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_factory.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';
import 'package:lazurite/src/infrastructure/theming/custom_theme_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// Keys for persisted theme settings.
abstract final class ThemeSettingsKeys {
  static const themeMode = 'themeMode';
  static const themePackId = 'themePackId';
  static const customThemeId = 'customThemeId';
}

/// State for the theme controller.
class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.currentPackId,
    required this.lightTheme,
    required this.darkTheme,
    this.customThemeId,
  });

  /// The current theme mode (light, dark, system).
  final ThemeMode themeMode;

  /// The ID of the currently selected theme pack.
  final String currentPackId;

  /// Pre-built light theme for the current pack.
  final ThemeData lightTheme;

  /// Pre-built dark theme for the current pack.
  final ThemeData darkTheme;

  /// ID of the active custom theme, if any.
  final String? customThemeId;

  /// Whether a custom theme is currently active.
  bool get isUsingCustomTheme => customThemeId != null;

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? currentPackId,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    String? customThemeId,
    bool clearCustomTheme = false,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      currentPackId: currentPackId ?? this.currentPackId,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      customThemeId: clearCustomTheme ? null : (customThemeId ?? this.customThemeId),
    );
  }
}

/// Provides the list of available theme packs.
@Riverpod(keepAlive: true)
List<ThemePack> availableThemePacks(Ref ref) => [oxocarbonPack];

/// Provides access to the LocalSettingsDao.
@Riverpod(keepAlive: true)
LocalSettingsDao localSettingsDao(Ref ref) {
  return ref.watch(appDatabaseProvider).localSettingsDao;
}

/// Controls the app theme with pack selection and persistence.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const _defaultPackId = 'oxocarbon';
  static const _defaultMode = ThemeMode.dark;

  LocalSettingsDao get _dao => ref.read(localSettingsDaoProvider);
  List<ThemePack> get _packs => ref.read(availableThemePacksProvider);
  CustomThemeRepository get _customThemeRepo => ref.read(customThemeRepositoryProvider);

  @override
  ThemeState build() {
    _loadPersistedSettings();
    return _buildState(_defaultMode, _defaultPackId);
  }

  /// Loads persisted settings and updates state.
  Future<void> _loadPersistedSettings() async {
    final modeStr = await _dao.get(ThemeSettingsKeys.themeMode);
    final packId = await _dao.get(ThemeSettingsKeys.themePackId);
    final customThemeId = await _dao.get(ThemeSettingsKeys.customThemeId);

    final mode = _parseThemeMode(modeStr) ?? _defaultMode;
    final resolvedPackId = _resolvePackId(packId);

    if (customThemeId != null) {
      final customTheme = await _customThemeRepo.getById(customThemeId);
      if (customTheme != null) {
        state = _buildStateWithCustomTheme(mode, customTheme);
        return;
      }
    }

    state = _buildState(mode, resolvedPackId);
  }

  /// Sets the theme mode and persists to database.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _dao.set(ThemeSettingsKeys.themeMode, mode.name);
  }

  /// Sets the theme pack by ID and persists to database.
  ///
  /// This also clears any active custom theme.
  Future<void> setThemePack(String packId) async {
    final resolvedPackId = _resolvePackId(packId);
    if (resolvedPackId == state.currentPackId && !state.isUsingCustomTheme) return;

    state = _buildState(state.themeMode, resolvedPackId);
    await _dao.set(ThemeSettingsKeys.themePackId, resolvedPackId);
    await _dao.remove(ThemeSettingsKeys.customThemeId);
  }

  /// Sets a custom theme as active.
  ///
  /// The custom theme's overrides are applied to its base pack.
  Future<void> setCustomTheme(String customThemeId) async {
    final customTheme = await _customThemeRepo.getById(customThemeId);
    if (customTheme == null) return;

    state = _buildStateWithCustomTheme(state.themeMode, customTheme);
    await _dao.set(ThemeSettingsKeys.themePackId, customTheme.basePackId);
    await _dao.set(ThemeSettingsKeys.customThemeId, customThemeId);
  }

  /// Clears the active custom theme, reverting to the base pack.
  Future<void> clearCustomTheme() async {
    if (!state.isUsingCustomTheme) return;

    state = _buildState(state.themeMode, state.currentPackId);
    await _dao.remove(ThemeSettingsKeys.customThemeId);
  }

  /// Toggles between light and dark modes (ignores system).
  void toggle() {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  /// Builds theme state from mode and pack ID.
  ThemeState _buildState(ThemeMode mode, String packId) {
    final pack = _getPackById(packId);
    final lightVariant = pack.lightVariant;
    final darkVariant = pack.darkVariant;

    return ThemeState(
      themeMode: mode,
      currentPackId: packId,
      lightTheme: lightVariant != null
          ? ThemeFactory.buildThemeData(lightVariant)
          : ThemeFactory.buildThemeData(oxocarbonLightVariant),
      darkTheme: darkVariant != null
          ? ThemeFactory.buildThemeData(darkVariant)
          : ThemeFactory.buildThemeData(oxocarbonDarkVariant),
    );
  }

  /// Builds theme state with custom theme overrides applied.
  ThemeState _buildStateWithCustomTheme(ThemeMode mode, CustomThemeDraft customTheme) {
    final basePack = _getPackById(customTheme.basePackId);
    final lightVariant = _applyOverridesToVariant(basePack.lightVariant, customTheme.overrides);
    final darkVariant = _applyOverridesToVariant(basePack.darkVariant, customTheme.overrides);

    return ThemeState(
      themeMode: mode,
      currentPackId: customTheme.basePackId,
      customThemeId: customTheme.id,
      lightTheme: lightVariant != null
          ? ThemeFactory.buildThemeData(lightVariant)
          : ThemeFactory.buildThemeData(oxocarbonLightVariant),
      darkTheme: darkVariant != null
          ? ThemeFactory.buildThemeData(darkVariant)
          : ThemeFactory.buildThemeData(oxocarbonDarkVariant),
    );
  }

  /// Applies overrides to a theme variant, creating a new variant.
  ThemeVariant? _applyOverridesToVariant(ThemeVariant? variant, ThemeRoleOverrides overrides) {
    if (variant == null) return null;
    if (!overrides.hasOverrides) return variant;

    final modifiedSpec = variant.spec.copyWith(
      primary: overrides.primary,
      secondary: overrides.secondary,
      tertiary: overrides.tertiary,
      surface: overrides.surface,
      surfaceContainerLow: overrides.surfaceContainerLow,
      surfaceContainerHigh: overrides.surfaceContainerHigh,
      outlineVariant: overrides.outlineVariant,
    );

    return ThemeVariant(
      id: '${variant.id}-custom',
      name: variant.name,
      brightness: variant.brightness,
      spec: modifiedSpec,
      derivedScheme: deriveColorScheme(modifiedSpec, variant.brightness),
    );
  }

  /// Resolves pack ID to an existing pack, falling back to default.
  String _resolvePackId(String? packId) {
    if (packId == null) return _defaultPackId;
    final pack = _packs.where((p) => p.id == packId).firstOrNull;
    return pack?.id ?? _defaultPackId;
  }

  /// Gets a pack by ID, falling back to oxocarbon.
  ThemePack _getPackById(String packId) {
    return _packs.where((p) => p.id == packId).firstOrNull ?? oxocarbonPack;
  }

  /// Parses a theme mode string.
  ThemeMode? _parseThemeMode(String? value) {
    if (value == null) return null;
    return ThemeMode.values.where((m) => m.name == value).firstOrNull;
  }
}
