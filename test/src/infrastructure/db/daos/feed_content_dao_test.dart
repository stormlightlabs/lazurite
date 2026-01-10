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
}
