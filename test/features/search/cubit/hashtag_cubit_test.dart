import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/feed_fixtures.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

PostView _post(String uri, String text) => testPostView(
  uri: uri,
  record: testPostRecordJson(text: text, createdAt: DateTime.utc(2026, 1, 1)),
  indexedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late MockSearchRepository searchRepository;

  setUp(() {
    searchRepository = MockSearchRepository();
  });

  group('HashtagCubit', () {
    test('initialize loads top timeline for hashtag query', () async {
      final topPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'Top post');

      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchPostsResult(posts: [topPost], cursor: 'cursor-1'));

      final cubit = HashtagCubit(searchRepository: searchRepository, tag: 'atproto');
      addTearDown(cubit.close);

      await cubit.initialize();

      expect(cubit.state.topTimeline.status, HashtagTimelineStatus.loaded);
      expect(cubit.state.topTimeline.posts, [topPost]);
      expect(cubit.state.topTimeline.cursor, 'cursor-1');
      verify(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: 50,
        ),
      ).called(1);
    });

    test('switchSort loads latest timeline and preserves top timeline', () async {
      final topPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'Top post');
      final latestPost = _post('at://did:plc:author/app.bsky.feed.post/2', 'Latest post');

      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchPostsResult(posts: [topPost], cursor: null));

      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'latest',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchPostsResult(posts: [latestPost], cursor: null));

      final cubit = HashtagCubit(searchRepository: searchRepository, tag: 'atproto');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.switchSort(HashtagSort.latest);
      expect(cubit.state.currentSort, HashtagSort.latest);
      expect(cubit.state.topTimeline.posts, [topPost]);
      expect(cubit.state.latestTimeline.posts, [latestPost]);
    });

    test('loadMoreCurrent appends posts using cursor', () async {
      final firstPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'First');
      final secondPost = _post('at://did:plc:author/app.bsky.feed.post/2', 'Second');

      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((invocation) async {
        final cursor = invocation.namedArguments[#cursor] as String?;
        if (cursor == null) {
          return SearchPostsResult(posts: [firstPost], cursor: 'next');
        }
        return SearchPostsResult(posts: [secondPost], cursor: null);
      });

      final cubit = HashtagCubit(searchRepository: searchRepository, tag: 'atproto');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.loadMoreCurrent();
      expect(cubit.state.topTimeline.posts, [firstPost, secondPost]);
      expect(cubit.state.topTimeline.cursor, isNull);
    });

    test('refreshCurrent replaces current timeline posts', () async {
      final firstPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'First');
      final refreshedPost = _post('at://did:plc:author/app.bsky.feed.post/2', 'Refreshed');

      var callCount = 0;
      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        callCount += 1;
        if (callCount == 1) {
          return SearchPostsResult(posts: [firstPost], cursor: null);
        }
        return SearchPostsResult(posts: [refreshedPost], cursor: null);
      });

      final cubit = HashtagCubit(searchRepository: searchRepository, tag: 'atproto');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.refreshCurrent();
      expect(cubit.state.topTimeline.posts, [refreshedPost]);
    });

    test('missing tag is ignored and no requests are sent', () async {
      final cubit = HashtagCubit(searchRepository: searchRepository, tag: '');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.loadMoreCurrent();
      await cubit.refreshCurrent();

      verifyNever(
        () => searchRepository.searchPosts(
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      );
      expect(cubit.state.isMissingTag, isTrue);
    });

    test('load failure transitions timeline to error state', () async {
      when(
        () => searchRepository.searchPosts(
          query: '#atproto',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final cubit = HashtagCubit(searchRepository: searchRepository, tag: 'atproto');
      addTearDown(cubit.close);

      await cubit.initialize();
      expect(cubit.state.topTimeline.status, HashtagTimelineStatus.error);
      expect(cubit.state.topTimeline.errorMessage, isNotNull);
    });
  });
}
