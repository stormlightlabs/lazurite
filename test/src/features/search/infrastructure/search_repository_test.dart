import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late SearchRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = SearchRepository(mockApi, db.searchDao, mockLogger);
  });

  tearDown(() async {
    await db.close();
  });

  group('SearchRepository', () {
    group('searchPosts', () {
      test('searches posts and returns results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse());

        final result = await repository.searchPosts('flutter');

        expect(result.posts, hasLength(2));
        expect(result.cursor, 'next_page');
        expect(result.hasMore, isTrue);
        expect(result.posts.first.text, 'Flutter is awesome');
      });

      test('passes cursor for pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse(cursor: null));

        await repository.searchPosts('flutter', cursor: 'prev_cursor');

        verify(
          () => mockApi.call(
            'app.bsky.feed.searchPosts',
            params: {'q': 'flutter', 'limit': 25, 'cursor': 'prev_cursor'},
          ),
        ).called(1);
      });

      test('handles empty results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'posts': <dynamic>[]});

        final result = await repository.searchPosts('nonexistent_query');

        expect(result.posts, isEmpty);
        expect(result.hasMore, isFalse);
      });

      test('logs error and rethrows on failure', () async {
        final exception = Exception('Search API error');
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

        expect(() => repository.searchPosts('error'), throwsA(isA<Exception>()));

        verify(() => mockLogger.error(any(), exception, any())).called(1);
      });
    });

    group('saveRecentSearch', () {
      test('saves search to DAO', () async {
        await repository.saveRecentSearch('flutter');

        final searches = await db.searchDao.getRecentSearches();
        expect(searches, hasLength(1));
        expect(searches.first.query, 'flutter');
      });
    });

    group('getRecentSearches', () {
      test('returns searches from DAO', () async {
        await db.searchDao.addRecentSearch('flutter');
        await db.searchDao.addRecentSearch('dart');

        final result = await repository.getRecentSearches();

        expect(result, hasLength(2));
        expect(result.map((s) => s.query), containsAll(['flutter', 'dart']));
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 20; i++) {
          await db.searchDao.addRecentSearch('query$i');
        }

        final result = await repository.getRecentSearches(limit: 5);
        expect(result, hasLength(5));
      });
    });

    group('watchRecentSearches', () {
      test('returns stream from DAO', () async {
        await db.searchDao.addRecentSearch('test');

        final results = await repository.watchRecentSearches().first;
        expect(results, hasLength(1));
        expect(results.first.query, 'test');
      });
    });

    group('removeRecentSearch', () {
      test('deletes search from DAO', () async {
        await db.searchDao.addRecentSearch('flutter');
        await db.searchDao.addRecentSearch('dart');

        await repository.removeRecentSearch('flutter');

        final searches = await db.searchDao.getRecentSearches();
        expect(searches, hasLength(1));
        expect(searches.first.query, 'dart');
      });
    });

    group('clearAllRecentSearches', () {
      test('clears all searches in DAO', () async {
        await db.searchDao.addRecentSearch('flutter');
        await db.searchDao.addRecentSearch('dart');

        await repository.clearAllRecentSearches();

        final searches = await db.searchDao.getRecentSearches();
        expect(searches, isEmpty);
      });
    });
  });
}

Map<String, dynamic> _mockSearchResponse({String? cursor = 'next_page'}) => {
  'posts': [
    {
      'uri': 'at://did:plc:user1/app.bsky.feed.post/1',
      'cid': 'cid1',
      'author': {
        'did': 'did:plc:user1',
        'handle': 'flutterdev.bsky.social',
        'displayName': 'Flutter Developer',
        'avatar': 'https://example.com/avatar1.jpg',
      },
      'record': {'text': 'Flutter is awesome'},
      'indexedAt': '2024-01-01T12:00:00.000Z',
      'replyCount': 10,
      'repostCount': 5,
      'likeCount': 50,
    },
    {
      'uri': 'at://did:plc:user2/app.bsky.feed.post/2',
      'cid': 'cid2',
      'author': {'did': 'did:plc:user2', 'handle': 'dartlang.bsky.social'},
      'record': {'text': 'Dart programming'},
      'indexedAt': '2024-01-02T12:00:00.000Z',
    },
  ],
  if (cursor != null) 'cursor': cursor,
};
