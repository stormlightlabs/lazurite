import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';
import 'package:mocktail/mocktail.dart';

class MockSemanticIndexer extends Mock implements SemanticIndexer {}

class MockEmbeddingRepository extends Mock implements EmbeddingRepository {}

const _accountDid = 'did:plc:testuser';

void main() {
  late MockSemanticIndexer mockIndexer;
  late MockEmbeddingRepository mockRepo;

  setUp(() {
    mockIndexer = MockSemanticIndexer();
    mockRepo = MockEmbeddingRepository();

    when(() => mockRepo.countByAccount(_accountDid)).thenReturn(0);
    when(() => mockRepo.queryByAccount(_accountDid)).thenReturn([]);
    when(() => mockRepo.deleteByUri(any())).thenReturn(null);
    when(() => mockIndexer.backfill(_accountDid)).thenAnswer((_) => const Stream.empty());
  });

  SemanticIndexCubit buildCubit() =>
      SemanticIndexCubit(indexer: mockIndexer, embeddingRepository: mockRepo, accountDid: _accountDid);

  group('SemanticIndexCubit', () {
    group('initial state', () {
      test('has idle status and zero indexed count', () {
        final cubit = buildCubit();
        expect(cubit.state.status, SemanticIndexStatus.idle);
        expect(cubit.state.indexedCount, 0);
        expect(cubit.state.backfillCompleted, isNull);
        expect(cubit.state.backfillTotal, isNull);
        expect(cubit.state.isBackfilling, isFalse);
      });
    });

    group('loadCount', () {
      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'updates indexedCount from repository',
        build: buildCubit,
        setUp: () => when(() => mockRepo.countByAccount(_accountDid)).thenReturn(42),
        act: (cubit) => cubit.loadCount(),
        expect: () => [
          predicate<SemanticIndexState>((s) => s.indexedCount == 42 && s.status == SemanticIndexStatus.idle),
        ],
      );

      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'emits zero when no posts are indexed',
        build: buildCubit,
        act: (cubit) => cubit.loadCount(),
        expect: () => [predicate<SemanticIndexState>((s) => s.indexedCount == 0)],
      );
    });

    group('reindex', () {
      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'clears existing embeddings before backfill',
        build: buildCubit,
        setUp: () {
          final post1 = EmbeddedPost(
            postUri: 'at://1',
            accountDid: _accountDid,
            source: 'saved',
            indexedText: 'text',
            embeddedAt: DateTime.now(),
          );
          final post2 = EmbeddedPost(
            postUri: 'at://2',
            accountDid: _accountDid,
            source: 'liked',
            indexedText: 'other',
            embeddedAt: DateTime.now(),
          );
          when(() => mockRepo.queryByAccount(_accountDid)).thenReturn([post1, post2]);
          when(() => mockIndexer.backfill(_accountDid)).thenAnswer((_) => const Stream.empty());
          when(() => mockRepo.countByAccount(_accountDid)).thenReturn(0);
        },
        act: (cubit) => cubit.reindex(),
        verify: (_) {
          verify(() => mockRepo.deleteByUri('at://1')).called(1);
          verify(() => mockRepo.deleteByUri('at://2')).called(1);
        },
      );

      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'emits backfilling with progress then idle on completion',
        build: buildCubit,
        setUp: () {
          when(
            () => mockIndexer.backfill(_accountDid),
          ).thenAnswer((_) => Stream.fromIterable([(1, 3), (2, 3), (3, 3)]));
          when(() => mockRepo.countByAccount(_accountDid)).thenReturn(3);
        },
        act: (cubit) => cubit.reindex(),
        expect: () => [
          predicate<SemanticIndexState>((s) => s.isBackfilling && s.backfillCompleted == 0 && s.backfillTotal == 0),
          predicate<SemanticIndexState>((s) => s.isBackfilling && s.backfillCompleted == 1 && s.backfillTotal == 3),
          predicate<SemanticIndexState>((s) => s.isBackfilling && s.backfillCompleted == 2 && s.backfillTotal == 3),
          predicate<SemanticIndexState>((s) => s.isBackfilling && s.backfillCompleted == 3 && s.backfillTotal == 3),
          predicate<SemanticIndexState>(
            (s) => s.status == SemanticIndexStatus.idle && s.indexedCount == 3 && s.backfillCompleted == null,
          ),
        ],
      );

      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'emits error when backfill stream emits an error',
        build: buildCubit,
        setUp: () {
          when(() => mockIndexer.backfill(_accountDid)).thenAnswer((_) => Stream.error(Exception('embedding failure')));
        },
        act: (cubit) => cubit.reindex(),
        expect: () => [
          predicate<SemanticIndexState>((s) => s.isBackfilling),
          predicate<SemanticIndexState>((s) => s.status == SemanticIndexStatus.error && s.errorMessage != null),
        ],
      );

      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'is a no-op when already backfilling',
        build: buildCubit,
        seed: () =>
            const SemanticIndexState(status: SemanticIndexStatus.backfilling, backfillCompleted: 5, backfillTotal: 10),
        act: (cubit) => cubit.reindex(),
        expect: () => [],
        verify: (_) => verifyNever(() => mockIndexer.backfill(any())),
      );

      blocTest<SemanticIndexCubit, SemanticIndexState>(
        'idle backfill emits initial backfilling then immediate idle',
        build: buildCubit,
        setUp: () {
          when(() => mockIndexer.backfill(_accountDid)).thenAnswer((_) => const Stream.empty());
          when(() => mockRepo.countByAccount(_accountDid)).thenReturn(0);
        },
        act: (cubit) => cubit.reindex(),
        expect: () => [
          predicate<SemanticIndexState>((s) => s.isBackfilling && s.backfillCompleted == 0),
          predicate<SemanticIndexState>((s) => s.status == SemanticIndexStatus.idle && s.backfillCompleted == null),
        ],
      );
    });
  });
}
