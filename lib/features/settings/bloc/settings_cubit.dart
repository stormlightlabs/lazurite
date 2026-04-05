import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.database,
    AppThemePalette? initialPalette,
    AppThemeVariant? initialVariant,
    bool? initialUseSystemTheme,
    FeedLayout? initialFeedLayout,
    bool? initialSimulateOffline,
    int? initialThreadAutoCollapseDepth,
    String? initialConstellationUrl,
  }) : super(
         SettingsState(
           themePalette: initialPalette ?? AppThemePalette.oxocarbon,
           themeVariant: initialVariant ?? AppThemeVariant.dark,
           useSystemTheme: initialUseSystemTheme ?? false,
           feedLayout: initialFeedLayout ?? FeedLayout.card,
           simulateOffline: initialSimulateOffline ?? false,
           threadAutoCollapseDepth: initialThreadAutoCollapseDepth,
           constellationUrl: initialConstellationUrl ?? 'https://constellation.microcosm.blue',
         ),
       );

  final AppDatabase database;

  static const String _keyThemePalette = 'theme_palette';
  static const String _keyThemeVariant = 'theme_variant';
  static const String _keyUseSystemTheme = 'use_system_theme';
  static const String _keyFeedLayout = 'feed_layout';
  static const String _legacyKeyFeedArchitecture = 'feed_architecture';
  static const String _keySimulateOffline = 'simulate_offline';
  static const String _keyThreadAutoCollapseDepth = 'thread_auto_collapse_depth';
  static const String _keyConstellationUrl = 'constellation_url';
  static const String _defaultConstellationUrl = 'https://constellation.microcosm.blue';
  static const String _keyAdsRemoved = 'ads_removed';

  Future<void> loadSettings() async {
    final paletteStr = await database.getSetting(_keyThemePalette);
    final variantStr = await database.getSetting(_keyThemeVariant);
    final useSystemStr = await database.getSetting(_keyUseSystemTheme);
    final feedLayoutStr =
        await database.getSetting(_keyFeedLayout) ?? await database.getSetting(_legacyKeyFeedArchitecture);
    final simulateOfflineStr = await database.getSetting(_keySimulateOffline);
    final threadAutoCollapseDepthStr = await database.getSetting(_keyThreadAutoCollapseDepth);
    final constellationUrlStr = await database.getSetting(_keyConstellationUrl);
    final adsRemovedStr = await database.getSetting(_keyAdsRemoved);

    emit(
      state.copyWith(
        themePalette: AppTheme.parsePalette(paletteStr),
        themeVariant: AppTheme.parseVariant(variantStr),
        useSystemTheme: useSystemStr == 'true',
        feedLayout: FeedLayout.fromString(feedLayoutStr),
        simulateOffline: simulateOfflineStr == 'true',
        threadAutoCollapseDepth: int.tryParse(threadAutoCollapseDepthStr ?? ''),
        constellationUrl: constellationUrlStr ?? _defaultConstellationUrl,
        adsRemoved: adsRemovedStr == 'true',
      ),
    );
  }

  Future<void> setThemePalette(AppThemePalette palette) async {
    await database.setSetting(_keyThemePalette, AppTheme.paletteToString(palette));
    emit(state.copyWith(themePalette: palette));
  }

  Future<void> setThemeVariant(AppThemeVariant variant) async {
    await database.setSetting(_keyThemeVariant, AppTheme.variantToString(variant));
    emit(state.copyWith(themeVariant: variant));
  }

  Future<void> setTheme(AppThemePalette palette, AppThemeVariant variant) async {
    await database.setSetting(_keyThemePalette, AppTheme.paletteToString(palette));
    await database.setSetting(_keyThemeVariant, AppTheme.variantToString(variant));
    emit(state.copyWith(themePalette: palette, themeVariant: variant));
  }

  Future<void> setUseSystemTheme(bool value) async {
    await database.setSetting(_keyUseSystemTheme, value.toString());
    emit(state.copyWith(useSystemTheme: value));
  }

  Future<void> setFeedLayout(FeedLayout layout) async {
    await database.setSetting(_keyFeedLayout, layout.name);
    await database.deleteSetting(_legacyKeyFeedArchitecture);
    emit(state.copyWith(feedLayout: layout));
  }

  Future<void> setSimulateOffline(bool value) async {
    await database.setSetting(_keySimulateOffline, value.toString());
    emit(state.copyWith(simulateOffline: value));
  }

  Future<void> setThreadAutoCollapseDepth(int? depth) async {
    if (depth == null) {
      await database.deleteSetting(_keyThreadAutoCollapseDepth);
    } else {
      await database.setSetting(_keyThreadAutoCollapseDepth, depth.toString());
    }
    emit(state.copyWith(threadAutoCollapseDepth: depth));
  }

  Future<void> setConstellationUrl(String url) async {
    await database.setSetting(_keyConstellationUrl, url);
    emit(state.copyWith(constellationUrl: url));
  }

  Future<void> setAdsRemoved(bool value) async {
    await database.setSetting(_keyAdsRemoved, value.toString());
    emit(state.copyWith(adsRemoved: value));
  }
}
