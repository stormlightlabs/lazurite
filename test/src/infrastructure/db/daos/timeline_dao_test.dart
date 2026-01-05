import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';

void main() {
  late AppDatabase db;
  late TimelineDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.timelineDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('insertTimeline inserts posts, profiles, and items', () async {
    final posts = [
      PostInsert(
        uri: 'at://did:1/app.bsky.feed.post/1',
        cid: 'cid1',
        authorDid: 'did:1',
        record: '{"text": "hello"}',
        indexedAt: DateTime.now(),
      ),
    ];

    final profiles = [ProfileInsert(did: 'did:1', handle: 'alice.test', displayName: 'Alice')];

    final postsCompanion = posts
        .map(
          (p) => PostsCompanion.insert(
            uri: p.uri,
            cid: p.cid,
            authorDid: p.authorDid,
            record: p.record,
            indexedAt: Value(p.indexedAt),
          ),
        )
        .toList();

    final profilesCompanion = profiles
        .map(
          (p) => ProfilesCompanion.insert(
            did: p.did,
            handle: p.handle,
            displayName: Value(p.displayName),
          ),
        )
        .toList();

    final itemsCompanion = [
      TimelineItemsCompanion.insert(
        feedKey: 'home',
        postUri: 'at://did:1/app.bsky.feed.post/1',
        sortKey: '999',
      ),
    ];

    await dao.insertTimelineBatch(
      feedKey: 'home',
      newPosts: postsCompanion,
      newProfiles: profilesCompanion,
      newItems: itemsCompanion,
      newCursor: 'cursor123',
    );

    final timeline = await dao.watchTimeline('home').first.timeout(const Duration(seconds: 2));
    expect(timeline.length, 1);
    expect(timeline.first.post.uri, 'at://did:1/app.bsky.feed.post/1');
    expect(timeline.first.author.handle, 'alice.test');

    final cursor = await dao.getCursor('home');
    expect(cursor, 'cursor123');
  });

  test('watchTimeline returns items in descending sortKey order', () async {
    await dao.insertTimelineBatch(
      feedKey: 'home',
      newPosts: [
        PostsCompanion.insert(uri: 'p1', cid: 'c1', authorDid: 'd1', record: '{}'),
        PostsCompanion.insert(uri: 'p2', cid: 'c2', authorDid: 'd1', record: '{}'),
      ],
      newProfiles: [ProfilesCompanion.insert(did: 'd1', handle: 'alice')],
      newItems: [
        TimelineItemsCompanion.insert(feedKey: 'home', postUri: 'p1', sortKey: '100'),
        TimelineItemsCompanion.insert(feedKey: 'home', postUri: 'p2', sortKey: '200'),
      ],
    );

    final timeline = await dao.watchTimeline('home').first.timeout(const Duration(seconds: 2));
    expect(timeline, hasLength(2));
    expect(timeline[0].item.sortKey, '200');
    expect(timeline[0].post.uri, 'p2');
    expect(timeline[1].item.sortKey, '100');
    expect(timeline[1].post.uri, 'p1');
  });

  test('insertTimelineBatch updates existing posts', () async {
    await dao.insertTimelineBatch(
      feedKey: 'home',
      newPosts: [
        PostsCompanion.insert(
          uri: 'p1',
          cid: 'c1',
          authorDid: 'd1',
          record: '{}',
          likeCount: const Value(0),
        ),
      ],
      newProfiles: [ProfilesCompanion.insert(did: 'd1', handle: 'alice')],
      newItems: [TimelineItemsCompanion.insert(feedKey: 'home', postUri: 'p1', sortKey: '100')],
    );

    await dao.insertTimelineBatch(
      feedKey: 'home',
      newPosts: [
        PostsCompanion.insert(
          uri: 'p1',
          cid: 'c1',
          authorDid: 'd1',
          record: '{}',
          likeCount: const Value(5),
        ),
      ],
      newProfiles: [],
      newItems: [],
    );

    final timeline = await dao.watchTimeline('home').first.timeout(const Duration(seconds: 2));
    expect(timeline.first.post.likeCount, 5);
  });
}
