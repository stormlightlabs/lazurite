import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/objectbox.g.dart';

var _storeCounter = 0;

ObjectBoxStore _makeInMemoryStore() {
  final store = Store(getObjectBoxModel(), directory: 'memory:search-repo-${_storeCounter++}');
  return ObjectBoxStore.forTesting(store);
}

Float32List _unitVector() {
  final v = Float32List(384);
  const val = 1.0 / 384;
  for (var i = 0; i < 384; i++) {
    v[i] = val;
  }
  return v;
}

EmbeddingService _availableService() => EmbeddingService.forTesting((_) async => _unitVector());

EmbeddingService _unavailableService() => EmbeddingService();

String _savedPostJson(String uri, String text) => jsonEncode({
  'uri': uri,
  'cid': 'bafycid1',
  'author': {'did': 'did:plc:author', 'handle': 'author.bsky.social'},
  'record': {'\$type': 'app.bsky.feed.post', 'text': text, 'createdAt': '2024-01-01T00:00:00.000Z'},
  'replyCount': 0,
  'repostCount': 0,
  'likeCount': 0,
  'quoteCount': 0,
  'indexedAt': '2024-01-01T00:00:00.000Z',
});

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
  late EmbeddingService embeddingService;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    objectBoxStore = _makeInMemoryStore();
    embeddingRepo = EmbeddingRepository(objectBoxStore);
    embeddingService = _availableService();
    await embeddingService.initialize();
  });

  tearDown(() async {
    await database.close();
    objectBoxStore.close();
  });

  SemanticSearchRepository makeRepo({EmbeddingService? service}) => SemanticSearchRepository(
    embeddingService: service ?? embeddingService,
    embeddingRepository: embeddingRepo,
    database: database,
  );

  /// Inserts an EmbeddedPost in ObjectBox and the corresponding raw post JSON
  /// in the Drift SavedPosts table.
  Future<void> insertSavedPost(
    String postUri,
    String accountDid, {
    String text = 'post text',
    List<double>? embedding,
  }) async {
    final json = _savedPostJson(postUri, text);
    embeddingRepo.upsert(
      EmbeddedPost(
        postUri: postUri,
        accountDid: accountDid,
        source: 'saved',
        indexedText: text,
        embedding: embedding ?? _unitVector().toList(),
        embeddedAt: DateTime(2026, 1, 1),
      ),
    );
    await database.savePost(
      SavedPostsCompanion(accountDid: Value(accountDid), postUri: Value(postUri), postJson: Value(json)),
    );
  }

  /// Inserts an EmbeddedPost in ObjectBox and the corresponding raw post JSON
  /// in the Drift LikedPosts table.
  Future<void> insertLikedPost(
    String postUri,
    String accountDid, {
    String text = 'post text',
    List<double>? embedding,
  }) async {
    final json = _likedPostJson(postUri, text);
    embeddingRepo.upsert(
      EmbeddedPost(
        postUri: postUri,
        accountDid: accountDid,
        source: 'liked',
        indexedText: text,
        embedding: embedding ?? _unitVector().toList(),
        embeddedAt: DateTime(2026, 1, 1),
      ),
    );
    await database.upsertLikedPost(
      LikedPostsCompanion(accountDid: Value(accountDid), postUri: Value(postUri), postJson: Value(json)),
    );
  }

  group('SemanticSearchRepository', () {
    group('search', () {
      test('returns empty list when EmbeddingService is unavailable', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user');

        final repo = makeRepo(service: _unavailableService());
        final results = await repo.search('hello', 'did:plc:user');

        expect(results, isEmpty);
      });

      test('returns empty list when query is empty', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('', 'did:plc:user');

        expect(results, isEmpty);
      });

      test('returns empty list when query is whitespace only', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('   ', 'did:plc:user');

        expect(results, isEmpty);
      });

      test('returns empty list when no posts are indexed', () async {
        final repo = makeRepo();
        final results = await repo.search('query', 'did:plc:user');

        expect(results, isEmpty);
      });

      test('returns SemanticSearchResult with correct postUri and source', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user', text: 'interesting article');

        final repo = makeRepo();
        final results = await repo.search('interesting', 'did:plc:user');

        expect(results, hasLength(1));
        expect(results.first.postUri, equals('at://did/post/1'));
        expect(results.first.source, equals('saved'));
      });

      test('result contains postJson from Drift SavedPosts', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user', text: 'test post');

        final repo = makeRepo();
        final results = await repo.search('test', 'did:plc:user');

        expect(results, hasLength(1));
        final decoded = jsonDecode(results.first.postJson) as Map<String, dynamic>;
        expect(decoded['uri'], equals('at://did/post/1'));
      });

      test('result contains postJson from Drift LikedPosts', () async {
        await insertLikedPost('at://did/post/2', 'did:plc:user', text: 'liked content');

        final repo = makeRepo();
        final results = await repo.search('content', 'did:plc:user');

        expect(results, hasLength(1));
        expect(results.first.source, equals('liked'));
        final decoded = jsonDecode(results.first.postJson) as Map<String, dynamic>;
        // liked post JSON has a nested 'post' key
        expect((decoded['post'] as Map<String, dynamic>)['uri'], equals('at://did/post/2'));
      });

      test('score is in the range [0, 100]', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user');

        expect(results, isNotEmpty);
        expect(results.first.score, greaterThanOrEqualTo(0.0));
        expect(results.first.score, lessThanOrEqualTo(100.0));
      });

      test('identical-vector query produces near-100% score', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user');

        // Query with the same unit vector the post was indexed with.
        final svc = EmbeddingService.forTesting((_) async => _unitVector());
        await svc.initialize();
        final repo = makeRepo(service: svc);
        final results = await repo.search('hello', 'did:plc:user');

        expect(results, isNotEmpty);
        // Score should be very close to 100%.
        expect(results.first.score, greaterThan(90.0));
      });

      test('filters results to the searched accountDid only', () async {
        await insertSavedPost('at://did/post/1', 'did:plc:user-a');
        await insertSavedPost('at://did/post/2', 'did:plc:user-b');

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user-a');

        expect(results.length, equals(1));
        expect(results.first.postUri, equals('at://did/post/1'));
      });

      test('returns both saved and liked posts by default', () async {
        await insertSavedPost('at://did/post/saved', 'did:plc:user');
        await insertLikedPost('at://did/post/liked', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user');

        expect(results.length, equals(2));
        final sources = results.map((r) => r.source).toSet();
        expect(sources, containsAll(['saved', 'liked']));
      });

      test('filters to saved posts when source is "saved"', () async {
        await insertSavedPost('at://did/post/saved', 'did:plc:user');
        await insertLikedPost('at://did/post/liked', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user', source: 'saved');

        expect(results.length, equals(1));
        expect(results.first.source, equals('saved'));
        expect(results.first.postUri, equals('at://did/post/saved'));
      });

      test('filters to liked posts when source is "liked"', () async {
        await insertSavedPost('at://did/post/saved', 'did:plc:user');
        await insertLikedPost('at://did/post/liked', 'did:plc:user');

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user', source: 'liked');

        expect(results.length, equals(1));
        expect(results.first.source, equals('liked'));
        expect(results.first.postUri, equals('at://did/post/liked'));
      });

      test('skips results whose postJson cannot be found in Drift', () async {
        // Insert embedding in ObjectBox but NOT in Drift.
        embeddingRepo.upsert(
          EmbeddedPost(
            postUri: 'at://did/post/orphan',
            accountDid: 'did:plc:user',
            source: 'saved',
            indexedText: 'orphaned post',
            embedding: _unitVector().toList(),
            embeddedAt: DateTime(2026, 1, 1),
          ),
        );

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user');

        // The orphaned result is silently skipped.
        expect(results, isEmpty);
      });

      test('respects maxResults limit', () async {
        for (var i = 1; i <= 10; i++) {
          await insertSavedPost('at://did/post/$i', 'did:plc:user');
        }

        final repo = makeRepo();
        final results = await repo.search('hello', 'did:plc:user', maxResults: 3);

        expect(results.length, lessThanOrEqualTo(3));
      });
    });
  });
}
