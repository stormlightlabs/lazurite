import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/application/mark_as_seen_service.dart';
import 'package:lazurite/src/features/notifications/infrastructure/notifications_repository.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_sync_queue_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

class MockNotificationsSyncQueueDao extends Mock implements NotificationsSyncQueueDao {}

void main() {
  const ownerDid = 'did:web:tester';
  late MockNotificationsRepository mockRepository;
  late MockNotificationsSyncQueueDao mockSyncQueue;
  late MockLogger mockLogger;
  late MarkAsSeenService service;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    mockSyncQueue = MockNotificationsSyncQueueDao();
    mockLogger = MockLogger();
    service = MarkAsSeenService(mockRepository, mockSyncQueue, mockLogger);

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    registerFallbackValue(DateTime.now());
  });

  tearDown(() {
    service.dispose();
  });

  group('MarkAsSeenService', () {
    group('markAsSeen', () {
      test('batches multiple mark as seen operations', () async {
        final timestamp1 = DateTime.parse('2026-01-07T12:00:00.000Z');
        final timestamp2 = DateTime.parse('2026-01-07T12:01:00.000Z');
        final timestamp3 = DateTime.parse('2026-01-07T12:02:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp1, ownerDid);
        service.markAsSeen(timestamp2, ownerDid);
        service.markAsSeen(timestamp3, ownerDid);

        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockRepository.markAsSeenLocally(timestamp3, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(timestamp3)).called(1);
      });

      test('uses latest timestamp when multiple notifications marked', () async {
        final earlier = DateTime.parse('2026-01-07T12:00:00.000Z');
        final later = DateTime.parse('2026-01-07T12:05:00.000Z');
        final middle = DateTime.parse('2026-01-07T12:02:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(middle, ownerDid);
        service.markAsSeen(earlier, ownerDid);
        service.markAsSeen(later, ownerDid);

        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockRepository.markAsSeenLocally(later, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(later)).called(1);
      });

      test('resets timer when new notification is marked', () async {
        final timestamp1 = DateTime.parse('2026-01-07T12:00:00.000Z');
        final timestamp2 = DateTime.parse('2026-01-07T12:01:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp1, ownerDid);

        await Future.delayed(const Duration(seconds: 1));

        service.markAsSeen(timestamp2, ownerDid);

        await Future.delayed(const Duration(milliseconds: 2500));

        verify(() => mockRepository.markAsSeenLocally(timestamp2, ownerDid)).called(1);
      });
    });

    group('flush', () {
      test('immediately flushes pending operations', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp, ownerDid);

        await service.flush();

        verify(() => mockRepository.markAsSeenLocally(timestamp, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(timestamp)).called(1);
      });

      test('does nothing when no pending operations', () async {
        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        await service.flush();

        verifyNever(() => mockRepository.markAsSeenLocally(any(), any()));
        verifyNever(() => mockRepository.updateSeen(any()));
      });

      test('cancels pending timer', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp, ownerDid);
        await service.flush();

        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockRepository.markAsSeenLocally(timestamp, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(timestamp)).called(1);
      });
    });

    group('error handling', () {
      test('updates local cache even when API fails', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenThrow(Exception('Network error'));
        when(() => mockSyncQueue.enqueueMarkSeen(any(), any())).thenAnswer((_) async => 1);

        service.markAsSeen(timestamp, ownerDid);
        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockRepository.markAsSeenLocally(timestamp, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(timestamp)).called(1);
        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });

      test('does not retry failed operations automatically', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenThrow(Exception('Network error'));
        when(() => mockSyncQueue.enqueueMarkSeen(any(), any())).thenAnswer((_) async => 1);

        service.markAsSeen(timestamp, ownerDid);
        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockRepository.updateSeen(timestamp)).called(1);
      });

      test('enqueues failed operation to sync queue', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenThrow(Exception('Network error'));
        when(() => mockSyncQueue.enqueueMarkSeen(any(), any())).thenAnswer((_) async => 1);

        service.markAsSeen(timestamp, ownerDid);
        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockSyncQueue.enqueueMarkSeen(timestamp, ownerDid)).called(1);
      });

      test('logs error if queueing fails', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenThrow(Exception('Network error'));
        when(
          () => mockSyncQueue.enqueueMarkSeen(any(), any()),
        ).thenThrow(Exception('Queue error'));
        service.markAsSeen(timestamp, ownerDid);
        await Future.delayed(const Duration(seconds: 3));

        verify(() => mockLogger.error(any(), any(), any())).called(2);
      });

      test('does not enqueue when flush succeeds', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp, ownerDid);
        await Future.delayed(const Duration(seconds: 3));

        verifyNever(() => mockSyncQueue.enqueueMarkSeen(any(), any()));
      });
    });

    group('dispose', () {
      test('cancels pending timer', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});

        service.markAsSeen(timestamp, ownerDid);
        service.dispose();

        await Future.delayed(const Duration(seconds: 3));

        verifyNever(() => mockRepository.markAsSeenLocally(any(), any()));
        verifyNever(() => mockRepository.updateSeen(any()));
      });
    });

    group('concurrent operations', () {
      test('prevents concurrent flush operations', () async {
        final timestamp = DateTime.parse('2026-01-07T12:00:00.000Z');

        when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
        when(
          () => mockRepository.updateSeen(any()),
        ).thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 100)));

        service.markAsSeen(timestamp, ownerDid);

        final flush1 = service.flush();
        final flush2 = service.flush();

        await Future.wait([flush1, flush2]);

        verify(() => mockRepository.markAsSeenLocally(timestamp, ownerDid)).called(1);
        verify(() => mockRepository.updateSeen(timestamp)).called(1);
      });
    });
  });
}
