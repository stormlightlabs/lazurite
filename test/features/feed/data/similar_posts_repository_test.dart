import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBluesky extends Mock implements Bluesky {}

void main() {
  group('SimilarPostsRepository', () {
    test('loads relationships, ranks shared-like duplicates, and hydrates only the top candidates', () async {
      final hydratedUris = <List<String>>[];
      final repository = SimilarPostsRepository(
        bluesky: MockBluesky(),
        constellationClient: ConstellationClient(),
        relationshipLoader: (postUri, cursor, limit) async {
          expect(postUri, 'at://did:plc:seed/app.bsky.feed.post/root');
          expect(cursor, isNull);
          expect(limit, 100);
          return (
            items: [
              _item('at://did:plc:one/app.bsky.feed.post/a'),
              _item('at://did:plc:two/app.bsky.feed.post/b'),
              _item('at://did:plc:one/app.bsky.feed.post/a'),
              _item('at://did:plc:seed/app.bsky.feed.post/root'),
              _item('not-a-uri'),
            ],
            cursor: 'next',
          );
        },
        postHydrator: (uris) async {
          hydratedUris.add(uris.map((uri) => uri.toString()).toList());
          return [_post('at://did:plc:two/app.bsky.feed.post/b'), _post('at://did:plc:one/app.bsky.feed.post/a')];
        },
      );

      final page = await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');

      expect(page.cursor, 'next');
      expect(hydratedUris.single, ['at://did:plc:one/app.bsky.feed.post/a', 'at://did:plc:two/app.bsky.feed.post/b']);
      expect(page.posts.map((post) => post.uri.toString()), [
        'at://did:plc:one/app.bsky.feed.post/a',
        'at://did:plc:two/app.bsky.feed.post/b',
      ]);
    });

    test('returns an empty page without hydrating when candidates are all invalid or self', () async {
      var hydrateCalled = false;
      final repository = SimilarPostsRepository(
        bluesky: MockBluesky(),
        constellationClient: ConstellationClient(),
        relationshipLoader: (_, _, _) async => (
          items: [
            _item(''),
            _item('not-a-uri'),
            _item('at://did:plc:seed/app.bsky.feed.post/root'),
            _item('at://did:plc:actor/app.bsky.feed.like/rkey'),
          ],
          cursor: null,
        ),
        postHydrator: (_) async {
          hydrateCalled = true;
          return const <PostView>[];
        },
      );

      final page = await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');

      expect(page.posts, isEmpty);
      expect(hydrateCalled, isFalse);
    });

    test('caches pages within the configured ttl', () async {
      var now = DateTime.utc(2026, 5, 23, 12);
      var relationshipCalls = 0;
      final repository = SimilarPostsRepository(
        bluesky: MockBluesky(),
        constellationClient: ConstellationClient(),
        now: () => now,
        cacheTtl: const Duration(hours: 1),
        relationshipLoader: (_, _, _) async {
          relationshipCalls++;
          return (items: [_item('at://did:plc:one/app.bsky.feed.post/a')], cursor: null);
        },
        postHydrator: (_) async => [_post('at://did:plc:one/app.bsky.feed.post/a')],
      );

      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');
      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');
      now = now.add(const Duration(hours: 2));
      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');

      expect(relationshipCalls, 2);
    });
  });
}

ManyToManyItem _item(String otherSubject) => ManyToManyItem(
  linkRecord: const ConstellationLinkRecord(did: 'did:plc:liker', collection: 'app.bsky.feed.like', rkey: 'like'),
  otherSubject: otherSubject,
);

PostView _post(String uri) => PostView(
  uri: AtUri(uri),
  cid: 'cid-$uri',
  author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.example'),
  record: {
    r'$type': 'app.bsky.feed.post',
    'text': 'similar post',
    'createdAt': DateTime.utc(2026, 5, 23).toIso8601String(),
  },
  indexedAt: DateTime.utc(2026, 5, 23),
);
