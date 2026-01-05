import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockProfileDao extends Mock implements ProfileDao {}

class MockFollowsDao extends Mock implements FollowsDao {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late MockProfileDao mockProfileDao;
  late MockFollowsDao mockFollowsDao;
  late MockLogger mockLogger;
  late ProfileRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    mockProfileDao = MockProfileDao();
    mockFollowsDao = MockFollowsDao();
    mockLogger = MockLogger();
    repository = ProfileRepository(mockApi, mockProfileDao, mockFollowsDao, mockLogger);
  });

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [profileRepositoryProvider.overrideWithValue(repository)]);
  }

  group('FollowersNotifier', () {
    test('fetches initial followers on build', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse());

      final container = createContainer();
      final result = await container.read(followersProvider('did:plc:test').future);

      expect(result, hasLength(2));
      expect(result.first.did, 'did:plc:follower1');
      expect(result.first.displayName, 'Follower One');
    });

    test('loadMore appends to existing list', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse(cursor: 'next'));

      final container = createContainer();
      await container.read(followersProvider('did:plc:test').future);

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse(cursor: null));

      await container.read(followersProvider('did:plc:test').notifier).loadMore();

      final result = container.read(followersProvider('did:plc:test')).value!;
      expect(result, hasLength(4));
    });

    test('loadMore when hasMore is false does nothing', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse(cursor: null));

      final container = createContainer();
      await container.read(followersProvider('did:plc:test').future);

      await container.read(followersProvider('did:plc:test').notifier).loadMore();

      verify(() => mockApi.call(any(), params: any(named: 'params'))).called(1);
    });

    test('refresh resets cursor and reloads', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse(cursor: 'next'));

      final container = createContainer();
      await container.read(followersProvider('did:plc:test').future);
      await container.read(followersProvider('did:plc:test').notifier).loadMore();

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => _mockFollowersResponse(cursor: null));

      await container.read(followersProvider('did:plc:test').notifier).refresh();

      final result = container.read(followersProvider('did:plc:test')).value!;
      expect(result, hasLength(2));
    });
  });
}

Map<String, dynamic> _mockFollowersResponse({String? cursor = 'next'}) => {
  'followers': [
    {
      'did': 'did:plc:follower1',
      'handle': 'follower1.bsky.social',
      'displayName': 'Follower One',
      'avatar': 'https://example.com/f1.jpg',
    },
    {'did': 'did:plc:follower2', 'handle': 'follower2.bsky.social'},
  ],
  if (cursor != null) 'cursor': cursor,
};
