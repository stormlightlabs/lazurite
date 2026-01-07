import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_dao.dart';

void main() {
  late AppDatabase database;
  late SearchDao dao;

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
        await dao.addRecentSearch('flutter');

        final searches = await dao.getRecentSearches();
        expect(searches, hasLength(1));
        expect(searches.first.query, 'flutter');
      });

      test('trims whitespace from query', () async {
        await dao.addRecentSearch('  flutter  ');

        final searches = await dao.getRecentSearches();
        expect(searches.first.query, 'flutter');
      });

      test('ignores empty queries', () async {
        await dao.addRecentSearch('');
        await dao.addRecentSearch('   ');

        final searches = await dao.getRecentSearches();
        expect(searches, isEmpty);
      });

      test('updates timestamp for existing query', () async {
        await dao.addRecentSearch('flutter');
        final first = await dao.getRecentSearches();
        final firstTime = first.first.searchedAt;

        await Future<void>.delayed(const Duration(milliseconds: 100));
        await dao.addRecentSearch('flutter');
        final second = await dao.getRecentSearches();
        final secondTime = second.first.searchedAt;

        expect(second, hasLength(1));
        expect(secondTime.millisecondsSinceEpoch >= firstTime.millisecondsSinceEpoch, isTrue);
      });

      test('maintains separate entries for different queries', () async {
        await dao.addRecentSearch('flutter');
        await dao.addRecentSearch('dart');
        await dao.addRecentSearch('riverpod');

        final searches = await dao.getRecentSearches();
        expect(searches, hasLength(3));
        expect(searches.map((s) => s.query), containsAll(['flutter', 'dart', 'riverpod']));
      });
    });

    group('getRecentSearches', () {
      test('returns empty list when no searches', () async {
        final searches = await dao.getRecentSearches();
        expect(searches, isEmpty);
      });

      test('returns searches ordered by most recent searchedAt', () async {
        await dao.addRecentSearch('alpha');
        await dao.addRecentSearch('beta');
        await dao.addRecentSearch('gamma');

        final searches = await dao.getRecentSearches();

        expect(searches, hasLength(3));

        expect(
          searches.first.searchedAt.millisecondsSinceEpoch >=
              searches.last.searchedAt.millisecondsSinceEpoch,
          isTrue,
        );
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 20; i++) {
          await dao.addRecentSearch('query$i');
        }

        final searches = await dao.getRecentSearches(limit: 5);
        expect(searches, hasLength(5));
      });

      test('default limit is 10', () async {
        for (var i = 0; i < 15; i++) {
          await dao.addRecentSearch('query$i');
        }

        final searches = await dao.getRecentSearches();
        expect(searches, hasLength(10));
      });
    });

    group('watchRecentSearches', () {
      test('emits empty list initially', () async {
        final results = await dao.watchRecentSearches().first;
        expect(results, isEmpty);
      });

      test('emits updates when searches are added', () async {
        await dao.addRecentSearch('test');
        final results = await dao.watchRecentSearches().first;
        expect(results, hasLength(1));
        expect(results.first.query, 'test');
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 20; i++) {
          await dao.addRecentSearch('query$i');
        }

        final results = await dao.watchRecentSearches(limit: 3).first;
        expect(results, hasLength(3));
      });
    });

    group('deleteRecentSearch', () {
      test('deletes a specific search', () async {
        await dao.addRecentSearch('flutter');
        await dao.addRecentSearch('dart');

        final deleted = await dao.deleteRecentSearch('flutter');

        expect(deleted, 1);
        final searches = await dao.getRecentSearches();
        expect(searches, hasLength(1));
        expect(searches.first.query, 'dart');
      });

      test('returns 0 when search does not exist', () async {
        await dao.addRecentSearch('flutter');

        final deleted = await dao.deleteRecentSearch('nonexistent');
        expect(deleted, 0);

        final searches = await dao.getRecentSearches();
        expect(searches, hasLength(1));
      });
    });

    group('clearAllRecentSearches', () {
      test('removes all searches', () async {
        await dao.addRecentSearch('flutter');
        await dao.addRecentSearch('dart');
        await dao.addRecentSearch('riverpod');

        final deleted = await dao.clearAllRecentSearches();
        expect(deleted, 3);

        final searches = await dao.getRecentSearches();
        expect(searches, isEmpty);
      });

      test('returns 0 when no searches exist', () async {
        final deleted = await dao.clearAllRecentSearches();
        expect(deleted, 0);
      });
    });
  });
}
