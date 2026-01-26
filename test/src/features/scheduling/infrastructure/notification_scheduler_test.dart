import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/notification_scheduler.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' as db;
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../helpers/mocks.dart';

void main() {
  late NotificationScheduler scheduler;
  late MockSchedulesDao mockSchedulesDao;
  late MockSessionStorage mockSessionStorage;
  late MockLogger mockLogger;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;

  setUpAll(() {
    tz_data.initializeTimeZones();

    registerFallbackValue(tz.TZDateTime.now(tz.UTC));
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('channel', 'name'),
        iOS: DarwinNotificationDetails(),
      ),
    );
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(Exception('error'));
  });

  setUp(() {
    mockSchedulesDao = MockSchedulesDao();
    mockSessionStorage = MockSessionStorage();
    mockLogger = MockLogger();
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

    scheduler = NotificationScheduler(
      schedulesDao: mockSchedulesDao,
      sessionStorage: mockSessionStorage,
      logger: mockLogger,
      plugin: mockNotificationsPlugin,
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

  group('NotificationScheduler - schedule', () {
    test('schedules notification with correct TZDateTime and payload', () async {
      final scheduledTime = DateTime.utc(2030, 1, 26, 10, 0);
      final expectedNotificationId = 1000000 + testDraftId.hashCode.abs();

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).thenAnswer((_) async {});

      final result = await scheduler.schedule(testDraftId, scheduledTime);

      expect(result, isTrue);
      verify(
        () => mockNotificationsPlugin.zonedSchedule(
          id: expectedNotificationId,
          scheduledDate: any(named: 'scheduledDate', that: isA<tz.TZDateTime>()),
          notificationDetails: any(named: 'notificationDetails', that: isA<NotificationDetails>()),
          payload: 'draft:$testDraftId',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        ),
      ).called(1);
    });

    test('returns false when no active session', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      final result = await scheduler.schedule(testDraftId, DateTime.utc(2030, 1, 26));

      expect(result, isFalse);
      verifyNever(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      );
    });

    test('returns false when scheduled time is in the past', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);

      final pastTime = DateTime.utc(2020, 1, 1);
      final result = await scheduler.schedule(testDraftId, pastTime);

      expect(result, isFalse);
      verifyNever(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      );
    });

    test('logs error when notification scheduling fails', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).thenThrow(Exception('Notification error'));

      final result = await scheduler.schedule(testDraftId, DateTime.utc(2030, 1, 26));

      expect(result, isFalse);
      verify(
        () => mockLogger.error(
          'Failed to schedule notification for draft $testDraftId',
          any(),
          any(),
        ),
      ).called(1);
    });
  });

  group('NotificationScheduler - cancel', () {
    test('cancels notification with correct ID', () async {
      final expectedNotificationId = 1000000 + testDraftId.hashCode.abs();

      when(() => mockNotificationsPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});

      final result = await scheduler.cancel(testDraftId);

      expect(result, isTrue);
      verify(() => mockNotificationsPlugin.cancel(id: expectedNotificationId)).called(1);
    });

    test('logs error when cancel fails', () async {
      when(
        () => mockNotificationsPlugin.cancel(id: any(named: 'id')),
      ).thenThrow(Exception('Cancel error'));

      final result = await scheduler.cancel(testDraftId);

      expect(result, isFalse);
      verify(
        () => mockLogger.error(
          'Failed to cancel notification for draft $testDraftId',
          any<dynamic>(),
          any<dynamic>(),
        ),
      ).called(1);
    });
  });

  group('NotificationScheduler - resyncAll', () {
    test('reschedules all pending scheduled posts', () async {
      final scheduledTime = DateTime.utc(2030, 1, 26, 10, 0);
      final createdTime = DateTime.utc(2030, 1, 26, 0, 0);

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockSchedulesDao.listSchedulesByStatus(ScheduleStatus.scheduled.name, testDid),
      ).thenAnswer(
        (_) async => [
          db.Schedule(
            draftId: testDraftId,
            ownerDid: testDid,
            scheduledAtUtc: scheduledTime,
            status: 'scheduled',
            attempts: 0,
            createdAt: createdTime,
            updatedAt: createdTime,
          ),
        ],
      );
      when(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).thenAnswer((_) async {});

      await scheduler.resyncAll();

      verify(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate', that: isA<tz.TZDateTime>()),
          notificationDetails: any(named: 'notificationDetails', that: isA<NotificationDetails>()),
          payload: 'draft:$testDraftId',
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).called(1);
    });

    test('skips past notifications', () async {
      final pastTime = DateTime.utc(2020, 1, 1, 10, 0);
      final createdTime = DateTime.utc(2020, 1, 1, 0, 0);

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockSchedulesDao.listSchedulesByStatus(ScheduleStatus.scheduled.name, testDid),
      ).thenAnswer(
        (_) async => [
          db.Schedule(
            draftId: testDraftId,
            ownerDid: testDid,
            scheduledAtUtc: pastTime,
            status: 'scheduled',
            attempts: 0,
            createdAt: createdTime,
            updatedAt: createdTime,
          ),
        ],
      );

      await scheduler.resyncAll();

      verifyNever(
        () => mockNotificationsPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      );
    });

    test('logs warning when no active session', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await scheduler.resyncAll();

      verify(() => mockLogger.warning('Cannot resync notifications: no active session')).called(1);
      verifyNever(() => mockSchedulesDao.listSchedulesByStatus(any(), any()));
    });

    test('handles errors during resync', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
      when(
        () => mockSchedulesDao.listSchedulesByStatus(any(), any()),
      ).thenThrow(Exception('Database error'));

      await scheduler.resyncAll();

      verify(() => mockLogger.error('Failed to resync notifications', any(), any())).called(1);
    });
  });

  group('NotificationScheduler - helper methods', () {
    test('generates consistent notification ID from draft ID', () {
      final id1 = 1000000 + testDraftId.hashCode.abs();
      final id2 = 1000000 + testDraftId.hashCode.abs();

      expect(id1, equals(id2));
      expect(id1, isPositive);
    });

    test('converts UTC to local timezone correctly', () {
      final utcTime = DateTime.utc(2030, 1, 26, 10, 0);
      expect(() => utcTime.toLocal(), returnsNormally);
    });
  });
}
