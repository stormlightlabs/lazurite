import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late ProfileRepository repository;
  const ownerDid = 'did:web:test';

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = ProfileRepository(
      mockApi,
      db.profileDao,
      db.followsDao,
      db.profileRelationshipDao,
      mockLogger,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileRepository Pinned Post', () {
    test('parses pinnedPost URI from API response', () async {
      when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
        (_) async => {
          'did': 'did:plc:test123',
          'handle': 'test.bsky.social',
          'pinnedPost': {
            'uri': 'at://did:plc:test123/app.bsky.feed.post/pinned123',
            'cid': 'bafybeicid123',
          },
        },
      );

      final profile = await repository.getProfile('test.bsky.social', ownerDid);

      expect(profile.pinnedPostUri, 'at://did:plc:test123/app.bsky.feed.post/pinned123');

      final cached = await db.profileDao.getProfile('did:plc:test123');
      expect(cached?.pinnedPostUri, 'at://did:plc:test123/app.bsky.feed.post/pinned123');
    });

    test('handles missing pinnedPost', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => {'did': 'did:plc:test123', 'handle': 'test.bsky.social'});

      final profile = await repository.getProfile('test.bsky.social', ownerDid);

      expect(profile.pinnedPostUri, isNull);
    });
  });
}
