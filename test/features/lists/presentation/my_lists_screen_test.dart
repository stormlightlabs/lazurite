import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/my_lists_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockListRepository extends Mock implements ListRepository {}

class MockMyListsCubit extends MockCubit<MyListsState> implements MyListsCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockListRepository listRepository;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:me',
    handle: 'me.bsky.social',
  );

  final listUri = AtUri.parse('at://did:plc:me/app.bsky.graph.list/list-1');
  final modUri = AtUri.parse('at://did:plc:me/app.bsky.graph.list/mod-1');

  final curationList = bsky_graph.ListView(
    uri: listUri,
    cid: 'cid-1',
    creator: const ProfileView(did: 'did:plc:me', handle: 'me.bsky.social'),
    name: 'My Feed List',
    purpose: const bsky_graph.ListPurpose.knownValue(data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist),
    indexedAt: DateTime.utc(2026, 3, 21),
  );

  final moderationList = bsky_graph.ListView(
    uri: modUri,
    cid: 'cid-2',
    creator: const ProfileView(did: 'did:plc:me', handle: 'me.bsky.social'),
    name: 'My Mod List',
    purpose: const bsky_graph.ListPurpose.knownValue(data: bsky_graph.KnownListPurpose.appBskyGraphDefsModlist),
    indexedAt: DateTime.utc(2026, 3, 21),
  );

  setUp(() {
    authBloc = MockAuthBloc();
    listRepository = MockListRepository();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));

    when(
      () => listRepository.getLists(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => ListsResult(lists: [curationList, moderationList]));
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      child: MultiRepositoryProvider(
        providers: [RepositoryProvider<ListRepository>.value(value: listRepository)],
        child: const MaterialApp(home: MyListsScreen()),
      ),
    );
  }

  testWidgets('shows loading indicator initially', (tester) async {
    when(
      () => listRepository.getLists(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return const ListsResult(lists: []);
    });

    await tester.pumpWidget(buildSubject());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows FEEDS and MODERATION tabs', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('FEEDS'), findsOneWidget);
    expect(find.text('MODERATION'), findsOneWidget);
  });

  testWidgets('shows curation lists in FEEDS tab', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('My Feed List'), findsOneWidget);
  });

  testWidgets('shows moderation lists in MODERATION tab', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('MODERATION'));
    await tester.pumpAndSettle();

    expect(find.text('My Mod List'), findsOneWidget);
  });

  testWidgets('shows FAB for creating a new list', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('shows empty state when no lists', (tester) async {
    when(
      () => listRepository.getLists(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ListsResult(lists: []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('No lists yet'), findsOneWidget);
  });

  testWidgets('shows error and retry button on failure', (tester) async {
    when(
      () => listRepository.getLists(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('network error'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
