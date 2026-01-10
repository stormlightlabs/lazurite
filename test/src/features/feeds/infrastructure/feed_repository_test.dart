import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/saved_feeds_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockSavedFeedsDao extends Mock implements SavedFeedsDao {}

class MockPreferenceSyncQueueDao extends Mock implements PreferenceSyncQueueDao {}

class MockProfileDao extends Mock implements ProfileDao {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late MockSavedFeedsDao mockSavedFeedsDao;
  late MockPreferenceSyncQueueDao mockSyncQueueDao;
  late MockProfileDao mockProfileDao;
  late MockLogger mockLogger;
  late FeedRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    mockSavedFeedsDao = MockSavedFeedsDao();
    mockSyncQueueDao = MockPreferenceSyncQueueDao();
    mockProfileDao = MockProfileDao();
    mockLogger = MockLogger();

    repository = FeedRepository(
      mockApi,
      mockSavedFeedsDao,
      mockSyncQueueDao,
      mockProfileDao,
      mockLogger,
    );

    registerFallbackValue(
      SavedFeedsCompanion.insert(
        uri: 'uri',
        ownerDid: 'did',
        displayName: 'name',
        creatorDid: 'did',
        sortOrder: 0,
        lastSynced: DateTime.now(),
      ),
    );
  });

  group('FeedRepository', () {
    test('syncPreferences inserts placeholder when metadata fetch fails', () async {
      const ownerDid = 'did:web:test';
      const feedUri = 'at://did:test/app.bsky.feed.generator/test';

      when(() => mockApi.isAuthenticated).thenReturn(true);

      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
              'items': [
                {'type': 'feed', 'value': feedUri, 'pinned': true, 'id': '1'},
              ],
            },
          ],
        },
      );

      when(() => mockSavedFeedsDao.getAllFeeds(ownerDid)).thenAnswer((_) async => []);

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerators', params: any(named: 'params')),
      ).thenThrow(Exception('Network error'));

      when(() => mockSavedFeedsDao.upsertFeeds(any())).thenAnswer((_) async {});
      when(
        () => mockSavedFeedsDao.db,
      ).thenThrow(UnimplementedError('DB access not expected unless transaction used'));

      await repository.syncPreferences(ownerDid);

      final captured = verify(() => mockSavedFeedsDao.upsertFeeds(captureAny())).captured;
      final insertedFeeds = captured.first as List<SavedFeedsCompanion>;

      expect(insertedFeeds.length, 1);
      expect(insertedFeeds.first.uri.value, feedUri);
      expect(insertedFeeds.first.displayName.value, 'Unknown Feed'); // This is the placeholder!
      expect(insertedFeeds.first.description.value, 'Metadata unavailable');
    });
    test('seedDefaultFeeds only cleans up legacy home alias for authenticated users', () async {
      const ownerDid = 'did:web:test';
      when(() => mockApi.isAuthenticated).thenReturn(true);

      when(() => mockSavedFeedsDao.getFeed(any(), any())).thenAnswer((_) async => null);
      when(() => mockSavedFeedsDao.deleteFeed(any(), any())).thenAnswer((_) async => 1);
      await repository.seedDefaultFeeds(ownerDid);

      verify(() => mockSavedFeedsDao.deleteFeed(FeedRepository.kHomeFeedUri, ownerDid)).called(1);

      verifyNever(() => mockSavedFeedsDao.deleteFeed(FeedRepository.kForYouFeedUri, ownerDid));
      verifyNever(() => mockSavedFeedsDao.deleteFeed(FeedRepository.kDiscoverFeedUri, ownerDid));
    });
  });
}
