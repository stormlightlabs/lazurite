import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_relationship_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockProfileDao extends Mock implements ProfileDao {}

class MockFollowsDao extends Mock implements FollowsDao {}

class MockProfileRelationshipDao extends Mock implements ProfileRelationshipDao {}

void main() {
  late MockXrpcClient mockApi;
  late MockProfileDao mockProfileDao;
  late MockFollowsDao mockFollowsDao;
  late MockProfileRelationshipDao mockRelationshipsDao;
  late MockLogger mockLogger;
  late ProfileRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    mockProfileDao = MockProfileDao();
    mockFollowsDao = MockFollowsDao();
    mockRelationshipsDao = MockProfileRelationshipDao();
    mockLogger = MockLogger();
    repository = ProfileRepository(
      mockApi,
      mockProfileDao,
      mockFollowsDao,
      mockRelationshipsDao,
      mockLogger,
    );
  });

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [profileRepositoryProvider.overrideWithValue(repository)]);
  }

  group('FollowingNotifier', () {
    test('fetches initial following on build', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse());

      final container = createContainer();
      final result = await container.read(followingProvider('did:plc:test').future);

      expect(result, hasLength(2));
      expect(result.first.did, 'did:plc:following1');
      expect(result.first.displayName, 'Following One');
    });

    test('loadMore appends to existing list', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse(cursor: 'next'));

      final container = createContainer();
      await container.read(followingProvider('did:plc:test').future);

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse(cursor: null));

      await container.read(followingProvider('did:plc:test').notifier).loadMore();

      final result = container.read(followingProvider('did:plc:test')).value!;
      expect(result, hasLength(4));
    });

    test('loadMore when hasMore is false does nothing', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse(cursor: null));

      final container = createContainer();
      await container.read(followingProvider('did:plc:test').future);

      await container.read(followingProvider('did:plc:test').notifier).loadMore();

      verify(() => mockApi.call(any(), params: any(named: 'params'))).called(1);
    });

    test('refresh resets cursor and reloads', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse(cursor: 'next'));

      final container = createContainer();
      await container.read(followingProvider('did:plc:test').future);
      await container.read(followingProvider('did:plc:test').notifier).loadMore();

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowsResponse(cursor: null));

      await container.read(followingProvider('did:plc:test').notifier).refresh();

      final result = container.read(followingProvider('did:plc:test')).value!;
      expect(result, hasLength(2));
    });
  });
}

Map<String, dynamic> _mockFollowsResponse({String? cursor = 'next'}) => {
  'follows': [
    {
      'did': 'did:plc:following1',
      'handle': 'following1.bsky.social',
      'displayName': 'Following One',
      'avatar': 'https://example.com/f1.jpg',
    },
    {'did': 'did:plc:following2', 'handle': 'following2.bsky.social'},
  ],
  if (cursor != null) 'cursor': cursor,
};
