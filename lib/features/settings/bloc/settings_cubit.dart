import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/search/data/search_scope.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.database,
    AppThemePalette? initialPalette,
    AppThemeVariant? initialVariant,
    bool? initialUseSystemTheme,
    FeedLayout? initialFeedLayout,
    bool? initialAnimationsEnabled,
    bool? initialSimulateOffline,
    int? initialThreadAutoCollapseDepth,
    String? initialConstellationUrl,
    Future<AppViewHealth> Function(String providerKey)? appViewHealthProber,
  }) : _appViewHealthProber = appViewHealthProber,
       super(
         SettingsState(
           themePalette: initialPalette ?? AppThemePalette.lazurite,
           themeVariant: initialVariant ?? AppThemeVariant.dark,
           useSystemTheme: initialUseSystemTheme ?? false,
           feedLayout: initialFeedLayout ?? FeedLayout.card,
           animationsEnabled: initialAnimationsEnabled ?? true,
           simulateOffline: initialSimulateOffline ?? false,
           threadAutoCollapseDepth: initialThreadAutoCollapseDepth,
           constellationUrl: initialConstellationUrl ?? 'https://constellation.microcosm.blue',
         ),
       );

  final AppDatabase database;
  final Future<AppViewHealth> Function(String providerKey)? _appViewHealthProber;

  static const String _keyThemePalette = 'theme_palette';
  static const String _keyThemeVariant = 'theme_variant';
  static const String _keyUseSystemTheme = 'use_system_theme';
  static const String _keyFeedLayout = 'feed_layout';
  static const String _legacyKeyFeedArchitecture = 'feed_architecture';
  static const String _keyAnimationsEnabled = 'animations_enabled';
  static const String _keySimulateOffline = 'simulate_offline';
  static const String _keyThreadAutoCollapseDepth = 'thread_auto_collapse_depth';
  static const String _keyConstellationUrl = 'constellation_url';
  static const String _defaultConstellationUrl = 'https://constellation.microcosm.blue';
  static const String _keySemanticSearchEnabled = 'semantic_search_enabled';
  static const String _keySearchScope = 'search_scope';
  static const String _keySemanticSearchMaxResults = 'semantic_search_max_results';
  static const String _keyTypeaheadProvider = 'typeahead_provider';
  static const String _defaultTypeaheadProvider = 'bluesky';
  static const Set<String> _supportedTypeaheadProviders = {'bluesky', 'community'};
  static const String _keyAppViewProvider = 'appview_provider';
  static const String _keyCrossProviderFallbackEnabled = 'cross_provider_fallback_enabled';
  static const String _keySlingshotIdentityFallbackEnabled = 'slingshot_identity_fallback_enabled';
  static const String _keyCrashReportingEnabled = 'crash_reporting_enabled';
  static const String _keyCrashReportingConsentPrompted = 'crash_reporting_consent_prompted';

  Future<void> loadSettings() async {
    final paletteStr = await database.getSetting(_keyThemePalette);
    final variantStr = await database.getSetting(_keyThemeVariant);
    final useSystemStr = await database.getSetting(_keyUseSystemTheme);
    final feedLayoutStr =
        await database.getSetting(_keyFeedLayout) ?? await database.getSetting(_legacyKeyFeedArchitecture);
    final animationsEnabledStr = await database.getSetting(_keyAnimationsEnabled);
    final simulateOfflineStr = await database.getSetting(_keySimulateOffline);
    final threadAutoCollapseDepthStr = await database.getSetting(_keyThreadAutoCollapseDepth);
    final constellationUrlStr = await database.getSetting(_keyConstellationUrl);
    final semanticSearchEnabledStr = await database.getSetting(_keySemanticSearchEnabled);
    final searchScopeStr = await database.getSetting(_keySearchScope);
    final semanticSearchMaxResultsStr = await database.getSetting(_keySemanticSearchMaxResults);
    final typeaheadProviderStr = await database.getSetting(_keyTypeaheadProvider);
    final appViewProviderStr = await database.getSetting(_keyAppViewProvider);
    final crossProviderFallbackEnabledStr = await database.getSetting(_keyCrossProviderFallbackEnabled);
    final slingshotIdentityFallbackEnabledStr = await database.getSetting(_keySlingshotIdentityFallbackEnabled);
    final crashReportingEnabledStr = await database.getSetting(_keyCrashReportingEnabled);
    final crashReportingConsentPromptedStr = await database.getSetting(_keyCrashReportingConsentPrompted);
    final resolvedTypeaheadProvider = _supportedTypeaheadProviders.contains(typeaheadProviderStr)
        ? typeaheadProviderStr!
        : _defaultTypeaheadProvider;
    final resolvedAppViewProvider = AppViewProviders.normalizeSettingKey(appViewProviderStr);

    emit(
      state.copyWith(
        themePalette: AppTheme.parsePalette(paletteStr),
        themeVariant: AppTheme.parseVariant(variantStr),
        useSystemTheme: useSystemStr == 'true',
        feedLayout: FeedLayout.fromString(feedLayoutStr),
        animationsEnabled: animationsEnabledStr != 'false',
        simulateOffline: simulateOfflineStr == 'true',
        threadAutoCollapseDepth: int.tryParse(threadAutoCollapseDepthStr ?? ''),
        constellationUrl: constellationUrlStr ?? _defaultConstellationUrl,
        semanticSearchEnabled: semanticSearchEnabledStr != 'false',
        searchScope: SearchScope.values.firstWhere((s) => s.name == searchScopeStr, orElse: () => SearchScope.both),
        semanticSearchMaxResults: int.tryParse(semanticSearchMaxResultsStr ?? '') ?? 20,
        typeaheadProvider: resolvedTypeaheadProvider,
        appViewProvider: resolvedAppViewProvider,
        crossProviderFallbackEnabled: crossProviderFallbackEnabledStr == 'true',
        slingshotIdentityFallbackEnabled: slingshotIdentityFallbackEnabledStr == 'true',
        crashReportingEnabled: crashReportingEnabledStr == 'true',
        crashReportingConsentPrompted: crashReportingConsentPromptedStr == 'true',
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

  Future<void> setAnimationsEnabled(bool value) async {
    await database.setSetting(_keyAnimationsEnabled, value.toString());
    emit(state.copyWith(animationsEnabled: value));
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

  Future<void> setSemanticSearchEnabled(bool value) async {
    await database.setSetting(_keySemanticSearchEnabled, 'true');
    emit(state.copyWith(semanticSearchEnabled: true));
  }

  Future<void> setSearchScope(SearchScope scope) async {
    await database.setSetting(_keySearchScope, scope.name);
    emit(state.copyWith(searchScope: scope));
  }

  Future<void> setSemanticSearchMaxResults(int value) async {
    await database.setSetting(_keySemanticSearchMaxResults, value.toString());
    emit(state.copyWith(semanticSearchMaxResults: value));
  }

  Future<void> setTypeaheadProvider(String provider) async {
    final normalizedProvider = provider.trim().toLowerCase();
    if (!_supportedTypeaheadProviders.contains(normalizedProvider)) {
      throw ArgumentError.value(
        provider,
        'provider',
        'Supported typeahead providers are: ${_supportedTypeaheadProviders.join(', ')}.',
      );
    }

    await database.setSetting(_keyTypeaheadProvider, normalizedProvider);
    emit(state.copyWith(typeaheadProvider: normalizedProvider));
  }

  Future<void> setAppViewProvider(String provider) async {
    final normalizedProvider = AppViewProviders.normalizeSettingKey(provider);
    if (normalizedProvider == state.appViewProvider) {
      return;
    }
    await database.setSetting(_keyAppViewProvider, normalizedProvider);
    emit(state.copyWith(appViewProvider: normalizedProvider));
  }

  void bumpRoutingEpoch() {
    emit(state.copyWith(routingEpoch: state.routingEpoch + 1));
  }

  Future<void> refreshAppViewHealth() async {
    emit(state.copyWith(appViewHealthRefreshing: true));
    try {
      final healthProber = _appViewHealthProber;
      final health = healthProber != null
          ? await healthProber(state.appViewProvider)
          : await AppViewRouter(provider: AppViewProviders.descriptorForSetting(state.appViewProvider)).probeProvider();
      emit(
        state.copyWith(
          appViewHealthRefreshing: false,
          appViewHealthSummary: health.summary(),
          appViewHealthCheckedAt: health.checkedAt,
          appViewLastError: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          appViewHealthRefreshing: false,
          appViewLastError: 'health probe failed: $error',
          appViewHealthCheckedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  void recordAppViewRoutingEvent(AppViewRoutingEvent event) {
    if (event is AppViewFallbackUsedEvent) {
      emit(
        state.copyWith(appViewLastFallback: 'endpoint=${event.endpointId} ${event.fromProvider}->${event.toProvider}'),
      );
      return;
    }

    if (event is AppViewProviderErrorEvent) {
      emit(
        state.copyWith(
          appViewLastError: 'endpoint=${event.endpointId} provider=${event.provider} reason=${event.reason}',
        ),
      );
    }
  }

  Future<void> setCrossProviderFallbackEnabled(bool enabled) async {
    await database.setSetting(_keyCrossProviderFallbackEnabled, enabled.toString());
    emit(state.copyWith(crossProviderFallbackEnabled: enabled));
  }

  Future<void> setSlingshotIdentityFallbackEnabled(bool enabled) async {
    await database.setSetting(_keySlingshotIdentityFallbackEnabled, enabled.toString());
    emit(state.copyWith(slingshotIdentityFallbackEnabled: enabled));
  }

  Future<void> setCrashReportingEnabled(bool enabled) async {
    await database.setSetting(_keyCrashReportingEnabled, enabled.toString());
    emit(state.copyWith(crashReportingEnabled: enabled));
  }

  Future<void> setCrashReportingConsentPrompted(bool prompted) async {
    await database.setSetting(_keyCrashReportingConsentPrompted, prompted.toString());
    emit(state.copyWith(crashReportingConsentPrompted: prompted));
  }
}
