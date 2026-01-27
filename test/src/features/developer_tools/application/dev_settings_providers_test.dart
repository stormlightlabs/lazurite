import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/developer_tools/application/dev_settings_providers.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockDevToolsDao extends Mock implements DevToolsDao {}

void main() {
  group('DevSettingsProviders', () {
    late MockAppDatabase mockDb;
    late MockDevToolsDao mockDao;
    late ProviderContainer container;

    setUp(() {
      mockDb = MockAppDatabase();
      mockDao = MockDevToolsDao();
      when(() => mockDb.devToolsDao).thenReturn(mockDao);

      container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(mockDb)]);
    });

    tearDown(() {
      container.dispose();
    });

    test('AllowOtherRepos initial value', () async {
      when(
        () => mockDao.getSetting('dev_tools_allow_other_repos'),
      ).thenAnswer((_) async => 'true');

      final value = await container.read(allowOtherReposProvider.future);
      expect(value, isTrue);
    });

    test('AllowOtherRepos toggle', () async {
      when(
        () => mockDao.getSetting('dev_tools_allow_other_repos'),
      ).thenAnswer((_) async => 'false');
      when(() => mockDao.setSetting(any(), any(), any())).thenAnswer((_) async => {});

      final notifier = container.read(allowOtherReposProvider.notifier);
      await notifier.toggle();

      verify(() => mockDao.setSetting('dev_tools_allow_other_repos', 'true', 'boolean')).called(1);
    });

    test('EnableRecordEditing toggle', () async {
      when(
        () => mockDao.getSetting('dev_tools_enable_record_editing'),
      ).thenAnswer((_) async => 'true');
      when(() => mockDao.setSetting(any(), any(), any())).thenAnswer((_) async => {});

      final notifier = container.read(enableRecordEditingProvider.notifier);
      await notifier.toggle();

      verify(
        () => mockDao.setSetting('dev_tools_enable_record_editing', 'false', 'boolean'),
      ).called(1);
    });
  });
}
