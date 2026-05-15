import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/cubit/topic_cubit.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

PostView _post(String uri, String text) {
  return PostView(
    uri: AtUri.parse(uri),
    cid: 'cid-${uri.hashCode}',
    author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': '2026-01-01T00:00:00.000Z'},
    indexedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  late MockSearchRepository searchRepository;

  setUp(() {
    searchRepository = MockSearchRepository();
  });

  group('TopicCubit', () {
    test('initialize loads top timeline for topic query', () async {
      final topPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'Top post');

      when(
        () => searchRepository.searchTopicPosts(
          topic: '1441',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => TopicPostsResult(posts: [topPost], cursor: 'cursor-1', topicName: 'Politics'));

      final cubit = TopicCubit(searchRepository: searchRepository, topic: '1441');
      addTearDown(cubit.close);

      await cubit.initialize();

      expect(cubit.state.topTimeline.status, TopicTimelineStatus.loaded);
      expect(cubit.state.topTimeline.posts, [topPost]);
      expect(cubit.state.topTimeline.cursor, 'cursor-1');
      expect(cubit.state.displayName, 'Politics');
      verify(
        () => searchRepository.searchTopicPosts(
          topic: '1441',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: 25,
        ),
      ).called(1);
    });

    test('switchSort loads latest timeline and preserves top timeline', () async {
      final topPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'Top post');
      final latestPost = _post('at://did:plc:author/app.bsky.feed.post/2', 'Latest post');

      when(
        () => searchRepository.searchTopicPosts(
          topic: 'sports',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => TopicPostsResult(posts: [topPost], cursor: null));

      when(
        () => searchRepository.searchTopicPosts(
          topic: 'sports',
          sort: 'latest',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => TopicPostsResult(posts: [latestPost], cursor: null));

      final cubit = TopicCubit(searchRepository: searchRepository, topic: 'sports');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.switchSort(TopicSort.latest);

      expect(cubit.state.currentSort, TopicSort.latest);
      expect(cubit.state.topTimeline.posts, [topPost]);
      expect(cubit.state.latestTimeline.posts, [latestPost]);
    });

    test('loadMoreCurrent appends posts using cursor', () async {
      final firstPost = _post('at://did:plc:author/app.bsky.feed.post/1', 'First');
      final secondPost = _post('at://did:plc:author/app.bsky.feed.post/2', 'Second');

      when(
        () => searchRepository.searchTopicPosts(
          topic: 'sports',
          sort: 'top',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((invocation) async {
        final cursor = invocation.namedArguments[#cursor] as String?;
        if (cursor == null) {
          return TopicPostsResult(posts: [firstPost], cursor: 'next');
        }
        return TopicPostsResult(posts: [secondPost], cursor: null);
      });

      final cubit = TopicCubit(searchRepository: searchRepository, topic: 'sports');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.loadMoreCurrent();

      expect(cubit.state.topTimeline.posts, [firstPost, secondPost]);
      expect(cubit.state.topTimeline.cursor, isNull);
    });

    test('missing topic is ignored and no requests are sent', () async {
      final cubit = TopicCubit(searchRepository: searchRepository, topic: '');
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.loadMoreCurrent();
      await cubit.refreshCurrent();

      verifyNever(
        () => searchRepository.searchTopicPosts(
          topic: any(named: 'topic'),
          sort: any(named: 'sort'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      );
      expect(cubit.state.isMissingTopic, isTrue);
    });
  });
}
