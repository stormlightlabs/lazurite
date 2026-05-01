import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getpostthread.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';

class _FakeThreadResponse {
  _FakeThreadResponse(this.data);

  final FeedGetPostThreadOutput data;
}

class _FakeThreadFeedApi {
  _FakeThreadFeedApi({required this.getPostThreadHandler});

  final Future<_FakeThreadResponse> Function({required AtUri uri}) getPostThreadHandler;

  Future<_FakeThreadResponse> getPostThread({
    required AtUri uri,
    int? depth,
    int? parentHeight,
    String? $service,
    Map<String, String>? $headers,
    Map<String, String>? $unknown,
  }) {
    return getPostThreadHandler(uri: uri);
  }
}

class _FakeBluesky {
  _FakeBluesky(this.feed);

  final _FakeThreadFeedApi feed;
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
      final feedApi = _FakeThreadFeedApi(
        getPostThreadHandler: ({required uri}) async =>
            _FakeThreadResponse(FeedGetPostThreadOutput(thread: UFeedGetPostThreadThread.threadViewPost(data: thread))),
      );
      final repository = PostThreadRepository(
        bluesky: _FakeBluesky(feedApi),
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
      final feedApi = _FakeThreadFeedApi(getPostThreadHandler: ({required uri}) async => throw Exception('offline'));
      final repository = PostThreadRepository(
        bluesky: _FakeBluesky(feedApi),
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
      final feedApi = _FakeThreadFeedApi(
        getPostThreadHandler: ({required uri}) async =>
            _FakeThreadResponse(FeedGetPostThreadOutput(thread: UFeedGetPostThreadThread.threadViewPost(data: newest))),
      );
      final repository = PostThreadRepository(
        bluesky: _FakeBluesky(feedApi),
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
