import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_cache_dao.dart';

void main() {
  late AppDatabase database;
  late SearchCacheDao dao;

  const testOwnerDid = 'did:plc:test';

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.searchCacheDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('SearchCacheDao', () {
    group('insertSearchBatch', () {
      test('inserts posts, profiles, and cache items', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'flutter',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:user1/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:plc:user1',
              record: '{"text": "Hello Flutter"}',
            ),
          ],
          newProfiles: [
            ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'flutterdev.bsky.social'),
          ],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'flutter',
              postUri: 'at://did:plc:user1/app.bsky.feed.post/1',
              sortKey: '0000000000',
            ),
          ],
          newCursor: 'next_page',
        );

        final results = await dao.getSearchResults('flutter', testOwnerDid);
        expect(results, hasLength(1));
        expect(results.first.post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
        expect(results.first.author.handle, 'flutterdev.bsky.social');
      });

      test('updates cursor when provided', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'dart',
          newPosts: [],
          newProfiles: [],
          newItems: [],
          newCursor: 'cursor123',
        );

        final cursor = await dao.getCursor('dart', testOwnerDid);
        expect(cursor, 'cursor123');
      });

      test('does not update cursor when null', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'test',
          newPosts: [],
          newProfiles: [],
          newItems: [],
          newCursor: 'initial',
        );

        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'test',
          newPosts: [],
          newProfiles: [],
          newItems: [],
          newCursor: null,
        );

        final cursor = await dao.getCursor('test', testOwnerDid);
        expect(cursor, 'initial');
      });
    });

    group('getSearchResults', () {
      test('returns results ordered by sortKey', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'order_test',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:user1/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:plc:user1',
              record: '{"text": "First"}',
            ),
            PostsCompanion.insert(
              uri: 'at://did:plc:user2/app.bsky.feed.post/2',
              cid: 'cid2',
              authorDid: 'did:plc:user2',
              record: '{"text": "Second"}',
            ),
          ],
          newProfiles: [
            ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'user1.bsky'),
            ProfilesCompanion.insert(did: 'did:plc:user2', handle: 'user2.bsky'),
          ],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'order_test',
              postUri: 'at://did:plc:user1/app.bsky.feed.post/1',
              sortKey: '0000000000',
            ),
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'order_test',
              postUri: 'at://did:plc:user2/app.bsky.feed.post/2',
              sortKey: '0000000001',
            ),
          ],
          newCursor: null,
        );

        final results = await dao.getSearchResults('order_test', testOwnerDid);
        expect(results, hasLength(2));
        expect(results[0].post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
        expect(results[1].post.uri, 'at://did:plc:user2/app.bsky.feed.post/2');
      });

      test('returns empty list for unknown query', () async {
        final results = await dao.getSearchResults('unknown_query', testOwnerDid);
        expect(results, isEmpty);
      });
    });

    group('watchSearchResults', () {
      test('emits updates when cache changes', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'watch_test',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:user1/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:plc:user1',
              record: '{"text": "Test"}',
            ),
          ],
          newProfiles: [ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'user1.bsky')],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'watch_test',
              postUri: 'at://did:plc:user1/app.bsky.feed.post/1',
              sortKey: '0000000000',
            ),
          ],
          newCursor: null,
        );

        final results = await dao.watchSearchResults('watch_test', testOwnerDid).first;
        expect(results, hasLength(1));
        expect(results.first.post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
      });
    });

    group('getCursor', () {
      test('returns null for unknown query', () async {
        final cursor = await dao.getCursor('nonexistent', testOwnerDid);
        expect(cursor, isNull);
      });

      test('returns cursor for known query', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'cursor_test',
          newPosts: [],
          newProfiles: [],
          newItems: [],
          newCursor: 'my_cursor',
        );

        final cursor = await dao.getCursor('cursor_test', testOwnerDid);
        expect(cursor, 'my_cursor');
      });
    });

    group('clearSearchCache', () {
      test('clears cache for specific query', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'query1',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:user1/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:plc:user1',
              record: '{"text": "Test 1"}',
            ),
          ],
          newProfiles: [ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'user1.bsky')],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'query1',
              postUri: 'at://did:plc:user1/app.bsky.feed.post/1',
              sortKey: '0000000000',
            ),
          ],
          newCursor: 'cursor1',
        );

        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'query2',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:user2/app.bsky.feed.post/2',
              cid: 'cid2',
              authorDid: 'did:plc:user2',
              record: '{"text": "Test 2"}',
            ),
          ],
          newProfiles: [ProfilesCompanion.insert(did: 'did:plc:user2', handle: 'user2.bsky')],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'query2',
              postUri: 'at://did:plc:user2/app.bsky.feed.post/2',
              sortKey: '0000000000',
            ),
          ],
          newCursor: 'cursor2',
        );

        await dao.clearSearchCache('query1', testOwnerDid);

        expect(await dao.getSearchResults('query1', testOwnerDid), isEmpty);
        expect(await dao.getCursor('query1', testOwnerDid), isNull);
        expect(await dao.getSearchResults('query2', testOwnerDid), hasLength(1));
        expect(await dao.getCursor('query2', testOwnerDid), 'cursor2');
      });
    });

    group('deleteStaleCacheItems', () {
      test('deletes items older than threshold', () async {
        final now = DateTime.now();
        final old = now.subtract(const Duration(days: 10));

        await database
            .into(database.searchCacheCursors)
            .insert(
              SearchCacheCursorsCompanion.insert(
                ownerDid: testOwnerDid,
                queryKey: 'old_query',
                cursor: 'old_cursor',
                lastUpdated: Value(old),
              ),
            );
        await database
            .into(database.posts)
            .insert(
              PostsCompanion.insert(
                uri: 'at://did:plc:old/app.bsky.feed.post/old',
                cid: 'old_cid',
                authorDid: 'did:plc:old',
                record: '{"text": "Old"}',
              ),
            );
        await database
            .into(database.profiles)
            .insert(ProfilesCompanion.insert(did: 'did:plc:old', handle: 'old.bsky'));
        await database
            .into(database.searchCacheItems)
            .insert(
              SearchCacheItemsCompanion.insert(
                ownerDid: testOwnerDid,
                queryKey: 'old_query',
                postUri: 'at://did:plc:old/app.bsky.feed.post/old',
                sortKey: '0000000000',
              ),
            );

        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'fresh_query',
          newPosts: [
            PostsCompanion.insert(
              uri: 'at://did:plc:fresh/app.bsky.feed.post/fresh',
              cid: 'fresh_cid',
              authorDid: 'did:plc:fresh',
              record: '{"text": "Fresh"}',
            ),
          ],
          newProfiles: [ProfilesCompanion.insert(did: 'did:plc:fresh', handle: 'fresh.bsky')],
          newItems: [
            SearchCacheItemsCompanion.insert(
              ownerDid: testOwnerDid,
              queryKey: 'fresh_query',
              postUri: 'at://did:plc:fresh/app.bsky.feed.post/fresh',
              sortKey: '0000000000',
            ),
          ],
          newCursor: 'fresh_cursor',
        );

        final threshold = now.subtract(const Duration(days: 7));
        final deleted = await dao.deleteStaleCacheItems(threshold, testOwnerDid);

        expect(deleted, 1);
        expect(await dao.getSearchResults('old_query', testOwnerDid), isEmpty);
        expect(await dao.getCursor('old_query', testOwnerDid), isNull);
        expect(await dao.getSearchResults('fresh_query', testOwnerDid), hasLength(1));
      });

      test('returns 0 when no stale items', () async {
        await dao.insertSearchBatch(
          ownerDid: testOwnerDid,
          queryKey: 'recent',
          newPosts: [],
          newProfiles: [],
          newItems: [],
          newCursor: 'recent_cursor',
        );

        final threshold = DateTime.now().subtract(const Duration(days: 7));
        final deleted = await dao.deleteStaleCacheItems(threshold, testOwnerDid);

        expect(deleted, 0);
      });
    });
  });
}
