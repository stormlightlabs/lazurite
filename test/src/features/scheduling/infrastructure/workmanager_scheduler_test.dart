import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_scheduler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:workmanager/workmanager.dart';

class MockWorkmanager extends Mock implements Workmanager {}

class MockLogger extends Mock implements Logger {}

class FakeConstraints extends Fake implements Constraints {}

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(FakeConstraints());
  });

  late MockWorkmanager mockWorkmanager;
  late MockLogger mockLogger;
  late WorkmanagerScheduler scheduler;

  setUp(() {
    mockWorkmanager = MockWorkmanager();
    mockLogger = MockLogger();
    scheduler = WorkmanagerScheduler(logger: mockLogger, workmanager: mockWorkmanager);
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
        ),
      ).called(1);
    });

    test('schedule returns false and logs warning if time is in the past', () async {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1)).toUtc();

      final result = await scheduler.schedule(draftId, pastTime);

      expect(result, isFalse);
      verify(() => mockLogger.warning(any())).called(1);
      verifyNever(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          tag: any(named: 'tag'),
          initialDelay: any(named: 'initialDelay'),
          inputData: any(named: 'inputData'),
          constraints: any(named: 'constraints'),
        ),
      );
    });

    test('cancel cancels task by unique name', () async {
      when(() => mockWorkmanager.cancelByUniqueName(any())).thenAnswer((_) async => {});

      final result = await scheduler.cancel(draftId);

      expect(result, isTrue);
      verify(() => mockWorkmanager.cancelByUniqueName('task_$draftId')).called(1);
    });

    test('methods return false on exception and log error', () async {
      when(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          tag: any(named: 'tag'),
          initialDelay: any(named: 'initialDelay'),
          inputData: any(named: 'inputData'),
          constraints: any(named: 'constraints'),
        ),
      ).thenThrow(Exception('Failed'));

      final result = await scheduler.schedule(draftId, scheduledAt);

      expect(result, isFalse);
      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });
  });
}
