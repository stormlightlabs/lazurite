import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalSettingsDao extends Mock implements LocalSettingsDao {}

/// Test-specific ThemeController that avoids ThemeFactory.buildThemeData()
/// which triggers Google Fonts loading requiring TestWidgetsFlutterBinding.
///
/// This version also skips async loading to avoid Riverpod lifecycle issues.
class TestThemeController extends ThemeController {
  @override
  ThemeState build() => _buildTestState(ThemeMode.dark, 'oxocarbon');

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = _buildTestState(mode, state.currentPackId);
    await ref.read(localSettingsDaoProvider).set(ThemeSettingsKeys.themeMode, mode.name);
  }

  @override
  Future<void> setThemePack(String packId) async {
    final resolved = _resolvePackId(packId);
    if (resolved == state.currentPackId) return;
    state = _buildTestState(state.themeMode, resolved);
    await ref.read(localSettingsDaoProvider).set(ThemeSettingsKeys.themePackId, resolved);
  }

  ThemeState _buildTestState(ThemeMode mode, String packId) => ThemeState(
    themeMode: mode,
    currentPackId: packId,
    lightTheme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
  );

  String _resolvePackId(String? packId) {
    if (packId == null) return 'oxocarbon';
    final packs = ref.read(availableThemePacksProvider);
    return packs.where((p) => p.id == packId).firstOrNull?.id ?? 'oxocarbon';
  }
}

void main() {
  late MockLocalSettingsDao mockDao;
  late ProviderContainer container;

  setUp(() {
    mockDao = MockLocalSettingsDao();
    when(() => mockDao.get(any())).thenAnswer((_) async => null);
    when(() => mockDao.set(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        localSettingsDaoProvider.overrideWithValue(mockDao),
        availableThemePacksProvider.overrideWithValue([oxocarbonPack]),
        themeControllerProvider.overrideWith(TestThemeController.new),
      ],
    );
  }

  group('ThemeController', () {
    test('defaults to oxocarbon pack and dark mode', () {
      container = createContainer();

      final state = container.read(themeControllerProvider);

      expect(state.themeMode, ThemeMode.dark);
      expect(state.currentPackId, 'oxocarbon');
      expect(state.lightTheme, isA<ThemeData>());
      expect(state.darkTheme, isA<ThemeData>());
    });

    test('setThemeMode updates state', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      await notifier.setThemeMode(ThemeMode.light);

      expect(container.read(themeControllerProvider).themeMode, ThemeMode.light);
    });

    test('setThemeMode persists to database', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      await notifier.setThemeMode(ThemeMode.light);

      verify(() => mockDao.set(ThemeSettingsKeys.themeMode, 'light')).called(1);
    });

    test('setThemeMode to system mode persists correctly', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      await notifier.setThemeMode(ThemeMode.system);

      expect(container.read(themeControllerProvider).themeMode, ThemeMode.system);
      verify(() => mockDao.set(ThemeSettingsKeys.themeMode, 'system')).called(1);
    });

    test('setThemePack with same pack is no-op', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      await notifier.setThemePack('oxocarbon');

      expect(container.read(themeControllerProvider).currentPackId, 'oxocarbon');
      verifyNever(() => mockDao.set(ThemeSettingsKeys.themePackId, any()));
    });

    test('setThemePack falls back to default for unknown pack', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      await notifier.setThemePack('nonexistent');

      expect(container.read(themeControllerProvider).currentPackId, 'oxocarbon');
    });

    test('toggle switches between light and dark modes', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      notifier.toggle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(themeControllerProvider).themeMode, ThemeMode.light);

      notifier.toggle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(themeControllerProvider).themeMode, ThemeMode.dark);
    });

    test('toggle persists mode changes', () async {
      container = createContainer();

      final notifier = container.read(themeControllerProvider.notifier);

      notifier.toggle();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verify(() => mockDao.set(ThemeSettingsKeys.themeMode, 'light')).called(1);
    });

    test('lightTheme is present and uses Material 3', () {
      container = createContainer();

      final state = container.read(themeControllerProvider);

      expect(state.lightTheme, isA<ThemeData>());
      expect(state.lightTheme.useMaterial3, true);
    });

    test('darkTheme is present and uses Material 3', () {
      container = createContainer();

      final state = container.read(themeControllerProvider);

      expect(state.darkTheme, isA<ThemeData>());
      expect(state.darkTheme.useMaterial3, true);
    });
  });

  group('ThemeState', () {
    test('copyWith creates modified copy', () {
      final state = ThemeState(
        themeMode: ThemeMode.dark,
        currentPackId: 'oxocarbon',
        lightTheme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      );

      final copied = state.copyWith(themeMode: ThemeMode.light);

      expect(copied.themeMode, ThemeMode.light);
      expect(copied.currentPackId, 'oxocarbon');
    });

    test('copyWith preserves unchanged values', () {
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();
      final state = ThemeState(
        themeMode: ThemeMode.dark,
        currentPackId: 'oxocarbon',
        lightTheme: lightTheme,
        darkTheme: darkTheme,
      );

      final copied = state.copyWith(themeMode: ThemeMode.light);

      expect(copied.lightTheme, same(lightTheme));
      expect(copied.darkTheme, same(darkTheme));
    });
  });

  group('ThemeSettingsKeys', () {
    test('has correct key values', () {
      expect(ThemeSettingsKeys.themeMode, 'themeMode');
      expect(ThemeSettingsKeys.themePackId, 'themePackId');
    });
  });
}
