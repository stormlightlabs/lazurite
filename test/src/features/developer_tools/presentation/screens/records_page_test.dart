import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/records_page.dart';
import 'package:lazurite/src/features/developer_tools/infrastructure/devtools_repository.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  group('RecordsPage', () {
    const testDid = 'did:web:test.example';
    const testCollection = 'app.bsky.feed.post';

    late AppDatabase testDb;
    late MockDevToolsDao mockDevToolsDao;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockDevToolsDao = MockDevToolsDao();
      testDb = MockAppDatabase();

      when(() => testDb.devToolsDao).thenReturn(mockDevToolsDao);

      when(
        () => mockDevToolsDao.savePin(
          uri: any(named: 'uri'),
          type: any(named: 'type'),
          label: any(named: 'label'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockDevToolsDao.deletePin(any())).thenAnswer((_) async {});
    });

    testWidgets('renders loading state correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(testDb)],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: testCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state correctly', (tester) async {
      final testError = Exception('Failed to load records');
      final mockRepo = _MockDevtoolsRepository()..throwError(testError);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: testCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load records'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders empty state correctly', (tester) async {
      final mockRepo = _MockDevtoolsRepository()..setEmptyResponse();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: testCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('renders records list correctly', (tester) async {
      final testRecords = [
        RepoRecord(
          uri: 'at://$testDid/$testCollection/record1',
          cid: 'bafytest1',
          value: {'text': 'Hello world', 'createdAt': '2023-01-01T00:00:00.000Z'},
          indexedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        ),
        RepoRecord(
          uri: 'at://$testDid/$testCollection/record2',
          cid: 'bafytest2',
          value: {'text': 'Another post', 'createdAt': '2023-01-02T00:00:00.000Z'},
          indexedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
        ),
      ];

      final mockRepo = _MockDevtoolsRepository()..setRecords(testRecords);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: testCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('record1'), findsOneWidget);
      expect(find.text('record2'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('Another post'), findsOneWidget);
      expect(find.text('View Details'), findsNWidgets(2));
    });

    testWidgets('formats collection name in title', (tester) async {
      const longCollection = 'app.bsky.feed.some.long.collection.name';
      final mockRepo = _MockDevtoolsRepository()..setEmptyResponse();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: longCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('name'), findsOneWidget);
    });

    testWidgets('shows loading indicator when has more records', (tester) async {
      final testRecords = [
        const RepoRecord(
          uri: 'at://$testDid/$testCollection/record1',
          cid: 'bafytest1',
          value: {'text': 'Hello world'},
        ),
      ];

      final mockRepo = _MockDevtoolsRepository()..setRecordsWithCursor(testRecords, 'next-cursor');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: testCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders different record preview types', (tester) async {
      const customCollection = 'custom.collection';
      final testRecords = [
        const RepoRecord(
          uri: 'at://$testDid/$customCollection/record1',
          cid: 'bafytest5',
          value: {'key1': 'value1', 'key2': 'value2', 'key3': 'value3'},
        ),
      ];

      final mockRepo = _MockDevtoolsRepository()..setRecords(testRecords);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            devtoolsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: const RecordsPage(did: testDid, collection: customCollection),
            theme: AppTheme.dark,
          ),
        ),
      );

      await tester.pump();
      expect(find.text('JSON Record'), findsOneWidget);
      expect(find.text('key1: value1\nkey2: value2\nkey3: value3'), findsOneWidget);
    });
  });
}

class _MockDevtoolsRepository extends Mock implements DevtoolsRepository {
  List<RepoRecord>? _records;
  String? _cursor;
  Exception? _error;

  void setRecords(List<RepoRecord> records) {
    _records = records;
    _cursor = null;
    _error = null;
  }

  void setRecordsWithCursor(List<RepoRecord> records, String cursor) {
    _records = records;
    _cursor = cursor;
    _error = null;
  }

  void setEmptyResponse() {
    _records = [];
    _cursor = null;
    _error = null;
  }

  void throwError(Exception error) {
    _error = error;
    _records = null;
    _cursor = null;
  }

  @override
  Future<Map<String, dynamic>> listRecords({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool reverse = false,
    String? rkeyEnd,
    String? rkeyStart,
  }) async {
    if (_error != null) {
      throw _error!;
    }

    return {'records': _records ?? [], 'cursor': _cursor};
  }
}
