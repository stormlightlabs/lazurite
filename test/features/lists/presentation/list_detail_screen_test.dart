import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/list_detail_screen.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockListRepository extends Mock implements ListRepository {}

class MockModerationService extends Mock implements ModerationService {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockPostActionCache extends Mock implements PostActionCache {}

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
    name: 'Awesome Feed',
    description: 'A curated list of posts',
    purpose: const bsky_graph.ListPurpose.knownValue(data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist),
    listItemCount: 5,
    indexedAt: DateTime.utc(2026, 3, 21),
  );

  final member = bsky_graph.ListItemView(
    uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1'),
    subject: const ProfileView(did: 'did:plc:member', handle: 'member.bsky.social', displayName: 'A Member'),
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

    when(
      () => listRepository.getListFeed(
        listUri: listUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ListFeedResult(posts: []));
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ListRepository>.value(value: listRepository),
          RepositoryProvider<PostActionRepository>.value(value: MockPostActionRepository()),
          RepositoryProvider<PostActionCache>.value(value: MockPostActionCache()),
        ],
        child: MaterialApp(home: ListDetailScreen(listUri: listUri)),
      ),
    );
  }

  testWidgets('shows loading state initially', (tester) async {
    when(
      () => listRepository.getList(
        listUri: listUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return ListDetailResult(list: curationList, items: [], cursor: null);
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows list name in app bar after loading', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Awesome Feed'), findsWidgets);
  });

  testWidgets('shows list header with description and creator', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('A curated list of posts'), findsOneWidget);
    expect(find.text('by @creator.bsky.social'), findsOneWidget);
  });

  testWidgets('shows FEED and MEMBERS tabs', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('FEED'), findsOneWidget);
    expect(find.text('MEMBERS'), findsOneWidget);
  });

  testWidgets('shows members in MEMBERS tab', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEMBERS'));
    await tester.pumpAndSettle();

    expect(find.text('A Member'), findsOneWidget);
    expect(find.text('@member.bsky.social'), findsOneWidget);
  });

  testWidgets('shows feed unavailable message for moderation list in FEED tab', (tester) async {
    final modList = bsky_graph.ListView(
      uri: listUri,
      cid: 'cid-1',
      creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
      name: 'Mod List',
      purpose: const bsky_graph.ListPurpose.knownValue(data: bsky_graph.KnownListPurpose.appBskyGraphDefsModlist),
      indexedAt: DateTime.utc(2026, 3, 21),
    );

    when(
      () => listRepository.getList(
        listUri: listUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => ListDetailResult(list: modList, items: [], cursor: null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Feed not available for moderation lists'), findsOneWidget);
  });

  testWidgets('shows more options button', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('remove button shown for own list members', (tester) async {
    when(() => authBloc.state).thenReturn(
      const AuthState.authenticated(
        AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          did: 'did:plc:creator',
          handle: 'creator.bsky.social',
        ),
      ),
    );
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticated(
        AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          did: 'did:plc:creator',
          handle: 'creator.bsky.social',
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEMBERS'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
  });
}
