import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:lazurite/features/search/data/post_text_extractor.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';
import 'package:lazurite/objectbox.g.dart';

var storeCounter = 0;

ObjectBoxStore makeInMemoryStore() {
  final store = Store(getObjectBoxModel(), directory: 'memory:indexer-test-${storeCounter++}');
  return ObjectBoxStore.forTesting(store);
}

/// Fixed 384-dimensional unit vector (all values 1/sqrt(384)).
Float32List _unitVector() {
  final v = Float32List(384);
  const val = 1.0 / 384;
  for (var i = 0; i < 384; i++) {
    v[i] = val;
  }
  return v;
}

EmbeddingService _availableService() => EmbeddingService.forTesting((_) async => _unitVector());

EmbeddingService _unavailableService() {
  // Returns an uninitialized service (isAvailable == false).
  return EmbeddingService();
}

/// Minimal valid PostView JSON with a text record.
String _savedPostJson(String text) => jsonEncode({
  'uri': 'at://did:plc:author/app.bsky.feed.post/1',
  'cid': 'bafycid1',
  'author': {'did': 'did:plc:author', 'handle': 'author.bsky.social'},
  'record': {'\$type': 'app.bsky.feed.post', 'text': text, 'createdAt': '2024-01-01T00:00:00.000Z'},
  'replyCount': 0,
  'repostCount': 0,
  'likeCount': 0,
  'quoteCount': 0,
  'indexedAt': '2024-01-01T00:00:00.000Z',
});

/// Minimal valid FeedViewPost JSON (liked post format).
String _likedPostJson(String uri, String text) => jsonEncode({
  'post': {
    'uri': uri,
    'cid': 'bafycid2',
    'author': {'did': 'did:plc:author', 'handle': 'author.bsky.social'},
    'record': {'\$type': 'app.bsky.feed.post', 'text': text, 'createdAt': '2024-01-01T00:00:00.000Z'},
    'replyCount': 0,
    'repostCount': 0,
    'likeCount': 0,
    'quoteCount': 0,
    'indexedAt': '2024-01-01T00:00:00.000Z',
  },
});

void main() {
  late AppDatabase database;
  late ObjectBoxStore objectBoxStore;
  late EmbeddingRepository embeddingRepo;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    objectBoxStore = makeInMemoryStore();
    embeddingRepo = EmbeddingRepository(objectBoxStore);
  });

  tearDown(() async {
    await database.close();
    objectBoxStore.close();
  });

  SemanticIndexer makeIndexer({EmbeddingService? service, PostTextExtractor? textExtractor}) => SemanticIndexer(
    embeddingService: service ?? _availableService(),
    embeddingRepository: embeddingRepo,
    database: database,
    textExtractor: textExtractor ?? const PostTextExtractor(),
  );

  group('SemanticIndexer', () {
    group('indexPost', () {
      test('stores embedded post in repository', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.indexPost('at://did/post/1', _savedPostJson('hello world'), 'did:plc:user', 'saved');

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(1));
        final posts = embeddingRepo.queryByAccount('did:plc:user');
        expect(posts.first.postUri, equals('at://did/post/1'));
        expect(posts.first.source, equals('saved'));
        expect(posts.first.embedding, isNotNull);
        expect(posts.first.embedding!.length, equals(384));
      });

      test('extracts text from liked post (FeedViewPost format)', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.indexPost(
          'at://did/post/2',
          _likedPostJson('at://did/post/2', 'liked text'),
          'did:plc:user',
          'liked',
        );

        final posts = embeddingRepo.queryByAccount('did:plc:user');
        expect(posts.first.source, equals('liked'));
        expect(posts.first.indexedText, equals('liked text'));
      });

      test('is a no-op when EmbeddingService is unavailable', () async {
        final indexer = makeIndexer(service: _unavailableService());

        await indexer.indexPost('at://did/post/1', _savedPostJson('hello'), 'did:plc:user', 'saved');

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(0));
      });

      test('is a no-op when extracted text is empty', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        // JSON that cannot be parsed as PostView or FeedViewPost.
        await indexer.indexPost('at://did/post/1', '{}', 'did:plc:user', 'saved');

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(0));
      });

      test('upserts when called twice for the same postUri', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.indexPost('at://did/post/1', _savedPostJson('first'), 'did:plc:user', 'saved');
        await indexer.indexPost('at://did/post/1', _savedPostJson('updated'), 'did:plc:user', 'saved');

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(1));
        final posts = embeddingRepo.queryByAccount('did:plc:user');
        expect(posts.first.indexedText, equals('updated'));
      });
    });

    group('removePost', () {
      test('deletes the embedding entry for the given URI', () async {
        embeddingRepo.upsert(
          EmbeddedPost(
            postUri: 'at://did/post/1',
            accountDid: 'did:plc:user',
            source: 'saved',
            indexedText: 'text',
            embeddedAt: DateTime(2026, 1, 1),
          ),
        );

        final indexer = makeIndexer();
        indexer.removePost('at://did/post/1');

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(0));
      });

      test('is a no-op for a URI that is not indexed', () {
        final indexer = makeIndexer();
        expect(() => indexer.removePost('at://did/post/nonexistent'), returnsNormally);
      });
    });

    group('queueIndexPost', () {
      test('indexes post after queue drains', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        indexer.queueIndexPost('at://did/post/1', _savedPostJson('queued post'), 'did:plc:user', 'saved');

        // Drain the event loop to allow the queue to process.
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(1));
      });

      test('is a no-op when EmbeddingService is unavailable', () async {
        final indexer = makeIndexer(service: _unavailableService());

        indexer.queueIndexPost('at://did/post/1', _savedPostJson('hello'), 'did:plc:user', 'saved');

        await Future<void>.delayed(Duration.zero);
        expect(embeddingRepo.countByAccount('did:plc:user'), equals(0));
      });

      test('processes multiple items serially', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        indexer.queueIndexPost('at://did/post/1', _savedPostJson('one'), 'did:plc:user', 'saved');
        indexer.queueIndexPost('at://did/post/2', _savedPostJson('two'), 'did:plc:user', 'saved');
        indexer.queueIndexPost('at://did/post/3', _savedPostJson('three'), 'did:plc:user', 'saved');

        // Wait for all items to process.
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(3));
      });
    });

    group('backfill', () {
      test('indexes un-indexed saved posts', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/1'),
            postJson: Value(_savedPostJson('saved post')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        final indexer = makeIndexer();
        await indexer.initialize();

        final events = await indexer.backfill('did:plc:user').toList();

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(1));
        expect(events, [(1, 1)]);
      });

      test('indexes un-indexed liked posts', () async {
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/2'),
            postJson: Value(_likedPostJson('at://did/post/2', 'liked post')),
            likedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.backfill('did:plc:user').toList();

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(1));
        final posts = embeddingRepo.queryByAccount('did:plc:user');
        expect(posts.first.source, equals('liked'));
      });

      test('skips already-indexed posts', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/1'),
            postJson: Value(_savedPostJson('already indexed')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        embeddingRepo.upsert(
          EmbeddedPost(
            postUri: 'at://did/post/1',
            accountDid: 'did:plc:user',
            source: 'saved',
            indexedText: 'already indexed',
            embeddedAt: DateTime(2026, 1, 1),
          ),
        );

        final indexer = makeIndexer();
        await indexer.initialize();

        var embedCallCount = 0;
        final countingService = EmbeddingService.forTesting((text) async {
          embedCallCount++;
          return _unitVector();
        });
        final countingIndexer = SemanticIndexer(
          embeddingService: countingService,
          embeddingRepository: embeddingRepo,
          database: database,
        );
        await countingIndexer.initialize();

        await countingIndexer.backfill('did:plc:user').toList();

        // Already indexed, so embed should not be called.
        expect(embedCallCount, equals(0));
      });

      test('emits correct progress tuples', () async {
        for (var i = 1; i <= 3; i++) {
          await database.savePost(
            SavedPostsCompanion(
              accountDid: const Value('did:plc:user'),
              postUri: Value('at://did/post/$i'),
              postJson: Value(_savedPostJson('post $i')),
              savedAt: Value(DateTime(2026, 1, i)),
            ),
          );
        }

        final indexer = makeIndexer();
        await indexer.initialize();

        final events = await indexer.backfill('did:plc:user').toList();

        expect(events, [(1, 3), (2, 3), (3, 3)]);
      });

      test('emits nothing when there are no posts to index', () async {
        final indexer = makeIndexer();
        await indexer.initialize();

        final events = await indexer.backfill('did:plc:user').toList();

        expect(events, isEmpty);
      });

      test('completes immediately when EmbeddingService is unavailable', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/1'),
            postJson: Value(_savedPostJson('hello')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        final indexer = makeIndexer(service: _unavailableService());

        final events = await indexer.backfill('did:plc:user').toList();

        expect(events, isEmpty);
        expect(embeddingRepo.countByAccount('did:plc:user'), equals(0));
      });

      test('does not cross account boundaries', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user-a'),
            postUri: const Value('at://did/post/1'),
            postJson: Value(_savedPostJson('user a post')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user-b'),
            postUri: const Value('at://did/post/2'),
            postJson: Value(_savedPostJson('user b post')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.backfill('did:plc:user-a').toList();

        expect(embeddingRepo.countByAccount('did:plc:user-a'), equals(1));
        expect(embeddingRepo.countByAccount('did:plc:user-b'), equals(0));
      });

      test('indexes both saved and liked posts for the same account', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/saved'),
            postJson: Value(_savedPostJson('saved text')),
            savedAt: Value(DateTime(2026, 1, 1)),
          ),
        );
        await database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: const Value('did:plc:user'),
            postUri: const Value('at://did/post/liked'),
            postJson: Value(_likedPostJson('at://did/post/liked', 'liked text')),
            likedAt: Value(DateTime(2026, 1, 1)),
          ),
        );

        final indexer = makeIndexer();
        await indexer.initialize();

        await indexer.backfill('did:plc:user').toList();

        expect(embeddingRepo.countByAccount('did:plc:user'), equals(2));
        final saved = embeddingRepo.queryByAccount('did:plc:user', source: 'saved');
        final liked = embeddingRepo.queryByAccount('did:plc:user', source: 'liked');
        expect(saved, hasLength(1));
        expect(liked, hasLength(1));
      });
    });
  });
}
