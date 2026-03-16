import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
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
    });

    test('accepts initial values via constructor', () {
      final cubit = SettingsCubit(
        database: database,
        initialPalette: AppThemePalette.catppuccin,
        initialVariant: AppThemeVariant.light,
        initialUseSystemTheme: true,
      );
      expect(cubit.state.themePalette, AppThemePalette.catppuccin);
      expect(cubit.state.themeVariant, AppThemeVariant.light);
      expect(cubit.state.useSystemTheme, true);
    });

    blocTest<SettingsCubit, SettingsState>(
      'loadSettings loads persisted settings from database',
      build: () => SettingsCubit(database: database),
      setUp: () async {
        await database.setSetting('theme_palette', 'nord');
        await database.setSetting('theme_variant', 'light');
        await database.setSetting('use_system_theme', 'true');
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themePalette, 'themePalette', AppThemePalette.nord)
            .having((s) => s.themeVariant, 'themeVariant', AppThemeVariant.light)
            .having((s) => s.useSystemTheme, 'useSystemTheme', true),
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
            .having((s) => s.useSystemTheme, 'useSystemTheme', false),
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
  });
}
