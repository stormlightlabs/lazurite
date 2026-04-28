import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/typeahead/cubit/typeahead_cubit.dart';
import 'package:lazurite/features/typeahead/cubit/typeahead_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';

void main() {
  group('TypeaheadCubit', () {
    blocTest<TypeaheadCubit, TypeaheadState>(
      'debounces query changes and emits loading then results',
      build: () {
        final repository = _FakeTypeaheadRepository(
          searchHandler: ({required String query, int limit = 10}) async {
            expect(query, 'alice');
            return const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social')];
          },
        );

        return TypeaheadCubit(repository: repository, debounceDuration: const Duration(milliseconds: 300));
      },
      act: (cubit) => cubit.onQueryChanged('alice'),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const TypeaheadState(isLoading: true),
        const TypeaheadState(
          results: [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social')],
        ),
      ],
    );

    test('cancels stale in-flight requests when a new query arrives', () async {
      final firstSearchCompleter = Completer<List<TypeaheadResult>>();
      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) {
          if (query == 'alice') {
            return firstSearchCompleter.future;
          }

          return Future.value(const [TypeaheadResult(did: 'did:plc:bob', handle: 'bob.bsky.social')]);
        },
      );

      final cubit = TypeaheadCubit(repository: repository, debounceDuration: const Duration(milliseconds: 10));
      addTearDown(cubit.close);

      final emittedStates = <TypeaheadState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      cubit.onQueryChanged('alice');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      cubit.onQueryChanged('bob');

      await Future<void>.delayed(const Duration(milliseconds: 30));
      firstSearchCompleter.complete(const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social')]);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.results, const [TypeaheadResult(did: 'did:plc:bob', handle: 'bob.bsky.social')]);
      expect(cubit.state.isLoading, isFalse);

      final staleResultSeen = emittedStates.any(
        (state) => state.results.any((result) => result.handle == 'alice.bsky.social'),
      );
      expect(staleResultSeen, isFalse);
    });

    blocTest<TypeaheadCubit, TypeaheadState>(
      'empty or whitespace input clears results immediately',
      build: () => TypeaheadCubit(
        repository: _FakeTypeaheadRepository(
          searchHandler: ({required String query, int limit = 10}) async => const [
            TypeaheadResult(did: 'did:plc:ignored', handle: 'ignored.bsky.social'),
          ],
        ),
      ),
      seed: () => const TypeaheadState(
        results: [TypeaheadResult(did: 'did:plc:seed', handle: 'seed.bsky.social')],
        isLoading: true,
        error: 'error',
      ),
      act: (cubit) {
        cubit.onQueryChanged('   ');
      },
      expect: () => [const TypeaheadState()],
    );

    blocTest<TypeaheadCubit, TypeaheadState>(
      'clear resets state and cancels pending debounce',
      build: () {
        final repository = _FakeTypeaheadRepository(
          searchHandler: ({required String query, int limit = 10}) async {
            throw StateError('search should be cancelled by clear()');
          },
        );

        return TypeaheadCubit(repository: repository, debounceDuration: const Duration(milliseconds: 100));
      },
      seed: () => const TypeaheadState(
        results: [TypeaheadResult(did: 'did:plc:seed', handle: 'seed.bsky.social')],
      ),
      act: (cubit) async {
        cubit.onQueryChanged('alice');
        cubit.clear();
        await Future<void>.delayed(const Duration(milliseconds: 150));
      },
      expect: () => [const TypeaheadState()],
    );
  });
}

class _FakeTypeaheadRepository extends TypeaheadRepository {
  _FakeTypeaheadRepository({required this.searchHandler}) : super(provider: TypeaheadRepository.communityProvider);

  final Future<List<TypeaheadResult>> Function({required String query, int limit}) searchHandler;

  @override
  Future<List<TypeaheadResult>> search({required String query, int limit = 10}) {
    return searchHandler(query: query, limit: limit);
  }
}
