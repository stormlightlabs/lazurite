import 'dart:async';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase', () {
    group('Serialized writes', () {
      test('runSerializedWrite waits for the previous write to finish', () async {
        final events = <String>[];
        final firstStarted = Completer<void>();
        final releaseFirst = Completer<void>();

        final first = database.runSerializedWrite(() async {
          events.add('first-start');
          firstStarted.complete();
          await releaseFirst.future;
          events.add('first-end');
          return 'first';
        });

        await firstStarted.future;
        final second = database.runSerializedWrite(() async {
          events.add('second');
          return 'second';
        });

        await Future<void>.delayed(Duration.zero);
        expect(events, ['first-start']);

        releaseFirst.complete();

        expect(await Future.wait([first, second]), ['first', 'second']);
        expect(events, ['first-start', 'first-end', 'second']);
      });

      test('runSerializedWrite continues after a failed write', () async {
        await expectLater(
          database.runSerializedWrite<void>(() async {
            throw StateError('write failed');
          }),
          throwsA(isA<StateError>()),
        );

        final result = await database.runSerializedWrite(() async => 1);

        expect(result, 1);
      });
    });

    group('Account operations', () {
      test('should insert and retrieve an account', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          accessToken: 'access_token',
        );

        await database.insertAccount(account);
        final retrieved = await database.getAccount('did:plc:abc123');

        expect(retrieved, isNotNull);
        expect(retrieved!.did, equals('did:plc:abc123'));
        expect(retrieved.handle, equals('user.bsky.social'));
        expect(retrieved.accessToken, equals('access_token'));
      });

      test('should return null for non-existent account', () async {
        final result = await database.getAccount('did:plc:nonexistent');
        expect(result, isNull);
      });

      test('should return null when accounts exist but no account is active', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          accessToken: 'access_token',
        );

        await database.insertAccount(account);
        final active = await database.getActiveAccount();

        expect(active, isNull);
      });

      test('should prefer the account selected in settings', () async {
        await database.insertAccount(
          AccountsCompanion.insert(did: 'did:plc:older', handle: 'older.bsky.social', accessToken: 'older-token'),
        );
        await database.insertAccount(
          AccountsCompanion.insert(
            did: 'did:plc:selected',
            handle: 'selected.bsky.social',
            accessToken: 'selected-token',
          ),
        );
        await database.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:older');

        final active = await database.getActiveAccount();

        expect(active, isNotNull);
        expect(active!.did, equals('did:plc:older'));
      });

      test('should return null when the selected active account no longer exists', () async {
        await database.insertAccount(
          AccountsCompanion.insert(
            did: 'did:plc:available',
            handle: 'available.bsky.social',
            accessToken: 'available-token',
          ),
        );
        await database.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:missing');

        final active = await database.getActiveAccount();

        expect(active, isNull);
      });

      test('should return null when no active account exists', () async {
        final active = await database.getActiveAccount();
        expect(active, isNull);
      });

      test('should get all accounts', () async {
        final account1 = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user1.bsky.social',
          accessToken: 'token1',
        );
        final account2 = AccountsCompanion.insert(
          did: 'did:plc:def456',
          handle: 'user2.bsky.social',
          accessToken: 'token2',
        );

        await database.insertAccount(account1);
        await database.insertAccount(account2);

        final accounts = await database.getAllAccounts();
        expect(accounts.length, equals(2));
      });

      test('should delete account', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          accessToken: 'access_token',
        );

        await database.insertAccount(account);
        await database.deleteAccount('did:plc:abc123');

        final retrieved = await database.getAccount('did:plc:abc123');
        expect(retrieved, isNull);
      });

      test('should delete all accounts', () async {
        final account1 = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user1.bsky.social',
          accessToken: 'token1',
        );
        final account2 = AccountsCompanion.insert(
          did: 'did:plc:def456',
          handle: 'user2.bsky.social',
          accessToken: 'token2',
        );

        await database.insertAccount(account1);
        await database.insertAccount(account2);
        await database.deleteAllAccounts();

        final accounts = await database.getAllAccounts();
        expect(accounts, isEmpty);
      });

      test('should update account tokens', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          accessToken: 'old_token',
        );

        await database.insertAccount(account);
        final updated = await database.updateAccountTokens(
          'did:plc:abc123',
          accessToken: 'new_token',
          refreshToken: 'new_refresh',
          dpopNonce: 'nonce-1',
        );

        expect(updated, isTrue);

        final retrieved = await database.getAccount('did:plc:abc123');
        expect(retrieved!.accessToken, equals('new_token'));
        expect(retrieved.refreshToken, equals('new_refresh'));
        expect(retrieved.dpopNonce, equals('nonce-1'));
      });

      test('should preserve nullable session fields when compare-and-swap update omits them', () async {
        final expiresAt = DateTime.utc(2026, 5, 10, 12);
        final account = AccountsCompanion.insert(
          did: 'did:plc:oauth123',
          handle: 'user.bsky.social',
          accessToken: 'old-access',
          refreshToken: const Value('old-refresh'),
          displayName: const Value('Stored User'),
          service: const Value('porcini.us-east.host.bsky.network'),
          oauthService: const Value('bsky.social'),
          oauthClientId: const Value('https://lazurite.stormlightlabs.org/client-metadata.json'),
          oauthTokenType: const Value('DPoP'),
          oauthScope: const Value('atproto transition:generic'),
          dpopNonce: const Value('old-nonce'),
          dpopPublicKey: const Value('public-key'),
          dpopPrivateKey: const Value('private-key'),
          expiresAt: Value(expiresAt),
        );

        await database.insertAccount(account);
        final updated = await database.updateAccountSessionIfRefreshTokenMatches(
          'did:plc:oauth123',
          expectedRefreshToken: 'old-refresh',
          handle: 'user.bsky.social',
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );

        expect(updated, isTrue);

        final retrieved = await database.getAccount('did:plc:oauth123');
        expect(retrieved, isNotNull);
        expect(retrieved!.accessToken, equals('new-access'));
        expect(retrieved.refreshToken, equals('new-refresh'));
        expect(retrieved.displayName, equals('Stored User'));
        expect(retrieved.service, equals('porcini.us-east.host.bsky.network'));
        expect(retrieved.oauthService, equals('bsky.social'));
        expect(retrieved.oauthClientId, equals('https://lazurite.stormlightlabs.org/client-metadata.json'));
        expect(retrieved.oauthTokenType, equals('DPoP'));
        expect(retrieved.oauthScope, equals('atproto transition:generic'));
        expect(retrieved.dpopNonce, equals('old-nonce'));
        expect(retrieved.dpopPublicKey, equals('public-key'));
        expect(retrieved.dpopPrivateKey, equals('private-key'));
        expect(retrieved.expiresAt?.toUtc(), equals(expiresAt));
      });

      test('should persist oauth service separately from pds service', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:oauth123',
          handle: 'oauth-user.bsky.social',
          accessToken: 'access-token',
          service: const Value('porcini.us-east.host.bsky.network'),
          oauthService: const Value('bsky.social'),
        );

        await database.insertAccount(account);
        final retrieved = await database.getAccount('did:plc:oauth123');

        expect(retrieved, isNotNull);
        expect(retrieved!.service, equals('porcini.us-east.host.bsky.network'));
        expect(retrieved.oauthService, equals('bsky.social'));
      });

      test('should persist oauth token restore metadata for opaque-token accounts', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:opaquemetadata123',
          handle: 'opaque-user.bsky.social',
          accessToken: 'opaque-access-token',
          oauthTokenType: const Value('DPoP'),
          oauthScope: const Value('atproto transition:generic'),
        );

        await database.insertAccount(account);
        final retrieved = await database.getAccount('did:plc:opaquemetadata123');

        expect(retrieved, isNotNull);
        expect(retrieved!.oauthTokenType, equals('DPoP'));
        expect(retrieved.oauthScope, equals('atproto transition:generic'));
      });

      test('should persist oauth client id for oauth-backed accounts', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:oauthclient123',
          handle: 'oauth-client-user.bsky.social',
          accessToken: 'access-token',
          oauthClientId: const Value('https://lazurite.stormlightlabs.org/client-metadata.json'),
        );

        await database.insertAccount(account);
        final retrieved = await database.getAccount('did:plc:oauthclient123');

        expect(retrieved, isNotNull);
        expect(retrieved!.oauthClientId, equals('https://lazurite.stormlightlabs.org/client-metadata.json'));
      });
    });

    group('Cache operations', () {
      test('should cache a profile payload', () async {
        await database.cacheProfile(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          payload: '{"did":"did:plc:abc123"}',
        );

        final cached = await database.select(database.cachedProfiles).getSingle();
        expect(cached.did, equals('did:plc:abc123'));
        expect(cached.handle, equals('user.bsky.social'));
      });

      test('should cache a post payload', () async {
        await database.cachePost(
          uri: 'at://did:plc:abc123/app.bsky.feed.post/123',
          authorDid: 'did:plc:abc123',
          payload: '{"uri":"at://did:plc:abc123/app.bsky.feed.post/123"}',
        );

        final cached = await database.select(database.cachedPosts).getSingle();
        expect(cached.authorDid, equals('did:plc:abc123'));
      });

      test('should cache a feed page payload', () async {
        await database.cacheFeedPage(
          accountDid: 'did:plc:test',
          feedKey: 'timeline',
          payload: '{"cursor":"next","posts":[]}',
        );

        final cached = await database.getCachedFeedPage('did:plc:test', 'timeline');
        expect(cached, isNotNull);
        expect(cached!.payload, equals('{"cursor":"next","posts":[]}'));
      });

      test('should upsert and prune cached feed posts', () async {
        final posts = List.generate(
          3,
          (index) => CachedFeedPostsCompanion.insert(
            accountDid: 'did:plc:test',
            feedKey: 'timeline',
            postUri: 'at://did:plc:test/app.bsky.feed.post/$index',
            postJson: '{"uri":"$index"}',
            sortOrder: 3 - index,
          ),
        );
        await database.upsertCachedFeedPosts(accountDid: 'did:plc:test', feedKey: 'timeline', posts: posts);
        await database.pruneCachedFeedPosts(accountDid: 'did:plc:test', feedKey: 'timeline', maxCount: 2);

        final cached = await database.getCachedFeedPosts('did:plc:test', 'timeline');
        expect(cached.length, 2);
        expect(cached.first.postUri, 'at://did:plc:test/app.bsky.feed.post/0');
        expect(cached.last.postUri, 'at://did:plc:test/app.bsky.feed.post/1');
      });

      test('should cache and prune thread roots by recency', () async {
        await database.cacheThreadRoot(
          accountDid: 'did:plc:test',
          rootUri: 'at://did:plc:test/app.bsky.feed.post/old',
          payload: '{"uri":"old"}',
          fetchedAt: DateTime.utc(2026, 5, 1, 10),
        );
        await database.cacheThreadRoot(
          accountDid: 'did:plc:test',
          rootUri: 'at://did:plc:test/app.bsky.feed.post/new',
          payload: '{"uri":"new"}',
          fetchedAt: DateTime.utc(2026, 5, 1, 11),
        );

        await database.pruneCachedThreadRoots('did:plc:test', 1);

        final newest = await database.getCachedThreadRoot('did:plc:test', 'at://did:plc:test/app.bsky.feed.post/new');
        final oldest = await database.getCachedThreadRoot('did:plc:test', 'at://did:plc:test/app.bsky.feed.post/old');
        expect(newest, isNotNull);
        expect(oldest, isNull);
      });

      test('clearLocalCaches removes cache tables while preserving user data', () async {
        await database.insertAccount(
          AccountsCompanion.insert(did: 'did:plc:user', handle: 'user.bsky.social', accessToken: 'token'),
        );
        await database.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:user');
        await database.setSetting('theme', 'dark');
        await database.setSetting('moderation_preferences::did:plc:user', '[]');
        await database.cacheProfile(did: 'did:plc:user', handle: 'user.bsky.social', payload: '{}');
        await database.cachePost(
          uri: 'at://did:plc:user/app.bsky.feed.post/1',
          authorDid: 'did:plc:user',
          payload: '{}',
        );
        await database.cacheFeedPage(accountDid: 'did:plc:user', feedKey: 'timeline', payload: '{}');
        await database.upsertCachedFeedPosts(
          accountDid: 'did:plc:user',
          feedKey: 'timeline',
          posts: [
            CachedFeedPostsCompanion.insert(
              accountDid: 'did:plc:user',
              feedKey: 'timeline',
              postUri: 'at://did:plc:user/app.bsky.feed.post/1',
              postJson: '{}',
              sortOrder: 1,
            ),
          ],
        );
        await database.cacheThreadRoot(
          accountDid: 'did:plc:user',
          rootUri: 'at://did:plc:user/app.bsky.feed.post/1',
          payload: '{}',
        );
        await database.upsertLabelerCache('did:plc:labeler', '{}');
        await database.saveDraft(DraftsCompanion.insert(accountDid: 'did:plc:user', content: 'draft'));
        await database.savePost(
          SavedPostsCompanion.insert(
            accountDid: 'did:plc:user',
            postUri: 'at://did:plc:user/app.bsky.feed.post/saved',
            postJson: '{}',
          ),
        );

        await database.clearLocalCaches();

        expect(await database.select(database.cachedProfiles).get(), isEmpty);
        expect(await database.select(database.cachedPosts).get(), isEmpty);
        expect(await database.select(database.cachedFeedPages).get(), isEmpty);
        expect(await database.select(database.cachedFeedPosts).get(), isEmpty);
        expect(await database.select(database.cachedThreadRoots).get(), isEmpty);
        expect(await database.select(database.labelerCache).get(), isEmpty);
        expect(await database.getSetting('moderation_preferences::did:plc:user'), isNull);

        expect(await database.getAccount('did:plc:user'), isNotNull);
        expect(await database.getSetting(AppDatabase.activeAccountDidSettingKey), 'did:plc:user');
        expect(await database.getSetting('theme'), 'dark');
        expect(await database.getDrafts('did:plc:user'), hasLength(1));
        expect(await database.getSavedPosts('did:plc:user'), hasLength(1));
      });
    });

    group('Notification delivery operations', () {
      test('should update existing delivery metadata on duplicate insert', () async {
        final firstInsert = await database.recordNotificationDelivery(
          accountDid: 'did:plc:test',
          notificationUri: 'at://did:plc:test/app.bsky.feed.post/1',
          notificationCid: 'cid-1',
          reason: 'like',
          indexedAt: DateTime.utc(2026, 5, 1, 9, 0),
          source: 'poll',
        );

        final secondInsert = await database.recordNotificationDelivery(
          accountDid: 'did:plc:test',
          notificationUri: 'at://did:plc:test/app.bsky.feed.post/1',
          notificationCid: 'cid-2',
          reason: 'repost',
          indexedAt: DateTime.utc(2026, 5, 1, 10, 0),
          source: 'push',
        );

        final delivery = await database.getNotificationDelivery(
          'did:plc:test',
          'at://did:plc:test/app.bsky.feed.post/1',
        );

        expect(firstInsert, isTrue);
        expect(secondInsert, isFalse);
        expect(await database.countNotificationDeliveries('did:plc:test'), 1);
        expect(delivery, isNotNull);
        expect(delivery!.notificationCid, 'cid-2');
        expect(delivery.reason, 'repost');
        expect(delivery.indexedAt.toUtc(), DateTime.utc(2026, 5, 1, 10, 0));
        expect(delivery.source, 'push');
      });
    });

    group('Settings operations', () {
      test('should seed default typeahead provider on database creation', () async {
        final value = await database.getSetting('typeahead_provider');
        expect(value, equals('bluesky'));
      });

      test('should seed default appview provider on database creation', () async {
        final value = await database.getSetting('appview_provider');
        expect(value, equals('bluesky'));
      });

      test('should set and get setting', () async {
        await database.setSetting('theme', 'dark');
        final value = await database.getSetting('theme');

        expect(value, equals('dark'));
      });

      test('should return null for non-existent setting', () async {
        final value = await database.getSetting('nonexistent');
        expect(value, isNull);
      });

      test('should update existing setting', () async {
        await database.setSetting('theme', 'light');
        await database.setSetting('theme', 'dark');
        final value = await database.getSetting('theme');

        expect(value, equals('dark'));
      });

      test('should delete setting', () async {
        await database.setSetting('theme', 'dark');
        await database.deleteSetting('theme');
        final value = await database.getSetting('theme');

        expect(value, isNull);
      });

      test('should persist thread auto-collapse depth setting', () async {
        await database.setSetting('thread_auto_collapse_depth', '3');
        final value = await database.getSetting('thread_auto_collapse_depth');

        expect(value, equals('3'));
      });

      test('auth refresh lock is exclusive until released', () async {
        final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 1));

        final firstAcquire = await database.acquireAuthRefreshLock(
          'did:plc:test',
          owner: 'worker-a',
          expiresAt: expiresAt,
        );
        final secondAcquire = await database.acquireAuthRefreshLock(
          'did:plc:test',
          owner: 'worker-b',
          expiresAt: expiresAt,
        );

        expect(firstAcquire, isTrue);
        expect(secondAcquire, isFalse);
        expect(await database.isAuthRefreshLockActive('did:plc:test'), isTrue);

        await database.releaseAuthRefreshLock('did:plc:test', owner: 'worker-a');

        final thirdAcquire = await database.acquireAuthRefreshLock(
          'did:plc:test',
          owner: 'worker-b',
          expiresAt: expiresAt,
        );
        expect(thirdAcquire, isTrue);
      });

      test('auth refresh lock can be stolen after lease expiry', () async {
        final expiredAt = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
        final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 1));

        final firstAcquire = await database.acquireAuthRefreshLock(
          'did:plc:test',
          owner: 'worker-a',
          expiresAt: expiredAt,
        );
        final secondAcquire = await database.acquireAuthRefreshLock(
          'did:plc:test',
          owner: 'worker-b',
          expiresAt: expiresAt,
        );

        expect(firstAcquire, isTrue);
        expect(secondAcquire, isTrue);
      });
    });
  });
}
