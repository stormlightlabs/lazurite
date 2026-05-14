import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:poptart_lex/app/bsky/actor.dart' as actor_methods;
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed.dart' as feed_methods;
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:poptart_lex/com/atproto/repo/apply_writes.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';

void main() {
  group('Bluesky poptart adapter', () {
    test('feed.like.create encodes createRecord input through descriptor type conversion', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response(
            '{"uri":"at://did:plc:test/app.bsky.feed.like/like1","cid":"like-cid"}',
            200,
            request: http.Request('POST', url),
          );
        },
      );

      final response = await bluesky.feed.like.create(
        subject: RepoStrongRef(cid: 'post-cid', uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/post1')),
        createdAt: DateTime.utc(2026, 5, 10, 15, 8, 56),
      );

      expect(response.data.uri.toString(), 'at://did:plc:test/app.bsky.feed.like/like1');
      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      expect(body['repo'], 'did:plc:test');
      expect(body['collection'], 'app.bsky.feed.like');
      expect(body['record'], {
        r'$type': 'app.bsky.feed.like',
        'subject': {
          r'$type': 'com.atproto.repo.strongRef',
          'uri': 'at://did:plc:author/app.bsky.feed.post/post1',
          'cid': 'post-cid',
        },
        'createdAt': '2026-05-10T15:08:56.000Z',
      });
    });

    test('feed.like.create canonicalizes local datetimes to UTC milliseconds', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response(
            '{"uri":"at://did:plc:test/app.bsky.feed.like/like1","cid":"like-cid"}',
            200,
            request: http.Request('POST', url),
          );
        },
      );

      await bluesky.feed.like.create(
        subject: RepoStrongRef(cid: 'post-cid', uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/post1')),
        createdAt: DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal(),
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      final record = body['record'] as Map<String, dynamic>;
      expect(record['createdAt'], '2026-05-12T10:11:50.052Z');
    });

    test('repo.createRecord canonicalizes datetime strings in record maps', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response(
            '{"uri":"at://did:plc:test/app.bsky.feed.like/like1","cid":"like-cid"}',
            200,
            request: http.Request('POST', url),
          );
        },
      );

      await bluesky.atproto.repo.createRecord(
        repo: 'did:plc:test',
        collection: 'app.bsky.feed.like',
        record: {
          r'$type': 'app.bsky.feed.like',
          'createdAt': '2026-05-12T10:11:50.052513Z',
          'subject': {
            r'$type': 'com.atproto.repo.strongRef',
            'uri': 'at://did:plc:author/app.bsky.feed.post/post1',
            'cid': 'post-cid',
          },
        },
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      final record = body['record'] as Map<String, dynamic>;
      expect(record['createdAt'], '2026-05-12T10:11:50.052Z');
    });

    test('notification.updateSeen canonicalizes generated input datetime values', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response('{}', 200, request: http.Request('POST', url));
        },
      );

      await bluesky.notification.updateSeen(seenAt: DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal());

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      expect(body['seenAt'], '2026-05-12T10:11:50.052Z');
    });

    test('notification.listNotifications canonicalizes seenAt query parameter', () async {
      Uri? capturedUrl;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrl = url;
          return http.Response('{"notifications":[]}', 200, request: http.Request('GET', url));
        },
      );

      await bluesky.notification.listNotifications(seenAt: DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal());

      expect(capturedUrl!.queryParameters['seenAt'], '2026-05-12T10:11:50.052Z');
    });

    test('actor.putPreferences canonicalizes datetime values inside preferences', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response('{}', 200, request: http.Request('POST', url));
        },
      );

      await bluesky.actor.putPreferences(
        preferences: [
          UPreferences.mutedWordsPref(
            data: MutedWordsPref(
              items: [
                MutedWord(
                  value: 'spoiler',
                  targets: const [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
                  expiresAt: DateTime.utc(2026, 5, 12, 10, 11, 50, 52, 513).toLocal(),
                ),
              ],
            ),
          ),
        ],
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      final preferences = body['preferences'] as List<dynamic>;
      final preference = preferences.single as Map<String, dynamic>;
      final items = preference['items'] as List<dynamic>;
      final mutedWord = items.single as Map<String, dynamic>;
      expect(mutedWord['expiresAt'], '2026-05-12T10:11:50.052Z');
    });

    test('repo.applyWrites canonicalizes datetime fields inside write values', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response('{}', 200, request: http.Request('POST', url));
        },
      );

      await bluesky.atproto.repo.applyWrites(
        repo: 'did:plc:test',
        writes: [
          const URepoApplyWritesWrites.create(
            data: Create(
              collection: 'app.bsky.feed.post',
              value: {r'$type': 'app.bsky.feed.post', 'text': 'Hello', 'createdAt': '2026-05-12T10:11:50.052513Z'},
            ),
          ),
        ],
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      final writes = body['writes'] as List<dynamic>;
      final write = writes.single as Map<String, dynamic>;
      final value = write['value'] as Map<String, dynamic>;
      expect(value['createdAt'], '2026-05-12T10:11:50.052Z');
    });

    test('actor.putPreferences encodes procedure values through descriptor type conversion', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response('{}', 200, request: http.Request('POST', url));
        },
      );

      const feed = SavedFeed(
        id: 'feed-1',
        type: SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
        value: 'at://did:plc:feed/app.bsky.feed.generator/news',
        pinned: true,
      );

      await bluesky.actor.putPreferences(
        preferences: [
          const UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: [feed])),
        ],
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      expect(body['preferences'], [
        {
          r'$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
          'items': [
            {
              r'$type': 'app.bsky.actor.defs#savedFeed',
              'id': 'feed-1',
              'type': 'feed',
              'value': 'at://did:plc:feed/app.bsky.feed.generator/news',
              'pinned': true,
            },
          ],
        },
      ]);
    });

    test('record put and delete encode repo write inputs through descriptor type conversion', () async {
      final capturedBodies = <Map<String, dynamic>>[];
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBodies.add(jsonDecode(body! as String) as Map<String, dynamic>);
          if (url.path.endsWith('com.atproto.repo.deleteRecord')) {
            return http.Response('{}', 200, request: http.Request('POST', url));
          }
          return http.Response(
            '{"uri":"at://did:plc:test/app.bsky.feed.post/post1","cid":"post-cid"}',
            200,
            request: http.Request('POST', url),
          );
        },
      );

      await bluesky.feed.post.put(
        rkey: 'post1',
        record: FeedPostRecord(text: 'Hello', createdAt: DateTime.utc(2026, 5, 10, 15, 8, 56)),
      );
      await bluesky.feed.post.delete(rkey: 'post1');

      expect(capturedBodies.first, {
        'repo': 'did:plc:test',
        'collection': 'app.bsky.feed.post',
        'rkey': 'post1',
        'record': {r'$type': 'app.bsky.feed.post', 'text': 'Hello', 'createdAt': '2026-05-10T15:08:56.000Z'},
      });
      expect(capturedBodies.last, {'repo': 'did:plc:test', 'collection': 'app.bsky.feed.post', 'rkey': 'post1'});
    });

    test('feed.getFeedGenerators encodes query parameters through descriptor type conversion', () async {
      Uri? capturedUrl;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrl = url;
          return http.Response(
            '{"feeds":[{"uri":"at://did:plc:feed/app.bsky.feed.generator/news","cid":"cid-feed","did":"did:web:feed.example","creator":{"did":"did:plc:feed","handle":"feed.example"},"displayName":"News","indexedAt":"2026-05-10T15:08:56.000Z"}]}',
            200,
            request: http.Request('GET', url),
          );
        },
      );

      final feeds = await bluesky.feed.getFeedGenerators(
        feeds: [AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/news')],
      );

      expect(feeds.data.feeds.single.displayName, 'News');
      expect(capturedUrl!.queryParametersAll['feeds'], ['at://did:plc:feed/app.bsky.feed.generator/news']);
    });

    test('actor.getPreferences omits empty query parameter maps for EmptyData descriptors', () async {
      Uri? capturedUrl;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrl = url;
          return http.Response('{"preferences":[]}', 200, request: http.Request('GET', url));
        },
      );

      final response = await bluesky.actor.getPreferences();

      expect(response.data.preferences, isEmpty);
      expect(capturedUrl!.query, isEmpty);
    });

    test('no-argument EmptyData queries omit empty query parameter maps', () async {
      final capturedUrls = <Uri>[];
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrls.add(url);
          final path = url.path;
          if (path.endsWith('app.bsky.notification.getUnreadCount')) {
            return http.Response('{"count":3}', 200, request: http.Request('GET', url));
          }
          if (path.endsWith('app.bsky.video.getUploadLimits')) {
            return http.Response('{"canUpload":true}', 200, request: http.Request('GET', url));
          }
          if (path.endsWith('com.atproto.server.getSession')) {
            return http.Response(
              '{"handle":"test.bsky.social","did":"did:plc:test"}',
              200,
              request: http.Request('GET', url),
            );
          }
          return http.Response('{}', 404, request: http.Request('GET', url));
        },
      );

      final unread = await bluesky.notification.getUnreadCount();
      final limits = await bluesky.video.getUploadLimits();
      final session = await bluesky.atproto.server.getSession();

      expect(unread.data.count, 3);
      expect(limits.data.canUpload, isTrue);
      expect(session.data.did, 'did:plc:test');
      expect(capturedUrls.map((url) => url.query), everyElement(isEmpty));
    });

    test('public call coerces map query parameters before forwarding to poptart', () async {
      Uri? capturedUrl;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrl = url;
          return http.Response(
            '{"feeds":[{"uri":"at://did:plc:feed/app.bsky.feed.generator/news","cid":"cid-feed","did":"did:web:feed.example","creator":{"did":"did:plc:feed","handle":"feed.example"},"displayName":"News","indexedAt":"2026-05-10T15:08:56.000Z"}]}',
            200,
            request: http.Request('GET', url),
          );
        },
      );

      final response = await bluesky.call(
        feed_methods.appBskyFeedGetFeedGenerators as XRPCMethod<dynamic, dynamic, dynamic>,
        parameters: {
          'feeds': [AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/news')],
        },
      );

      expect(response.data.feeds.single.displayName, 'News');
      expect(capturedUrl!.queryParametersAll['feeds'], ['at://did:plc:feed/app.bsky.feed.generator/news']);
    });

    test('public call omits empty query parameter maps for EmptyData descriptors', () async {
      Uri? capturedUrl;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        getClient: (url, {headers}) async {
          capturedUrl = url;
          return http.Response('{"preferences":[]}', 200, request: http.Request('GET', url));
        },
      );

      final response = await bluesky.call(
        actor_methods.appBskyActorGetPreferences as XRPCMethod<dynamic, dynamic, dynamic>,
        parameters: {},
      );

      expect(response.data.preferences, isEmpty);
      expect(capturedUrl!.query, isEmpty);
    });

    test('public call coerces map procedure input before forwarding to poptart', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response('{}', 200, request: http.Request('POST', url));
        },
      );

      const feed = SavedFeed(
        id: 'feed-1',
        type: SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
        value: 'at://did:plc:feed/app.bsky.feed.generator/news',
        pinned: true,
      );

      await bluesky.call(
        actor_methods.appBskyActorPutPreferences as XRPCMethod<dynamic, dynamic, dynamic>,
        input: {
          'preferences': [
            const UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: [feed])),
          ],
        },
      );

      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      expect(body['preferences'], [
        {
          r'$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
          'items': [
            {
              r'$type': 'app.bsky.actor.defs#savedFeed',
              'id': 'feed-1',
              'type': 'feed',
              'value': 'at://did:plc:feed/app.bsky.feed.generator/news',
              'pinned': true,
            },
          ],
        },
      ]);
    });
  });
}
