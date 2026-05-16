import 'package:equatable/equatable.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/core/theme/typography.dart';
import 'package:lazurite/features/search/data/search_scope.dart';

const Object _threadAutoCollapseDepthUnset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    required this.themePalette,
    required this.themeVariant,
    required this.useSystemTheme,
    this.headingFontFamily = AppHeadingFontFamily.lora,
    this.contentFontFamily = AppContentFontFamily.googleSans,
    this.codeFontFamily = AppCodeFontFamily.googleSansCode,
    this.feedLayout = FeedLayout.card,
    this.animationsEnabled = true,
    this.simulateOffline = false,
    this.threadAutoCollapseDepth,
    this.constellationUrl = 'https://constellation.microcosm.blue',
    this.semanticSearchEnabled = true,
    this.searchScope = SearchScope.both,
    this.semanticSearchMaxResults = 20,
    this.typeaheadProvider = 'bluesky',
    this.appViewProvider = 'bluesky',
    this.crossProviderFallbackEnabled = false,
    this.slingshotIdentityFallbackEnabled = false,
    this.crashReportingEnabled = false,
    this.crashReportingConsentPrompted = false,
    this.routingEpoch = 0,
    this.appViewHealthSummary,
    this.appViewHealthCheckedAt,
    this.appViewHealthRefreshing = false,
    this.appViewLastFallback,
    this.appViewLastError,
  });

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;
  final AppHeadingFontFamily headingFontFamily;
  final AppContentFontFamily contentFontFamily;
  final AppCodeFontFamily codeFontFamily;
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

  /// Enables public read fallback from selected AppView to alternate built-in AppView.
  final bool crossProviderFallbackEnabled;

  /// Enables Slingshot identity fallback for degraded handle resolution.
  final bool slingshotIdentityFallbackEnabled;

  /// Whether crash/error reports can be sent to Crashlytics.
  final bool crashReportingEnabled;

  /// Whether the one-time crash reporting consent prompt has already been shown.
  final bool crashReportingConsentPrompted;

  /// In-memory epoch incremented when routing state is soft-reset.
  final int routingEpoch;

  /// Last known provider health summary shown in diagnostics.
  final String? appViewHealthSummary;

  /// UTC timestamp of the most recent provider health check.
  final DateTime? appViewHealthCheckedAt;

  /// Whether provider health refresh is currently in-flight.
  final bool appViewHealthRefreshing;

  /// Last fallback event summary.
  final String? appViewLastFallback;

  /// Last provider error summary.
  final String? appViewLastError;

  SettingsState copyWith({
    AppThemePalette? themePalette,
    AppThemeVariant? themeVariant,
    bool? useSystemTheme,
    AppHeadingFontFamily? headingFontFamily,
    AppContentFontFamily? contentFontFamily,
    AppCodeFontFamily? codeFontFamily,
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
    bool? crossProviderFallbackEnabled,
    bool? slingshotIdentityFallbackEnabled,
    bool? crashReportingEnabled,
    bool? crashReportingConsentPrompted,
    int? routingEpoch,
    Object? appViewHealthSummary = _threadAutoCollapseDepthUnset,
    Object? appViewHealthCheckedAt = _threadAutoCollapseDepthUnset,
    bool? appViewHealthRefreshing,
    Object? appViewLastFallback = _threadAutoCollapseDepthUnset,
    Object? appViewLastError = _threadAutoCollapseDepthUnset,
  }) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      headingFontFamily: headingFontFamily ?? this.headingFontFamily,
      contentFontFamily: contentFontFamily ?? this.contentFontFamily,
      codeFontFamily: codeFontFamily ?? this.codeFontFamily,
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
      crossProviderFallbackEnabled: crossProviderFallbackEnabled ?? this.crossProviderFallbackEnabled,
      slingshotIdentityFallbackEnabled: slingshotIdentityFallbackEnabled ?? this.slingshotIdentityFallbackEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      crashReportingConsentPrompted: crashReportingConsentPrompted ?? this.crashReportingConsentPrompted,
      routingEpoch: routingEpoch ?? this.routingEpoch,
      appViewHealthSummary: identical(appViewHealthSummary, _threadAutoCollapseDepthUnset)
          ? this.appViewHealthSummary
          : appViewHealthSummary as String?,
      appViewHealthCheckedAt: identical(appViewHealthCheckedAt, _threadAutoCollapseDepthUnset)
          ? this.appViewHealthCheckedAt
          : appViewHealthCheckedAt as DateTime?,
      appViewHealthRefreshing: appViewHealthRefreshing ?? this.appViewHealthRefreshing,
      appViewLastFallback: identical(appViewLastFallback, _threadAutoCollapseDepthUnset)
          ? this.appViewLastFallback
          : appViewLastFallback as String?,
      appViewLastError: identical(appViewLastError, _threadAutoCollapseDepthUnset)
          ? this.appViewLastError
          : appViewLastError as String?,
    );
  }

  @override
  List<Object?> get props => [
    themePalette,
    themeVariant,
    useSystemTheme,
    headingFontFamily,
    contentFontFamily,
    codeFontFamily,
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
    crossProviderFallbackEnabled,
    slingshotIdentityFallbackEnabled,
    crashReportingEnabled,
    crashReportingConsentPrompted,
    routingEpoch,
    appViewHealthSummary,
    appViewHealthCheckedAt,
    appViewHealthRefreshing,
    appViewLastFallback,
    appViewLastError,
  ];
}
