import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('SettingsCubit', () {
    test('initial state has default values', () {
      final cubit = SettingsCubit(database: database);
      expect(cubit.state.themePalette, AppThemePalette.oxocarbon);
      expect(cubit.state.themeVariant, AppThemeVariant.dark);
      expect(cubit.state.useSystemTheme, false);
      expect(cubit.state.feedLayout, FeedLayout.card);
      expect(cubit.state.simulateOffline, false);
      expect(cubit.state.threadAutoCollapseDepth, isNull);
      expect(cubit.state.adsRemoved, false);
    });

    test('accepts initial values via constructor', () {
      final cubit = SettingsCubit(
        database: database,
        initialPalette: AppThemePalette.catppuccin,
        initialVariant: AppThemeVariant.light,
        initialUseSystemTheme: true,
        initialFeedLayout: FeedLayout.compact,
        initialSimulateOffline: true,
        initialThreadAutoCollapseDepth: 3,
      );
      expect(cubit.state.themePalette, AppThemePalette.catppuccin);
      expect(cubit.state.themeVariant, AppThemeVariant.light);
      expect(cubit.state.useSystemTheme, true);
      expect(cubit.state.feedLayout, FeedLayout.compact);
      expect(cubit.state.simulateOffline, true);
      expect(cubit.state.threadAutoCollapseDepth, 3);
    });

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings loads persisted settings from database',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('theme_palette', 'nord');
        await database.setSetting('theme_variant', 'light');
        await database.setSetting('use_system_theme', 'true');
        await database.setSetting('feed_architecture', 'linear');
        await database.setSetting('simulate_offline', 'true');
        await database.setSetting('thread_auto_collapse_depth', '4');
        await database.setSetting('ads_removed', 'true');
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themePalette, 'themePalette', AppThemePalette.nord)
            .having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.light)
            .having((s) => s.useSystemTheme, 'useSystemTheme', true)
            .having((s) => s.feedLayout, 'feedLayout', FeedLayout.compact)
            .having((s) => s.simulateOffline, 'simulateOffline', true)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', 4)
            .having((s) => s.adsRemoved, 'adsRemoved', true),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings uses defaults when no settings persisted',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themePalette, 'themePalette', AppThemePalette.oxocarbon)
            .having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.dark)
            .having((s) => s.useSystemTheme, 'useSystemTheme', false)
            .having((s) => s.feedLayout, 'feedLayout', FeedLayout.card)
            .having((s) => s.simulateOffline, 'simulateOffline', false)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', isNull)
            .having((s) => s.adsRemoved, 'adsRemoved', false),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'setThemePalette updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setThemePalette(AppThemePalette.rosePine),
      expect: () => [isA<SettingsState>().having((s) => s.themePalette, 'themePalette', AppThemePalette.rosePine)],
      verify: (cubit) async {
        final value = await database.getSetting('theme_palette');
        expect(value, 'rosePine');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setThemeVariant updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setThemeVariant(AppThemeVariant.light),
      expect: () => [isA<SettingsState>().having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.light)],
      verify: (cubit) async {
        final value = await database.getSetting('theme_variant');
        expect(value, 'light');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setTheme updates both palette and variant',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setTheme(AppThemePalette.nord, AppThemeVariant.light),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themePalette, 'themePalette', AppThemePalette.nord)
            .having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.light),
      ],
      verify: (cubit) async {
        expect(await database.getSetting('theme_palette'), 'nord');
        expect(await database.getSetting('theme_variant'), 'light');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setUseSystemTheme updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setUseSystemTheme(true),
      expect: () => [isA<SettingsState>().having((s) => s.useSystemTheme, 'useSystemTheme', true)],
      verify: (cubit) async {
        final value = await database.getSetting('use_system_theme');
        expect(value, 'true');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setFeedLayout updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setFeedLayout(FeedLayout.compact),
      expect: () => [isA<SettingsState>().having((s) => s.feedLayout, 'feedLayout', FeedLayout.compact)],
      verify: (cubit) async {
        final value = await database.getSetting('feed_layout');
        expect(value, 'compact');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setFeedLayout card updates state and persists to database',
      build: () => SettingsCubit(database: database, initialFeedLayout: FeedLayout.compact),
      act: (cubit) => cubit.setFeedLayout(FeedLayout.card),
      expect: () => [isA<SettingsState>().having((s) => s.feedLayout, 'feedLayout', FeedLayout.card)],
      verify: (cubit) async {
        final value = await database.getSetting('feed_layout');
        expect(value, 'card');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setFeedLayout clears the legacy feed_architecture setting',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('feed_architecture', 'linear');
      },
      act: (cubit) => cubit.setFeedLayout(FeedLayout.compact),
      expect: () => [isA<SettingsState>().having((s) => s.feedLayout, 'feedLayout', FeedLayout.compact)],
      verify: (cubit) async {
        expect(await database.getSetting('feed_layout'), 'compact');
        expect(await database.getSetting('feed_architecture'), isNull);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setSimulateOffline updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setSimulateOffline(true),
      expect: () => [isA<SettingsState>().having((s) => s.simulateOffline, 'simulateOffline', true)],
      verify: (cubit) async {
        final value = await database.getSetting('simulate_offline');
        expect(value, 'true');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setThreadAutoCollapseDepth updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setThreadAutoCollapseDepth(5),
      expect: () => [isA<SettingsState>().having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', 5)],
      verify: (cubit) async {
        final value = await database.getSetting('thread_auto_collapse_depth');
        expect(value, '5');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setThreadAutoCollapseDepth null clears the persisted setting',
      build: () => SettingsCubit(database: database, initialThreadAutoCollapseDepth: 4),
      setUp: () async {
        await database.setSetting('thread_auto_collapse_depth', '4');
      },
      act: (cubit) => cubit.setThreadAutoCollapseDepth(null),
      expect: () => [isA<SettingsState>().having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', isNull)],
      verify: (cubit) async {
        final value = await database.getSetting('thread_auto_collapse_depth');
        expect(value, isNull);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setAdsRemoved updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setAdsRemoved(true),
      expect: () => [isA<SettingsState>().having((s) => s.adsRemoved, 'adsRemoved', true)],
      verify: (cubit) async {
        final value = await database.getSetting('ads_removed');
        expect(value, 'true');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings round-trips feed_layout and thread auto-collapse depth',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('feed_layout', 'linear');
        await database.setSetting('thread_auto_collapse_depth', '6');
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.feedLayout, 'feedLayout', FeedLayout.compact)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', 6),
      ],
    );

    test('initial state has default constellation URL', () {
      final cubit = SettingsCubit(database: database);
      expect(cubit.state.constellationUrl, 'https://constellation.microcosm.blue');
    });

    test('accepts initial constellation URL via constructor', () {
      final cubit = SettingsCubit(database: database, initialConstellationUrl: 'https://my.instance.example');
      expect(cubit.state.constellationUrl, 'https://my.instance.example');
    });

    blocTest<SettingsCubit, SettingsState>(
      'setConstellationUrl updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setConstellationUrl('https://custom.example.com'),
      expect: () => [
        isA<SettingsState>().having((s) => s.constellationUrl, 'constellationUrl', 'https://custom.example.com'),
      ],
      verify: (cubit) async {
        final value = await database.getSetting('constellation_url');
        expect(value, 'https://custom.example.com');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings loads persisted constellation URL',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('constellation_url', 'https://self-hosted.example');
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>().having((s) => s.constellationUrl, 'constellationUrl', 'https://self-hosted.example'),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings uses default constellation URL when not persisted',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.constellationUrl,
          'constellationUrl',
          'https://constellation.microcosm.blue',
        ),
      ],
    );
  });
}
