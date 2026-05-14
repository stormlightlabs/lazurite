import 'dart:collection';
import 'dart:convert';

import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/get_timeline.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

import '../../../helpers/test_bluesky_client.dart';

class _QueuedFeedTransport {
  _QueuedFeedTransport({List<FeedGetTimelineOutput>? timelineResponses})
    : _timelineResponses = Queue<FeedGetTimelineOutput>.from(timelineResponses ?? const []);

  final Queue<FeedGetTimelineOutput> _timelineResponses;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.pathSegments.last != 'app.bsky.feed.getTimeline') {
      return unexpectedGetClient(url, headers: headers);
    }

    if (_timelineResponses.isEmpty) {
      throw StateError('No timeline response queued for cursor=${url.queryParameters['cursor']}');
    }
    return jsonResponse(url, 'GET', _timelineResponses.removeFirst().toJson());
  }
}

class _HandlerFeedTransport {
  _HandlerFeedTransport({required this.getTimelineHandler});

  final Future<FeedGetTimelineOutput> Function({String? cursor, int? limit, Map<String, String>? headers})
  getTimelineHandler;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.pathSegments.last != 'app.bsky.feed.getTimeline') {
      return unexpectedGetClient(url, headers: headers);
    }

    final output = await getTimelineHandler(
      cursor: url.queryParameters['cursor'],
      limit: int.tryParse(url.queryParameters['limit'] ?? ''),
      headers: headers,
    );
    return jsonResponse(url, 'GET', output.toJson());
  }
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
      final feedApi = _QueuedFeedTransport(
        timelineResponses: [
          FeedGetTimelineOutput(feed: [_post(100), _post(99), _post(98)], cursor: 'cursor-1'),
          FeedGetTimelineOutput(feed: [_post(98), _post(97), _post(96)], cursor: 'cursor-2'),
        ],
      );
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      await repository.getTimeline();
      await repository.getTimeline(cursor: 'cursor-1');

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(_uris(cached!.posts), equals(_uris([_post(100), _post(99), _post(98), _post(97), _post(96)])));
      expect(cached.cursor, equals('cursor-2'));
    });

    test('refresh prepends latest page while preserving older cached posts', () async {
      final feedApi = _QueuedFeedTransport(
        timelineResponses: [
          FeedGetTimelineOutput(feed: [_post(30), _post(29), _post(28)], cursor: 'cursor-old'),
          FeedGetTimelineOutput(feed: [_post(40), _post(29), _post(39)], cursor: 'cursor-new'),
        ],
      );
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      await repository.getTimeline();
      await repository.getTimeline();

      final cached = await repository.getCachedFeedPage(FeedRepository.timelineCacheKey);
      expect(cached, isNotNull);
      expect(_uris(cached!.posts), equals(_uris([_post(40), _post(29), _post(39), _post(30), _post(28)])));
      expect(cached.cursor, equals('cursor-new'));
    });

    test('refresh enforces OfflineCachePolicy feed post cap', () async {
      final posts = List<FeedViewPost>.generate(OfflineCachePolicy.feedPostLimit + 10, _post);
      final feedApi = _QueuedFeedTransport(timelineResponses: [FeedGetTimelineOutput(feed: posts)]);
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

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
      final feedApi = _QueuedFeedTransport();
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );
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

    test('retries timeline request once after unauthorized recovery', () async {
      var refreshCalls = 0;
      var primaryCalls = 0;
      var fallbackCalls = 0;

      final primaryFeedApi = _HandlerFeedTransport(
        getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
          primaryCalls += 1;
          throw _unauthorizedException('app.bsky.feed.getTimeline');
        },
      );
      final fallbackFeedApi = _HandlerFeedTransport(
        getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
          fallbackCalls += 1;
          return FeedGetTimelineOutput(feed: [_post(1)]);
        },
      );
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: primaryFeedApi.get),
        database: database,
        accountDid: 'did:plc:test',
        onUnauthorized: () async {
          refreshCalls += 1;
          return _testTokens();
        },
        blueskyClientFactory: (_) => testBluesky(getClient: fallbackFeedApi.get),
      );

      final result = await repository.getTimeline();

      expect(refreshCalls, 1);
      expect(primaryCalls, 1);
      expect(fallbackCalls, 1);
      expect(result.posts.length, 1);
      expect(result.posts.first.post.uri.toString(), _post(1).post.uri.toString());
    });

    test('rethrows unauthorized when recovery callback returns null tokens', () async {
      var refreshCalls = 0;
      var primaryCalls = 0;
      final primaryFeedApi = _HandlerFeedTransport(
        getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
          primaryCalls += 1;
          throw _unauthorizedException('app.bsky.feed.getTimeline');
        },
      );
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: primaryFeedApi.get),
        database: database,
        accountDid: 'did:plc:test',
        onUnauthorized: () async {
          refreshCalls += 1;
          return null;
        },
      );

      await expectLater(repository.getTimeline(), throwsA(isA<UnauthorizedException>()));
      expect(primaryCalls, 1);
      expect(refreshCalls, 1);
    });

    test('rethrows unauthorized when no recovery callback is configured', () async {
      var primaryCalls = 0;
      final primaryFeedApi = _HandlerFeedTransport(
        getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
          primaryCalls += 1;
          throw _unauthorizedException('app.bsky.feed.getTimeline');
        },
      );
      final repository = FeedRepository(
        bluesky: testBluesky(getClient: primaryFeedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      await expectLater(repository.getTimeline(), throwsA(isA<UnauthorizedException>()));
      expect(primaryCalls, 1);
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

AuthTokens _testTokens() {
  final now = DateTime.now().toUtc();
  return AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresAt: now.add(const Duration(hours: 1)),
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    service: 'bsky.social',
  );
}

UnauthorizedException _unauthorizedException(String methodId) {
  return UnauthorizedException(
    XRPCResponse(
      headers: const {},
      status: HttpStatus.unauthorized,
      request: XRPCRequest(method: HttpMethod.get, url: Uri.https('bsky.social', '/xrpc/$methodId')),
      rateLimit: RateLimit.unlimited(),
      data: const XRPCError(error: 'Unauthorized', message: 'exp claim timestamp check failed'),
    ),
  );
}
