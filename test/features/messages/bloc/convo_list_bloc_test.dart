import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/chat/bsky/convo/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  late MockConvoRepository mockConvoRepository;

  setUp(() {
    mockConvoRepository = MockConvoRepository();
  });

  ConvoView makeConvoView(String id) => ConvoView(id: id, rev: 'rev-1', members: [], muted: false, unreadCount: 0);

  group('ConvoListBloc', () {
    blocTest<ConvoListBloc, ConvoListState>(
      'emits loading and loaded when ConvosRequested succeeds',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      setUp: () {
        when(
          () => mockConvoRepository.listConvos(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ConvoListResult(convos: [makeConvoView('c1')], cursor: 'cursor-1'));
      },
      act: (bloc) => bloc.add(const ConvosRequested()),
      expect: () => [
        const ConvoListState.loading(),
        predicate<ConvoListState>(
          (state) =>
              state.status == ConvoListStatus.loaded &&
              state.convos.length == 1 &&
              state.cursor == 'cursor-1' &&
              state.hasMore == true,
        ),
      ],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'emits error when ConvosRequested fails',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      setUp: () {
        when(
          () => mockConvoRepository.listConvos(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const ConvosRequested()),
      expect: () => [
        const ConvoListState.loading(),
        predicate<ConvoListState>((state) => state.status == ConvoListStatus.error),
      ],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'does not refresh when state is not loaded',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      act: (bloc) => bloc.add(const ConvosRefreshed()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockConvoRepository.listConvos(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'refreshes convos on ConvosRefreshed when loaded',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => ConvoListState.loaded(convos: [makeConvoView('c1')], cursor: 'old-cursor', hasMore: true),
      setUp: () {
        when(
          () => mockConvoRepository.listConvos(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ConvoListResult(convos: [makeConvoView('c2')], cursor: 'new-cursor'));
      },
      act: (bloc) => bloc.add(const ConvosRefreshed()),
      expect: () => [
        predicate<ConvoListState>((state) => state.isRefreshing),
        predicate<ConvoListState>(
          (state) =>
              state.status == ConvoListStatus.loaded &&
              state.convos.length == 1 &&
              state.convos.first.id == 'c2' &&
              state.cursor == 'new-cursor' &&
              !state.isRefreshing,
        ),
      ],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'mutes convo and updates list on ConvoMuted',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => ConvoListState.loaded(convos: [makeConvoView('c1')], cursor: null, hasMore: false),
      setUp: () {
        const mutedConvo = ConvoView(id: 'c1', rev: 'rev-2', members: [], muted: true, unreadCount: 0);
        when(() => mockConvoRepository.muteConvo(any())).thenAnswer((_) async => mutedConvo);
      },
      act: (bloc) => bloc.add(const ConvoMuted(convoId: 'c1')),
      expect: () => [predicate<ConvoListState>((state) => state.convos.isNotEmpty && state.convos.first.muted)],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'unmutes convo and updates list on ConvoUnmuted',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => const ConvoListState.loaded(
        convos: [ConvoView(id: 'c1', rev: 'rev-1', members: [], muted: true, unreadCount: 0)],
        cursor: null,
        hasMore: false,
      ),
      setUp: () {
        final unmutedConvo = makeConvoView('c1');
        when(() => mockConvoRepository.unmuteConvo(any())).thenAnswer((_) async => unmutedConvo);
      },
      act: (bloc) => bloc.add(const ConvoUnmuted(convoId: 'c1')),
      expect: () => [predicate<ConvoListState>((state) => state.convos.isNotEmpty && !state.convos.first.muted)],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'handles mute failure silently',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => ConvoListState.loaded(convos: [makeConvoView('c1')], cursor: null, hasMore: false),
      setUp: () {
        when(() => mockConvoRepository.muteConvo(any())).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const ConvoMuted(convoId: 'c1')),
      expect: () => [],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'switches active tab on ConvoTabChanged',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => const ConvoListState.loaded(convos: [], cursor: null, hasMore: false),
      act: (bloc) => bloc.add(const ConvoTabChanged(tab: ConvoTab.requests)),
      expect: () => [predicate<ConvoListState>((state) => state.activeTab == ConvoTab.requests)],
    );

    blocTest<ConvoListBloc, ConvoListState>(
      'switches back to primary tab on ConvoTabChanged',
      build: () => ConvoListBloc(convoRepository: mockConvoRepository),
      seed: () => const ConvoListState.loaded(convos: [], cursor: null, hasMore: false, activeTab: ConvoTab.requests),
      act: (bloc) => bloc.add(const ConvoTabChanged(tab: ConvoTab.primary)),
      expect: () => [predicate<ConvoListState>((state) => state.activeTab == ConvoTab.primary)],
    );
  });
}
