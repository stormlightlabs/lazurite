import 'package:equatable/equatable.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';

const Object _threadAutoCollapseDepthUnset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    required this.themePalette,
    required this.themeVariant,
    required this.useSystemTheme,
    this.feedLayout = FeedLayout.card,
    this.simulateOffline = false,
    this.threadAutoCollapseDepth,
    this.constellationUrl = 'https://constellation.microcosm.blue',
  });

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;
  final FeedLayout feedLayout;
  final bool simulateOffline;
  final int? threadAutoCollapseDepth;
  final String constellationUrl;

  SettingsState copyWith({
    AppThemePalette? themePalette,
    AppThemeVariant? themeVariant,
    bool? useSystemTheme,
    FeedLayout? feedLayout,
    bool? simulateOffline,
    Object? threadAutoCollapseDepth = _threadAutoCollapseDepthUnset,
    String? constellationUrl,
  }) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      feedLayout: feedLayout ?? this.feedLayout,
      simulateOffline: simulateOffline ?? this.simulateOffline,
      threadAutoCollapseDepth: identical(threadAutoCollapseDepth, _threadAutoCollapseDepthUnset)
          ? this.threadAutoCollapseDepth
          : threadAutoCollapseDepth as int?,
      constellationUrl: constellationUrl ?? this.constellationUrl,
    );
  }

  @override
  List<Object?> get props => [
    themePalette,
    themeVariant,
    useSystemTheme,
    feedLayout,
    simulateOffline,
    threadAutoCollapseDepth,
    constellationUrl,
  ];
}
