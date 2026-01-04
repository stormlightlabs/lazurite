import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';

void main() {
  late AppDatabase database;
  late ProfileDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.profileDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('ProfileDao', () {
    group('upsertProfile', () {
      test('inserts a new profile', () async {
        final profile = ProfilesCompanion.insert(
          did: 'did:plc:test123',
          handle: 'testuser',
          displayName: const Value('Test User'),
          description: const Value('A test user account'),
          avatar: const Value('https://example.com/avatar.jpg'),
        );

        await dao.upsertProfile(profile);

        final result = await dao.getProfile('did:plc:test123');
        expect(result, isNotNull);
        expect(result!.did, 'did:plc:test123');
        expect(result.handle, 'testuser');
        expect(result.displayName, 'Test User');
        expect(result.description, 'A test user account');
        expect(result.avatar, 'https://example.com/avatar.jpg');
      });

      test('updates an existing profile', () async {
        final profile1 = ProfilesCompanion.insert(
          did: 'did:plc:test123',
          handle: 'testuser',
          displayName: const Value('Test User'),
        );
        await dao.upsertProfile(profile1);

        final profile2 = ProfilesCompanion.insert(
          did: 'did:plc:test123',
          handle: 'testuser',
          displayName: const Value('Updated User'),
          description: const Value('New description'),
        );
        await dao.upsertProfile(profile2);

        final result = await dao.getProfile('did:plc:test123');
        expect(result, isNotNull);
        expect(result!.displayName, 'Updated User');
        expect(result.description, 'New description');
      });
    });

    group('upsertProfiles', () {
      test('inserts multiple profiles', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'user1'),
          ProfilesCompanion.insert(did: 'did:plc:user2', handle: 'user2'),
          ProfilesCompanion.insert(did: 'did:plc:user3', handle: 'user3'),
        ];

        await dao.upsertProfiles(profiles);

        final allProfiles = await dao.getAllProfiles();
        expect(allProfiles, hasLength(3));
        expect(
          allProfiles.map((p) => p.did),
          containsAll(['did:plc:user1', 'did:plc:user2', 'did:plc:user3']),
        );
      });

      test('updates existing profiles in batch', () async {
        final initial = [
          ProfilesCompanion.insert(did: 'did:plc:user1', handle: 'user1'),
          ProfilesCompanion.insert(did: 'did:plc:user2', handle: 'user2'),
        ];
        await dao.upsertProfiles(initial);

        final updates = [
          ProfilesCompanion.insert(
            did: 'did:plc:user1',
            handle: 'user1_updated',
            displayName: const Value('User 1 Updated'),
          ),
          ProfilesCompanion.insert(did: 'did:plc:user3', handle: 'user3'),
        ];
        await dao.upsertProfiles(updates);

        final allProfiles = await dao.getAllProfiles();
        expect(allProfiles, hasLength(3));

        final user1 = await dao.getProfile('did:plc:user1');
        expect(user1!.handle, 'user1_updated');
        expect(user1.displayName, 'User 1 Updated');
      });
    });

    group('getProfile', () {
      test('returns null for non-existent profile', () async {
        final result = await dao.getProfile('did:plc:nonexistent');
        expect(result, isNull);
      });

      test('returns profile with all fields', () async {
        final profile = ProfilesCompanion.insert(
          did: 'did:plc:test',
          handle: 'testhandle',
          displayName: const Value('Display Name'),
          description: const Value('Description'),
          avatar: const Value('avatar.jpg'),
          banner: const Value('banner.jpg'),
          indexedAt: Value(DateTime(2024, 1, 1)),
        );
        await dao.upsertProfile(profile);

        final result = await dao.getProfile('did:plc:test');
        expect(result, isNotNull);
        expect(result!.did, 'did:plc:test');
        expect(result.handle, 'testhandle');
        expect(result.displayName, 'Display Name');
        expect(result.description, 'Description');
        expect(result.avatar, 'avatar.jpg');
        expect(result.banner, 'banner.jpg');
        expect(result.indexedAt, DateTime(2024, 1, 1));
      });
    });

    group('watchProfile', () {
      test('emits null for non-existent profile', () async {
        final result = await dao.watchProfile('did:plc:nonexistent').first;
        expect(result, isNull);
      });

      test('emits profile when it exists', () async {
        final profile = ProfilesCompanion.insert(did: 'did:plc:test', handle: 'testhandle');
        await dao.upsertProfile(profile);

        final result = await dao.watchProfile('did:plc:test').first;
        expect(result, isNotNull);
        expect(result!.did, 'did:plc:test');
      });

      test('returns updated profile after upsert', () async {
        await dao.upsertProfile(ProfilesCompanion.insert(did: 'did:plc:test', handle: 'initial'));
        await dao.upsertProfile(ProfilesCompanion.insert(did: 'did:plc:test', handle: 'updated'));

        final result = await dao.watchProfile('did:plc:test').first;
        expect(result!.handle, 'updated');
      });
    });

    group('deleteProfile', () {
      test('deletes an existing profile', () async {
        await dao.upsertProfile(ProfilesCompanion.insert(did: 'did:plc:test', handle: 'test'));

        final deleted = await dao.deleteProfile('did:plc:test');
        expect(deleted, 1);

        final result = await dao.getProfile('did:plc:test');
        expect(result, isNull);
      });

      test('returns 0 when profile does not exist', () async {
        final deleted = await dao.deleteProfile('did:plc:nonexistent');
        expect(deleted, 0);
      });
    });

    group('getAllProfiles', () {
      test('returns empty list when no profiles', () async {
        final profiles = await dao.getAllProfiles();
        expect(profiles, isEmpty);
      });

      test('returns all profiles', () async {
        await dao.upsertProfiles([
          ProfilesCompanion.insert(did: 'did:plc:a', handle: 'a'),
          ProfilesCompanion.insert(did: 'did:plc:b', handle: 'b'),
        ]);

        final profiles = await dao.getAllProfiles();
        expect(profiles, hasLength(2));
      });
    });
  });
}
