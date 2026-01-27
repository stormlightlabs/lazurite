import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

void main() {
  late AppDatabase db;
  late FeedContentDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.feedContentDao;
  });

  tearDown(() async {
    await db.close();
  });

  const ownerDid = 'did:plc:owner';
  const feedKey = 'home';
  const postUri = 'at://did:plc:author/app.bsky.feed.post/123';

  group('FeedContentDao with Interactions', () {
    test('watchFeedContent joins correctly and picks up local interaction', () async {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              did: 'did:plc:author',
              handle: 'author.bsky.social',
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: postUri,
              cid: 'cid123',
              authorDid: 'did:plc:author',
              record: jsonEncode({'text': 'Hello world'}),
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.feedContentItems)
          .insert(
            FeedContentItemsCompanion.insert(
              feedKey: feedKey,
              postUri: postUri,
              ownerDid: ownerDid,
              sortKey: DateTime.now().toIso8601String(),
            ),
          );

      final firstResults = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(firstResults.length, 1);
      expect(firstResults.first.interaction, isNull);

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          likeUri: const Value('at://did:plc:owner/app.bsky.feed.like/456'),
          updatedAt: DateTime.now(),
        ),
      );

      final secondResults = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(secondResults.length, 1);
      expect(secondResults.first.interaction, isNotNull);
      expect(
        secondResults.first.interaction?.likeUri,
        'at://did:plc:owner/app.bsky.feed.like/456',
      );
    });

    test('bookmarkUri persistence works', () async {
      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          bookmarked: const Value(true),
          bookmarkUri: const Value('at://did:plc:owner/app.bsky.bookmark/abc'),
          updatedAt: DateTime.now(),
        ),
      );

      final interaction = await db.postInteractionsDao.getInteraction(postUri, ownerDid);
      expect(interaction, isNotNull);
      expect(interaction?.bookmarked, isTrue);
      expect(interaction?.bookmarkUri, 'at://did:plc:owner/app.bsky.bookmark/abc');
    });
  });

  group('FeedContentDao Filtering', () {
    const otherPostUri = 'at://did:plc:other/app.bsky.feed.post/456';
    const otherDid = 'did:plc:other';

    setUp(() async {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              did: otherDid,
              handle: 'other.bsky.social',
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: otherPostUri,
              cid: 'cid456',
              authorDid: otherDid,
              record: jsonEncode({'text': 'Hidden post'}),
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.feedContentItems)
          .insert(
            FeedContentItemsCompanion.insert(
              feedKey: feedKey,
              postUri: otherPostUri,
              ownerDid: ownerDid,
              sortKey: '2024-01-01T00:00:00Z',
            ),
          );

      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              did: 'did:plc:author',
              handle: 'author.bsky.social',
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: postUri,
              cid: 'cid123',
              authorDid: 'did:plc:author',
              record: jsonEncode({'text': 'Visible post'}),
              indexedAt: Value(DateTime.now()),
            ),
          );

      await db
          .into(db.feedContentItems)
          .insert(
            FeedContentItemsCompanion.insert(
              feedKey: feedKey,
              postUri: postUri,
              ownerDid: ownerDid,
              sortKey: '2024-01-01T00:00:01Z',
            ),
          );
    });

    test('watchFeedContent filters out muted users', () async {
      final initialResults = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(initialResults.length, 2);

      await db
          .into(db.profileRelationships)
          .insert(
            ProfileRelationshipsCompanion.insert(
              ownerDid: ownerDid,
              profileDid: otherDid,
              muted: const Value(true),
              updatedAt: DateTime.now(),
            ),
          );

      final results = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(results.length, 1);
      expect(results.first.post.uri, postUri);
    });

    test('watchFeedContent filters out blocked users', () async {
      await db
          .into(db.profileRelationships)
          .insert(
            ProfileRelationshipsCompanion.insert(
              ownerDid: ownerDid,
              profileDid: otherDid,
              blocked: const Value(true),
              updatedAt: DateTime.now(),
            ),
          );

      final results = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(results.length, 1);
      expect(results.first.post.uri, postUri);
    });

    test('watchFeedContent filters out users who blocked us', () async {
      await db
          .into(db.profileRelationships)
          .insert(
            ProfileRelationshipsCompanion.insert(
              ownerDid: ownerDid,
              profileDid: otherDid,
              blockedBy: const Value(true),
              updatedAt: DateTime.now(),
            ),
          );

      final results = await dao.watchFeedContent(feedKey, ownerDid).first;
      expect(results.length, 1);
      expect(results.first.post.uri, postUri);
    });
  });
}
