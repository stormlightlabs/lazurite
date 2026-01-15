import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart' as domain;
import 'package:lazurite/src/features/scheduling/infrastructure/schedule_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late AppDatabase database;
  late ScheduleRepository repository;
  late MockSessionStorage mockSessionStorage;
  late MockLogger mockLogger;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    mockSessionStorage = MockSessionStorage();
    mockLogger = MockLogger();

    const testDid = 'did:plc:test123';
    final testSession = Session(
      did: testDid,
      handle: 'test.bsky.social',
      accessJwt: 'access_jwt',
      refreshJwt: 'refresh_jwt',
      pdsUrl: 'https://bsky.social',
      scope: 'atproto transition:generic',
      expiresAt: DateTime.parse('2030-01-01T00:00:00.000Z'),
      dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'x', 'y': 'y'},
    );

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);

    repository = ScheduleRepository(
      dao: database.schedulesDao,
      sessionStorage: mockSessionStorage,
      logger: mockLogger,
    );
  });

  tearDown(() async {
    await database.close();
  });

  const testDid = 'did:plc:test123';
  const testDraftId = 'draft-123';

  group('ScheduleRepository - upsertSchedule', () {
    test('creates a new schedule', () async {
      final scheduledAt = DateTime.utc(2026, 1, 15, 10, 0);

      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.draftId, testDraftId);
      expect(result.ownerDid, testDid);
      expect(result.status, domain.ScheduleStatus.scheduled);
      expect(result.attempts, 0);
      expect(result.scheduledAtUtc.isAtSameMomentAs(scheduledAt), isTrue);
    });

    test('updates an existing schedule', () async {
      final scheduledAt1 = DateTime.utc(2026, 1, 15, 10, 0);
      final scheduledAt2 = DateTime.utc(2026, 1, 15, 12, 0);

      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt1);
      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt2);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.scheduledAtUtc.isAtSameMomentAs(scheduledAt2), isTrue);
    });
  });

  group('ScheduleRepository - getSchedule', () {
    test('returns null for non-existent schedule', () async {
      final result = await repository.getSchedule('non-existent');
      expect(result, isNull);
    });

    test('returns schedule when it exists', () async {
      final scheduledAt = DateTime.utc(2026, 1, 15, 10, 0);
      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.draftId, testDraftId);
      expect(result.ownerDid, testDid);
    });
  });

  group('ScheduleRepository - watchSchedule', () {
    test('emits null for non-existent schedule', () async {
      final result = await repository.watchSchedule('non-existent').first;
      expect(result, isNull);
    });

    test('emits schedule when it exists', () async {
      final scheduledAt = DateTime.utc(2026, 1, 15, 10, 0);
      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt);

      final result = await repository.watchSchedule(testDraftId).first;
      expect(result, isNotNull);
      expect(result!.draftId, testDraftId);
    });

    test('returns updated schedule after upsert', () async {
      final scheduledAt1 = DateTime.utc(2026, 1, 15, 10, 0);
      final scheduledAt2 = DateTime.utc(2026, 1, 15, 12, 0);

      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt1);

      final results = <domain.Schedule?>[];
      final subscription = repository.watchSchedule(testDraftId).listen(results.add);

      await repository.upsertSchedule(draftId: testDraftId, scheduledAtUtc: scheduledAt2);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(results, hasLength(greaterThan(0)));
      expect(results.last!.scheduledAtUtc.isAtSameMomentAs(scheduledAt2), isTrue);

      await subscription.cancel();
    });
  });

  group('ScheduleRepository - listSchedules', () {
    test('returns empty list when no schedules', () async {
      final result = await repository.listSchedules();
      expect(result, isEmpty);
    });

    test('returns all schedules ordered by scheduled time', () async {
      const draft1 = 'draft-1';
      const draft2 = 'draft-2';
      const draft3 = 'draft-3';

      await repository.upsertSchedule(
        draftId: draft2,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 12, 0),
      );
      await repository.upsertSchedule(
        draftId: draft1,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );
      await repository.upsertSchedule(
        draftId: draft3,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 14, 0),
      );

      final result = await repository.listSchedules();
      expect(result, hasLength(3));
      expect(result[0].draftId, draft1);
      expect(result[1].draftId, draft2);
      expect(result[2].draftId, draft3);
    });
  });

  group('ScheduleRepository - watchSchedules', () {
    test('emits empty list when no schedules', () async {
      final result = await repository.watchSchedules().first;
      expect(result, isEmpty);
    });

    test('emits schedules when they exist', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      final result = await repository.watchSchedules().first;
      expect(result, hasLength(1));
      expect(result[0].draftId, testDraftId);
    });
  });

  group('ScheduleRepository - listSchedulesByStatus', () {
    test('returns schedules filtered by status', () async {
      const draft1 = 'draft-1';
      const draft2 = 'draft-2';
      const draft3 = 'draft-3';

      await repository.upsertSchedule(
        draftId: draft1,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );
      await repository.upsertSchedule(
        draftId: draft2,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 11, 0),
      );
      await repository.upsertSchedule(
        draftId: draft3,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 12, 0),
      );

      await repository.markAsPosted(draft2, 'at://test', 'cid-123');
      await repository.markAsFailed(draft3, 'Test error');

      final scheduled = await repository.listSchedulesByStatus(domain.ScheduleStatus.scheduled);
      final posted = await repository.listSchedulesByStatus(domain.ScheduleStatus.posted);
      final failed = await repository.listSchedulesByStatus(domain.ScheduleStatus.failed);

      expect(scheduled, hasLength(1));
      expect(scheduled[0].draftId, draft1);
      expect(posted, hasLength(1));
      expect(posted[0].draftId, draft2);
      expect(failed, hasLength(1));
      expect(failed[0].draftId, draft3);
    });
  });

  group('ScheduleRepository - listDueSchedules', () {
    test('returns schedules that are due for publishing', () async {
      const draft1 = 'draft-1';
      const draft2 = 'draft-2';

      await repository.upsertSchedule(
        draftId: draft1,
        scheduledAtUtc: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await repository.upsertSchedule(
        draftId: draft2,
        scheduledAtUtc: DateTime.now().add(const Duration(hours: 1)),
      );

      final result = await repository.listDueSchedules();
      expect(result, hasLength(1));
      expect(result[0].draftId, draft1);
    });
  });

  group('ScheduleRepository - updateScheduleStatus', () {
    test('updates schedule status', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.updateScheduleStatus(testDraftId, domain.ScheduleStatus.posting);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.posting);
    });

    test('updates status with attempts and error', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.updateScheduleStatus(
        testDraftId,
        domain.ScheduleStatus.failed,
        attempts: 2,
        lastError: 'Network error',
      );

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.failed);
      expect(result.attempts, 2);
      expect(result.lastError, 'Network error');
    });

    test('updates status with posted URI and CID', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.updateScheduleStatus(
        testDraftId,
        domain.ScheduleStatus.posted,
        postedUri: 'at://test',
        postedCid: 'cid-123',
      );

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.posted);
      expect(result.postedUri, 'at://test');
      expect(result.postedCid, 'cid-123');
    });
  });

  group('ScheduleRepository - markAsPublishing', () {
    test('marks schedule as posting', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsPublishing(testDraftId);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.posting);
    });
  });

  group('ScheduleRepository - markAsPosted', () {
    test('marks schedule as posted with URI and CID', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsPosted(testDraftId, 'at://test', 'cid-123');

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.posted);
      expect(result.postedUri, 'at://test');
      expect(result.postedCid, 'cid-123');
    });
  });

  group('ScheduleRepository - markAsFailed', () {
    test('marks schedule as failed and increments attempts', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsFailed(testDraftId, 'Network error');

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.status, domain.ScheduleStatus.failed);
      expect(result.attempts, 1);
      expect(result.lastError, 'Network error');
    });

    test('increments attempts on multiple failures', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsFailed(testDraftId, 'Error 1');
      await repository.markAsFailed(testDraftId, 'Error 2');

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.attempts, 2);
      expect(result.lastError, 'Error 2');
    });
  });

  group('ScheduleRepository - incrementAttempts', () {
    test('increments attempts counter', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.incrementAttempts(testDraftId);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNotNull);
      expect(result!.attempts, 1);
    });
  });

  group('ScheduleRepository - cancelSchedule', () {
    test('deletes schedule', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.cancelSchedule(testDraftId);

      final result = await repository.getSchedule(testDraftId);
      expect(result, isNull);
    });

    test('does not throw when cancelling non-existent schedule', () async {
      await repository.cancelSchedule('non-existent');
    });
  });

  group('ScheduleRepository - deleteSchedulesByStatus', () {
    test('deletes all schedules with given status', () async {
      const draft1 = 'draft-1';
      const draft2 = 'draft-2';
      const draft3 = 'draft-3';

      await repository.upsertSchedule(
        draftId: draft1,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );
      await repository.upsertSchedule(
        draftId: draft2,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 11, 0),
      );
      await repository.upsertSchedule(
        draftId: draft3,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 12, 0),
      );

      await repository.markAsPosted(draft1, 'at://test1', 'cid-1');
      await repository.markAsPosted(draft2, 'at://test2', 'cid-2');

      final count = await repository.deleteSchedulesByStatus(domain.ScheduleStatus.posted);

      expect(count, 2);

      final remaining = await repository.listSchedules();
      expect(remaining, hasLength(1));
      expect(remaining[0].draftId, draft3);
    });

    test('returns 0 when no schedules match status', () async {
      final count = await repository.deleteSchedulesByStatus(domain.ScheduleStatus.posted);
      expect(count, 0);
    });
  });

  group('ScheduleRepository - countSchedulesByStatus', () {
    test('counts schedules by status', () async {
      const draft1 = 'draft-1';
      const draft2 = 'draft-2';
      const draft3 = 'draft-3';

      await repository.upsertSchedule(
        draftId: draft1,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );
      await repository.upsertSchedule(
        draftId: draft2,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 11, 0),
      );
      await repository.upsertSchedule(
        draftId: draft3,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 12, 0),
      );

      await repository.markAsPosted(draft1, 'at://test1', 'cid-1');
      await repository.markAsPosted(draft2, 'at://test2', 'cid-2');

      final postedCount = await repository.countSchedulesByStatus(domain.ScheduleStatus.posted);
      final scheduledCount = await repository.countSchedulesByStatus(
        domain.ScheduleStatus.scheduled,
      );

      expect(postedCount, 2);
      expect(scheduledCount, 1);
    });

    test('returns 0 when no schedules match status', () async {
      final count = await repository.countSchedulesByStatus(domain.ScheduleStatus.failed);
      expect(count, 0);
    });
  });

  group('ScheduleRepository - domain model helpers', () {
    test('Schedule getters return correct values', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      final schedule = await repository.getSchedule(testDraftId);
      expect(schedule, isNotNull);
      expect(schedule!.isScheduled, isTrue);
      expect(schedule.isPosted, isFalse);
      expect(schedule.isFailed, isFalse);
      expect(schedule.isPublishing, isFalse);
      expect(schedule.canRetry, isFalse);
    });

    test('Schedule.canRetry returns true for failed schedule with < 3 attempts', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsFailed(testDraftId, 'Test error');
      await repository.markAsFailed(testDraftId, 'Test error');

      final schedule = await repository.getSchedule(testDraftId);
      expect(schedule, isNotNull);
      expect(schedule!.isFailed, isTrue);
      expect(schedule.attempts, 2);
      expect(schedule.canRetry, isTrue);
    });

    test('Schedule.canRetry returns false for failed schedule with >= 3 attempts', () async {
      await repository.upsertSchedule(
        draftId: testDraftId,
        scheduledAtUtc: DateTime.utc(2026, 1, 15, 10, 0),
      );

      await repository.markAsFailed(testDraftId, 'Error 1');
      await repository.markAsFailed(testDraftId, 'Error 2');
      await repository.markAsFailed(testDraftId, 'Error 3');

      final schedule = await repository.getSchedule(testDraftId);
      expect(schedule, isNotNull);
      expect(schedule!.isFailed, isTrue);
      expect(schedule.attempts, 3);
      expect(schedule.canRetry, isFalse);
    });
  });
}
