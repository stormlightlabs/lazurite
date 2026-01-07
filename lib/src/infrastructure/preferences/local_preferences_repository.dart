import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../db/daos/local_settings_dao.dart';

/// Setting keys for local preferences stored in the key-value store.
abstract final class LocalPreferenceKeys {
  /// Theme mode setting (light, dark, system).
  static const String themeMode = 'themeMode';

  /// Theme pack identifier (e.g., 'oxocarbon').
  static const String themePackId = 'themePackId';

  /// Font scale multiplier for accessibility.
  static const String fontScale = 'fontScale';
}

/// Repository for managing local app preferences stored on-device.
///
/// Provides typed access to the underlying key-value store for settings that
/// don't sync with Bluesky (theme, font scale, etc.). All settings are
/// persisted locally and survive app restarts.
///
/// This repository wraps [LocalSettingsDao] to provide type-safe getters and
/// setters for specific preference values.
class LocalPreferencesRepository {
  LocalPreferencesRepository(this._dao, this._logger);

  final LocalSettingsDao _dao;
  final Logger _logger;

  /// Retrieves the current theme mode setting.
  ///
  /// Returns the persisted theme mode, or [ThemeMode.dark] as default if not
  /// set. Valid values are 'light', 'dark', and 'system'.
  Future<ThemeMode> getThemeMode() async {
    _logger.debug('Getting theme mode');
    final value = await _dao.get(LocalPreferenceKeys.themeMode);
    return _parseThemeMode(value);
  }

  /// Watches the theme mode setting for changes.
  ///
  /// Returns a stream that emits whenever the theme mode is updated. The
  /// stream emits immediately with the current value.
  Stream<ThemeMode> watchThemeMode() {
    _logger.debug('Watching theme mode');
    return _dao.watch(LocalPreferenceKeys.themeMode).map(_parseThemeMode);
  }

  /// Updates the theme mode setting.
  ///
  /// Persists the new theme mode to local storage. Valid modes are light,
  /// dark, and system.
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = _serializeThemeMode(mode);
    _logger.info('Setting theme mode to $value');
    await _dao.set(LocalPreferenceKeys.themeMode, value);
  }

  /// Retrieves the current theme pack identifier.
  ///
  /// Returns the persisted theme pack ID, or 'oxocarbon' as default if not
  /// set.
  Future<String> getThemePackId() async {
    _logger.debug('Getting theme pack ID');
    final value = await _dao.get(LocalPreferenceKeys.themePackId);
    return value ?? 'oxocarbon';
  }

  /// Watches the theme pack identifier for changes.
  ///
  /// Returns a stream that emits whenever the theme pack is updated. The
  /// stream emits immediately with the current value.
  Stream<String> watchThemePackId() {
    _logger.debug('Watching theme pack ID');
    return _dao.watch(LocalPreferenceKeys.themePackId).map((value) => value ?? 'oxocarbon');
  }

  /// Updates the theme pack identifier.
  ///
  /// Persists the new theme pack ID to local storage. The caller is
  /// responsible for validating that the pack exists.
  Future<void> setThemePackId(String packId) async {
    _logger.info('Setting theme pack ID to $packId');
    await _dao.set(LocalPreferenceKeys.themePackId, packId);
  }

  /// Retrieves the current font scale multiplier.
  ///
  /// Returns the persisted font scale, or 1.0 as default if not set. Font
  /// scale affects text size throughout the app for accessibility.
  Future<double> getFontScale() async {
    _logger.debug('Getting font scale');
    final value = await _dao.get(LocalPreferenceKeys.fontScale);
    if (value == null) return 1.0;

    final scale = double.tryParse(value);
    if (scale == null) {
      _logger.warning('Invalid font scale value: $value, using default 1.0');
      return 1.0;
    }

    return scale;
  }

  /// Watches the font scale multiplier for changes.
  ///
  /// Returns a stream that emits whenever the font scale is updated. The
  /// stream emits immediately with the current value.
  Stream<double> watchFontScale() {
    _logger.debug('Watching font scale');
    return _dao.watch(LocalPreferenceKeys.fontScale).map((value) {
      if (value == null) return 1.0;
      final scale = double.tryParse(value);
      if (scale == null) {
        _logger.warning('Invalid font scale value: $value, using default 1.0');
        return 1.0;
      }
      return scale;
    });
  }

  /// Updates the font scale multiplier.
  ///
  /// Persists the new font scale to local storage. The scale should be a
  /// positive number, typically between 0.5 and 2.0.
  Future<void> setFontScale(double scale) async {
    _logger.info('Setting font scale to $scale');
    await _dao.set(LocalPreferenceKeys.fontScale, scale.toString());
  }

  /// Removes all local preferences.
  ///
  /// This is primarily useful for testing or resetting the app to defaults.
  /// Use with caution as this cannot be undone.
  Future<void> clearAll() async {
    _logger.warning('Clearing all local preferences');
    await _dao.remove(LocalPreferenceKeys.themeMode);
    await _dao.remove(LocalPreferenceKeys.themePackId);
    await _dao.remove(LocalPreferenceKeys.fontScale);
  }

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  String _serializeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
