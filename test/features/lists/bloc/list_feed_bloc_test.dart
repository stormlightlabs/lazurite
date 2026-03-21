import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/bloc/list_feed_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockListRepository mockListRepository;

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.list/fallback'));
  });

  setUp(() {
    mockListRepository = MockListRepository();
  });

  group('ListFeedBloc', () {
    final firstPost = _buildPost('at://did:plc:member-1/app.bsky.feed.post/post-1', 'First post');
    final secondPost = _buildPost('at://did:plc:member-2/app.bsky.feed.post/post-2', 'Second post');

    blocTest<ListFeedBloc, ListFeedState>(
      'loads the list feed',
      build: () => ListFeedBloc(listRepository: mockListRepository),
      setUp: () {
        when(
          () => mockListRepository.getListFeed(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 25,
          ),
        ).thenAnswer((_) async => ListFeedResult(posts: [firstPost], cursor: 'cursor-1'));
      },
      act: (bloc) => bloc.add(ListFeedRequested(listUri: listUri, limit: 25)),
      expect: () => [
        ListFeedState.loading(listUri: listUri),
        ListFeedState.loaded(listUri: listUri, posts: [firstPost], cursor: 'cursor-1', hasMore: true),
      ],
    );

    blocTest<ListFeedBloc, ListFeedState>(
      'loads more feed items using the tracked list uri',
      build: () => ListFeedBloc(listRepository: mockListRepository),
      seed: () => ListFeedState.loaded(listUri: listUri, posts: [firstPost], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockListRepository.getListFeed(listUri: listUri, cursor: 'cursor-1', limit: 50),
        ).thenAnswer((_) async => ListFeedResult(posts: [secondPost], cursor: null));
      },
      act: (bloc) => bloc.add(const ListFeedLoadMoreRequested()),
      expect: () => [
        predicate<ListFeedState>((state) => state.isLoadingMore),
        predicate<ListFeedState>((state) => !state.isLoadingMore && state.posts.length == 2 && !state.hasMore),
      ],
    );

    blocTest<ListFeedBloc, ListFeedState>(
      'refreshes the current list feed',
      build: () => ListFeedBloc(listRepository: mockListRepository),
      seed: () => ListFeedState.loaded(listUri: listUri, posts: [firstPost], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockListRepository.getListFeed(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 10,
          ),
        ).thenAnswer((_) async => ListFeedResult(posts: [secondPost], cursor: null));
      },
      act: (bloc) => bloc.add(const ListFeedRefreshed(limit: 10)),
      expect: () => [
        predicate<ListFeedState>((state) => state.isRefreshing),
        predicate<ListFeedState>((state) => !state.isRefreshing && state.posts.single == secondPost),
      ],
    );
  });
}

FeedViewPost _buildPost(String uri, String text) {
  return FeedViewPost(
    post: PostView(
      uri: AtUri.parse(uri),
      cid: 'cid-${uri.hashCode}',
      author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
      record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': DateTime.utc(2026, 3, 21).toIso8601String()},
      indexedAt: DateTime.utc(2026, 3, 21),
    ),
  );
}
