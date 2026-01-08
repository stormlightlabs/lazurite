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
          ),
        ).thenAnswer((_) async {});

        await repository.fetchNotifications();

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
          ),
        ).thenAnswer((_) async {});

        await repository.fetchNotifications(cursor: 'test_cursor');

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
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
          capturedProfiles = invocation.namedArguments[#newProfiles] as List;
        });

        await repository.fetchNotifications();

        expect(capturedNotifications, hasLength(2));
        expect(capturedProfiles, hasLength(2));

        verify(
          () => mockDao.insertNotificationsBatch(
            newNotifications: any(named: 'newNotifications'),
            newProfiles: any(named: 'newProfiles'),
            newCursor: 'next_cursor',
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
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications();

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
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications();

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
          ),
        ).thenAnswer((invocation) async {
          capturedNotifications = invocation.namedArguments[#newNotifications] as List;
        });

        await repository.fetchNotifications();

        expect(capturedNotifications, hasLength(1));
      });

      test('rethrows errors from API', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.fetchNotifications(), throwsException);

        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });
    });

    group('watchNotifications', () {
      test('returns stream from DAO mapped to domain models', () async {
        when(() => mockDao.watchNotifications()).thenAnswer((_) => Stream.value([]));

        final stream = repository.watchNotifications();
        final result = await stream.first;

        expect(result, isEmpty);
        verify(() => mockDao.watchNotifications()).called(1);
      });
    });

    group('getCursor', () {
      test('returns cursor from DAO', () async {
        when(() => mockDao.getCursor()).thenAnswer((_) async => 'test_cursor');

        final cursor = await repository.getCursor();

        expect(cursor, 'test_cursor');
        verify(() => mockDao.getCursor()).called(1);
      });
    });

    group('clearNotifications', () {
      test('calls DAO clearNotifications', () async {
        when(() => mockDao.clearNotifications()).thenAnswer((_) async {});

        await repository.clearNotifications();

        verify(() => mockDao.clearNotifications()).called(1);
      });
    });

    group('markAllAsRead', () {
      test('calls DAO markAllAsRead', () async {
        when(() => mockDao.markAllAsRead()).thenAnswer((_) async {});

        await repository.markAllAsRead();

        verify(() => mockDao.markAllAsRead()).called(1);
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
        when(() => mockDao.markAsSeenBefore(any())).thenAnswer((_) async {});

        await repository.markAsSeenLocally(seenAt);

        verify(() => mockDao.markAsSeenBefore(seenAt)).called(1);
      });
    });

    group('watchUnreadCount', () {
      test('returns stream from DAO', () async {
        when(() => mockDao.watchUnreadCount()).thenAnswer((_) => Stream.value(5));

        final stream = repository.watchUnreadCount();
        final result = await stream.first;

        expect(result, 5);
        verify(() => mockDao.watchUnreadCount()).called(1);
      });
    });

    group('processSyncQueue', () {
      test('does nothing when queue is empty', () async {
        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt()).thenAnswer((_) async => null);

        await repository.processSyncQueue();

        verify(() => mockSyncQueue.cleanupOldFailedItems(any())).called(1);
        verify(() => mockSyncQueue.getLatestSeenAt()).called(1);
        verifyNever(() => mockDao.markAsSeenBefore(any()));
        verifyNever(() => mockApi.call(any(), body: any(named: 'body')));
      });

      test('processes queue with latest timestamp', () async {
        final latestSeenAt = DateTime.parse('2026-01-07T12:30:00.000Z');

        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt()).thenAnswer((_) async => latestSeenAt);
        when(() => mockSyncQueue.getRetryableItems()).thenAnswer((_) async => []);
        when(() => mockDao.markAsSeenBefore(any())).thenAnswer((_) async {});
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer((_) async => {});
        when(() => mockSyncQueue.deleteItemsUpTo(any())).thenAnswer((_) async => 2);

        await repository.processSyncQueue();

        verify(() => mockDao.markAsSeenBefore(latestSeenAt)).called(1);
        verify(
          () => mockApi.call(
            'app.bsky.notification.updateSeen',
            body: {'seenAt': latestSeenAt.toIso8601String()},
          ),
        ).called(1);
        verify(() => mockSyncQueue.deleteItemsUpTo(latestSeenAt)).called(1);
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
        );
        final mockItem2 = NotificationsSyncQueueData(
          id: 2,
          type: 'mark_seen',
          seenAt: latestSeenAt.toIso8601String(),
          createdAt: now,
          retryCount: 1,
        );

        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 0);
        when(() => mockSyncQueue.getLatestSeenAt()).thenAnswer((_) async => latestSeenAt);
        when(
          () => mockSyncQueue.getRetryableItems(),
        ).thenAnswer((_) async => [mockItem1, mockItem2]);
        when(() => mockDao.markAsSeenBefore(any())).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenThrow(Exception('Network error'));
        when(() => mockSyncQueue.incrementRetryCount(any())).thenAnswer((_) async => 1);

        await repository.processSyncQueue();

        verify(() => mockSyncQueue.incrementRetryCount(1)).called(1);
        verify(() => mockSyncQueue.incrementRetryCount(2)).called(1);
        verifyNever(() => mockSyncQueue.deleteItemsUpTo(any()));
      });

      test('cleans up old failed items', () async {
        when(() => mockSyncQueue.cleanupOldFailedItems(any())).thenAnswer((_) async => 3);
        when(() => mockSyncQueue.getLatestSeenAt()).thenAnswer((_) async => null);

        await repository.processSyncQueue();

        verify(() => mockSyncQueue.cleanupOldFailedItems(any())).called(1);
        verify(() => mockLogger.info(any(), any())).called(greaterThanOrEqualTo(1));
      });
    });
  });
}
