import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_dao.dart';

void main() {
  late AppDatabase database;
  late SearchDao dao;
  const ownerDid = 'did:plc:test';

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.searchDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('SearchDao', () {
    group('addRecentSearch', () {
      test('inserts a new search query', () async {
        await dao.addRecentSearch('flutter', ownerDid);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, hasLength(1));
        expect(searches.first.query, 'flutter');
      });

      test('trims whitespace from query', () async {
        await dao.addRecentSearch('  flutter  ', ownerDid);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches.first.query, 'flutter');
      });

      test('ignores empty queries', () async {
        await dao.addRecentSearch('', ownerDid);
        await dao.addRecentSearch('   ', ownerDid);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, isEmpty);
      });

      test('updates timestamp for existing query', () async {
        await dao.addRecentSearch('flutter', ownerDid);
        final first = await dao.getRecentSearches(ownerDid);
        final firstTime = first.first.searchedAt;

        await Future<void>.delayed(const Duration(milliseconds: 100));
        await dao.addRecentSearch('flutter', ownerDid);
        final second = await dao.getRecentSearches(ownerDid);
        final secondTime = second.first.searchedAt;

        expect(second, hasLength(1));
        expect(secondTime.millisecondsSinceEpoch >= firstTime.millisecondsSinceEpoch, isTrue);
      });

      test('maintains separate entries for different queries', () async {
        await dao.addRecentSearch('flutter', ownerDid);
        await dao.addRecentSearch('dart', ownerDid);
        await dao.addRecentSearch('riverpod', ownerDid);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, hasLength(3));
        expect(searches.map((s) => s.query), containsAll(['flutter', 'dart', 'riverpod']));
      });
    });

    group('getRecentSearches', () {
      test('returns empty list when no searches', () async {
        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, isEmpty);
      });

      test('returns searches ordered by most recent searchedAt', () async {
        await dao.addRecentSearch('alpha', ownerDid);
        await dao.addRecentSearch('beta', ownerDid);
        await dao.addRecentSearch('gamma', ownerDid);

        final searches = await dao.getRecentSearches(ownerDid);

        expect(searches, hasLength(3));

        expect(
          searches.first.searchedAt.millisecondsSinceEpoch >=
              searches.last.searchedAt.millisecondsSinceEpoch,
          isTrue,
        );
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 20; i++) {
          await dao.addRecentSearch('query$i', ownerDid);
        }

        final searches = await dao.getRecentSearches(ownerDid, limit: 5);
        expect(searches, hasLength(5));
      });

      test('default limit is 10', () async {
        for (var i = 0; i < 15; i++) {
          await dao.addRecentSearch('query$i', ownerDid);
        }

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, hasLength(10));
      });
    });

    group('watchRecentSearches', () {
      test('emits empty list initially', () async {
        final results = await dao.watchRecentSearches(ownerDid).first;
        expect(results, isEmpty);
      });

      test('emits updates when searches are added', () async {
        await dao.addRecentSearch('test', ownerDid);
        final results = await dao.watchRecentSearches(ownerDid).first;
        expect(results, hasLength(1));
        expect(results.first.query, 'test');
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 20; i++) {
          await dao.addRecentSearch('query$i', ownerDid);
        }

        final results = await dao.watchRecentSearches(ownerDid, limit: 3).first;
        expect(results, hasLength(3));
      });
    });

    group('deleteRecentSearch', () {
      test('deletes a specific search', () async {
        await dao.addRecentSearch('flutter', ownerDid);
        await dao.addRecentSearch('dart', ownerDid);

        final deleted = await dao.deleteRecentSearch('flutter', ownerDid);

        expect(deleted, 1);
        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, hasLength(1));
        expect(searches.first.query, 'dart');
      });

      test('returns 0 when search does not exist', () async {
        await dao.addRecentSearch('flutter', ownerDid);

        final deleted = await dao.deleteRecentSearch('nonexistent', ownerDid);
        expect(deleted, 0);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, hasLength(1));
      });
    });

    group('clearAllRecentSearches', () {
      test('removes all searches', () async {
        await dao.addRecentSearch('flutter', ownerDid);
        await dao.addRecentSearch('dart', ownerDid);
        await dao.addRecentSearch('riverpod', ownerDid);

        final deleted = await dao.clearAllRecentSearches(ownerDid);
        expect(deleted, 3);

        final searches = await dao.getRecentSearches(ownerDid);
        expect(searches, isEmpty);
      });

      test('returns 0 when no searches exist', () async {
        final deleted = await dao.clearAllRecentSearches(ownerDid);
        expect(deleted, 0);
      });
    });
  });
}
