import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/animation_preferences_dao.dart';

void main() {
  late AppDatabase db;
  late AnimationPreferencesDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.animationPreferencesDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('get', () {
    test('returns null for missing key', () async {
      final result = await dao.get('nonexistent');
      expect(result, isNull);
    });

    test('returns value for existing key', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');
      final result = await dao.get(AnimationPreferenceKeys.mode);
      expect(result, 'full');
    });
  });

  group('set', () {
    test('inserts a new setting', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'reduced');
      final result = await dao.get(AnimationPreferenceKeys.mode);
      expect(result, 'reduced');
    });

    test('updates an existing setting', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');
      await dao.set(AnimationPreferenceKeys.mode, 'minimal');
      final result = await dao.get(AnimationPreferenceKeys.mode);
      expect(result, 'minimal');
    });

    test('can store speed multiplier as string', () async {
      await dao.set(AnimationPreferenceKeys.speedMultiplier, '1.5');
      final result = await dao.get(AnimationPreferenceKeys.speedMultiplier);
      expect(result, '1.5');
    });
  });

  group('watch', () {
    test('emits null for missing key', () async {
      final result = await dao.watch('nonexistent').first;
      expect(result, isNull);
    });

    test('emits value for existing key', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');
      final result = await dao.watch(AnimationPreferenceKeys.mode).first;
      expect(result, 'full');
    });

    test('emits updates when value changes', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');

      final emissions = <String?>[];
      final subscription = dao.watch(AnimationPreferenceKeys.mode).listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.set(AnimationPreferenceKeys.mode, 'reduced');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions, contains('full'));
      expect(emissions, contains('reduced'));
    });
  });

  group('remove', () {
    test('removes a setting by key', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');

      final removed = await dao.remove(AnimationPreferenceKeys.mode);
      expect(removed, 1);

      final result = await dao.get(AnimationPreferenceKeys.mode);
      expect(result, isNull);
    });

    test('returns 0 when key does not exist', () async {
      final removed = await dao.remove('nonexistent');
      expect(removed, 0);
    });
  });

  group('getAll', () {
    test('returns empty map when no settings exist', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('returns all settings as a map', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');
      await dao.set(AnimationPreferenceKeys.speedMultiplier, '1.5');

      final result = await dao.getAll();
      expect(result, {
        AnimationPreferenceKeys.mode: 'full',
        AnimationPreferenceKeys.speedMultiplier: '1.5',
      });
    });
  });

  group('clearAll', () {
    test('removes all settings', () async {
      await dao.set(AnimationPreferenceKeys.mode, 'full');
      await dao.set(AnimationPreferenceKeys.speedMultiplier, '1.5');

      final cleared = await dao.clearAll();
      expect(cleared, 2);

      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('returns 0 when no settings exist', () async {
      final cleared = await dao.clearAll();
      expect(cleared, 0);
    });
  });
}
