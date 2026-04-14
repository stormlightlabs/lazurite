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

      test('should get active account', () async {
        final account = AccountsCompanion.insert(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          accessToken: 'access_token',
        );

        await database.insertAccount(account);
        final active = await database.getActiveAccount();

        expect(active, isNotNull);
        expect(active!.did, equals('did:plc:abc123'));
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

      test('should fall back when the selected active account no longer exists', () async {
        await database.insertAccount(
          AccountsCompanion.insert(
            did: 'did:plc:available',
            handle: 'available.bsky.social',
            accessToken: 'available-token',
          ),
        );
        await database.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:missing');

        final active = await database.getActiveAccount();

        expect(active, isNotNull);
        expect(active!.did, equals('did:plc:available'));
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
    });

    group('Settings operations', () {
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
    });
  });
}
