import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/preferences/local_preferences_repository.dart';

void main() {
  late AppDatabase db;
  late Logger logger;
  late LocalPreferencesRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    logger = const Logger('LocalPreferencesRepositoryTest');
    repository = LocalPreferencesRepository(db.localSettingsDao, logger);
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalPreferencesRepository', () {
    group('themeMode', () {
      test('returns dark as default when not set', () async {
        final mode = await repository.getThemeMode();
        expect(mode, ThemeMode.dark);
      });

      test('retrieves persisted light theme mode', () async {
        await repository.setThemeMode(ThemeMode.light);
        final mode = await repository.getThemeMode();
        expect(mode, ThemeMode.light);
      });

      test('retrieves persisted dark theme mode', () async {
        await repository.setThemeMode(ThemeMode.dark);
        final mode = await repository.getThemeMode();
        expect(mode, ThemeMode.dark);
      });

      test('retrieves persisted system theme mode', () async {
        await repository.setThemeMode(ThemeMode.system);
        final mode = await repository.getThemeMode();
        expect(mode, ThemeMode.system);
      });

      test('updates theme mode', () async {
        await repository.setThemeMode(ThemeMode.light);
        expect(await repository.getThemeMode(), ThemeMode.light);

        await repository.setThemeMode(ThemeMode.dark);
        expect(await repository.getThemeMode(), ThemeMode.dark);

        await repository.setThemeMode(ThemeMode.system);
        expect(await repository.getThemeMode(), ThemeMode.system);
      });

      test('watchThemeMode emits current value immediately', () async {
        await repository.setThemeMode(ThemeMode.light);

        final stream = repository.watchThemeMode();
        await expectLater(stream.first, completion(ThemeMode.light));
      });

      test('watchThemeMode emits updates', () async {
        final stream = repository.watchThemeMode();

        await expectLater(stream.first, completion(ThemeMode.dark));

        await repository.setThemeMode(ThemeMode.light);
        await expectLater(stream.first, completion(ThemeMode.light));
      });

      test('handles invalid theme mode value gracefully', () async {
        await db.localSettingsDao.set('themeMode', 'invalid');

        final mode = await repository.getThemeMode();
        expect(mode, ThemeMode.dark);
      });
    });

    group('themePackId', () {
      test('returns oxocarbon as default when not set', () async {
        final packId = await repository.getThemePackId();
        expect(packId, 'oxocarbon');
      });

      test('retrieves persisted theme pack ID', () async {
        await repository.setThemePackId('custom-pack');
        final packId = await repository.getThemePackId();
        expect(packId, 'custom-pack');
      });

      test('updates theme pack ID', () async {
        await repository.setThemePackId('pack1');
        expect(await repository.getThemePackId(), 'pack1');

        await repository.setThemePackId('pack2');
        expect(await repository.getThemePackId(), 'pack2');
      });

      test('watchThemePackId emits current value immediately', () async {
        await repository.setThemePackId('custom-pack');

        final stream = repository.watchThemePackId();
        await expectLater(stream.first, completion('custom-pack'));
      });

      test('watchThemePackId emits default when not set', () async {
        final stream = repository.watchThemePackId();
        await expectLater(stream.first, completion('oxocarbon'));
      });

      test('watchThemePackId emits updates', () async {
        final stream = repository.watchThemePackId();

        await expectLater(stream.first, completion('oxocarbon'));

        await repository.setThemePackId('new-pack');
        await expectLater(stream.first, completion('new-pack'));
      });
    });

    group('fontScale', () {
      test('returns 1.0 as default when not set', () async {
        final scale = await repository.getFontScale();
        expect(scale, 1.0);
      });

      test('retrieves persisted font scale', () async {
        await repository.setFontScale(1.5);
        final scale = await repository.getFontScale();
        expect(scale, 1.5);
      });

      test('updates font scale', () async {
        await repository.setFontScale(0.8);
        expect(await repository.getFontScale(), 0.8);

        await repository.setFontScale(2.0);
        expect(await repository.getFontScale(), 2.0);
      });

      test('handles decimal values correctly', () async {
        await repository.setFontScale(1.25);
        final scale = await repository.getFontScale();
        expect(scale, 1.25);
      });

      test('watchFontScale emits current value immediately', () async {
        await repository.setFontScale(1.2);

        final stream = repository.watchFontScale();
        await expectLater(stream.first, completion(1.2));
      });

      test('watchFontScale emits default when not set', () async {
        final stream = repository.watchFontScale();
        await expectLater(stream.first, completion(1.0));
      });

      test('watchFontScale emits updates', () async {
        final stream = repository.watchFontScale();

        await expectLater(stream.first, completion(1.0));

        await repository.setFontScale(1.5);
        await expectLater(stream.first, completion(1.5));
      });

      test('handles invalid font scale value gracefully', () async {
        await db.localSettingsDao.set('fontScale', 'not-a-number');

        final scale = await repository.getFontScale();
        expect(scale, 1.0);
      });

      test('handles null font scale value gracefully in watch', () async {
        final stream = repository.watchFontScale();
        await expectLater(stream.first, completion(1.0));
      });

      test('handles invalid font scale value gracefully in watch', () async {
        await db.localSettingsDao.set('fontScale', 'invalid');

        final stream = repository.watchFontScale();
        await expectLater(stream.first, completion(1.0));
      });
    });

    group('clearAll', () {
      test('removes all preferences', () async {
        await repository.setThemeMode(ThemeMode.light);
        await repository.setThemePackId('custom-pack');
        await repository.setFontScale(1.5);

        expect(await repository.getThemeMode(), ThemeMode.light);
        expect(await repository.getThemePackId(), 'custom-pack');
        expect(await repository.getFontScale(), 1.5);

        await repository.clearAll();

        expect(await repository.getThemeMode(), ThemeMode.dark);
        expect(await repository.getThemePackId(), 'oxocarbon');
        expect(await repository.getFontScale(), 1.0);
      });
    });

    group('LocalPreferenceKeys', () {
      test('defines expected key constants', () {
        expect(LocalPreferenceKeys.themeMode, 'themeMode');
        expect(LocalPreferenceKeys.themePackId, 'themePackId');
        expect(LocalPreferenceKeys.fontScale, 'fontScale');
      });
    });
  });
}
