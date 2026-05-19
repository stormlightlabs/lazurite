import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

class MockFeedRepository extends Mock implements FeedRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockFeedRepository feedRepository;
  late MockSearchRepository searchRepository;

  setUpAll(() {
    registerFallbackValue(<atcore.AtUri>[]);
  });

  setUp(() {
    feedRepository = MockFeedRepository();
    searchRepository = MockSearchRepository();
  });

  test('loads BlueSky discover and feeds from suggested feeds', () async {
    when(
      () => feedRepository.getSuggestedFeeds(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [_feed('discover')]);
    final repository = RepositoryPublicContentRepository(
      providerKey: AppViewProviders.blueskyKey,
      feedRepository: feedRepository,
      searchRepository: searchRepository,
    );

    final discover = await repository.loadDiscover();
    final feeds = await repository.loadFeeds();

    expect(discover.feeds.single.displayName, 'Feed discover');
    expect(feeds.feeds.single.displayName, 'Feed discover');
    verify(() => feedRepository.getSuggestedFeeds(cursor: null, limit: 25)).called(2);
  });

  test('loads BlackSky discover from trends', () async {
    when(() => feedRepository.getTrends(limit: any(named: 'limit'))).thenAnswer((_) async => [_trend()]);
    final repository = RepositoryPublicContentRepository(
      providerKey: AppViewProviders.blackskyKey,
      feedRepository: feedRepository,
      searchRepository: searchRepository,
    );

    final discover = await repository.loadDiscover();

    expect(discover.trends.single.displayName, 'BlackSky Topic');
    verify(() => feedRepository.getTrends(limit: 25)).called(1);
  });

  test('loads BlackSky feeds from fixed feed generator list', () async {
    when(() => feedRepository.getFeedGenerators(any())).thenAnswer((_) async => [_feed('blacksky')]);
    final repository = RepositoryPublicContentRepository(
      providerKey: AppViewProviders.blackskyKey,
      feedRepository: feedRepository,
      searchRepository: searchRepository,
    );

    final result = await repository.loadFeeds();

    expect(result.feeds.single.displayName, 'Feed blacksky');
    final captured = verify(() => feedRepository.getFeedGenerators(captureAny())).captured.single as List<atcore.AtUri>;
    expect(captured.map((uri) => uri.toString()), [
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-trend',
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky',
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-edu',
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-op',
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-videos',
      'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-photos',
      'at://did:plc:3guzzweuqraryl3rdkimjamk/app.bsky.feed.generator/for-you',
    ]);
    verifyNever(
      () => feedRepository.getSuggestedFeeds(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    );
  });

  test('searches feeds through SearchRepository', () async {
    when(
      () => searchRepository.searchFeedGenerators(
        query: any(named: 'query'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => SearchFeedsResult(feeds: [_feed('news')], cursor: 'next'));
    final repository = RepositoryPublicContentRepository(
      providerKey: AppViewProviders.blackskyKey,
      feedRepository: feedRepository,
      searchRepository: searchRepository,
    );

    final result = await repository.searchFeeds(query: 'news');

    expect(result.feeds.single.displayName, 'Feed news');
    expect(result.cursor, 'next');
    verify(() => searchRepository.searchFeedGenerators(query: 'news', cursor: null, limit: 25)).called(1);
  });
}

GeneratorView _feed(String rkey) {
  return GeneratorView(
    uri: atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/$rkey'),
    cid: 'cid-$rkey',
    did: 'did:web:feeds.example',
    creator: const ProfileView(did: 'did:plc:feed', handle: 'feeds.example'),
    displayName: 'Feed $rkey',
    indexedAt: DateTime.utc(2026, 5, 18),
  );
}

TrendView _trend() {
  return TrendView(
    topic: 'topic',
    displayName: 'BlackSky Topic',
    link: '/topic/1',
    startedAt: DateTime.utc(2026, 5, 18),
    postCount: 1,
    actors: const [],
  );
}
