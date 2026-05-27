import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/feed/cubit/similar_posts_cubit.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/feed.dart';

class MockBluesky extends Mock implements Bluesky {}

void main() {
  group('SimilarPostsCubit', () {
    blocTest<SimilarPostsCubit, SimilarPostsState>(
      'loads the first page on demand',
      build: () => SimilarPostsCubit(
        repository: _repository(candidateUris: ['at://did:plc:one/app.bsky.feed.post/a'], cursor: 'next'),
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
          repository: _repositoryWithLoader(
            (_, cursor, _) async {
              call++;
              if (call == 1) {
                return (dids: ['did:plc:liker1'], cursor: 'next');
              }
              expect(cursor, 'next');
              return (dids: ['did:plc:liker2'], cursor: null);
            },
            recentLikedPostUriLoader: (did, _) async {
              return switch (did) {
                'did:plc:liker1' => ['at://did:plc:one/app.bsky.feed.post/a'],
                'did:plc:liker2' => ['at://did:plc:one/app.bsky.feed.post/a', 'at://did:plc:two/app.bsky.feed.post/b'],
                _ => const <String>[],
              };
            },
          ),
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

SimilarPostsRepository _repository({required List<String> candidateUris, String? cursor}) => _repositoryWithLoader(
  (_, _, _) async => (dids: ['did:plc:liker'], cursor: cursor),
  recentLikedPostUriLoader: (_, _) async => candidateUris,
);

SimilarPostsRepository _repositoryWithLoader(
  Future<({List<String> dids, String? cursor})> Function(String postUri, String? cursor, int limit) loader, {
  required Future<List<String>> Function(String did, int limit) recentLikedPostUriLoader,
}) {
  return SimilarPostsRepository(
    bluesky: MockBluesky(),
    constellationClient: ConstellationClient(),
    likerDidLoader: loader,
    recentLikedPostUriLoader: recentLikedPostUriLoader,
    postHydrator: (uris) async => uris.map((uri) => _post(uri.toString())).toList(),
  );
}

PostView _post(String uri) => testPostView(
  uri: uri,
  cid: 'cid-$uri',
  author: testProfileViewBasic(handle: 'author.example'),
  record: testPostRecordJson(text: 'similar post', createdAt: DateTime.utc(2026, 5, 23)),
  indexedAt: DateTime.utc(2026, 5, 23),
);
