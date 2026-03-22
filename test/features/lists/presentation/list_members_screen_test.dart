import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/list_members_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockListRepository listRepository;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:me',
    handle: 'me.bsky.social',
  );

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');

  final curationList = bsky_graph.ListView(
    uri: listUri,
    cid: 'cid-1',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: 'My List',
    purpose: const bsky_graph.ListPurpose.knownValue(data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist),
    indexedAt: DateTime.utc(2026, 3, 21),
  );

  final member = bsky_graph.ListItemView(
    uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1'),
    subject: const ProfileView(did: 'did:plc:member', handle: 'member.bsky.social', displayName: 'Alice Member'),
  );

  setUp(() {
    authBloc = MockAuthBloc();
    listRepository = MockListRepository();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));

    when(
      () => listRepository.getList(
        listUri: listUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => ListDetailResult(list: curationList, items: [member], cursor: null));
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      child: MultiRepositoryProvider(
        providers: [RepositoryProvider<ListRepository>.value(value: listRepository)],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => ListBloc(listRepository: listRepository)..add(ListRequested(listUri: listUri)),
            child: ListMembersScreen(listUri: listUri),
          ),
        ),
      ),
    );
  }

  testWidgets('shows app bar with Add members title', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Add members'), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search for people'), findsOneWidget);
  });

  testWidgets('shows current members', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Alice Member'), findsOneWidget);
    expect(find.text('@member.bsky.social'), findsOneWidget);
  });

  testWidgets('shows CURRENT MEMBERS heading', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('CURRENT MEMBERS'), findsOneWidget);
  });

  testWidgets('shows remove buttons for each member', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
  });

  testWidgets('shows empty state when no members', (tester) async {
    when(
      () => listRepository.getList(
        listUri: listUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => ListDetailResult(list: curationList, items: [], cursor: null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('No members yet. Search above to add people.'), findsOneWidget);
  });

  testWidgets('search results appear when query is entered and repo returns results', (tester) async {
    const searchResult = ProfileViewBasic(did: 'did:plc:new', handle: 'newuser.bsky.social', displayName: 'New User');

    when(
      () => listRepository.searchActorsTypeahead(
        query: 'newuser',
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [searchResult]);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'newuser');
    await tester.pumpAndSettle();

    expect(find.text('New User'), findsOneWidget);
    expect(find.text('@newuser.bsky.social'), findsOneWidget);
  });
}
