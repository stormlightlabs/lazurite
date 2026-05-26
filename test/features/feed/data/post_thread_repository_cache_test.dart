import 'dart:convert';

import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_post_thread.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import '../../../helpers/test_utils.dart';

import '../../../helpers/test_bluesky_client.dart';

class _FakeThreadFeedTransport {
  _FakeThreadFeedTransport({required this.getPostThreadHandler});

  final Future<FeedGetPostThreadOutput> Function({required AtUri uri}) getPostThreadHandler;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.pathSegments.last != 'app.bsky.feed.getPostThread') {
      return unexpectedGetClient(url, headers: headers);
    }

    final output = await getPostThreadHandler(uri: AtUri.parse(url.queryParameters['uri']!));
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

  group('PostThreadRepository cache', () {
    test('caches successful thread fetch by root URI', () async {
      final root = _thread(uri: 'at://did:plc:root/app.bsky.feed.post/root', cid: 'cid-root', text: 'Root');
      final childPost = _post(uri: 'at://did:plc:child/app.bsky.feed.post/child', cid: 'cid-child', text: 'Child');
      final thread = ThreadViewPost(
        post: childPost,
        parent: UThreadViewPostParent.threadViewPost(data: root),
      );
      final feedApi = _FakeThreadFeedTransport(
        getPostThreadHandler: ({required uri}) async =>
            FeedGetPostThreadOutput(thread: UFeedGetPostThreadThread.threadViewPost(data: thread)),
      );
      final repository = PostThreadRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      await repository.getPostThread(childPost.uri.toString());

      final cached = await database.getCachedThreadRoot('did:plc:test', root.post.uri.toString());
      expect(cached, isNotNull);
      final decoded = ThreadViewPost.fromJson(jsonDecode(cached!.payload) as Map<String, dynamic>);
      expect(decoded.post.uri.toString(), childPost.uri.toString());
    });

    test('returns cached thread when network request fails', () async {
      final child = _thread(uri: 'at://did:plc:child/app.bsky.feed.post/child', cid: 'cid-child', text: 'Child');
      final root = ThreadViewPost(
        post: _post(uri: 'at://did:plc:root/app.bsky.feed.post/root', cid: 'cid-root', text: 'Root'),
        replies: [UThreadViewPostReplies.threadViewPost(data: child)],
      );
      await database.cacheThreadRoot(
        accountDid: 'did:plc:test',
        rootUri: root.post.uri.toString(),
        payload: jsonEncode(root.toJson()),
      );
      final feedApi = _FakeThreadFeedTransport(
        getPostThreadHandler: ({required uri}) async => throw Exception('offline'),
      );
      final repository = PostThreadRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      final resolved = await repository.getPostThread(child.post.uri.toString());

      expect(resolved.post.uri.toString(), root.post.uri.toString());
      expect(resolved.replies, isNotNull);
      expect(resolved.replies!.length, 1);
    });

    test('prunes thread cache to OfflineCachePolicy.threadRootLimit', () async {
      for (var i = 0; i < OfflineCachePolicy.threadRootLimit; i++) {
        await database.cacheThreadRoot(
          accountDid: 'did:plc:test',
          rootUri: 'at://did:plc:seed/app.bsky.feed.post/$i',
          payload: '{}',
          fetchedAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: i)),
        );
      }

      final newest = _thread(uri: 'at://did:plc:new/app.bsky.feed.post/newest', cid: 'cid-new', text: 'Newest');
      final feedApi = _FakeThreadFeedTransport(
        getPostThreadHandler: ({required uri}) async =>
            FeedGetPostThreadOutput(thread: UFeedGetPostThreadThread.threadViewPost(data: newest)),
      );
      final repository = PostThreadRepository(
        bluesky: testBluesky(getClient: feedApi.get),
        database: database,
        accountDid: 'did:plc:test',
      );

      await repository.getPostThread(newest.post.uri.toString());

      final all = await (database.select(
        database.cachedThreadRoots,
      )..where((entry) => entry.accountDid.equals('did:plc:test'))).get();
      expect(all.length, OfflineCachePolicy.threadRootLimit);
      final newestEntry = await database.getCachedThreadRoot('did:plc:test', newest.post.uri.toString());
      expect(newestEntry, isNotNull);
    });

    test('retries thread request once after unauthorized recovery', () async {
      var primaryCalls = 0;
      var fallbackCalls = 0;
      var refreshCalls = 0;
      final thread = _thread(uri: 'at://did:plc:retry/app.bsky.feed.post/retry', cid: 'cid-retry', text: 'Retry');
      final primaryFeedApi = _FakeThreadFeedTransport(
        getPostThreadHandler: ({required uri}) async {
          primaryCalls += 1;
          throw testUnauthorizedException('app.bsky.feed.getPostThread');
        },
      );
      final fallbackFeedApi = _FakeThreadFeedTransport(
        getPostThreadHandler: ({required uri}) async {
          fallbackCalls += 1;
          return FeedGetPostThreadOutput(thread: UFeedGetPostThreadThread.threadViewPost(data: thread));
        },
      );
      final repository = PostThreadRepository(
        bluesky: testBluesky(getClient: primaryFeedApi.get),
        database: database,
        accountDid: 'did:plc:test',
        onUnauthorized: () async {
          refreshCalls += 1;
          return testAuthTokens();
        },
        blueskyClientFactory: (_) => testBluesky(getClient: fallbackFeedApi.get),
      );

      final resolved = await repository.getPostThread(thread.post.uri.toString());

      expect(refreshCalls, 1);
      expect(primaryCalls, 1);
      expect(fallbackCalls, 1);
      expect(resolved.post.uri.toString(), thread.post.uri.toString());
    });
  });
}

ThreadViewPost _thread({required String uri, required String cid, required String text}) {
  return ThreadViewPost(
    post: _post(uri: uri, cid: cid, text: text),
  );
}

PostView _post({required String uri, required String cid, required String text}) {
  final timestamp = DateTime.utc(2026, 5, 1, 12);
  final did = AtUri.parse(uri).hostname;
  return PostView(
    uri: AtUri(uri),
    cid: cid,
    author: ProfileViewBasic(did: did, handle: '$did.bsky.social'),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': timestamp.toIso8601String()},
    indexedAt: timestamp,
  );
}
