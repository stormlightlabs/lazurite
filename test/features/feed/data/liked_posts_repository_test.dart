import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getactorlikes.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/data/liked_posts_repository.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';
import 'package:mocktail/mocktail.dart';

class MockSemanticIndexer extends Mock implements SemanticIndexer {}

const _accountDid = 'did:plc:testuser';
const _otherAccountDid = 'did:plc:otheruser';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('LikedPostsRepository', () {
    group('syncLikes', () {
      test('inserts new liked posts into the database', () async {
        final post1 = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1');
        final post2 = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post2');
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(
              pages: [
                FeedGetActorLikesOutput(feed: [post1, post2]),
              ],
            ),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final result = await database.getLikedPosts(_accountDid);
        expect(result, hasLength(2));
        expect(
          result.map((e) => e.postUri).toList(),
          containsAll(['at://did:plc:author/app.bsky.feed.post/post1', 'at://did:plc:author/app.bsky.feed.post/post2']),
        );
      });

      test('stops paginating when a known URI is encountered', () async {
        final post1 = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1');
        final post2 = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post2');

        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: const Value('at://did:plc:author/app.bsky.feed.post/post2'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(
              pages: [
                FeedGetActorLikesOutput(feed: [post1, post2]),
              ],
            ),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final result = await database.getLikedPosts(_accountDid);
        expect(result, hasLength(2));
      });

      test('stops paginating at the 1000-post cap', () async {
        final pages = List.generate(
          5,
          (pageIdx) => FeedGetActorLikesOutput(
            feed: List.generate(100, (i) {
              final idx = pageIdx * 100 + i;
              return _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post$idx');
            }),
            cursor: pageIdx < 4 ? 'cursor-${pageIdx + 1}' : null,
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: pages)),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final result = await database.getLikedPosts(_accountDid, limit: 1100);
        expect(result, hasLength(500));
      });

      test('evicts oldest entries when count exceeds 1000', () async {
        for (var i = 0; i < 1001; i++) {
          await database.upsertLikedPost(
            LikedPostsCompanion(
              accountDid: const Value(_accountDid),
              postUri: Value('at://did:plc:author/app.bsky.feed.post/post$i'),
              postJson: const Value('{}'),
              likedAt: Value(DateTime.now().subtract(Duration(seconds: i))),
            ),
          );
        }

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(pages: [const FeedGetActorLikesOutput(feed: [])]),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final count = await database.countLikedPosts(_accountDid);
        expect(count, equals(1000));
      });

      test('does not insert duplicate posts (idempotent)', () async {
        final post = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1');
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(
              pages: [
                FeedGetActorLikesOutput(feed: [post]),
              ],
            ),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);
        await repo.syncLikes(_accountDid);

        final result = await database.getLikedPosts(_accountDid);
        expect(result, hasLength(1));
      });

      test('paginates using cursor across multiple pages', () async {
        final pages = [
          FeedGetActorLikesOutput(
            feed: [_makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1')],
            cursor: 'page-2',
          ),
          FeedGetActorLikesOutput(feed: [_makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post2')]),
        ];

        final fakeService = _FakeFeedService(pages: pages);
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: fakeService),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        expect(fakeService.callCount, equals(2));
        final result = await database.getLikedPosts(_accountDid);
        expect(result, hasLength(2));
      });

      test('stores postJson as valid JSON', () async {
        final post = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1');
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(
              pages: [
                FeedGetActorLikesOutput(feed: [post]),
              ],
            ),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final result = await database.getLikedPosts(_accountDid);
        expect(result, hasLength(1));
        expect(() => jsonDecode(result.first.postJson), returnsNormally);
      });

      test('isolates posts by accountDid', () async {
        final post = _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/post1');
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(
            feed: _FakeFeedService(
              pages: [
                FeedGetActorLikesOutput(feed: [post]),
              ],
            ),
          ),
          database: database,
        );

        await repo.syncLikes(_accountDid);

        final otherResult = await database.getLikedPosts(_otherAccountDid);
        expect(otherResult, isEmpty);
      });
    });

    group('getLikedPosts', () {
      test('returns empty list when no posts exist', () async {
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final result = await repo.getLikedPosts(_accountDid);
        expect(result, isEmpty);
      });

      test('returns paginated results with limit and offset', () async {
        for (var i = 0; i < 10; i++) {
          await database.upsertLikedPost(
            LikedPostsCompanion(
              accountDid: const Value(_accountDid),
              postUri: Value('at://did:plc:a/app.bsky.feed.post/p$i'),
              postJson: const Value('{}'),
              likedAt: Value(DateTime.now().subtract(Duration(seconds: i))),
            ),
          );
        }

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final page1 = await repo.getLikedPosts(_accountDid, limit: 5, offset: 0);
        final page2 = await repo.getLikedPosts(_accountDid, limit: 5, offset: 5);

        expect(page1, hasLength(5));
        expect(page2, hasLength(5));
        expect({...page1.map((e) => e.postUri), ...page2.map((e) => e.postUri)}, hasLength(10));
      });

      test('orders results by likedAt descending', () async {
        final older = DateTime.now().subtract(const Duration(hours: 1));
        final newer = DateTime.now();

        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: const Value('at://did:plc:a/app.bsky.feed.post/old'),
            postJson: const Value('{}'),
            likedAt: Value(older),
          ),
        );
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: const Value('at://did:plc:a/app.bsky.feed.post/new'),
            postJson: const Value('{}'),
            likedAt: Value(newer),
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final result = await repo.getLikedPosts(_accountDid);
        expect(result.first.postUri, contains('new'));
        expect(result.last.postUri, contains('old'));
      });

      test('only returns posts for the given accountDid', () async {
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: const Value('at://did:plc:a/app.bsky.feed.post/mine'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_otherAccountDid),
            postUri: const Value('at://did:plc:a/app.bsky.feed.post/theirs'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final result = await repo.getLikedPosts(_accountDid);
        expect(result, hasLength(1));
        expect(result.first.postUri, contains('mine'));
      });
    });

    group('removeLike', () {
      test('deletes a liked post by accountDid and postUri', () async {
        const postUri = 'at://did:plc:a/app.bsky.feed.post/post1';
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: const Value(postUri),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final deleted = await repo.removeLike(_accountDid, postUri);
        expect(deleted, equals(1));

        final result = await database.getLikedPosts(_accountDid);
        expect(result, isEmpty);
      });

      test('returns 0 when post does not exist', () async {
        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        final deleted = await repo.removeLike(_accountDid, 'at://did:plc:a/app.bsky.feed.post/nonexistent');
        expect(deleted, equals(0));
      });

      test('does not delete posts belonging to other accounts', () async {
        const postUri = 'at://did:plc:a/app.bsky.feed.post/shared-uri';
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_otherAccountDid),
            postUri: const Value(postUri),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );

        final repo = LikedPostsRepository(
          bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
          database: database,
        );

        await repo.removeLike(_accountDid, postUri);

        final result = await database.getLikedPosts(_otherAccountDid);
        expect(result, hasLength(1));
      });
    });
  });

  group('SemanticIndexer hooks', () {
    late MockSemanticIndexer mockIndexer;

    setUp(() {
      mockIndexer = MockSemanticIndexer();
      when(() => mockIndexer.queueIndexPost(any(), any(), any(), any())).thenReturn(null);
      when(() => mockIndexer.removePost(any())).thenReturn(null);
    });

    test('syncLikes queues newly synced posts for indexing', () async {
      const postUri = 'at://did:plc:author/app.bsky.feed.post/post1';
      final post = _makeFeedViewPost(postUri);
      final repo = LikedPostsRepository(
        bluesky: _FakeBluesky(
          feed: _FakeFeedService(
            pages: [
              FeedGetActorLikesOutput(feed: [post]),
            ],
          ),
        ),
        database: database,
        semanticIndexer: mockIndexer,
      );

      await repo.syncLikes(_accountDid);

      verify(() => mockIndexer.queueIndexPost(postUri, any(), _accountDid, 'liked')).called(1);
    });

    test('syncLikes does not queue already-known posts', () async {
      const postUri = 'at://did:plc:author/app.bsky.feed.post/known';
      await database.upsertLikedPost(
        LikedPostsCompanion(
          accountDid: const Value(_accountDid),
          postUri: const Value(postUri),
          postJson: const Value('{}'),
          likedAt: Value(DateTime.now()),
        ),
      );

      final post = _makeFeedViewPost(postUri);
      final repo = LikedPostsRepository(
        bluesky: _FakeBluesky(
          feed: _FakeFeedService(
            pages: [
              FeedGetActorLikesOutput(feed: [post]),
            ],
          ),
        ),
        database: database,
        semanticIndexer: mockIndexer,
      );

      await repo.syncLikes(_accountDid);

      verifyNever(() => mockIndexer.queueIndexPost(any(), any(), any(), any()));
    });

    test('removeLike removes post from index', () async {
      const postUri = 'at://did:plc:author/app.bsky.feed.post/post1';
      await database.upsertLikedPost(
        LikedPostsCompanion(
          accountDid: const Value(_accountDid),
          postUri: const Value(postUri),
          postJson: const Value('{}'),
          likedAt: Value(DateTime.now()),
        ),
      );

      final repo = LikedPostsRepository(
        bluesky: _FakeBluesky(feed: _FakeFeedService(pages: [])),
        database: database,
        semanticIndexer: mockIndexer,
      );

      await repo.removeLike(_accountDid, postUri);

      verify(() => mockIndexer.removePost(postUri)).called(1);
    });
  });

  group('AppDatabase liked posts methods', () {
    test('upsertLikedPost inserts and ignores duplicates', () async {
      const postUri = 'at://did:plc:a/app.bsky.feed.post/p1';
      final companion = LikedPostsCompanion(
        accountDid: const Value(_accountDid),
        postUri: const Value(postUri),
        postJson: const Value('{"first": true}'),
        likedAt: Value(DateTime.now()),
      );

      await database.upsertLikedPost(companion);

      await database.upsertLikedPost(
        LikedPostsCompanion(
          accountDid: const Value(_accountDid),
          postUri: const Value(postUri),
          postJson: const Value('{"second": true}'),
          likedAt: Value(DateTime.now()),
        ),
      );

      final result = await database.getLikedPosts(_accountDid);
      expect(result, hasLength(1));
      expect(result.first.postJson, contains('first'));
    });

    test('countLikedPosts returns correct count', () async {
      for (var i = 0; i < 5; i++) {
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: Value('at://did:plc:a/app.bsky.feed.post/p$i'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );
      }

      final count = await database.countLikedPosts(_accountDid);
      expect(count, equals(5));

      final otherCount = await database.countLikedPosts(_otherAccountDid);
      expect(otherCount, equals(0));
    });

    test('evictOldestLikedPosts keeps only the N newest entries', () async {
      for (var i = 0; i < 5; i++) {
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: Value('at://did:plc:a/app.bsky.feed.post/p$i'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now().subtract(Duration(seconds: i))),
          ),
        );
      }

      await database.evictOldestLikedPosts(_accountDid, 3);

      final result = await database.getLikedPosts(_accountDid, limit: 10);
      expect(result, hasLength(3));

      expect(
        result.map((e) => e.postUri),
        containsAll([
          'at://did:plc:a/app.bsky.feed.post/p0',
          'at://did:plc:a/app.bsky.feed.post/p1',
          'at://did:plc:a/app.bsky.feed.post/p2',
        ]),
      );
    });

    test('deleteAllLikedPosts removes all posts for account', () async {
      for (var i = 0; i < 3; i++) {
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value(_accountDid),
            postUri: Value('at://did:plc:a/app.bsky.feed.post/p$i'),
            postJson: const Value('{}'),
            likedAt: Value(DateTime.now()),
          ),
        );
      }
      await database.upsertLikedPost(
        LikedPostsCompanion(
          accountDid: const Value(_otherAccountDid),
          postUri: const Value('at://did:plc:a/app.bsky.feed.post/other'),
          postJson: const Value('{}'),
          likedAt: Value(DateTime.now()),
        ),
      );

      await database.deleteAllLikedPosts(_accountDid);

      expect(await database.getLikedPosts(_accountDid), isEmpty);
      expect(await database.getLikedPosts(_otherAccountDid), hasLength(1));
    });
  });
}

FeedViewPost _makeFeedViewPost(String uriStr) {
  return FeedViewPost(
    post: PostView(
      uri: AtUri.parse(uriStr),
      cid: 'cid-${uriStr.hashCode}',
      author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
      record: const {r'$type': 'app.bsky.feed.post', 'text': 'Test post', 'createdAt': '2026-01-01T00:00:00.000Z'},
      indexedAt: DateTime.utc(2026, 1, 1),
    ),
  );
}

class _FakeBluesky {
  _FakeBluesky({required this.feed});

  final _FakeFeedService feed;
}

class _FakeFeedService {
  _FakeFeedService({required this.pages});

  final List<FeedGetActorLikesOutput> pages;
  int _callIndex = 0;
  int callCount = 0;

  Future<_FakeXRPCResponse<FeedGetActorLikesOutput>> getActorLikes({
    required String actor,
    int? limit,
    String? cursor,
  }) async {
    callCount++;
    if (_callIndex >= pages.length) {
      return _FakeXRPCResponse(const FeedGetActorLikesOutput(feed: []));
    }
    return _FakeXRPCResponse(pages[_callIndex++]);
  }
}

class _FakeXRPCResponse<T> {
  _FakeXRPCResponse(this.data);

  final T data;
}
