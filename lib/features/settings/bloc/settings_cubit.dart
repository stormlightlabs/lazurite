import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/core/theme/ui_density.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.database,
    AppThemePalette? initialPalette,
    AppThemeVariant? initialVariant,
    bool? initialUseSystemTheme,
    UiDensity? initialUiDensity,
    FeedArchitecture? initialFeedArchitecture,
  }) : super(
         SettingsState(
           themePalette: initialPalette ?? AppThemePalette.oxocarbon,
           themeVariant: initialVariant ?? AppThemeVariant.dark,
           useSystemTheme: initialUseSystemTheme ?? false,
           uiDensity: initialUiDensity ?? UiDensity.standard,
           feedArchitecture: initialFeedArchitecture ?? FeedArchitecture.grid,
         ),
       );

  final AppDatabase database;

  static const String _keyThemePalette = 'theme_palette';
  static const String _keyThemeVariant = 'theme_variant';
  static const String _keyUseSystemTheme = 'use_system_theme';
  static const String _keyUiDensity = 'ui_density';
  static const String _keyFeedArchitecture = 'feed_architecture';

  Future<void> loadSettings() async {
    final paletteStr = await database.getSetting(_keyThemePalette);
    final variantStr = await database.getSetting(_keyThemeVariant);
    final useSystemStr = await database.getSetting(_keyUseSystemTheme);
    final uiDensityStr = await database.getSetting(_keyUiDensity);
    final feedArchStr = await database.getSetting(_keyFeedArchitecture);

    emit(
      state.copyWith(
        themePalette: AppTheme.parsePalette(paletteStr),
        themeVariant: AppTheme.parseVariant(variantStr),
        useSystemTheme: useSystemStr == 'true',
        uiDensity: UiDensity.fromString(uiDensityStr),
        feedArchitecture: FeedArchitecture.fromString(feedArchStr),
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

  Future<void> setUiDensity(UiDensity density) async {
    await database.setSetting(_keyUiDensity, density.name);
    emit(state.copyWith(uiDensity: density));
  }

  Future<void> setFeedArchitecture(FeedArchitecture architecture) async {
    await database.setSetting(_keyFeedArchitecture, architecture.name);
    emit(state.copyWith(feedArchitecture: architecture));
  }
}
