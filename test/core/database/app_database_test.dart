import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = AppDatabase();
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
        );

        expect(updated, isTrue);

        final retrieved = await database.getAccount('did:plc:abc123');
        expect(retrieved!.accessToken, equals('new_token'));
        expect(retrieved.refreshToken, equals('new_refresh'));
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
    });
  });
}
