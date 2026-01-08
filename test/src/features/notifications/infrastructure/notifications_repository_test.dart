import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/infrastructure/notifications_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_sync_queue_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockNotificationsDao extends Mock implements NotificationsDao {}

class MockNotificationsSyncQueueDao extends Mock implements NotificationsSyncQueueDao {}

void main() {
  late MockXrpcClient mockApi;
  late MockNotificationsDao mockDao;
  late MockNotificationsSyncQueueDao mockSyncQueue;
  late MockLogger mockLogger;
  late NotificationsRepository repository;
  const ownerDid = 'did:web:tester';

  setUp(() {
    mockApi = MockXrpcClient();
    mockDao = MockNotificationsDao();
    mockSyncQueue = MockNotificationsSyncQueueDao();
    mockLogger = MockLogger();
    repository = NotificationsRepository(mockApi, mockDao, mockSyncQueue, mockLogger);

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  group('NotificationsRepository', () {
    group('fetchNotifications', () {
      test('calls listNotifications API with default limit', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'notifications': [], 'cursor': null});
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchNotifications(ownerDid: ownerDid);

        verify(
          () => mockApi.call(
            'app.bsky.notification.listNotifications',
            params: any(named: 'params', that: containsPair('limit', 50)),
          ),
        ).called(1);
      });

      test('includes cursor in API call when provided', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'notifications': [], 'cursor': null});
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchNotifications(cursor: 'test_cursor', ownerDid: ownerDid);

        verify(
          () => mockApi.call(
            'app.bsky.notification.listNotifications',
            params: any(named: 'params', that: containsPair('cursor', 'test_cursor')),
          ),
        ).called(1);
      });

      test('parses and caches notifications with all types', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'notifications': [
              {
                'uri': 'at://did:plc:user/app.bsky.notification/1',
                'cid': 'cid1',
                'author': {
                  'did': 'did:plc:actor1',
                  'handle': 'actor1.bsky.social',
                  'displayName': 'Actor One',
                },
                'reason': 'like',
                'reasonSubject': 'at://did:plc:user/app.bsky.feed.post/1',
                'isRead': false,
                'indexedAt': '2026-01-07T12:00:00.000Z',
                'record': {'text': 'test post'},
              },
              {
                'uri': 'at://did:plc:user/app.bsky.notification/2',
                'cid': 'cid2',
                'author': {'did': 'did:plc:actor2', 'handle': 'actor2.bsky.social'},
                'reason': 'follow',
                'isRead': true,
                'indexedAt': '2026-01-07T11:00:00.000Z',
              },
            ],
            'cursor': 'next_cursor',
          },
        );

        List? capturedNotifications;
        List? capturedProfiles;
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
          capturedProfiles = invocation.namedArguments[#newProfiles] as List;
        });

        await repository.fetchNotifications(ownerDid: ownerDid);

        expect(capturedNotifications, hasLength(2));
        expect(capturedProfiles, hasLength(2));

        verify(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: 'next_cursor',
            ownerDid: ownerDid,
          ),
        ).called(1);
      });

      test('skips notifications without author', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'notifications': [
              {
                'uri': 'at://did:plc:user/app.bsky.notification/1',
                'cid': 'cid1',
                'reason': 'like',
                'isRead': false,
                'indexedAt': '2026-01-07T12:00:00.000Z',
              },
            ],
            'cursor': null,
          },
        );

        List? capturedNotifications;
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications(ownerDid: ownerDid);

        expect(capturedNotifications, isEmpty);
      });

      test('skips unknown notification types', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'notifications': [
              {
                'uri': 'at://did:plc:user/app.bsky.notification/1',
                'cid': 'cid1',
                'author': {'did': 'did:plc:actor1', 'handle': 'actor1.bsky'},
                'reason': 'unknown_type',
                'isRead': false,
                'indexedAt': '2026-01-07T12:00:00.000Z',
              },
            ],
            'cursor': null,
          },
        );

        List? capturedNotifications;
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications(ownerDid: ownerDid);

        expect(capturedNotifications, isEmpty);
      });

      test('handles starterpack-joined with kebab-case', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'notifications': [
              {
                'uri': 'at://did:plc:user/app.bsky.notification/1',
                'cid': 'cid1',
                'author': {'did': 'did:plc:actor1', 'handle': 'actor1.bsky'},
                'reason': 'starterpack-joined',
                'isRead': false,
                'indexedAt': '2026-01-07T12:00:00.000Z',
              },
            ],
            'cursor': null,
          },
        );

        List? capturedNotifications;
        when(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: any(named: 'newCursor'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications(ownerDid: ownerDid);

        expect(capturedNotifications, hasLength(1));
      });

      test('rethrows errors from API', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.fetchNotifications(ownerDid: ownerDid), throwsException);

        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });
    });

    group('watchNotifications', () {
      test('returns stream from DAO mapped to domain models', () async {
        when(() => mockDao.watchNotifications(any())).thenAnswer((_) => Stream.value([]));

        final stream = repository.watchNotifications(ownerDid);
        final result = await stream.first;

        expect(result, isEmpty);
        verify(() => mockDao.watchNotifications(ownerDid)).called(1);
      });
    });

    group('getCursor', () {
      test('returns cursor from DAO', () async {
        when(() => mockDao.getCursor(any())).thenAnswer((_) async => 'test_cursor');

        final cursor = await repository.getCursor(ownerDid);

        expect(cursor, 'test_cursor');
        verify(() => mockDao.getCursor(ownerDid)).called(1);
      });
    });

    group('clearNotifications', () {
      test('calls DAO clearNotifications', () async {
        when(() => mockDao.clearNotifications(any())).thenAnswer((_) async {});

        await repository.clearNotifications(ownerDid);

        verify(() => mockDao.clearNotifications(ownerDid)).called(1);
      });
    });

    group('markAllAsRead', () {
      test('calls DAO markAllAsRead', () async {
        when(() => mockDao.markAllAsRead(any())).thenAnswer((_) async {});

        await repository.markAllAsRead(ownerDid);

        verify(() => mockDao.markAllAsRead(ownerDid)).called(1);
      });
    });

    group('getUnreadCount', () {
      test('fetches unread count from API', () async {
        when(
          () => mockApi.call('app.bsky.notification.getUnreadCount'),
        ).thenAnswer((_) async => {'count': 42});

        final count = await repository.getUnreadCount();

        expect(count, 42);
        verify(() => mockApi.call('app.bsky.notification.getUnreadCount')).called(1);
      });

      test('returns 0 when count is null', () async {
        when(
          () => mockApi.call('app.bsky.notification.getUnreadCount'),
        ).thenAnswer((_) async => {});

        final count = await repository.getUnreadCount();

        expect(count, 0);
      });

      test('rethrows errors from API', () async {
        when(
          () => mockApi.call('app.bsky.notification.getUnreadCount'),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.getUnreadCount(), throwsException);
        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });
    });

    group('updateSeen', () {
      test('calls updateSeen API with timestamp', () async {
        final seenAt = DateTime.parse('2026-01-07T12:30:00.000Z');
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer((_) async => {});

        await repository.updateSeen(seenAt);

        verify(
          () => mockApi.call(
            'app.bsky.notification.updateSeen',
            body: {'seenAt': '2026-01-07T12:30:00.000Z'},
          ),
        ).called(1);
      });

      test('rethrows errors from API', () async {
        final seenAt = DateTime.parse('2026-01-07T12:30:00.000Z');
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.updateSeen(seenAt), throwsException);
        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });
    });

    group('markAsSeenLocally', () {
      test('calls DAO markAsSeenBefore with timestamp', () async {
        final seenAt = DateTime.parse('2026-01-07T12:30:00.000Z');
        when(() => mockDao.markAsSeenBefore(any(), any())).thenAnswer((_) async {});

        await repository.markAsSeenLocally(seenAt, ownerDid);

        verify(() => mockDao.markAsSeenBefore(seenAt, ownerDid)).called(1);
      });
    });

    group('watchUnreadCount', () {
      test('returns stream from DAO', () async {
        when(() => mockDao.watchUnreadCount(any())).thenAnswer((_) => Stream.value(5));

        final stream = repository.watchUnreadCount(ownerDid);
        final result = await stream.first;

        expect(result, 5);
        verify(() => mockDao.watchUnreadCount(ownerDid)).called(1);
      });
    });

    group('processSyncQueue', () {
      test('does nothing when queue is empty', () async {
        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt(any())).thenAnswer((_) async => null);

        await repository.processSyncQueue(ownerDid);

        verify(() => mockSyncQueue.cleanupOldFailedItems(any())).called(1);
        verify(() => mockSyncQueue.getLatestSeenAt(ownerDid)).called(1);
        verifyNever(() => mockDao.markAsSeenBefore(any(), any()));
        verifyNever(() => mockApi.call(any(), body: any(named: 'body')));
      });

      test('processes queue with latest timestamp', () async {
        final latestSeenAt = DateTime.parse('2026-01-07T12:30:00.000Z');

        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt(any())).thenAnswer((_) async => latestSeenAt);
        when(() => mockSyncQueue.getRetryableItems(any())).thenAnswer((_) async => []);
        when(() => mockDao.markAsSeenBefore(any(), any())).thenAnswer((_) async {});
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer((_) async => {});
        when(() => mockSyncQueue.deleteItemsUpTo(any(), any())).thenAnswer((_) async => 2);

        await repository.processSyncQueue(ownerDid);

        verify(() => mockDao.markAsSeenBefore(latestSeenAt, ownerDid)).called(1);
        verify(
          () => mockApi.call(
            'app.bsky.notification.updateSeen',
            body: {'seenAt': latestSeenAt.toIso8601String()},
          ),
        ).called(1);
        verify(() => mockSyncQueue.deleteItemsUpTo(latestSeenAt, ownerDid)).called(1);
      });

      test('increments retry count on failure', () async {
        final latestSeenAt = DateTime.parse('2026-01-07T12:30:00.000Z');
        final now = DateTime.now();

        final mockItem1 = NotificationsSyncQueueData(
          id: 1,
          type: 'mark_seen',
          seenAt: latestSeenAt.toIso8601String(),
          createdAt: now,
          retryCount: 0,
          ownerDid: ownerDid,
        );
        final mockItem2 = NotificationsSyncQueueData(
          id: 2,
          type: 'mark_seen',
          seenAt: latestSeenAt.toIso8601String(),
          createdAt: now,
          retryCount: 1,
          ownerDid: ownerDid,
        );

        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt(any())).thenAnswer((_) async => latestSeenAt);
        when(
          () => mockSyncQueue.getRetryableItems(any()),
        ).thenAnswer((_) async => [mockItem1, mockItem2]);
        when(() => mockDao.markAsSeenBefore(any(), any())).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenThrow(Exception('Network error'));
        when(() => mockSyncQueue.incrementRetryCount(any())).thenAnswer((_) async => 1);

        await repository.processSyncQueue(ownerDid);

        verify(() => mockSyncQueue.incrementRetryCount(1)).called(1);
        verify(() => mockSyncQueue.incrementRetryCount(2)).called(1);
        verifyNever(() => mockSyncQueue.deleteItemsUpTo(any(), any()));
      });

      test('cleans up old failed items', () async {
        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 3);
        when(() => mockSyncQueue.getLatestSeenAt(any())).thenAnswer((_) async => null);

        await repository.processSyncQueue(ownerDid);

        verify(() => mockSyncQueue.cleanupOldFailedItems(any())).called(1);
        verify(() => mockLogger.info(any(), any())).called(greaterThanOrEqualTo(1));
      });
    });
  });
}
