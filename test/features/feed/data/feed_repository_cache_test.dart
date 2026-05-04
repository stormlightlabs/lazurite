import 'dart:collection';
import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

class _FakeFeedData {
  _FakeFeedData({required this.feed, this.cursor});

  final List<FeedViewPost> feed;
  final String? cursor;
}

class _FakeFeedResponse {
  _FakeFeedResponse(this.data);

  final _FakeFeedData data;
}

class _QueuedFeedApi {
  _QueuedFeedApi({List<_FakeFeedResponse>? timelineResponses})
    : _timelineResponses = Queue<_FakeFeedResponse>.from(timelineResponses ?? const []);

  final Queue<_FakeFeedResponse> _timelineResponses;

  Future<_FakeFeedResponse> getTimeline({String? cursor, int? limit, Map<String, String>? $headers}) async {
    if (_timelineResponses.isEmpty) {
      throw StateError('No timeline response queued for cursor=$cursor');
    }
    return _timelineResponses.removeFirst();
  }
}

class _FakeBluesky {
  _FakeBluesky(this.feed);

  final _QueuedFeedApi feed;
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('FeedRepository cache window', () {
    test('pagination deduplicates by URI and appends older posts', () async {
      final feedApi = _QueuedFeedApi(
        timelineResponses: [
          _FakeFeedResponse(_FakeFeedData(feed: [_post(100), _post(99), _post(98)], cursor: 'cursor-1')),
          _FakeFeedResponse(_FakeFeedData(feed: [_post(98), _post(97), _post(96)], cursor: 'cursor-2')),
        ],
      );
      final repository = FeedRepository(bluesky: _FakeBluesky(feedApi), database: database, accountDid: 'did:plc:test');

      await repository.getTimeline();
      await repository.getTimeline(cursor: 'cursor-1');

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(_uris(cached!.posts), equals(_uris([_post(100), _post(99), _post(98), _post(97), _post(96)])));
      expect(cached.cursor, equals('cursor-2'));
    });

    test('refresh prepends latest page while preserving older cached posts', () async {
      final feedApi = _QueuedFeedApi(
        timelineResponses: [
          _FakeFeedResponse(_FakeFeedData(feed: [_post(30), _post(29), _post(28)], cursor: 'cursor-old')),
          _FakeFeedResponse(_FakeFeedData(feed: [_post(40), _post(29), _post(39)], cursor: 'cursor-new')),
        ],
      );
      final repository = FeedRepository(bluesky: _FakeBluesky(feedApi), database: database, accountDid: 'did:plc:test');

      await repository.getTimeline();
      await repository.getTimeline();

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(_uris(cached!.posts), equals(_uris([_post(40), _post(29), _post(39), _post(30), _post(28)])));
      expect(cached.cursor, equals('cursor-new'));
    });

    test('refresh enforces OfflineCachePolicy feed post cap', () async {
      final posts = List<FeedViewPost>.generate(OfflineCachePolicy.feedPostLimit + 10, _post);
      final feedApi = _QueuedFeedApi(timelineResponses: [_FakeFeedResponse(_FakeFeedData(feed: posts, cursor: null))]);
      final repository = FeedRepository(bluesky: _FakeBluesky(feedApi), database: database, accountDid: 'did:plc:test');

      await repository.getTimeline();

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(cached!.posts.length, OfflineCachePolicy.feedPostLimit);
      expect(cached.posts.first.post.uri.toString(), _post(0).post.uri.toString());
      expect(cached.posts.last.post.uri.toString(), _post(OfflineCachePolicy.feedPostLimit - 1).post.uri.toString());

      final rows = await database.getCachedFeedPosts('did:plc:test', FeedRepository.timelineCacheKey);
      expect(rows.length, OfflineCachePolicy.feedPostLimit);
    });

    test('getCachedFeedPage tolerates malformed cached posts and returns valid entries', () async {
      final feedApi = _QueuedFeedApi();
      final repository = FeedRepository(bluesky: _FakeBluesky(feedApi), database: database, accountDid: 'did:plc:test');
      final validPost = _post(2);

      await database.upsertCachedFeedPosts(
        accountDid: 'did:plc:test',
        feedKey: FeedRepository.timelineCacheKey,
        posts: [
          CachedFeedPostsCompanion.insert(
            accountDid: 'did:plc:test',
            feedKey: FeedRepository.timelineCacheKey,
            postUri: _post(1).post.uri.toString(),
            postJson: '{',
            sortOrder: 2,
          ),
          CachedFeedPostsCompanion.insert(
            accountDid: 'did:plc:test',
            feedKey: FeedRepository.timelineCacheKey,
            postUri: validPost.post.uri.toString(),
            postJson: jsonEncode(validPost.toJson()),
            sortOrder: 1,
          ),
        ],
      );

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(cached!.posts.length, 1);
      expect(cached.posts.single.post.uri.toString(), validPost.post.uri.toString());
    });
  });
}

FeedViewPost _post(int index) {
  final timestamp = DateTime.utc(2026, 5, 1, 12).subtract(Duration(minutes: index));
  final did = 'did:plc:author$index';
  return FeedViewPost(
    post: PostView(
      uri: AtUri('at://$did/app.bsky.feed.post/$index'),
      cid: 'cid-$index',
      author: ProfileViewBasic(did: did, handle: 'author$index.bsky.social'),
      record: {r'$type': 'app.bsky.feed.post', 'text': 'Post $index', 'createdAt': timestamp.toIso8601String()},
      indexedAt: timestamp,
    ),
  );
}

List<String> _uris(List<FeedViewPost> posts) => posts.map((post) => post.post.uri.toString()).toList(growable: false);
