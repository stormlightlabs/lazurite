import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/bluesky_preferences_dao.dart';

void main() {
  late AppDatabase db;
  late BlueskyPreferencesDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.blueskyPreferencesDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('getPreferenceByType', () {
    test('returns null for missing type', () async {
      final result = await dao.getPreferenceByType('nonexistent');
      expect(result, isNull);
    });

    test('returns preference for existing type', () async {
      await dao.upsertPreference(
        type: 'adultContent',
        data: '{"enabled":true}',
        lastSynced: DateTime.now(),
      );
      final result = await dao.getPreferenceByType('adultContent');
      expect(result, isNotNull);
      expect(result!.type, 'adultContent');
      expect(result.data, '{"enabled":true}');
    });
  });

  group('upsertPreference', () {
    test('inserts a new preference', () async {
      await dao.upsertPreference(type: 'contentLabels', data: '[]', lastSynced: DateTime.now());
      final result = await dao.getPreferenceByType('contentLabels');
      expect(result, isNotNull);
      expect(result!.data, '[]');
    });

    test('updates an existing preference', () async {
      final firstSync = DateTime(2024, 1, 1);
      final secondSync = DateTime(2024, 1, 2);

      await dao.upsertPreference(
        type: 'feedView',
        data: '{"hideReplies":false}',
        lastSynced: firstSync,
      );
      await dao.upsertPreference(
        type: 'feedView',
        data: '{"hideReplies":true}',
        lastSynced: secondSync,
      );

      final result = await dao.getPreferenceByType('feedView');
      expect(result, isNotNull);
      expect(result!.data, '{"hideReplies":true}');
      expect(result.lastSynced, secondSync);
    });
  });

  group('getAllPreferences', () {
    test('returns empty list when no preferences exist', () async {
      final result = await dao.getAllPreferences();
      expect(result, isEmpty);
    });

    test('returns all stored preferences', () async {
      final now = DateTime.now();
      await dao.upsertPreference(type: 'adultContent', data: '{"enabled":false}', lastSynced: now);
      await dao.upsertPreference(type: 'threadView', data: '{"sort":"oldest"}', lastSynced: now);

      final result = await dao.getAllPreferences();
      expect(result, hasLength(2));
      expect(result.map((p) => p.type), containsAll(['adultContent', 'threadView']));
    });
  });

  group('watchPreferenceByType', () {
    test('emits null for missing type', () async {
      final result = await dao.watchPreferenceByType('nonexistent').first;
      expect(result, isNull);
    });

    test('emits preference for existing type', () async {
      await dao.upsertPreference(
        type: 'labelers',
        data: '{"labelers":[]}',
        lastSynced: DateTime.now(),
      );
      final result = await dao.watchPreferenceByType('labelers').first;
      expect(result, isNotNull);
      expect(result!.type, 'labelers');
    });

    test('emits updates when preference changes', () async {
      await dao.upsertPreference(
        type: 'mutedWords',
        data: '{"items":[]}',
        lastSynced: DateTime.now(),
      );

      final emissions = <String?>[];
      final subscription = dao
          .watchPreferenceByType('mutedWords')
          .listen((pref) => emissions.add(pref?.data));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.upsertPreference(
        type: 'mutedWords',
        data: '{"items":[{"id":"1","value":"test"}]}',
        lastSynced: DateTime.now(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions, contains('{"items":[]}'));
      expect(emissions, contains('{"items":[{"id":"1","value":"test"}]}'));
    });
  });

  group('watchAllPreferences', () {
    test('emits empty list initially', () async {
      final result = await dao.watchAllPreferences().first;
      expect(result, isEmpty);
    });

    test('emits updates when preferences are added', () async {
      final emissions = <int>[];
      final subscription = dao.watchAllPreferences().listen(
        (prefs) => emissions.add(prefs.length),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.upsertPreference(type: 'adultContent', data: '{}', lastSynced: DateTime.now());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions, contains(0));
      expect(emissions, contains(1));
    });
  });

  group('deletePreference', () {
    test('removes a preference by type', () async {
      await dao.upsertPreference(type: 'feedView', data: '{}', lastSynced: DateTime.now());

      final deleted = await dao.deletePreference('feedView');
      expect(deleted, 1);

      final result = await dao.getPreferenceByType('feedView');
      expect(result, isNull);
    });

    test('returns 0 when type does not exist', () async {
      final deleted = await dao.deletePreference('nonexistent');
      expect(deleted, 0);
    });
  });

  group('clearAll', () {
    test('removes all preferences', () async {
      final now = DateTime.now();
      await dao.upsertPreference(type: 'type1', data: '{}', lastSynced: now);
      await dao.upsertPreference(type: 'type2', data: '{}', lastSynced: now);
      await dao.upsertPreference(type: 'type3', data: '{}', lastSynced: now);

      final cleared = await dao.clearAll();
      expect(cleared, 3);

      final result = await dao.getAllPreferences();
      expect(result, isEmpty);
    });

    test('returns 0 when no preferences exist', () async {
      final cleared = await dao.clearAll();
      expect(cleared, 0);
    });
  });
}
