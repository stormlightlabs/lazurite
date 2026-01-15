import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/post_publisher.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' as db;
import 'package:lazurite/src/infrastructure/db/daos/drafts_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late PostPublisher publisher;
  late MockDraftsDao mockDraftsDao;
  late MockSchedulesDao mockSchedulesDao;
  late MockSessionStorage mockSessionStorage;
  late MockAuthRepository mockAuthRepository;
  late MockDraftRepository mockDraftRepository;
  late MockLogger mockLogger;

  setUp(() {
    mockDraftsDao = MockDraftsDao();
    mockSchedulesDao = MockSchedulesDao();
    mockSessionStorage = MockSessionStorage();
    mockAuthRepository = MockAuthRepository();
    mockDraftRepository = MockDraftRepository();
    mockLogger = MockLogger();

    publisher = PostPublisher(
      draftsDao: mockDraftsDao,
      schedulesDao: mockSchedulesDao,
      sessionStorage: mockSessionStorage,
      authRepository: mockAuthRepository,
      draftRepository: mockDraftRepository,
      logger: mockLogger,
    );
  });

  const testDid = 'did:plc:test123';
  const testDraftId = 'draft-123';
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

  final testDraftRecord = DraftRecord(
    draft: db.Draft(
      id: testDraftId,
      ownerDid: testDid,
      content: 'Test post',
      status: composer.DraftStatus.draft.name,
      quoteDisabled: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    media: const [],
  );

  const testPublishResult = (uri: 'at://did:plc:test123/app.bsky.feed.post/123', cid: 'cid-123');

  group('PostPublisher - publishDraft builds correct ATProto record shapes', () {
    test('calls DraftRepository.publishDraft to build the ATProto record', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenAnswer((_) async => testSession);
      when(() => mockSessionStorage.saveSession(testSession)).thenAnswer((_) async {});
      when(
        () => mockDraftRepository.publishDraft(testDraftId),
      ).thenAnswer((_) async => testPublishResult);
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          postedUri: any(named: 'postedUri'),
          postedCid: any(named: 'postedCid'),
        ),
      ).thenAnswer((_) async {});

      await publisher.publishDraft(testDraftId);

      verify(() => mockDraftRepository.publishDraft(testDraftId)).called(1);
    });
  });

  group('PostPublisher - Session refresh flow with token storage and retry', () {
    test('successfully refreshes session before publishing', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenAnswer((_) async => testSession);
      when(() => mockSessionStorage.saveSession(testSession)).thenAnswer((_) async {});
      when(
        () => mockDraftRepository.publishDraft(testDraftId),
      ).thenAnswer((_) async => testPublishResult);
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          postedUri: any(named: 'postedUri'),
          postedCid: any(named: 'postedCid'),
        ),
      ).thenAnswer((_) async {});

      final result = await publisher.publishDraft(testDraftId);

      expect(result, equals(testPublishResult));
      verify(() => mockAuthRepository.refreshSession(testSession)).called(1);
      verify(() => mockSessionStorage.saveSession(testSession)).called(1);
      verify(() => mockDraftRepository.publishDraft(testDraftId)).called(1);
    });

    test('handles session refresh failure', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockSchedulesDao.incrementAttempts(any(), any())).thenAnswer((_) async {});
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          lastError: any(named: 'lastError'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenThrow(Exception('Session refresh failed'));

      await expectLater(() => publisher.publishDraft(testDraftId), throwsException);
      verify(() => mockSchedulesDao.incrementAttempts(testDraftId, testDid)).called(1);
    });
  });

  group('PostPublisher - State transitions: scheduled -> posting -> posted/failed', () {
    test('transitions from scheduled to posting to posted on success', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenAnswer((_) async => testSession);
      when(() => mockSessionStorage.saveSession(testSession)).thenAnswer((_) async {});
      when(
        () => mockDraftRepository.publishDraft(testDraftId),
      ).thenAnswer((_) async => testPublishResult);
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          postedUri: any(named: 'postedUri'),
          postedCid: any(named: 'postedCid'),
        ),
      ).thenAnswer((_) async {});

      await publisher.publishDraft(testDraftId);

      verify(
        () => mockSchedulesDao.updateScheduleStatus(
          testDraftId,
          testDid,
          ScheduleStatus.posted.name,
          postedUri: testPublishResult.uri,
          postedCid: testPublishResult.cid,
        ),
      ).called(1);
    });

    test('transitions from scheduled to posting to failed on error', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenAnswer((_) async => testSession);
      when(() => mockSessionStorage.saveSession(testSession)).thenAnswer((_) async {});
      when(
        () => mockDraftRepository.publishDraft(testDraftId),
      ).thenThrow(Exception('Network error'));
      when(() => mockSchedulesDao.incrementAttempts(any(), any())).thenAnswer((_) async {});
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          lastError: any(named: 'lastError'),
        ),
      ).thenAnswer((_) async {});

      await expectLater(() => publisher.publishDraft(testDraftId), throwsException);
      verify(
        () => mockSchedulesDao.updateScheduleStatus(
          testDraftId,
          testDid,
          ScheduleStatus.failed.name,
          lastError: any(named: 'lastError'),
        ),
      ).called(1);
    });
  });

  group('PostPublisher - Idempotency prevents duplicate posts', () {
    test('returns existing URI/CID when draft already posted', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          postedUri: testPublishResult.uri,
          postedCid: testPublishResult.cid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = await publisher.publishDraft(testDraftId);

      expect(result, equals(testPublishResult));
      verifyNever(() => mockDraftRepository.publishDraft(testDraftId));
    });

    test('isAlreadyPosted returns true when schedule has postedUri', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.posted.name,
          attempts: 1,
          postedUri: testPublishResult.uri,
          postedCid: testPublishResult.cid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = await publisher.isAlreadyPosted(testDraftId);

      expect(result, isTrue);
    });

    test('isAlreadyPosted returns false when schedule has no postedUri', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = await publisher.isAlreadyPosted(testDraftId);

      expect(result, isFalse);
    });
  });

  group('PostPublisher - Cancel prevents future publish', () {
    test('fails when schedule does not exist (was canceled)', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer((_) async => null);

      expect(
        () => publisher.publishDraft(testDraftId),
        throwsA(
          isA<Exception>().having((e) => e.toString(), 'message', contains('Schedule for draft')),
        ),
      );
    });
  });

  group('PostPublisher - validateDraft', () {
    test('returns true for valid draft', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);

      final result = await publisher.validateDraft(testDraftId);

      expect(result, isTrue);
    });

    test('returns false when no session', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      final result = await publisher.validateDraft(testDraftId);

      expect(result, isFalse);
    });

    test('returns false when draft not found', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(() => mockDraftsDao.getDraft(testDraftId, testDid)).thenAnswer((_) async => null);

      final result = await publisher.validateDraft(testDraftId);

      expect(result, isFalse);
    });

    test('returns false when draft already posted', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(() => mockDraftsDao.getDraft(testDraftId, testDid)).thenAnswer(
        (_) async => DraftRecord(
          draft: db.Draft(
            id: testDraftId,
            ownerDid: testDid,
            content: 'Test post',
            status: composer.DraftStatus.posted.name,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            quoteDisabled: 0,
          ),
          media: const [],
        ),
      );

      final result = await publisher.validateDraft(testDraftId);

      expect(result, isFalse);
    });
  });

  group('PostPublisher - publishDrafts', () {
    test('publishes multiple drafts and returns results', () async {
      const draftId1 = 'draft-1';
      const draftId2 = 'draft-2';
      const draftId3 = 'draft-3';

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(() => mockDraftsDao.getDraft(any(), testDid)).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(any(), testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.scheduled.name,
          attempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(any(), testDid, ScheduleStatus.posting.name),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.refreshSession(testSession),
      ).thenAnswer((_) async => testSession);
      when(() => mockSessionStorage.saveSession(testSession)).thenAnswer((_) async {});

      when(
        () => mockDraftRepository.publishDraft(draftId1),
      ).thenAnswer((_) async => (uri: 'at://did:plc:test123/app.bsky.feed.post/1', cid: 'cid-1'));
      when(
        () => mockDraftRepository.publishDraft(draftId2),
      ).thenAnswer((_) async => (uri: 'at://did:plc:test123/app.bsky.feed.post/2', cid: 'cid-2'));
      when(() => mockDraftRepository.publishDraft(draftId3)).thenThrow(Exception('Network error'));

      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          postedUri: any(named: 'postedUri'),
          postedCid: any(named: 'postedCid'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockSchedulesDao.incrementAttempts(any(), any())).thenAnswer((_) async {});
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          lastError: any(named: 'lastError'),
        ),
      ).thenAnswer((_) async {});

      final result = await publisher.publishDrafts([draftId1, draftId2, draftId3]);

      expect(result.succeeded, hasLength(2));
      expect(result.failed, hasLength(1));
      expect(result.succeeded[0].draftId, draftId1);
      expect(result.succeeded[1].draftId, draftId2);
      expect(result.failed[0].draftId, draftId3);
    });
  });

  group('PostPublisher - max attempts', () {
    test('throws exception when max attempts exceeded', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockDraftsDao.getDraft(testDraftId, testDid),
      ).thenAnswer((_) async => testDraftRecord);
      when(() => mockSchedulesDao.getSchedule(testDraftId, testDid)).thenAnswer(
        (_) async => db.Schedule(
          draftId: testDraftId,
          ownerDid: testDid,
          scheduledAtUtc: DateTime.now(),
          status: ScheduleStatus.failed.name,
          attempts: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      when(
        () => mockSchedulesDao.updateScheduleStatus(
          any(),
          any(),
          any(),
          lastError: any(named: 'lastError'),
        ),
      ).thenAnswer((_) async {});

      expect(() => publisher.publishDraft(testDraftId), throwsException);
    });
  });
}
