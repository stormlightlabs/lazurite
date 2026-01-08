import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

/// Regression tests ensuring data isolation by ownerDid.
///
/// These tests verify that data stored for one user is NOT visible to another user,
/// preventing "data bleeding" across accounts.
void main() {
  late AppDatabase db;
  const userA = 'did:plc:user_a';
  const userB = 'did:plc:user_b';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SavedFeeds isolation', () {
    test('User B cannot see User A saved feeds', () async {
      final dao = db.savedFeedsDao;

      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'User A Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: userA,
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final userBFeeds = await dao.getAllFeeds(userB);
      expect(userBFeeds, isEmpty);

      final userAFeeds = await dao.getAllFeeds(userA);
      expect(userAFeeds, hasLength(1));
      expect(userAFeeds.first.displayName, 'User A Feed');
    });

    test('Same URI can exist for different owners', () async {
      final dao = db.savedFeedsDao;
      const sharedUri = 'at://did:plc:shared/app.bsky.feed.generator/popular';

      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: sharedUri,
          displayName: 'Popular (A)',
          creatorDid: 'did:plc:shared',
          ownerDid: userA,
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: sharedUri,
          displayName: 'Popular (B)',
          creatorDid: 'did:plc:shared',
          ownerDid: userB,
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final userAFeed = await dao.getFeed(sharedUri, userA);
      final userBFeed = await dao.getFeed(sharedUri, userB);

      expect(userAFeed?.displayName, 'Popular (A)');
      expect(userBFeed?.displayName, 'Popular (B)');
    });
  });

  group('FeedContent isolation', () {
    test('User B cannot see User A feed content', () async {
      final dao = db.feedContentDao;
      const feedKey = 'home';

      await db.profileDao.upsertProfile(
        ProfilesCompanion.insert(did: 'did:plc:author', handle: 'author.test'),
      );

      await dao.insertFeedContentBatch(
        newPosts: [
          PostsCompanion.insert(
            uri: 'at://did:plc:author/app.bsky.feed.post/1',
            cid: 'bafyabc',
            authorDid: 'did:plc:author',
            record: '{}',
          ),
        ],
        newProfiles: [],
        newRelationships: [],
        newItems: [
          FeedContentItemsCompanion.insert(
            feedKey: feedKey,
            postUri: 'at://did:plc:author/app.bsky.feed.post/1',
            ownerDid: userA,
            sortKey: '2026-01-01T00:00:00Z',
          ),
        ],
        feedKey: feedKey,
        ownerDid: userA,
      );

      final userBContent = await dao.watchFeedContent(feedKey, userB).first;
      expect(userBContent, isEmpty);

      final userAContent = await dao.watchFeedContent(feedKey, userA).first;
      expect(userAContent, hasLength(1));
    });
  });

  group('Notifications isolation', () {
    test('User B cannot see User A notifications', () async {
      final dao = db.notificationsDao;

      await db.profileDao.upsertProfile(
        ProfilesCompanion.insert(did: 'did:plc:actor', handle: 'actor.test'),
      );

      await dao.insertNotificationsBatch(
        newNotifications: [
          NotificationsCompanion.insert(
            uri: 'at://did:plc:actor/app.bsky.feed.like/1',
            ownerDid: userA,
            actorDid: 'did:plc:actor',
            type: 'like',
            indexedAt: DateTime.now(),
            cachedAt: DateTime.now(),
          ),
        ],
        newProfiles: [],
        newCursor: null,
        ownerDid: userA,
      );

      final userBNotifs = await dao.watchNotifications(userB).first;
      expect(userBNotifs, isEmpty);

      final userANotifs = await dao.watchNotifications(userA).first;
      expect(userANotifs, hasLength(1));
    });
  });

  group('DM Conversations isolation', () {
    test('User B cannot see User A conversations', () async {
      final dao = db.dmConvosDao;

      await dao.insertConvosBatch(
        newConvos: [
          DmConvosCompanion.insert(
            convoId: 'convo-123',
            ownerDid: userA,
            membersJson: '["did:plc:member"]',
            cachedAt: DateTime.now(),
          ),
        ],
        newProfiles: [ProfilesCompanion.insert(did: 'did:plc:member', handle: 'member.test')],
      );

      final userBConvos = await dao.watchConversations(userB).first;
      expect(userBConvos, isEmpty);

      final userAConvos = await dao.watchConversations(userA).first;
      expect(userAConvos, hasLength(1));
    });
  });

  group('DM Messages isolation', () {
    test('User B cannot see User A messages', () async {
      final messagesDao = db.dmMessagesDao;
      final convosDao = db.dmConvosDao;
      const convoId = 'shared-convo';

      await db.profileDao.upsertProfile(
        ProfilesCompanion.insert(did: 'did:plc:sender', handle: 'sender.test'),
      );

      await convosDao.insertConvosBatch(
        newConvos: [
          DmConvosCompanion.insert(
            convoId: convoId,
            ownerDid: userA,
            membersJson: '["did:plc:sender"]',
            cachedAt: DateTime.now(),
          ),
          DmConvosCompanion.insert(
            convoId: convoId,
            ownerDid: userB,
            membersJson: '["did:plc:sender"]',
            cachedAt: DateTime.now(),
          ),
        ],
        newProfiles: [],
      );

      await messagesDao.insertMessagesBatch(
        newMessages: [
          DmMessagesCompanion.insert(
            messageId: 'msg-1',
            ownerDid: userA,
            convoId: convoId,
            senderDid: 'did:plc:sender',
            content: 'Private message for A',
            sentAt: DateTime.now(),
            status: 'sent',
            cachedAt: DateTime.now(),
          ),
        ],
        newProfiles: [],
      );

      final userBMessages = await messagesDao.watchMessagesByConvo(convoId, userB).first;
      expect(userBMessages, isEmpty);

      final userAMessages = await messagesDao.watchMessagesByConvo(convoId, userA).first;
      expect(userAMessages, hasLength(1));
      expect(userAMessages.first.message.content, 'Private message for A');
    });
  });

  group('BlueskyPreferences isolation', () {
    test('User B cannot see User A preferences', () async {
      final dao = db.blueskyPreferencesDao;

      await dao.upsertPreference(
        type: 'adultContent',
        ownerDid: userA,
        data: '{"enabled": true}',
        lastSynced: DateTime.now(),
      );

      final userBPref = await dao.getPreferenceByType('adultContent', userB);
      expect(userBPref, isNull);

      final userAPref = await dao.getPreferenceByType('adultContent', userA);
      expect(userAPref, isNotNull);
      expect(userAPref!.data, '{"enabled": true}');
    });
  });
}
