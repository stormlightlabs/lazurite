import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/debug/presentation/network_inspector_tab.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockDevToolsDao extends Mock implements DevToolsDao {}

void main() {
  late MockAppDatabase mockDb;
  late MockDevToolsDao mockDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockDao = MockDevToolsDao();
    when(() => mockDb.devToolsDao).thenReturn(mockDao);
  });

  testWidgets('NetworkInspectorTab displays logs', (tester) async {
    final logs = [
      DevNetworkLog(
        id: 1,
        uuid: 'uuid-1',
        method: 'GET',
        url: 'https://example.com/api',
        statusCode: 200,
        requestHeaders: '{}',
        responseHeaders: '{}',
        timestamp: DateTime.now(),
        durationMs: 150,
        requestBody: null,
        responseBody: null,
        error: null,
      ),
      DevNetworkLog(
        id: 2,
        uuid: 'uuid-2',
        method: 'POST',
        url: 'https://example.com/api/create',
        statusCode: 201,
        requestHeaders: '{}',
        responseHeaders: '{}',
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
        durationMs: 300,
        requestBody: '{"data": "test"}',
        responseBody: '{"id": "1"}',
        error: null,
      ),
    ];

    when(() => mockDao.watchLogs()).thenAnswer((_) => Stream.value(logs));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(mockDb)],
        child: const MaterialApp(home: Scaffold(body: NetworkInspectorTab())),
      ),
    );
    await tester.pump();

    expect(find.text('2 Requests'), findsOneWidget);
    expect(find.text('GET'), findsOneWidget);
    expect(find.text('https://example.com/api'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('POST'), findsOneWidget);
    expect(find.text('201'), findsOneWidget);

    await tester.tap(find.text('GET'));
    await tester.pumpAndSettle();

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.widgetWithText(SelectableText, '150ms'), findsOneWidget);
  });

  testWidgets('NetworkInspectorTab displays empty state', (tester) async {
    when(() => mockDao.watchLogs()).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(mockDb)],
        child: const MaterialApp(home: Scaffold(body: NetworkInspectorTab())),
      ),
    );
    await tester.pump();

    expect(find.text('No network logs recorded.'), findsOneWidget);
  });
}
