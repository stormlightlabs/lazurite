import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/search_posts.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:poptart_core/poptart_core.dart';

import '../../../helpers/test_bluesky_client.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('getActorMentions searches by DID and ranks useful mentions first', () async {
    const actorDid = 'did:plc:mentioned';
    final capturedQueries = <Map<String, String>>[];
    final bluesky = testBluesky(
      getClient: (url, {headers}) async {
        expect(url.pathSegments.last, 'app.bsky.feed.searchPosts');
        capturedQueries.add(url.queryParameters);
        return jsonResponse(
          url,
          'GET',
          FeedSearchPostsOutput(
            cursor: 'next',
            posts: [
              _post(
                'at://did:plc:reply/app.bsky.feed.post/reply',
                authorDid: 'did:plc:reply',
                text: 'reply mention',
                indexedAt: DateTime.utc(2026, 5, 23, 12),
                reply: true,
                likeCount: 100,
              ),
              _post(
                'at://did:plc:top/app.bsky.feed.post/top',
                authorDid: 'did:plc:top',
                text: 'good mention',
                indexedAt: DateTime.utc(2026, 5, 23, 10),
                likeCount: 4,
              ),
              _post(
                'at://did:plc:multi/app.bsky.feed.post/multi',
                authorDid: 'did:plc:multi',
                text: 'many mentions',
                indexedAt: DateTime.utc(2026, 5, 23, 11),
                mentionCount: 5,
                likeCount: 2,
              ),
            ],
          ).toJson(),
        );
      },
    );
    final repository = ProfileRepository(database: database, bluesky: bluesky);

    final page = await repository.getActorMentions(actor: actorDid, limit: 50);

    expect(capturedQueries.single['mentions'], actorDid);
    expect(capturedQueries.single['q'], '*');
    expect(capturedQueries.single['sort'], 'latest');
    expect(page.cursor, 'next');
    expect(page.posts.map((post) => post.uri.toString()), [
      'at://did:plc:top/app.bsky.feed.post/top',
      'at://did:plc:multi/app.bsky.feed.post/multi',
      'at://did:plc:reply/app.bsky.feed.post/reply',
    ]);
  });

  test('getActorMentions caps repeated authors per page', () async {
    final bluesky = testBluesky(
      getClient: (url, {headers}) async {
        return jsonResponse(
          url,
          'GET',
          FeedSearchPostsOutput(
            posts: [
              _post('at://did:plc:author/app.bsky.feed.post/1', authorDid: 'did:plc:author', text: 'one'),
              _post('at://did:plc:author/app.bsky.feed.post/2', authorDid: 'did:plc:author', text: 'two'),
              _post('at://did:plc:author/app.bsky.feed.post/3', authorDid: 'did:plc:author', text: 'three'),
            ],
          ).toJson(),
        );
      },
    );
    final repository = ProfileRepository(database: database, bluesky: bluesky);

    final page = await repository.getActorMentions(actor: 'did:plc:mentioned');

    expect(page.posts.map((post) => post.uri.toString()), [
      'at://did:plc:author/app.bsky.feed.post/1',
      'at://did:plc:author/app.bsky.feed.post/2',
    ]);
  });
}

PostView _post(
  String uri, {
  required String authorDid,
  required String text,
  DateTime? indexedAt,
  bool reply = false,
  int mentionCount = 1,
  int likeCount = 0,
}) {
  final postTime = indexedAt ?? DateTime.utc(2026, 5, 23, 12);
  return PostView(
    uri: AtUri(uri),
    cid: 'cid-$uri',
    author: ProfileViewBasic(did: authorDid, handle: '$authorDid.example'),
    record: {
      r'$type': 'app.bsky.feed.post',
      'text': text,
      'createdAt': postTime.toIso8601String(),
      if (reply)
        'reply': {
          'root': {'uri': 'at://did:plc:root/app.bsky.feed.post/root', 'cid': 'cid-root'},
          'parent': {'uri': 'at://did:plc:root/app.bsky.feed.post/root', 'cid': 'cid-root'},
        },
      'facets': [
        for (var i = 0; i < mentionCount; i++)
          {
            'features': [
              {r'$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:mentioned'},
            ],
            'index': {'byteStart': 0, 'byteEnd': 1},
          },
      ],
    },
    indexedAt: postTime,
    likeCount: likeCount,
  );
}
