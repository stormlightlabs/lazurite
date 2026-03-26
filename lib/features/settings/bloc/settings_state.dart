import 'package:equatable/equatable.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';

const Object _threadAutoCollapseDepthUnset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    required this.themePalette,
    required this.themeVariant,
    required this.useSystemTheme,
    this.feedArchitecture = FeedArchitecture.grid,
    this.simulateOffline = false,
    this.threadAutoCollapseDepth,
  });

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;
  final FeedArchitecture feedArchitecture;
  final bool simulateOffline;
  final int? threadAutoCollapseDepth;

  SettingsState copyWith({
    AppThemePalette? themePalette,
    AppThemeVariant? themeVariant,
    bool? useSystemTheme,
    FeedArchitecture? feedArchitecture,
    bool? simulateOffline,
    Object? threadAutoCollapseDepth = _threadAutoCollapseDepthUnset,
  }) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      feedArchitecture: feedArchitecture ?? this.feedArchitecture,
      simulateOffline: simulateOffline ?? this.simulateOffline,
      threadAutoCollapseDepth: identical(threadAutoCollapseDepth, _threadAutoCollapseDepthUnset)
          ? this.threadAutoCollapseDepth
          : threadAutoCollapseDepth as int?,
    );
  }

  @override
  List<Object?> get props => [
    themePalette,
    themeVariant,
    useSystemTheme,
    feedArchitecture,
    simulateOffline,
    threadAutoCollapseDepth,
  ];
}
