import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

const _actor = 'did:plc:alice';

ProfileView _profile(String did) => ProfileView(did: did, handle: '$did.bsky.social', indexedAt: DateTime.utc(2026));

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  SuggestedFollowsCubit buildCubit() => SuggestedFollowsCubit(repository: mockRepository);

  group('SuggestedFollowsCubit', () {
    group('initial state', () {
      test('has initial status and empty suggestions', () {
        final cubit = buildCubit();
        expect(cubit.state.status, SuggestedFollowsStatus.initial);
        expect(cubit.state.suggestions, isEmpty);
        expect(cubit.state.errorMessage, isNull);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.hasError, isFalse);
        expect(cubit.state.isEmpty, isFalse);
      });
    });

    group('load', () {
      blocTest<SuggestedFollowsCubit, SuggestedFollowsState>(
        'emits loading then loaded with suggestions',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepository.getSuggestedFollows(_actor),
          ).thenAnswer((_) async => [_profile('did:plc:bob'), _profile('did:plc:carol')]);
        },
        act: (cubit) => cubit.load(_actor),
        expect: () => [
          const SuggestedFollowsState.loading(),
          predicate<SuggestedFollowsState>(
            (s) => s.status == SuggestedFollowsStatus.loaded && s.suggestions.length == 2,
          ),
        ],
      );

      blocTest<SuggestedFollowsCubit, SuggestedFollowsState>(
        'emits loaded with empty list when no suggestions returned',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getSuggestedFollows(_actor)).thenAnswer((_) async => []);
        },
        act: (cubit) => cubit.load(_actor),
        expect: () => [
          const SuggestedFollowsState.loading(),
          predicate<SuggestedFollowsState>(
            (s) => s.status == SuggestedFollowsStatus.loaded && s.suggestions.isEmpty && s.isEmpty,
          ),
        ],
      );

      blocTest<SuggestedFollowsCubit, SuggestedFollowsState>(
        'emits error when repository throws',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getSuggestedFollows(_actor)).thenThrow(Exception('network error'));
        },
        act: (cubit) => cubit.load(_actor),
        expect: () => [
          const SuggestedFollowsState.loading(),
          predicate<SuggestedFollowsState>((s) => s.status == SuggestedFollowsStatus.error && s.errorMessage != null),
        ],
      );

      blocTest<SuggestedFollowsCubit, SuggestedFollowsState>(
        'is a no-op when already loading',
        build: buildCubit,
        seed: () => const SuggestedFollowsState.loading(),
        setUp: () {
          when(() => mockRepository.getSuggestedFollows(any())).thenAnswer((_) async => []);
        },
        act: (cubit) => cubit.load(_actor),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.getSuggestedFollows(any()));
        },
      );

      blocTest<SuggestedFollowsCubit, SuggestedFollowsState>(
        'loaded state isEmpty is false when suggestions present',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getSuggestedFollows(_actor)).thenAnswer((_) async => [_profile('did:plc:bob')]);
        },
        act: (cubit) => cubit.load(_actor),
        expect: () => [
          const SuggestedFollowsState.loading(),
          predicate<SuggestedFollowsState>((s) => s.status == SuggestedFollowsStatus.loaded && !s.isEmpty),
        ],
      );
    });
  });
}
