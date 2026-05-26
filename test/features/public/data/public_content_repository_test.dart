import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

import '../../../helpers/feed_fixtures.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockFeedRepository feedRepository;
  late MockSearchRepository searchRepository;

  setUpAll(() {
    registerFallbackValue(<atcore.AtUri>[]);
    registerFallbackValue(atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/fallback'));
  });

  setUp(() {
    feedRepository = MockFeedRepository();
    searchRepository = MockSearchRepository();
  });

  test('loads BlueSky discover from the Discover feed and feeds from suggested feeds', () async {
    when(
      () => feedRepository.getFeed(
        feedUri: any(named: 'feedUri'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: [_post('discover')], cursor: 'next-discover'));
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

    expect(discover.posts.single.post.uri.toString(), 'at://did:plc:author/app.bsky.feed.post/discover');
    expect(discover.cursor, 'next-discover');
    expect(feeds.feeds.single.displayName, 'Feed discover');
    verify(
      () => feedRepository.getFeed(
        feedUri: RepositoryPublicContentRepository.blueskyDiscoverFeedUri,
        cursor: null,
        limit: 25,
      ),
    ).called(1);
    verify(() => feedRepository.getSuggestedFeeds(cursor: null, limit: 25)).called(1);
  });

  test('loads BlackSky trending from the BlackSky trending feed', () async {
    when(
      () => feedRepository.getFeed(
        feedUri: any(named: 'feedUri'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: [_post('blacksky-trending')], cursor: 'next-blacksky'));
    final repository = RepositoryPublicContentRepository(
      providerKey: AppViewProviders.blackskyKey,
      feedRepository: feedRepository,
      searchRepository: searchRepository,
    );

    final discover = await repository.loadDiscover();
    expect(discover.posts.single.post.uri.toString(), 'at://did:plc:author/app.bsky.feed.post/blacksky-trending');
    expect(discover.cursor, 'next-blacksky');
    verify(
      () => feedRepository.getFeed(
        feedUri: RepositoryPublicContentRepository.blackskyTrendingFeedUri,
        cursor: null,
        limit: 25,
      ),
    ).called(1);
    verifyNever(() => feedRepository.getTrends(limit: any(named: 'limit')));
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

GeneratorView _feed(String rkey) => GeneratorView(
  uri: atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/$rkey'),
  cid: 'cid-$rkey',
  did: 'did:web:feeds.example',
  creator: const ProfileView(did: 'did:plc:feed', handle: 'feeds.example'),
  displayName: 'Feed $rkey',
  indexedAt: DateTime.utc(2026, 5, 18),
);

FeedViewPost _post(String rkey) => testFeedViewPost(
  uri: 'at://did:plc:author/app.bsky.feed.post/$rkey',
  cid: 'cid-$rkey',
  author: testProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social', displayName: 'Author'),
  record: testPostRecordJson(text: 'Post $rkey', createdAt: DateTime.utc(2026, 5, 20, 12)),
  indexedAt: DateTime.utc(2026, 5, 20),
  replyCount: 0,
  repostCount: 0,
  likeCount: 0,
);
