import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/app_theme.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.themePalette, required this.themeVariant, required this.useSystemTheme});

  final AppThemePalette themePalette;
  final AppThemeVariant themeVariant;
  final bool useSystemTheme;

  ThemeData get themeData => AppTheme.getTheme(themePalette, themeVariant);

  SettingsState copyWith({AppThemePalette? themePalette, AppThemeVariant? themeVariant, bool? useSystemTheme}) {
    return SettingsState(
      themePalette: themePalette ?? this.themePalette,
      themeVariant: themeVariant ?? this.themeVariant,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  @override
  List<Object?> get props => [themePalette, themeVariant, useSystemTheme];
}
