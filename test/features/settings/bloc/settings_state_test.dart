import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
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

    test('inequality when feedLayout differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.compact,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('inequality when animationsEnabled differs', () {
      const state1 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        animationsEnabled: true,
      );
      const state2 = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        animationsEnabled: false,
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
        feedLayout: FeedLayout.compact,
        animationsEnabled: false,
        simulateOffline: true,
        threadAutoCollapseDepth: 3,
      );

      expect(updated.themePalette, AppThemePalette.nord);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
      expect(updated.feedLayout, FeedLayout.compact);
      expect(updated.animationsEnabled, false);
      expect(updated.simulateOffline, true);
      expect(updated.threadAutoCollapseDepth, 3);
      expect(original.themePalette, AppThemePalette.oxocarbon);
    });

    test('copyWith preserves original values when not provided', () {
      const original = SettingsState(
        themePalette: AppThemePalette.catppuccin,
        themeVariant: AppThemeVariant.light,
        useSystemTheme: true,
        feedLayout: FeedLayout.compact,
        animationsEnabled: false,
        simulateOffline: true,
        threadAutoCollapseDepth: 4,
      );

      final updated = original.copyWith();

      expect(updated.themePalette, AppThemePalette.catppuccin);
      expect(updated.themeVariant, AppThemeVariant.light);
      expect(updated.useSystemTheme, true);
      expect(updated.feedLayout, FeedLayout.compact);
      expect(updated.animationsEnabled, false);
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
        feedLayout: FeedLayout.compact,
        animationsEnabled: false,
        simulateOffline: true,
        threadAutoCollapseDepth: 6,
      );

      expect(state.props, contains(AppThemePalette.rosePine));
      expect(state.props, contains(AppThemeVariant.light));
      expect(state.props, contains(true));
      expect(state.props, contains(FeedLayout.compact));
      expect(state.props, contains(false));
      expect(state.props, contains(true));
      expect(state.props, contains(6));
    });

    test('defaults feedLayout to card', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.feedLayout, FeedLayout.card);
    });

    test('defaults simulateOffline to false', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.simulateOffline, isFalse);
    });

    test('defaults animationsEnabled to true', () {
      const state = SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      );
      expect(state.animationsEnabled, isTrue);
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
