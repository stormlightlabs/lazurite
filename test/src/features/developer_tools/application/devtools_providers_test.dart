import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/features/developer_tools/infrastructure/devtools_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockDevtoolsRepository extends Mock implements DevtoolsRepository {}

void main() {
  group('Records Provider', () {
    late ProviderContainer container;
    late MockDevtoolsRepository mockRepository;
    const testDid = 'did:plc:test123';
    const testCollection = 'app.bsky.feed.post';

    final testRecords = [
      const RepoRecord(
        uri: 'at://$testDid/$testCollection/abc123',
        cid: 'bafyreiabc123',
        value: {'text': 'Post 1'},
      ),
      const RepoRecord(
        uri: 'at://$testDid/$testCollection/def456',
        cid: 'bafyreide456',
        value: {'text': 'Post 2'},
      ),
    ];

    setUp(() {
      mockRepository = MockDevtoolsRepository();

      container = ProviderContainer(
        overrides: [devtoolsRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads initial records without duplicates', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => {'records': testRecords, 'cursor': 'next-cursor'});

      final state = await container.read(recordsProvider(testDid, testCollection).future);

      expect(state.records, hasLength(2));
      expect(state.cursor, 'next-cursor');
      expect(state.hasMore, true);
      expect(state.isLoading, false);
      expect(state.error, isNull);

      final uris = state.records.map((r) => r.uri).toSet();
      expect(uris.length, 2);
    });

    test('loads more records on pagination', () async {
      final initialRecords = [testRecords[0]];
      final moreRecords = [testRecords[1]];

      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
          cursor: null,
        ),
      ).thenAnswer((_) async => {'records': initialRecords, 'cursor': 'page2'});

      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
          cursor: 'page2',
        ),
      ).thenAnswer((_) async => {'records': moreRecords, 'cursor': null});

      final notifier = container.read(recordsProvider(testDid, testCollection).notifier);
      await container.read(recordsProvider(testDid, testCollection).future);

      await notifier.loadMore();

      final state = container.read(recordsProvider(testDid, testCollection)).requireValue;

      expect(state.records, hasLength(2));
      expect(state.cursor, isNull);
      expect(state.hasMore, false);
      expect(state.isLoading, false);
    });

    test('does not paginate when already loading', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => {'records': testRecords, 'cursor': 'next-cursor'});

      final notifier = container.read(recordsProvider(testDid, testCollection).notifier);
      await container.read(recordsProvider(testDid, testCollection).future);

      final currentState = container.read(recordsProvider(testDid, testCollection)).requireValue;
      container.read(recordsProvider(testDid, testCollection).notifier).state = AsyncValue.data(
        currentState.copyWith(isLoading: true),
      );

      await notifier.loadMore();

      verify(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('does not paginate when no more records', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => {'records': testRecords, 'cursor': null});

      final notifier = container.read(recordsProvider(testDid, testCollection).notifier);
      await container.read(recordsProvider(testDid, testCollection).future);

      await notifier.loadMore();

      verify(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('refreshes records from beginning', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => {'records': testRecords, 'cursor': 'next-cursor'});

      final notifier = container.read(recordsProvider(testDid, testCollection).notifier);
      await container.read(recordsProvider(testDid, testCollection).future);

      await notifier.refresh();

      verify(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).called(2);
    });

    test('handles errors during initial load', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      await container.read(recordsProvider(testDid, testCollection).future);
      final state = container.read(recordsProvider(testDid, testCollection)).requireValue;

      expect(state.records, isEmpty);
      expect(state.error, isA<Exception>());
      expect(state.hasMore, false);
    });

    test('handles errors during pagination', () async {
      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
          cursor: null,
        ),
      ).thenAnswer((_) async => {'records': testRecords, 'cursor': 'page2'});

      when(
        () => mockRepository.listRecords(
          repo: any(named: 'repo'),
          collection: any(named: 'collection'),
          limit: any(named: 'limit'),
          cursor: 'page2',
        ),
      ).thenThrow(Exception('Network error'));

      final notifier = container.read(recordsProvider(testDid, testCollection).notifier);
      await container.read(recordsProvider(testDid, testCollection).future);

      await notifier.loadMore();

      final state = container.read(recordsProvider(testDid, testCollection)).requireValue;

      expect(state.records, hasLength(2));
      expect(state.error, isA<Exception>());
      expect(state.isLoading, false);
    });
  });
}
