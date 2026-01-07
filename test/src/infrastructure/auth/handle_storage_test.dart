import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/handle_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HandleStorage', () {
    late HandleStorage handleStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      handleStorage = HandleStorage(prefs);
    });

    test('getLastHandle returns null when no handle is saved', () {
      expect(handleStorage.getLastHandle(), isNull);
    });

    test('saveHandle stores the handle', () async {
      await handleStorage.saveHandle('alice.bsky.social');
      expect(handleStorage.getLastHandle(), equals('alice.bsky.social'));
    });

    test('saveHandle trims whitespace', () async {
      await handleStorage.saveHandle('  bob.bsky.social  ');
      expect(handleStorage.getLastHandle(), equals('bob.bsky.social'));
    });

    test('saveHandle overwrites previous handle', () async {
      await handleStorage.saveHandle('alice.bsky.social');
      await handleStorage.saveHandle('bob.bsky.social');
      expect(handleStorage.getLastHandle(), equals('bob.bsky.social'));
    });

    test('clearHandle removes the saved handle', () async {
      await handleStorage.saveHandle('alice.bsky.social');
      expect(handleStorage.getLastHandle(), isNotNull);

      await handleStorage.clearHandle();
      expect(handleStorage.getLastHandle(), isNull);
    });

    test('clearHandle is idempotent when no handle exists', () async {
      await handleStorage.clearHandle();
      expect(handleStorage.getLastHandle(), isNull);

      await handleStorage.clearHandle();
      expect(handleStorage.getLastHandle(), isNull);
    });

    test('handle persists across HandleStorage instances', () async {
      await handleStorage.saveHandle('alice.bsky.social');

      final prefs = await SharedPreferences.getInstance();
      final newStorage = HandleStorage(prefs);
      expect(newStorage.getLastHandle(), equals('alice.bsky.social'));
    });
  });
}
