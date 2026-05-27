import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/feed.dart';

class MockBluesky extends Mock implements Bluesky {}

void main() {
  group('SimilarPostsRepository', () {
    test('loads likers, reads their public likes, ranks duplicates, and hydrates top candidates', () async {
      final hydratedUris = <List<String>>[];
      final recentLikeCalls = <String>[];
      final repository = SimilarPostsRepository(
        bluesky: MockBluesky(),
        constellationClient: ConstellationClient(),
        likerDidLoader: (postUri, cursor, limit) async {
          expect(postUri, 'at://did:plc:seed/app.bsky.feed.post/root');
          expect(cursor, isNull);
          expect(limit, SimilarPostsRepository.defaultRelationshipLimit);
          return (dids: ['did:plc:liker1', 'did:plc:liker2'], cursor: 'next');
        },
        recentLikedPostUriLoader: (did, limit) async {
          recentLikeCalls.add('$did:$limit');
          return switch (did) {
            'did:plc:liker1' => [
              'at://did:plc:one/app.bsky.feed.post/a',
              'at://did:plc:two/app.bsky.feed.post/b',
              'at://did:plc:seed/app.bsky.feed.post/root',
              'not-a-uri',
            ],
            'did:plc:liker2' => ['at://did:plc:one/app.bsky.feed.post/a', 'at://did:plc:three/app.bsky.feed.post/c'],
            _ => const <String>[],
          };
        },
        postHydrator: (uris) async {
          hydratedUris.add(uris.map((uri) => uri.toString()).toList());
          return [_post('at://did:plc:two/app.bsky.feed.post/b'), _post('at://did:plc:one/app.bsky.feed.post/a')];
        },
      );

      final page = await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');

      expect(page.cursor, 'next');
      expect(recentLikeCalls, [
        'did:plc:liker1:${SimilarPostsRepository.defaultRecentLikesPerLiker}',
        'did:plc:liker2:${SimilarPostsRepository.defaultRecentLikesPerLiker}',
      ]);
      expect(hydratedUris.single, [
        'at://did:plc:one/app.bsky.feed.post/a',
        'at://did:plc:three/app.bsky.feed.post/c',
        'at://did:plc:two/app.bsky.feed.post/b',
      ]);
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
        likerDidLoader: (_, _, _) async => (dids: ['did:plc:liker'], cursor: null),
        recentLikedPostUriLoader: (_, _) async => const [
          '',
          'not-a-uri',
          'at://did:plc:seed/app.bsky.feed.post/root',
          'at://did:plc:actor/app.bsky.feed.like/rkey',
        ],
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
      var likerCalls = 0;
      final repository = SimilarPostsRepository(
        bluesky: MockBluesky(),
        constellationClient: ConstellationClient(),
        now: () => now,
        cacheTtl: const Duration(hours: 1),
        likerDidLoader: (_, _, _) async {
          likerCalls++;
          return (dids: ['did:plc:liker'], cursor: null);
        },
        recentLikedPostUriLoader: (_, _) async => ['at://did:plc:one/app.bsky.feed.post/a'],
        postHydrator: (_) async => [_post('at://did:plc:one/app.bsky.feed.post/a')],
      );

      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');
      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');
      now = now.add(const Duration(hours: 2));
      await repository.getSimilarPosts(postUri: 'at://did:plc:seed/app.bsky.feed.post/root');

      expect(likerCalls, 2);
    });
  });
}

PostView _post(String uri) => testPostView(
  uri: uri,
  cid: 'cid-$uri',
  author: testProfileViewBasic(handle: 'author.example'),
  record: testPostRecordJson(text: 'similar post', createdAt: DateTime.utc(2026, 5, 23)),
  indexedAt: DateTime.utc(2026, 5, 23),
);
