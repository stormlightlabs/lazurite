import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/convo_list_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/assertion_helpers.dart';
import '../../../helpers/connectivity_helpers.dart';
import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

void main() {
  const currentUserDid = 'did:plc:me';

  late MockConvoRepository mockRepository;
  late MockConnectivityCubit connectivityCubit;

  setUp(() {
    mockRepository = MockConvoRepository();
    connectivityCubit = MockConnectivityCubit();
    stubConnectivityCubit(connectivityCubit);
  });

  ProfileViewBasic makeProfile({String did = 'did:plc:other', String handle = 'other.bsky.social'}) =>
      ProfileViewBasic(did: did, handle: handle);

  ConvoView makeConvo({String id = 'c1', bool muted = false, int unreadCount = 0}) => ConvoView(
    id: id,
    rev: 'rev-1',
    members: [
      makeProfile(did: currentUserDid, handle: 'me.bsky.social'),
      makeProfile(),
    ],
    muted: muted,
    unreadCount: unreadCount,
  );

  ConvoView makeGroupConvo({String id = testConvoId, String name = testGroupName, ConvoStatus? status}) {
    return ConvoView.fromJson(
      testGroupConvoJson(id: id, name: name, extra: {if (status != null) 'status': status.toJson()}),
    );
  }

  Widget buildSubject() {
    return RepositoryProvider<String>.value(
      value: currentUserDid,
      child: MaterialApp(
        home: BlocProvider(
          create: (_) => ConvoListBloc(convoRepository: mockRepository),
          child: BlocProvider<ConnectivityCubit>.value(value: connectivityCubit, child: const ConvoListScreen()),
        ),
      ),
    );
  }

  group('ConvoListScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [], cursor: null));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Primary and Requests tabs', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows conversations after loading', (tester) async {
      final convos = [makeConvo(id: 'c1'), makeConvo(id: 'c2')];

      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: convos, cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows group conversations in primary tab', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => ConvoListResult(
          convos: [
            makeConvo(),
            makeGroupConvo(name: 'Release Planning'),
          ],
          cursor: null,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('other.bsky.social'), findsOneWidget);
      expect(find.text('Release Planning'), findsOneWidget);
      expect(find.text('3 members · Group updated'), findsOneWidget);
    });

    testWidgets('shows empty state when no conversations', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('shows offline empty state when offline with no conversations', (tester) async {
      stubConnectivityCubit(connectivityCubit, state: const ConnectivityState.offline());
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expectOfflineState('No connection', message: 'Reconnect to load messages.');
    });

    testWidgets('shows error state on failure', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expectErrorState('Failed to load messages');
    });

    testWidgets('retry button reloads conversations', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('filters to requests tab', (tester) async {
      final acceptedConvo = makeConvo(id: 'accepted');
      final requestConvo = ConvoView(
        id: 'request',
        rev: 'rev-1',
        members: [
          makeProfile(did: currentUserDid, handle: 'me.bsky.social'),
          makeProfile(handle: 'requester.bsky.social'),
        ],
        muted: false,
        unreadCount: 0,
        status: const ConvoStatus.knownValue(data: KnownConvoStatus.request),
      );

      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [acceptedConvo, requestConvo], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('other.bsky.social'), findsOneWidget);

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('requester.bsky.social'), findsOneWidget);
      expect(find.text('No conversations yet'), findsNothing);
    });

    testWidgets('filters group requests to requests tab', (tester) async {
      final acceptedConvo = makeConvo(id: 'accepted');
      final requestGroup = makeGroupConvo(
        id: 'group-request',
        name: 'Invite Group',
        status: const ConvoStatus.knownValue(data: KnownConvoStatus.request),
      );

      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [acceptedConvo, requestGroup], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Invite Group'), findsNothing);

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Group'), findsOneWidget);
      expect(find.text('3 members · Group updated'), findsOneWidget);
    });

    testWidgets('shows no message requests in requests tab when none exist', (tester) async {
      when(
        () => mockRepository.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ConvoListResult(convos: [makeConvo()], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('No message requests'), findsOneWidget);
    });
  });
}
