import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

void main() {
  late AppDatabase db;
  const ownerDid = 'did:plc:test';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PostInteractionsDao', () {
    test('upsertInteraction inserts new interaction', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "test"}',
            ),
          );

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('at://did:viewer/app.bsky.feed.like/1'),
          updatedAt: DateTime.now(),
        ),
      );

      final interaction = await db.postInteractionsDao.getInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );
      expect(interaction, isNotNull);
      expect(interaction!.likeUri, 'at://did:viewer/app.bsky.feed.like/1');
    });

    test('upsertInteraction updates existing interaction', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "test"}',
            ),
          );

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          updatedAt: DateTime.now(),
        ),
      );

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('at://did:viewer/app.bsky.feed.like/1'),
          bookmarked: const Value(true),
          updatedAt: DateTime.now(),
        ),
      );

      final interaction = await db.postInteractionsDao.getInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );
      expect(interaction, isNotNull);
      expect(interaction!.likeUri, 'at://did:viewer/app.bsky.feed.like/1');
      expect(interaction.bookmarked, true);
    });

    test('getInteraction returns null for non-existent post', () async {
      final interaction = await db.postInteractionsDao.getInteraction(
        'at://did:test/app.bsky.feed.post/nonexistent',
        ownerDid,
      );
      expect(interaction, isNull);
    });

    test('watchInteraction emits updates', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "test"}',
            ),
          );

      final stream = db.postInteractionsDao.watchInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );

      unawaited(
        expectLater(
          stream,
          emitsInOrder([
            null,
            isA<PostInteraction>().having((i) => i.likeUri, 'likeUri', isNotNull),
          ]),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('at://did:viewer/app.bsky.feed.like/1'),
          updatedAt: DateTime.now(),
        ),
      );
    });

    test('batchUpsert inserts multiple interactions', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "test1"}',
            ),
          );
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/2',
              cid: 'cid2',
              authorDid: 'did:test:author',
              record: '{"text": "test2"}',
            ),
          );

      await db.postInteractionsDao.batchUpsert([
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('like1'),
          updatedAt: DateTime.now(),
        ),
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/2',
          likeUri: const Value('like2'),
          bookmarked: const Value(true),
          updatedAt: DateTime.now(),
        ),
      ]);

      final i1 = await db.postInteractionsDao.getInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );
      final i2 = await db.postInteractionsDao.getInteraction(
        'at://did:test:author/app.bsky.feed.post/2',
        ownerDid,
      );

      expect(i1?.likeUri, 'like1');
      expect(i2?.likeUri, 'like2');
      expect(i2?.bookmarked, true);
    });

    test('watchLikedPosts returns only liked posts', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "liked"}',
            ),
          );
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/2',
              cid: 'cid2',
              authorDid: 'did:test:author',
              record: '{"text": "not liked"}',
            ),
          );

      await db.postInteractionsDao.batchUpsert([
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('like1'),
          updatedAt: DateTime.now(),
        ),
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/2',
          updatedAt: DateTime.now(),
        ),
      ]);

      final liked = await db.postInteractionsDao.watchLikedPosts(ownerDid).first;
      expect(liked, hasLength(1));
      expect(liked.first.postUri, 'at://did:test:author/app.bsky.feed.post/1');
    });

    test('watchBookmarkedPosts returns only bookmarked posts', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "bookmarked"}',
            ),
          );
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/2',
              cid: 'cid2',
              authorDid: 'did:test:author',
              record: '{"text": "not bookmarked"}',
            ),
          );

      await db.postInteractionsDao.batchUpsert([
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          bookmarked: const Value(true),
          updatedAt: DateTime.now(),
        ),
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/2',
          updatedAt: DateTime.now(),
        ),
      ]);

      final bookmarked = await db.postInteractionsDao.watchBookmarkedPosts(ownerDid).first;
      expect(bookmarked, hasLength(1));
      expect(bookmarked.first.postUri, 'at://did:test:author/app.bsky.feed.post/1');
    });

    test('deleteInteraction removes interaction', () async {
      await db
          .into(db.profiles)
          .insert(ProfilesCompanion.insert(did: 'did:test:author', handle: 'author'));
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              uri: 'at://did:test:author/app.bsky.feed.post/1',
              cid: 'cid1',
              authorDid: 'did:test:author',
              record: '{"text": "test"}',
            ),
          );

      await db.postInteractionsDao.upsertInteraction(
        PostInteractionsCompanion.insert(
          ownerDid: ownerDid,
          postUri: 'at://did:test:author/app.bsky.feed.post/1',
          likeUri: const Value('like1'),
          updatedAt: DateTime.now(),
        ),
      );

      final deleted = await db.postInteractionsDao.deleteInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );
      expect(deleted, 1);

      final interaction = await db.postInteractionsDao.getInteraction(
        'at://did:test:author/app.bsky.feed.post/1',
        ownerDid,
      );
      expect(interaction, isNull);
    });
  });
}
