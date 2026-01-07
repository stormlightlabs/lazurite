import 'package:flutter/material.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_factory.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// Keys for persisted theme settings.
abstract final class ThemeSettingsKeys {
  static const themeMode = 'themeMode';
  static const themePackId = 'themePackId';
}

/// State for the theme controller.
class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.currentPackId,
    required this.lightTheme,
    required this.darkTheme,
  });

  /// The current theme mode (light, dark, system).
  final ThemeMode themeMode;

  /// The ID of the currently selected theme pack.
  final String currentPackId;

  /// Pre-built light theme for the current pack.
  final ThemeData lightTheme;

  /// Pre-built dark theme for the current pack.
  final ThemeData darkTheme;

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? currentPackId,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      currentPackId: currentPackId ?? this.currentPackId,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
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

  @override
  ThemeState build() {
    _loadPersistedSettings();
    return _buildState(_defaultMode, _defaultPackId);
  }

  /// Loads persisted settings and updates state.
  Future<void> _loadPersistedSettings() async {
    final modeStr = await _dao.get(ThemeSettingsKeys.themeMode);
    final packId = await _dao.get(ThemeSettingsKeys.themePackId);

    final mode = _parseThemeMode(modeStr) ?? _defaultMode;
    final resolvedPackId = _resolvePackId(packId);

    state = _buildState(mode, resolvedPackId);
  }

  /// Sets the theme mode and persists to database.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _dao.set(ThemeSettingsKeys.themeMode, mode.name);
  }

  /// Sets the theme pack by ID and persists to database.
  Future<void> setThemePack(String packId) async {
    final resolvedPackId = _resolvePackId(packId);
    if (resolvedPackId == state.currentPackId) return;

    state = _buildState(state.themeMode, resolvedPackId);
    await _dao.set(ThemeSettingsKeys.themePackId, resolvedPackId);
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
