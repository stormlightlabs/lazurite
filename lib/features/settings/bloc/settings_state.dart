import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/density_spacing.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/core/theme/ui_density.dart';

const Object _threadAutoCollapseDepthUnset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    required this.themePalette,
    required this.themeVariant,
    required this.useSystemTheme,
    this.uiDensity = UiDensity.standard,
    this.feedArchitecture = FeedArchitecture.grid,
    this.threadAutoCollapseDepth,
  });

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;
  final UiDensity uiDensity;
  final FeedArchitecture feedArchitecture;
  final int? threadAutoCollapseDepth;

  ThemeData get themeData {
    final base = AppTheme.getTheme(themePalette, themeVariant);
    return base.copyWith(extensions: [DensitySpacing.fromDensity(uiDensity)]);
  }

  SettingsState copyWith({
    AppThemePalette? themePalette,
    AppThemeVariant? themeVariant,
    bool? useSystemTheme,
    UiDensity? uiDensity,
    FeedArchitecture? feedArchitecture,
    Object? threadAutoCollapseDepth = _threadAutoCollapseDepthUnset,
  }) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      uiDensity: uiDensity ?? this.uiDensity,
      feedArchitecture: feedArchitecture ?? this.feedArchitecture,
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
    uiDensity,
    feedArchitecture,
    threadAutoCollapseDepth,
  ];
}
