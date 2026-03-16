import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

void main() {
  group('SettingsState', () {
    test('supports equality', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );

      expect(state1, equals(state2));
    });

    test('inequality when palette differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.catppuccin,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('inequality when variant differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: false,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('inequality when useSystemTheme differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: true,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('copyWith returns new instance with updated values', () {
      const original = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );

      final updated = original.copyWith(
        themePalette: AppThemePalette.nord,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
      );

      expect(updated.themePalette, AppThemePalette.nord);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
      expect(original.themePalette, AppThemePalette.oxocarbon);
    });

    test('copyWith preserves original values when not provided', () {
      const original = SettingsState(
        themePalette: AppThemePalette.catppuccin,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
      );

      final updated = original.copyWith();

      expect(updated.themePalette, AppThemePalette.catppuccin);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
    });

    test('props includes all fields', () {
      const state = SettingsState(
        themePalette: AppThemePalette.rosePine,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
      );

      expect(state.props, contains(AppThemePalette.rosePine));
      expect(state.props, contains(AppThemeVariant.light));
      expect(state.props, contains(true));
    });
  });
}
