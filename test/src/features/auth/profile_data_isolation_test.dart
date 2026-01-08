import 'package:drift/drift.dart' show Value;
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

  group('PostInteractions isolation', () {
    test('User B cannot see User A interactions', () async {
      final dao = db.postInteractionsDao;
      const postUri = 'at://did:plc:author/app.bsky.feed.post/123';

      await dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: userA,
          likeUri: const Value('at://did:plc:user_a/app.bsky.feed.like/1'),
          bookmarked: const Value(true),
          updatedAt: DateTime.now(),
        ),
      );

      final userBInteraction = await dao.getInteraction(postUri, userB);
      expect(userBInteraction, isNull);

      final userAInteraction = await dao.getInteraction(postUri, userA);
      expect(userAInteraction, isNotNull);
      expect(userAInteraction!.likeUri, 'at://did:plc:user_a/app.bsky.feed.like/1');
      expect(userAInteraction.bookmarked, true);
    });

    test('Same post can have different interactions for different users', () async {
      final dao = db.postInteractionsDao;
      const postUri = 'at://did:plc:author/app.bsky.feed.post/popular';

      await dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: userA,
          likeUri: const Value('at://did:plc:user_a/app.bsky.feed.like/1'),
          updatedAt: DateTime.now(),
        ),
      );

      await dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: userB,
          bookmarked: const Value(true),
          updatedAt: DateTime.now(),
        ),
      );

      final userAInteraction = await dao.getInteraction(postUri, userA);
      final userBInteraction = await dao.getInteraction(postUri, userB);

      expect(userAInteraction?.likeUri, isNotNull);
      expect(userAInteraction?.bookmarked, false);

      expect(userBInteraction?.likeUri, isNull);
      expect(userBInteraction?.bookmarked, true);
    });

    test('watchLikedPosts only returns posts liked by specific user', () async {
      final dao = db.postInteractionsDao;

      await dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: 'at://did:plc:author/app.bsky.feed.post/1',
          ownerDid: userA,
          likeUri: const Value('at://did:plc:user_a/app.bsky.feed.like/1'),
          updatedAt: DateTime.now(),
        ),
      );

      await dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: 'at://did:plc:author/app.bsky.feed.post/2',
          ownerDid: userB,
          likeUri: const Value('at://did:plc:user_b/app.bsky.feed.like/1'),
          updatedAt: DateTime.now(),
        ),
      );

      final userALikes = await dao.watchLikedPosts(userA).first;
      final userBLikes = await dao.watchLikedPosts(userB).first;

      expect(userALikes, hasLength(1));
      expect(userALikes.first.postUri, 'at://did:plc:author/app.bsky.feed.post/1');

      expect(userBLikes, hasLength(1));
      expect(userBLikes.first.postUri, 'at://did:plc:author/app.bsky.feed.post/2');
    });
  });

  group('Drafts isolation', () {
    test('User B cannot see User A drafts', () async {
      final dao = db.draftsDao;

      await dao.insertDraft(
        DraftsCompanion.insert(
          id: 'draft-a-1',
          ownerDid: userA,
          content: const Value('User A draft content'),
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final userBDrafts = await dao.watchDrafts(userB).first;
      expect(userBDrafts, isEmpty);

      final userADrafts = await dao.watchDrafts(userA).first;
      expect(userADrafts, hasLength(1));
      expect(userADrafts.first.draft.content, 'User A draft content');
    });

    test('getDraft requires matching ownerDid', () async {
      final dao = db.draftsDao;
      const draftId = 'draft-private';

      await dao.insertDraft(
        DraftsCompanion.insert(
          id: draftId,
          ownerDid: userA,
          content: const Value('Private draft'),
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final userBDraft = await dao.getDraft(draftId, userB);
      expect(userBDraft, isNull);

      final userADraft = await dao.getDraft(draftId, userA);
      expect(userADraft, isNotNull);
      expect(userADraft!.draft.content, 'Private draft');
    });

    test('deleteDraft only deletes drafts owned by user', () async {
      final dao = db.draftsDao;

      await dao.insertDraft(
        DraftsCompanion.insert(
          id: 'draft-a',
          ownerDid: userA,
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await dao.deleteDraft('draft-a', userB);

      final userADraft = await dao.getDraft('draft-a', userA);
      expect(userADraft, isNotNull, reason: 'UserB should not be able to delete UserA draft');
    });
  });

  group('DmOutbox isolation', () {
    test('getById requires matching ownerDid', () async {
      final dao = db.dmOutboxDao;
      const outboxId = 'outbox-123';

      await dao.enqueue(
        DmOutboxCompanion.insert(
          outboxId: outboxId,
          ownerDid: userA,
          convoId: 'convo-1',
          messageText: 'Private outbox message',
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      final userBOutbox = await dao.getById(outboxId, userB);
      expect(userBOutbox, isNull);

      final userAOutbox = await dao.getById(outboxId, userA);
      expect(userAOutbox, isNotNull);
      expect(userAOutbox!.messageText, 'Private outbox message');
    });
  });

  group('RecentSearches isolation', () {
    test('User B cannot see User A recent searches', () async {
      final dao = db.searchDao;

      await dao.addRecentSearch('privacy query', userA);
      await dao.addRecentSearch('public search', userB);

      final userASearches = await dao.getRecentSearches(userA);
      final userBSearches = await dao.getRecentSearches(userB);

      expect(userASearches, hasLength(1));
      expect(userASearches.first.query, 'privacy query');

      expect(userBSearches, hasLength(1));
      expect(userBSearches.first.query, 'public search');
    });

    test('Same search query can exist for different users', () async {
      final dao = db.searchDao;
      const query = 'popular search';

      await dao.addRecentSearch(query, userA);
      await dao.addRecentSearch(query, userB);

      final userASearches = await dao.getRecentSearches(userA);
      final userBSearches = await dao.getRecentSearches(userB);

      expect(userASearches, hasLength(1));
      expect(userBSearches, hasLength(1));

      await dao.deleteRecentSearch(query, userA);

      final userAAfterDelete = await dao.getRecentSearches(userA);
      final userBAfterDelete = await dao.getRecentSearches(userB);

      expect(userAAfterDelete, isEmpty);
      expect(userBAfterDelete, hasLength(1), reason: 'UserA delete should not affect UserB');
    });
  });
}
