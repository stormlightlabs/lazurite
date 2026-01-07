import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';

void main() {
  late AppDatabase db;
  late LocalSettingsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.localSettingsDao;
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
      await dao.set('themeMode', 'dark');
      final result = await dao.get('themeMode');
      expect(result, 'dark');
    });
  });

  group('set', () {
    test('inserts a new setting', () async {
      await dao.set('themePackId', 'oxocarbon');
      final result = await dao.get('themePackId');
      expect(result, 'oxocarbon');
    });

    test('updates an existing setting', () async {
      await dao.set('themeMode', 'dark');
      await dao.set('themeMode', 'light');
      final result = await dao.get('themeMode');
      expect(result, 'light');
    });
  });

  group('watch', () {
    test('emits null for missing key', () async {
      final result = await dao.watch('nonexistent').first;
      expect(result, isNull);
    });

    test('emits value for existing key', () async {
      await dao.set('themeMode', 'dark');
      final result = await dao.watch('themeMode').first;
      expect(result, 'dark');
    });

    test('emits updates when value changes', () async {
      await dao.set('themeMode', 'dark');

      final emissions = <String?>[];
      final subscription = dao.watch('themeMode').listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.set('themeMode', 'light');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions, contains('dark'));
      expect(emissions, contains('light'));
    });
  });

  group('remove', () {
    test('removes a setting by key', () async {
      await dao.set('themeMode', 'dark');

      final removed = await dao.remove('themeMode');
      expect(removed, 1);

      final result = await dao.get('themeMode');
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
      await dao.set('themeMode', 'dark');
      await dao.set('themePackId', 'oxocarbon');

      final result = await dao.getAll();
      expect(result, {'themeMode': 'dark', 'themePackId': 'oxocarbon'});
    });
  });
}
