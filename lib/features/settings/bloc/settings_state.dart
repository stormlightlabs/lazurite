import 'package:equatable/equatable.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/search/data/search_scope.dart';

const Object _threadAutoCollapseDepthUnset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    required this.themePalette,
    required this.themeVariant,
    required this.useSystemTheme,
    this.feedLayout = FeedLayout.card,
    this.animationsEnabled = true,
    this.simulateOffline = false,
    this.threadAutoCollapseDepth,
    this.constellationUrl = 'https://constellation.microcosm.blue',
    this.semanticSearchEnabled = false,
    this.searchScope = SearchScope.both,
    this.semanticSearchMaxResults = 20,
    this.typeaheadProvider = 'bluesky',
    this.appViewProvider = 'bluesky',
  });

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;
  final FeedLayout feedLayout;
  final bool animationsEnabled;
  final bool simulateOffline;
  final int? threadAutoCollapseDepth;
  final String constellationUrl;

  /// Whether semantic (vector) search is enabled.
  final bool semanticSearchEnabled;

  /// Default scope used when opening the search tab.
  final SearchScope searchScope;

  /// Maximum number of results returned per search query (10–50).
  final int semanticSearchMaxResults;

  /// Configured typeahead backend provider (`bluesky` or `community`).
  final String typeaheadProvider;

  /// Configured AppView provider (`bluesky` or `blacksky`).
  final String appViewProvider;

  SettingsState copyWith({
    AppThemePalette? themePalette,
    AppThemeVariant? themeVariant,
    bool? useSystemTheme,
    FeedLayout? feedLayout,
    bool? animationsEnabled,
    bool? simulateOffline,
    Object? threadAutoCollapseDepth = _threadAutoCollapseDepthUnset,
    String? constellationUrl,
    bool? semanticSearchEnabled,
    SearchScope? searchScope,
    int? semanticSearchMaxResults,
    String? typeaheadProvider,
    String? appViewProvider,
  }) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      feedLayout: feedLayout ?? this.feedLayout,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      simulateOffline: simulateOffline ?? this.simulateOffline,
      threadAutoCollapseDepth: identical(threadAutoCollapseDepth, _threadAutoCollapseDepthUnset)
          ? this.threadAutoCollapseDepth
          : threadAutoCollapseDepth as int?,
      constellationUrl: constellationUrl ?? this.constellationUrl,
      semanticSearchEnabled: semanticSearchEnabled ?? this.semanticSearchEnabled,
      searchScope: searchScope ?? this.searchScope,
      semanticSearchMaxResults: semanticSearchMaxResults ?? this.semanticSearchMaxResults,
      typeaheadProvider: typeaheadProvider ?? this.typeaheadProvider,
      appViewProvider: appViewProvider ?? this.appViewProvider,
    );
  }

  @override
  List<Object?> get props => [
    themePalette,
    themeVariant,
    useSystemTheme,
    feedLayout,
    animationsEnabled,
    simulateOffline,
    threadAutoCollapseDepth,
    constellationUrl,
    semanticSearchEnabled,
    searchScope,
    semanticSearchMaxResults,
    typeaheadProvider,
    appViewProvider,
  ];
}
