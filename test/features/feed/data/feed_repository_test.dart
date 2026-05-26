import 'package:bluesky_poptart/app/bsky/actor/defs.dart' hide ViewerState;
import 'package:bluesky_poptart/app/bsky/actor/defs/viewer_state.dart' as actor_defs;
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart';

import '../../../helpers/fixtures/feed.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedRepository();
  });

  group('FeedRepository contract', () {
    final samplePost = testFeedViewPost(
      cid: 'cid-123',
      record: testPostRecordJson(text: 'Hello world'),
    );

    test('getTimeline returns FeedResult with posts and cursor', () async {
      when(
        () => mockRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: [samplePost], cursor: 'next-cursor'));

      final result = await mockRepository.getTimeline();

      expect(result.posts.length, 1);
      expect(result.cursor, 'next-cursor');
    });

    test('getTimeline with cursor returns paginated results', () async {
      when(
        () => mockRepository.getTimeline(
          cursor: 'page-2',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: [samplePost], cursor: 'page-3'));

      final result = await mockRepository.getTimeline(cursor: 'page-2');

      expect(result.cursor, 'page-3');
    });

    test('getFeed returns FeedResult for feed generator', () async {
      final feedUri = AtUri.parse('at://did:plc:gen/app.bsky.feed.generator/whats-hot');
      when(
        () => mockRepository.getFeed(
          feedUri: feedUri,
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: [samplePost], cursor: 'next-cursor'));

      final result = await mockRepository.getFeed(feedUri: feedUri);
      expect(result.posts.length, 1);
    });

    test('getPreferences returns preferences list', () async {
      when(() => mockRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
      final result = await mockRepository.getPreferences();
      expect(result.preferences, isEmpty);
    });

    test('putPreferences calls with correct parameters', () async {
      when(() => mockRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      await mockRepository.putPreferences(preferences: []);
      verify(() => mockRepository.putPreferences(preferences: [])).called(1);
    });

    test('getSuggestedFeeds returns list of generators', () async {
      final generator = GeneratorView(
        uri: const AtUri('at://did:plc:gen/app.bsky.feed.generator/discover'),
        cid: 'cid-gen',
        creator: const ProfileView(did: 'did:plc:gen', handle: 'gen.bsky.social'),
        did: 'did:plc:gen',
        displayName: 'Discover',
        indexedAt: DateTime.now(),
      );

      when(
        () => mockRepository.getSuggestedFeeds(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [generator]);

      final result = await mockRepository.getSuggestedFeeds();
      expect(result.length, 1);
      expect(result.first.displayName, 'Discover');
    });

    test('getFeedGenerator returns single generator', () async {
      final feedUri = AtUri.parse('at://did:plc:gen/app.bsky.feed.generator/discover');
      final generator = GeneratorView(
        uri: feedUri,
        cid: 'cid-gen',
        creator: const ProfileView(did: 'did:plc:gen', handle: 'gen.bsky.social'),
        did: 'did:plc:gen',
        displayName: 'Discover',
        indexedAt: DateTime.now(),
      );

      when(() => mockRepository.getFeedGenerator(feedUri)).thenAnswer((_) async => generator);
      final result = await mockRepository.getFeedGenerator(feedUri);
      expect(result.displayName, 'Discover');
    });

    test('getFeedGenerators returns list for multiple URIs', () async {
      final feedUri = AtUri.parse('at://did:plc:gen/app.bsky.feed.generator/discover');
      final generator = GeneratorView(
        uri: feedUri,
        cid: 'cid-gen',
        creator: const ProfileView(did: 'did:plc:gen', handle: 'gen.bsky.social'),
        did: 'did:plc:gen',
        displayName: 'Discover',
        indexedAt: DateTime.now(),
      );

      when(() => mockRepository.getFeedGenerators([feedUri])).thenAnswer((_) async => [generator]);
      final result = await mockRepository.getFeedGenerators([feedUri]);
      expect(result.length, 1);
    });

    test('getFeedGenerator returns single generator', () async {
      final feedUri = AtUri.parse('at://did:plc:gen/app.bsky.feed.generator/discover');
      final generator = GeneratorView(
        uri: feedUri,
        cid: 'cid-gen',
        creator: const ProfileView(did: 'did:plc:gen', handle: 'gen.bsky.social'),
        did: 'did:plc:gen',
        displayName: 'Discover',
        indexedAt: DateTime.now(),
      );

      when(() => mockRepository.getFeedGenerator(feedUri)).thenAnswer((_) async => generator);
      final result = await mockRepository.getFeedGenerator(feedUri);
      expect(result.displayName, 'Discover');
    });

    test('getFeedGenerators returns list for multiple URIs', () async {
      final feedUri = AtUri.parse('at://did:plc:gen/app.bsky.feed.generator/discover');
      final generator = GeneratorView(
        uri: feedUri,
        cid: 'cid-gen',
        creator: const ProfileView(did: 'did:plc:gen', handle: 'gen.bsky.social'),
        did: 'did:plc:gen',
        displayName: 'Discover',
        indexedAt: DateTime.now(),
      );

      when(() => mockRepository.getFeedGenerators([feedUri])).thenAnswer((_) async => [generator]);
      final result = await mockRepository.getFeedGenerators([feedUri]);
      expect(result.length, 1);
    });

    test('getFeedGenerators returns empty list for empty input', () async {
      when(() => mockRepository.getFeedGenerators([])).thenAnswer((_) async => []);
      final result = await mockRepository.getFeedGenerators([]);
      expect(result, isEmpty);
    });
  });

  group('FeedResult', () {
    test('stores posts and cursor', () {
      final post = FeedViewPost(
        post: PostView(
          uri: const AtUri('at://did:plc:test/app.bsky.feed.post/1'),
          cid: 'cid',
          author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
          record: {'text': 'Test'},
          indexedAt: DateTime.now(),
        ),
      );

      final result = FeedResult(posts: [post], cursor: 'cursor-1');
      expect(result.posts.length, 1);
      expect(result.cursor, 'cursor-1');
    });

    test('allows null cursor', () {
      final result = FeedResult(posts: const [], cursor: null);
      expect(result.posts, isEmpty);
      expect(result.cursor, isNull);
    });
  });

  group('PreferencesResult', () {
    test('stores preferences list', () {
      final result = PreferencesResult(preferences: []);
      expect(result.preferences, isEmpty);
    });
  });

  group('filterFeedViewPostsByPreference', () {
    FeedViewPost post({
      required String id,
      String authorDid = 'did:plc:author',
      bool followed = false,
      bool reply = false,
      bool repost = false,
      bool quote = false,
      int likeCount = 0,
    }) {
      final author = ProfileViewBasic(
        did: authorDid,
        handle: '$id.bsky.social',
        viewer: followed
            ? const actor_defs.ViewerState(following: AtUri('at://did:plc:self/app.bsky.graph.follow/follow'))
            : null,
      );
      final postView = PostView(
        uri: AtUri.parse('at://$authorDid/app.bsky.feed.post/$id'),
        cid: 'cid-$id',
        author: author,
        record: {r'$type': 'app.bsky.feed.post', 'text': id, if (reply) 'reply': <String, Object?>{}},
        embed: quote
            ? UPostViewEmbed.embedRecordView(
                data: EmbedRecordView(
                  record: UEmbedRecordViewRecord.embedRecordViewRecord(
                    data: EmbedRecordViewRecord(
                      uri: const AtUri('at://did:plc:quoted/app.bsky.feed.post/quoted'),
                      cid: 'quoted-cid',
                      author: const ProfileViewBasic(did: 'did:plc:quoted', handle: 'quoted.bsky.social'),
                      value: const {r'$type': 'app.bsky.feed.post', 'text': 'quoted'},
                      indexedAt: DateTime.utc(2026),
                    ),
                  ),
                ),
              )
            : null,
        likeCount: likeCount,
        indexedAt: DateTime.utc(2026),
      );
      return FeedViewPost(
        post: postView,
        reason: repost
            ? UFeedViewPostReason.reasonRepost(
                data: ReasonRepost(by: author, indexedAt: DateTime.utc(2026)),
              )
            : null,
      );
    }

    test('hides replies when hideReplies is enabled', () {
      final topLevel = post(id: 'top-level');
      final reply = post(id: 'reply', reply: true, followed: true);

      final filtered = filterFeedViewPostsByPreference(
        [topLevel, reply],
        const FeedViewPref(feed: 'home', hideReplies: true),
        currentAccountDid: 'did:plc:self',
      );

      expect(filtered, [topLevel]);
    });

    test('hides replies from unfollowed accounts while keeping self and followed replies', () {
      final selfReply = post(id: 'self-reply', authorDid: 'did:plc:self', reply: true);
      final followedReply = post(id: 'followed-reply', reply: true, followed: true);
      final unfollowedReply = post(id: 'unfollowed-reply', reply: true);

      final filtered = filterFeedViewPostsByPreference(
        [selfReply, followedReply, unfollowedReply],
        const FeedViewPref(feed: 'home', hideRepliesByUnfollowed: true),
        currentAccountDid: 'did:plc:self',
      );

      expect(filtered, [selfReply, followedReply]);
    });

    test('hides replies below the configured like threshold', () {
      final lowLikeReply = post(id: 'low-like-reply', reply: true, followed: true, likeCount: 4);
      final highLikeReply = post(id: 'high-like-reply', reply: true, followed: true, likeCount: 5);

      final filtered = filterFeedViewPostsByPreference(
        [lowLikeReply, highLikeReply],
        const FeedViewPref(feed: 'home', hideRepliesByUnfollowed: false, hideRepliesByLikeCount: 5),
        currentAccountDid: 'did:plc:self',
      );

      expect(filtered, [highLikeReply]);
    });

    test('hides reposts and quote posts independently', () {
      final topLevel = post(id: 'top-level');
      final repost = post(id: 'repost', repost: true);
      final quote = post(id: 'quote', quote: true);

      final filtered = filterFeedViewPostsByPreference(
        [topLevel, repost, quote],
        const FeedViewPref(feed: 'home', hideReposts: true, hideQuotePosts: true),
        currentAccountDid: 'did:plc:self',
      );

      expect(filtered, [topLevel]);
    });
  });

  group('FeedFilter', () {
    test('has expected filter values', () {
      expect(FeedFilter.values.length, 4);
      expect(FeedFilter.values, contains(FeedFilter.postsWithReplies));
      expect(FeedFilter.values, contains(FeedFilter.postsNoReplies));
      expect(FeedFilter.values, contains(FeedFilter.postsWithMedia));
      expect(FeedFilter.values, contains(FeedFilter.postsAndAuthorThreads));
    });
  });
}
