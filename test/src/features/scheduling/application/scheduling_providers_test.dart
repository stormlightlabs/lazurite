import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/scheduling/application/scheduling_providers.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/notification_scheduler.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_scheduler.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockLocalSettingsDao extends Mock implements LocalSettingsDao {}

void main() {
  late MockAppDatabase mockDb;
  late MockLocalSettingsDao mockLocalSettingsDao;
  late MockSchedulesDao mockSchedulesDao;
  late MockSessionStorage mockSessionStorage;
  late ProviderContainer container;

  setUp(() {
    mockDb = MockAppDatabase();
    mockLocalSettingsDao = MockLocalSettingsDao();
    mockSchedulesDao = MockSchedulesDao();
    mockSessionStorage = MockSessionStorage();

    when(() => mockDb.localSettingsDao).thenReturn(mockLocalSettingsDao);
    when(() => mockDb.schedulesDao).thenReturn(mockSchedulesDao);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(mockDb),
        sessionStorageProvider.overrideWithValue(mockSessionStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AutoPostEnabled provider', () {
    test('defaults to false when setting is missing', () async {
      when(() => mockLocalSettingsDao.get('auto_post_enabled')).thenAnswer((_) async => null);

      final result = await container.read(autoPostEnabledProvider.future);
      expect(result, isFalse);
    });

    test('returns true when setting is true', () async {
      when(() => mockLocalSettingsDao.get('auto_post_enabled')).thenAnswer((_) async => 'true');

      final result = await container.read(autoPostEnabledProvider.future);
      expect(result, isTrue);
    });

    test('toggle switches the value', () async {
      when(() => mockLocalSettingsDao.get('auto_post_enabled')).thenAnswer((_) async => 'false');
      when(() => mockLocalSettingsDao.set('auto_post_enabled', any())).thenAnswer((_) async => {});

      await container.read(autoPostEnabledProvider.notifier).toggle();

      verify(() => mockLocalSettingsDao.set('auto_post_enabled', 'true')).called(1);
    });
  });

  group('scheduler provider', () {
    test('returns NotificationScheduler when auto-post is disabled', () async {
      when(() => mockLocalSettingsDao.get('auto_post_enabled')).thenAnswer((_) async => 'false');

      await container.read(autoPostEnabledProvider.future);

      final result = container.read(schedulerProvider);
      expect(result, isA<NotificationScheduler>());
    });

    test('returns WorkmanagerScheduler when auto-post is enabled', () async {
      when(() => mockLocalSettingsDao.get('auto_post_enabled')).thenAnswer((_) async => 'true');

      await container.read(autoPostEnabledProvider.future);
      final result = container.read(schedulerProvider);
      expect(result, isA<WorkmanagerScheduler>());
    });
  });
}
