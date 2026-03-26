import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
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

    test('inequality when feedArchitecture differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedArchitecture: FeedArchitecture.grid,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedArchitecture: FeedArchitecture.linear,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('inequality when simulateOffline differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        simulateOffline: false,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        simulateOffline: true,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('inequality when threadAutoCollapseDepth differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        threadAutoCollapseDepth: 2,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        threadAutoCollapseDepth: 4,
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
        feedArchitecture: FeedArchitecture.linear,
        simulateOffline: true,
        threadAutoCollapseDepth: 3,
      );

      expect(updated.themePalette, AppThemePalette.nord);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
      expect(updated.feedArchitecture, FeedArchitecture.linear);
      expect(updated.simulateOffline, true);
      expect(updated.threadAutoCollapseDepth, 3);
      expect(original.themePalette, AppThemePalette.oxocarbon);
    });

    test('copyWith preserves original values when not provided', () {
      const original = SettingsState(
        themePalette: AppThemePalette.catppuccin,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
        feedArchitecture: FeedArchitecture.linear,
        simulateOffline: true,
        threadAutoCollapseDepth: 4,
      );

      final updated = original.copyWith();

      expect(updated.themePalette, AppThemePalette.catppuccin);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
      expect(updated.feedArchitecture, FeedArchitecture.linear);
      expect(updated.simulateOffline, true);
      expect(updated.threadAutoCollapseDepth, 4);
    });

    test('copyWith can clear threadAutoCollapseDepth', () {
      const original = SettingsState(
        themePalette: AppThemePalette.catppuccin,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
        threadAutoCollapseDepth: 5,
      );

      final updated = original.copyWith(threadAutoCollapseDepth: null);

      expect(updated.threadAutoCollapseDepth, isNull);
    });

    test('props includes all fields', () {
      const state = SettingsState(
        themePalette: AppThemePalette.rosePine,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
        feedArchitecture: FeedArchitecture.linear,
        simulateOffline: true,
        threadAutoCollapseDepth: 6,
      );

      expect(state.props, contains(AppThemePalette.rosePine));
      expect(state.props, contains(AppThemeVariant.light));
      expect(state.props, contains(true));
      expect(state.props, contains(FeedArchitecture.linear));
      expect(state.props, contains(true));
      expect(state.props, contains(6));
    });

    test('defaults feedArchitecture to grid', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.feedArchitecture, FeedArchitecture.grid);
    });

    test('defaults simulateOffline to false', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.simulateOffline, isFalse);
    });

    test('defaults threadAutoCollapseDepth to null', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.threadAutoCollapseDepth, isNull);
    });
  });
}
