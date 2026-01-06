import 'package:drift/drift.dart';
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
    repository = SearchRepository(mockApi, db.searchDao, db.searchCacheDao, mockLogger);
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

        expect(result.items, hasLength(2));
        expect(result.cursor, 'next_page');
        expect(result.hasMore, isTrue);
        expect(result.items.first.text, 'Flutter is awesome');
      });

      test('parses embed data from search results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse());

        final result = await repository.searchPosts('flutter');

        final postWithEmbed = result.items.first;
        expect(postWithEmbed.embed != null, isTrue);
        expect(postWithEmbed.embed![r'$type'], 'app.bsky.embed.images#view');
        expect(postWithEmbed.record != null, isTrue);
        expect(postWithEmbed.record!['text'], 'Flutter is awesome');

        final postWithoutEmbed = result.items.last;
        expect(postWithoutEmbed.embed == null, isTrue);
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

        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
      });

      test('logs error and rethrows on failure', () async {
        final exception = Exception('Search API error');
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

        expect(() => repository.searchPosts('error'), throwsA(isA<Exception>()));

        verify(() => mockLogger.error(any(), exception, any())).called(1);
      });

      test('caches results after successful search', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse());

        await repository.searchPosts('flutter');

        final cached = await repository.getCachedResults('flutter');
        expect(cached, hasLength(2));
        expect(cached.first.post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
      });

      test('caches cursor after successful search', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse(cursor: 'test_cursor'));

        await repository.searchPosts('flutter');

        final cursor = await repository.getCachedCursor('flutter');
        expect(cursor, 'test_cursor');
      });

      test('normalizes query for caching', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse());

        await repository.searchPosts('  FLUTTER  ');

        final cached = await repository.getCachedResults('flutter');
        expect(cached, hasLength(2));
      });
    });

    group('normalizeQuery', () {
      test('trims whitespace and lowercases', () {
        expect(SearchRepository.normalizeQuery('  Flutter  '), 'flutter');
        expect(SearchRepository.normalizeQuery('DART'), 'dart');
        expect(SearchRepository.normalizeQuery('MixedCase'), 'mixedcase');
      });
    });

    group('getCachedResults', () {
      test('returns cached results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockSearchResponse());

        await repository.searchPosts('dart');

        final cached = await repository.getCachedResults('dart');
        expect(cached, hasLength(2));
      });

      test('returns empty list for uncached query', () async {
        final cached = await repository.getCachedResults('nonexistent');
        expect(cached, isEmpty);
      });
    });

    group('cleanupSearchCache', () {
      test('removes stale cache entries', () async {
        final old = DateTime.now().subtract(const Duration(days: 10));
        await db
            .into(db.searchCacheCursors)
            .insert(
              SearchCacheCursorsCompanion.insert(
                queryKey: 'old_query',
                cursor: 'old_cursor',
                lastUpdated: Value(old),
              ),
            );
        await db
            .into(db.posts)
            .insert(
              PostsCompanion.insert(
                uri: 'at://did:plc:old/app.bsky.feed.post/old',
                cid: 'old_cid',
                authorDid: 'did:plc:old',
                record: '{"text": "Old"}',
              ),
            );
        await db
            .into(db.profiles)
            .insert(ProfilesCompanion.insert(did: 'did:plc:old', handle: 'old.bsky'));
        await db
            .into(db.searchCacheItems)
            .insert(
              SearchCacheItemsCompanion.insert(
                queryKey: 'old_query',
                postUri: 'at://did:plc:old/app.bsky.feed.post/old',
                sortKey: '0000000000',
              ),
            );

        await repository.cleanupSearchCache();

        final cached = await repository.getCachedResults('old_query');
        expect(cached, isEmpty);
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

    group('searchActors', () {
      test('searches actors and returns results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockActorsResponse());

        final result = await repository.searchActors('flutter');

        expect(result.items, hasLength(2));
        expect(result.cursor, 'next_actor_page');
        expect(result.hasMore, isTrue);
        expect(result.items.first.handle, 'flutterdev.bsky.social');
        expect(result.items.first.displayName, 'Flutter Developer');
      });

      test('passes cursor for pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockActorsResponse(cursor: null));

        await repository.searchActors('flutter', cursor: 'prev_cursor');

        verify(
          () => mockApi.call(
            'app.bsky.actor.searchActors',
            params: {'q': 'flutter', 'limit': 25, 'cursor': 'prev_cursor'},
          ),
        ).called(1);
      });

      test('handles empty results', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'actors': <dynamic>[]});

        final result = await repository.searchActors('nonexistent');

        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
      });

      test('parses follower and following counts', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockActorsResponse());

        final result = await repository.searchActors('flutter');

        expect(result.items.first.followersCount, 1000);
        expect(result.items.first.followsCount, 500);
      });

      test('logs error and rethrows on failure', () async {
        final exception = Exception('Actor search API error');
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

        expect(() => repository.searchActors('error'), throwsA(isA<Exception>()));

        verify(() => mockLogger.error(any(), exception, any())).called(1);
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
      'embed': {
        r'$type': 'app.bsky.embed.images#view',
        'images': [
          {
            'thumb': 'https://example.com/thumb1.jpg',
            'fullsize': 'https://example.com/full1.jpg',
            'alt': 'Test image',
          },
        ],
      },
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

Map<String, dynamic> _mockActorsResponse({String? cursor = 'next_actor_page'}) => {
  'actors': [
    {
      'did': 'did:plc:user1',
      'handle': 'flutterdev.bsky.social',
      'displayName': 'Flutter Developer',
      'description': 'Building awesome Flutter apps!',
      'avatar': 'https://example.com/avatar1.jpg',
      'followersCount': 1000,
      'followsCount': 500,
      'indexedAt': '2024-01-01T12:00:00.000Z',
    },
    {
      'did': 'did:plc:user2',
      'handle': 'dartlang.bsky.social',
      'displayName': 'Dart Lang',
      'indexedAt': '2024-01-02T12:00:00.000Z',
    },
  ],
  if (cursor != null) 'cursor': cursor,
};
