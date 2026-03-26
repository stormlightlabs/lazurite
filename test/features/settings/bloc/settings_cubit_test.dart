import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
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
      expect(cubit.state.feedArchitecture, FeedArchitecture.grid);
      expect(cubit.state.simulateOffline, false);
      expect(cubit.state.threadAutoCollapseDepth, isNull);
    });

    test('accepts initial values via constructor', () {
      final cubit = SettingsCubit(
        database: database,
        initialPalette: AppThemePalette.catppuccin,
        initialVariant: AppThemeVariant.light,
        initialUseSystemTheme: true,
        initialFeedArchitecture: FeedArchitecture.linear,
        initialSimulateOffline: true,
        initialThreadAutoCollapseDepth: 3,
      );
      expect(cubit.state.themePalette, AppThemePalette.catppuccin);
      expect(cubit.state.themeVariant, AppThemeVariant.light);
      expect(cubit.state.useSystemTheme, true);
      expect(cubit.state.feedArchitecture, FeedArchitecture.linear);
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
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themePalette, 'themePalette', AppThemePalette.nord)
            .having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.light)
            .having((s) => s.useSystemTheme, 'useSystemTheme', true)
            .having((s) => s.feedArchitecture, 'feedArchitecture', FeedArchitecture.linear)
            .having((s) => s.simulateOffline, 'simulateOffline', true)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', 4),
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
            .having((s) => s.feedArchitecture, 'feedArchitecture', FeedArchitecture.grid)
            .having((s) => s.simulateOffline, 'simulateOffline', false)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', isNull),
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
      'setFeedArchitecture updates state and persists to database',
      build: () => SettingsCubit(database: database),
      act: (cubit) => cubit.setFeedArchitecture(FeedArchitecture.linear),
      expect: () => [
        isA<SettingsState>().having((s) => s.feedArchitecture, 'feedArchitecture', FeedArchitecture.linear),
      ],
      verify: (cubit) async {
        final value = await database.getSetting('feed_architecture');
        expect(value, 'linear');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setFeedArchitecture grid updates state and persists to database',
      build: () => SettingsCubit(database: database, initialFeedArchitecture: FeedArchitecture.linear),
      act: (cubit) => cubit.setFeedArchitecture(FeedArchitecture.grid),
      expect: () => [isA<SettingsState>().having((s) => s.feedArchitecture, 'feedArchitecture', FeedArchitecture.grid)],
      verify: (cubit) async {
        final value = await database.getSetting('feed_architecture');
        expect(value, 'grid');
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
      'loadSettings round-trips feed_architecture and thread auto-collapse depth',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('feed_architecture', 'linear');
        await database.setSetting('thread_auto_collapse_depth', '6');
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.feedArchitecture, 'feedArchitecture', FeedArchitecture.linear)
            .having((s) => s.threadAutoCollapseDepth, 'threadAutoCollapseDepth', 6),
      ],
    );
  });
}
