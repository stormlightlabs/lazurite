import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/cubit/similar_posts_cubit.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBluesky extends Mock implements Bluesky {}

void main() {
  group('SimilarPostsCubit', () {
    blocTest<SimilarPostsCubit, SimilarPostsState>(
      'loads the first page on demand',
      build: () => SimilarPostsCubit(
        repository: _repository(items: [_item('at://did:plc:one/app.bsky.feed.post/a')], cursor: 'next'),
      ),
      act: (cubit) => cubit.load('at://did:plc:seed/app.bsky.feed.post/root'),
      expect: () => [
        const SimilarPostsState(status: SimilarPostsStatus.loading),
        isA<SimilarPostsState>()
            .having((state) => state.status, 'status', SimilarPostsStatus.loaded)
            .having((state) => state.posts.length, 'posts length', 1)
            .having((state) => state.cursor, 'cursor', 'next'),
      ],
    );

    blocTest<SimilarPostsCubit, SimilarPostsState>(
      'merges loadMore results without duplicates',
      build: () {
        var call = 0;
        return SimilarPostsCubit(
          repository: _repositoryWithLoader((_, cursor, _) async {
            call++;
            if (call == 1) {
              return (items: [_item('at://did:plc:one/app.bsky.feed.post/a')], cursor: 'next');
            }
            expect(cursor, 'next');
            return (
              items: [_item('at://did:plc:one/app.bsky.feed.post/a'), _item('at://did:plc:two/app.bsky.feed.post/b')],
              cursor: null,
            );
          }),
        );
      },
      act: (cubit) async {
        await cubit.load('at://did:plc:seed/app.bsky.feed.post/root');
        await cubit.loadMore();
      },
      expect: () => [
        const SimilarPostsState(status: SimilarPostsStatus.loading),
        isA<SimilarPostsState>().having((state) => state.posts.length, 'posts length', 1),
        isA<SimilarPostsState>().having((state) => state.status, 'status', SimilarPostsStatus.loadingMore),
        isA<SimilarPostsState>().having((state) => state.status, 'status', SimilarPostsStatus.loaded).having(
          (state) => state.posts.map((post) => post.uri.toString()),
          'uris',
          ['at://did:plc:one/app.bsky.feed.post/a', 'at://did:plc:two/app.bsky.feed.post/b'],
        ),
      ],
    );
  });
}

SimilarPostsRepository _repository({required List<ManyToManyItem> items, String? cursor}) =>
    _repositoryWithLoader((_, _, _) async => (items: items, cursor: cursor));

SimilarPostsRepository _repositoryWithLoader(
  Future<({List<ManyToManyItem> items, String? cursor})> Function(String postUri, String? cursor, int limit) loader,
) {
  return SimilarPostsRepository(
    bluesky: MockBluesky(),
    constellationClient: ConstellationClient(),
    relationshipLoader: loader,
    postHydrator: (uris) async => uris.map((uri) => _post(uri.toString())).toList(),
  );
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
