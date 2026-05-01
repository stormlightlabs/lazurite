import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';
import 'package:mocktail/mocktail.dart';

class MockSemanticSearchRepository extends Mock implements SemanticSearchRepository {}

Future<EmbeddingService> _makeAvailableService() async {
  final service = EmbeddingService.forTesting((_) async => Float32List.fromList(List.filled(384, 0.1)));
  await service.initialize();
  return service;
}

EmbeddingService _unavailableService() => EmbeddingService();

const _accountDid = 'did:plc:testuser';

const _result1 = SemanticSearchResult(
  postUri: 'at://did:plc:a/app.bsky.feed.post/1',
  score: 85.0,
  source: 'saved',
  postJson: '{}',
);

const _result2 = SemanticSearchResult(
  postUri: 'at://did:plc:b/app.bsky.feed.post/2',
  score: 72.5,
  source: 'liked',
  postJson: '{}',
);

void main() {
  late MockSemanticSearchRepository mockRepo;
  late EmbeddingService availableService;

  setUp(() async {
    mockRepo = MockSemanticSearchRepository();
    availableService = await _makeAvailableService();
  });

  SemanticSearchCubit buildCubit() => SemanticSearchCubit(
    repository: mockRepo,
    embeddingService: availableService,
    accountDid: _accountDid,
    debounceDuration: Duration.zero,
  );

  group('SemanticSearchCubit', () {
    group('initial state', () {
      test('is initial when embedding service is available', () {
        final cubit = buildCubit();
        expect(cubit.state.status, SemanticSearchStatus.initial);
        expect(cubit.state.results, isEmpty);
        expect(cubit.state.query, '');
        expect(cubit.state.scope, SearchScope.both);
        expect(cubit.state.errorMessage, isNull);
      });

      test('is unavailable when embedding service is not available', () {
        final cubit = SemanticSearchCubit(
          repository: mockRepo,
          embeddingService: _unavailableService(),
          accountDid: _accountDid,
        );
        expect(cubit.state.status, SemanticSearchStatus.unavailable);
      });

      test('recovers from startup race once embedding service initializes', () async {
        final lateInitService = EmbeddingService.forTesting((_) async => Float32List.fromList(List.filled(384, 0.2)));
        final cubit = SemanticSearchCubit(
          repository: mockRepo,
          embeddingService: lateInitService,
          accountDid: _accountDid,
        );

        expect(cubit.state.status, SemanticSearchStatus.unavailable);
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.status, SemanticSearchStatus.initial);
      });
    });

    group('search', () {
      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'empty query clears results immediately without calling repository',
        build: buildCubit,
        seed: () => const SemanticSearchState(
          status: SemanticSearchStatus.loaded,
          results: [_result1],
          query: 'rust',
          scope: SearchScope.saved,
        ),
        act: (cubit) => cubit.search(''),
        expect: () => [
          predicate<SemanticSearchState>(
            (s) =>
                s.status == SemanticSearchStatus.initial &&
                s.results.isEmpty &&
                s.query == '' &&
                s.scope == SearchScope.saved,
          ),
        ],
        verify: (_) => verifyNever(() => mockRepo.search(any(), any())),
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'whitespace-only query clears results',
        build: buildCubit,
        act: (cubit) => cubit.search('   '),
        expect: () => [
          predicate<SemanticSearchState>((s) => s.status == SemanticSearchStatus.initial && s.results.isEmpty),
        ],
        verify: (_) => verifyNever(() => mockRepo.search(any(), any())),
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'emits searching then loaded on successful search',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenAnswer((_) async => [_result1, _result2]);
        },
        act: (cubit) => cubit.search('flutter'),
        expect: () => [
          predicate<SemanticSearchState>((s) => s.status == SemanticSearchStatus.searching && s.query == 'flutter'),
          predicate<SemanticSearchState>(
            (s) => s.status == SemanticSearchStatus.loaded && s.results.length == 2 && s.results.first == _result1,
          ),
        ],
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'passes null source for SearchScope.both',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenAnswer((_) async => const []);
        },
        act: (cubit) => cubit.search('test'),
        verify: (_) {
          verify(
            () => mockRepo.search('test', _accountDid, source: null, maxResults: any(named: 'maxResults')),
          ).called(1);
        },
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'passes saved source for SearchScope.saved',
        build: buildCubit,
        seed: () => const SemanticSearchState(scope: SearchScope.saved),
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenAnswer((_) async => const []);
        },
        act: (cubit) => cubit.search('test'),
        verify: (_) {
          verify(
            () => mockRepo.search(
              'test',
              _accountDid,
              source: 'saved',
              maxResults: any(named: 'maxResults'),
            ),
          ).called(1);
        },
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'passes liked source for SearchScope.liked',
        build: buildCubit,
        seed: () => const SemanticSearchState(scope: SearchScope.liked),
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenAnswer((_) async => const []);
        },
        act: (cubit) => cubit.search('test'),
        verify: (_) {
          verify(
            () => mockRepo.search(
              'test',
              _accountDid,
              source: 'liked',
              maxResults: any(named: 'maxResults'),
            ),
          ).called(1);
        },
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'emits error when repository throws',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenThrow(Exception('network error'));
        },
        act: (cubit) => cubit.search('rust'),
        expect: () => [
          predicate<SemanticSearchState>((s) => s.status == SemanticSearchStatus.searching),
          predicate<SemanticSearchState>((s) => s.status == SemanticSearchStatus.error && s.errorMessage != null),
        ],
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'keeps unavailable state when service is not available',
        build: () =>
            SemanticSearchCubit(repository: mockRepo, embeddingService: _unavailableService(), accountDid: _accountDid),
        act: (cubit) => cubit.search('flutter'),
        expect: () => [],
        verify: (cubit) {
          expect(cubit.state.status, SemanticSearchStatus.unavailable);
          verifyNever(() => mockRepo.search(any(), any()));
        },
      );
    });

    group('setScope', () {
      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'changes scope and re-searches when query is non-empty',
        build: buildCubit,
        seed: () => const SemanticSearchState(
          status: SemanticSearchStatus.loaded,
          query: 'flutter',
          scope: SearchScope.both,
          results: [_result1],
        ),
        setUp: () {
          when(
            () => mockRepo.search(
              any(),
              any(),
              source: any(named: 'source'),
              maxResults: any(named: 'maxResults'),
            ),
          ).thenAnswer((_) async => [_result2]);
        },
        act: (cubit) => cubit.setScope(SearchScope.saved),
        expect: () => [
          predicate<SemanticSearchState>(
            (s) => s.scope == SearchScope.saved && s.status == SemanticSearchStatus.loaded,
          ),
          predicate<SemanticSearchState>((s) => s.status == SemanticSearchStatus.searching),
          predicate<SemanticSearchState>(
            (s) => s.status == SemanticSearchStatus.loaded && s.results.length == 1 && s.results.first == _result2,
          ),
        ],
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'changes scope without re-searching when query is empty',
        build: buildCubit,
        act: (cubit) => cubit.setScope(SearchScope.liked),
        expect: () => [
          predicate<SemanticSearchState>(
            (s) => s.scope == SearchScope.liked && s.status == SemanticSearchStatus.initial,
          ),
        ],
        verify: (_) => verifyNever(() => mockRepo.search(any(), any())),
      );

      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'is a no-op when scope is unchanged',
        build: buildCubit,
        act: (cubit) => cubit.setScope(SearchScope.both),
        expect: () => [],
        verify: (_) => verifyNever(() => mockRepo.search(any(), any())),
      );
    });

    group('clearResults', () {
      blocTest<SemanticSearchCubit, SemanticSearchState>(
        'resets to initial status with results cleared, preserving scope',
        build: buildCubit,
        seed: () => const SemanticSearchState(
          status: SemanticSearchStatus.loaded,
          results: [_result1],
          query: 'flutter',
          scope: SearchScope.saved,
        ),
        act: (cubit) => cubit.clearResults(),
        expect: () => [
          predicate<SemanticSearchState>(
            (s) =>
                s.status == SemanticSearchStatus.initial &&
                s.results.isEmpty &&
                s.query == '' &&
                s.scope == SearchScope.saved,
          ),
        ],
      );
    });
  });
}
