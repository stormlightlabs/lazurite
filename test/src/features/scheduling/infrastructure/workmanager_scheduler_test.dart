import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_scheduler.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/schedules_dao.dart';
import 'package:mocktail/mocktail.dart';
import 'package:workmanager/workmanager.dart';

class MockWorkmanager extends Mock implements Workmanager {}

class MockLogger extends Mock implements Logger {}

class MockSchedulesDao extends Mock implements SchedulesDao {}

class MockSessionStorage extends Mock implements SessionStorage {}

class FakeConstraints extends Fake implements Constraints {}

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(FakeConstraints());
    registerFallbackValue(BackoffPolicy.exponential);
  });

  late MockWorkmanager mockWorkmanager;
  late MockLogger mockLogger;
  late MockSchedulesDao mockSchedulesDao;
  late MockSessionStorage mockSessionStorage;
  late WorkmanagerScheduler scheduler;

  setUp(() {
    mockWorkmanager = MockWorkmanager();
    mockLogger = MockLogger();
    mockSchedulesDao = MockSchedulesDao();
    mockSessionStorage = MockSessionStorage();
    scheduler = WorkmanagerScheduler(
      schedulesDao: mockSchedulesDao,
      sessionStorage: mockSessionStorage,
      logger: mockLogger,
      workmanager: mockWorkmanager,
    );
  });

  group('WorkmanagerScheduler', () {
    const draftId = 'test_draft_id';
    final scheduledAt = DateTime.now().add(const Duration(hours: 1)).toUtc();

    test('schedule registers a one-off task with correct parameters', () async {
      when(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          tag: any(named: 'tag'),
          initialDelay: any(named: 'initialDelay'),
          inputData: any(named: 'inputData'),
          constraints: any(named: 'constraints'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).thenAnswer((_) async => {});

      final result = await scheduler.schedule(draftId, scheduledAt);

      expect(result, isTrue);
      verify(
        () => mockWorkmanager.registerOneOffTask(
          'task_$draftId',
          WorkmanagerScheduler.taskName,
          tag: 'scheduled_post_$draftId',
          initialDelay: any(named: 'initialDelay', that: isA<Duration>()),
          inputData: {'draftId': draftId},
          constraints: any(named: 'constraints', that: isA<Constraints>()),
          backoffPolicy: BackoffPolicy.exponential,
          backoffPolicyDelay: const Duration(minutes: 5),
        ),
      ).called(1);
    });

    test('resyncAll re-registers all scheduled tasks for current user', () async {
      final session = Session(
        did: 'did:plc:user1',
        handle: 'user1.test',
        pdsUrl: 'https://pds.test',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'atproto',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      );

      final scheduleRecord = Schedule(
        draftId: 'draft1',
        ownerDid: 'did:plc:user1',
        scheduledAtUtc: scheduledAt,
        status: 'scheduled',
        attempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => session);
      when(
        () => mockSchedulesDao.listSchedulesByStatus('scheduled', session.did),
      ).thenAnswer((_) async => [scheduleRecord]);
      when(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          tag: any(named: 'tag'),
          initialDelay: any(named: 'initialDelay'),
          inputData: any(named: 'inputData'),
          constraints: any(named: 'constraints'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).thenAnswer((_) async => {});

      await scheduler.resyncAll();

      verify(() => mockSessionStorage.getSession()).called(1);
      verify(() => mockSchedulesDao.listSchedulesByStatus('scheduled', session.did)).called(1);
      verify(
        () => mockWorkmanager.registerOneOffTask(
          'task_draft1',
          WorkmanagerScheduler.taskName,
          tag: 'scheduled_post_draft1',
          initialDelay: any(named: 'initialDelay'),
          inputData: {'draftId': 'draft1'},
          constraints: any(named: 'constraints'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).called(1);
    });

    test('cancel cancels task by unique name', () async {
      when(() => mockWorkmanager.cancelByUniqueName(any())).thenAnswer((_) async => {});

      final result = await scheduler.cancel(draftId);

      expect(result, isTrue);
      verify(() => mockWorkmanager.cancelByUniqueName('task_$draftId')).called(1);
    });
  });
}
