import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
  });

  group('FeedBloc', () {
    final samplePost = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:author/app.bsky.feed.post/abc'),
        cid: 'cid-123',
        author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'Hello world',
          'createdAt': DateTime.utc(2026, 3, 15).toIso8601String(),
        },
        indexedAt: DateTime.utc(2026, 3, 15),
      ),
    );

    blocTest<FeedBloc, FeedState>(
      'loads a feed for the requested actor and filter',
      build: () => FeedBloc(feedRepository: mockFeedRepository),
      setUp: () {
        when(
          () => mockFeedRepository.getAuthorFeed(actor: 'did:plc:target', filter: FeedFilter.postsWithMedia, limit: 25),
        ).thenAnswer((_) async => FeedResult(posts: [samplePost], cursor: 'cursor-1'));
      },
      act: (bloc) =>
          bloc.add(const FeedLoadRequested(actor: 'did:plc:target', filter: FeedFilter.postsWithMedia, limit: 25)),
      expect: () => [
        const FeedState.loading(actor: 'did:plc:target', filter: FeedFilter.postsWithMedia),
        predicate<FeedState>(
          (state) =>
              state.status == FeedStatus.loaded &&
              state.actor == 'did:plc:target' &&
              state.filter == FeedFilter.postsWithMedia &&
              state.cursor == 'cursor-1' &&
              state.posts.length == 1,
        ),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'uses the tracked actor for pagination instead of deriving it from returned posts',
      build: () => FeedBloc(feedRepository: mockFeedRepository),
      seed: () => FeedState.loaded(
        actor: 'did:plc:requested',
        posts: [samplePost],
        cursor: 'cursor-2',
        filter: FeedFilter.postsAndAuthorThreads,
        hasMore: true,
      ),
      setUp: () {
        when(
          () => mockFeedRepository.getAuthorFeed(
            actor: 'did:plc:requested',
            filter: FeedFilter.postsAndAuthorThreads,
            cursor: 'cursor-2',
            limit: 50,
          ),
        ).thenAnswer((_) async => FeedResult(posts: const [], cursor: null));
      },
      act: (bloc) => bloc.add(const FeedLoadMoreRequested()),
      expect: () => [
        predicate<FeedState>((state) => state.isLoadingMore && state.actor == 'did:plc:requested'),
        predicate<FeedState>(
          (state) =>
              state.status == FeedStatus.loaded &&
              state.actor == 'did:plc:requested' &&
              !state.isLoadingMore &&
              !state.hasMore,
        ),
      ],
      verify: (_) {
        verify(
          () => mockFeedRepository.getAuthorFeed(
            actor: 'did:plc:requested',
            filter: FeedFilter.postsAndAuthorThreads,
            cursor: 'cursor-2',
            limit: 50,
          ),
        ).called(1);
      },
    );
  });
}
