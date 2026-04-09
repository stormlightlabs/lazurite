import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/objectbox.g.dart';

var _storeCounter = 0;

ObjectBoxStore _makeInMemoryStore() {
  final store = Store(getObjectBoxModel(), directory: 'memory:test-${_storeCounter++}');
  return ObjectBoxStore.forTesting(store);
}

EmbeddedPost _post({
  required String postUri,
  required String accountDid,
  String source = 'saved',
  String indexedText = 'some text',
  List<double>? embedding,
}) => EmbeddedPost(
  postUri: postUri,
  accountDid: accountDid,
  source: source,
  indexedText: indexedText,
  embedding: embedding,
  embeddedAt: DateTime(2026, 1, 1),
);

void main() {
  late ObjectBoxStore objectBoxStore;
  late EmbeddingRepository repo;

  setUp(() {
    objectBoxStore = _makeInMemoryStore();
    repo = EmbeddingRepository(objectBoxStore);
  });

  tearDown(() {
    objectBoxStore.close();
  });

  group('EmbeddingRepository', () {
    group('upsert', () {
      test('inserts a new post', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a'));

        expect(repo.countByAccount('did:plc:a'), equals(1));
      });

      test('updates an existing post with the same postUri', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a', indexedText: 'original'));
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a', indexedText: 'updated'));

        final results = repo.queryByAccount('did:plc:a');
        expect(results.length, equals(1));
        expect(results.first.indexedText, equals('updated'));
      });

      test('stores the embedding vector', () {
        final embedding = List<double>.generate(384, (i) => i.toDouble());
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a', embedding: embedding));

        final results = repo.queryByAccount('did:plc:a');
        expect(results.first.embedding, equals(embedding));
      });
    });

    group('deleteByUri', () {
      test('removes the entry for the given postUri', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a'));
        repo.upsert(_post(postUri: 'at://did/post/2', accountDid: 'did:plc:a'));

        repo.deleteByUri('at://did/post/1');

        expect(repo.countByAccount('did:plc:a'), equals(1));
        final remaining = repo.queryByAccount('did:plc:a');
        expect(remaining.first.postUri, equals('at://did/post/2'));
      });

      test('is a no-op for a non-existent postUri', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a'));

        repo.deleteByUri('at://did/post/nonexistent');

        expect(repo.countByAccount('did:plc:a'), equals(1));
      });
    });

    group('queryByAccount', () {
      test('returns only posts for the given accountDid', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a'));
        repo.upsert(_post(postUri: 'at://did/post/2', accountDid: 'did:plc:b'));

        final results = repo.queryByAccount('did:plc:a');
        expect(results.length, equals(1));
        expect(results.first.accountDid, equals('did:plc:a'));
      });

      test('filters by source when provided', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a', source: 'saved'));
        repo.upsert(_post(postUri: 'at://did/post/2', accountDid: 'did:plc:a', source: 'liked'));

        final saved = repo.queryByAccount('did:plc:a', source: 'saved');
        expect(saved.length, equals(1));
        expect(saved.first.source, equals('saved'));

        final liked = repo.queryByAccount('did:plc:a', source: 'liked');
        expect(liked.length, equals(1));
        expect(liked.first.source, equals('liked'));
      });

      test('returns all posts when source is not provided', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a', source: 'saved'));
        repo.upsert(_post(postUri: 'at://did/post/2', accountDid: 'did:plc:a', source: 'liked'));

        expect(repo.queryByAccount('did:plc:a').length, equals(2));
      });

      test('returns empty list when account has no posts', () {
        expect(repo.queryByAccount('did:plc:nobody'), isEmpty);
      });
    });

    group('countByAccount', () {
      test('returns 0 for empty store', () {
        expect(repo.countByAccount('did:plc:a'), equals(0));
      });

      test('counts only posts for the given account', () {
        repo.upsert(_post(postUri: 'at://did/post/1', accountDid: 'did:plc:a'));
        repo.upsert(_post(postUri: 'at://did/post/2', accountDid: 'did:plc:a'));
        repo.upsert(_post(postUri: 'at://did/post/3', accountDid: 'did:plc:b'));

        expect(repo.countByAccount('did:plc:a'), equals(2));
        expect(repo.countByAccount('did:plc:b'), equals(1));
      });
    });
  });
}
