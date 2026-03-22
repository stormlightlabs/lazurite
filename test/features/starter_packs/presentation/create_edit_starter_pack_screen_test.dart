import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/create_edit_starter_pack_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

class MockListRepository extends Mock implements ListRepository {}

class MockStarterPackBloc extends Mock implements StarterPackBloc {}

void main() {
  late MockStarterPackRepository mockRepo;
  late MockListRepository mockListRepo;

  const userDid = 'did:plc:user';
  final packUri = AtUri.parse('at://did:plc:user/app.bsky.graph.starterpack/pack-1');
  final refListUri = AtUri.parse('at://did:plc:user/app.bsky.graph.list/list-1');

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.starterpack/fallback'));
  });

  setUp(() {
    mockRepo = MockStarterPackRepository();
    mockListRepo = MockListRepository();
  });

  StarterPackView buildPackView() {
    return StarterPackView(
      uri: packUri,
      cid: 'cid-pack',
      record: const {
        r'$type': 'app.bsky.graph.starterpack',
        'name': 'My Pack',
        'list': 'at://did:plc:user/app.bsky.graph.list/list-1',
        'createdAt': '2026-03-22T00:00:00.000Z',
      },
      creator: const ProfileViewBasic(did: userDid, handle: 'user.bsky.social'),
      list: ListViewBasic(
        uri: refListUri,
        cid: 'cid-list',
        name: 'Starter Pack Members',
        purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsReferencelist),
      ),
      indexedAt: DateTime.utc(2026, 3, 22),
    );
  }

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StarterPackRepository>.value(value: mockRepo),
        RepositoryProvider<ListRepository>.value(value: mockListRepo),
        RepositoryProvider.value(value: userDid),
      ],
      child: BlocProvider(
        create: (_) => StarterPackBloc(starterPackRepository: mockRepo),
        child: const MaterialApp(home: CreateStarterPackScreen(userDid: userDid)),
      ),
    );
  }

  testWidgets('shows name field and Create button', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });

  testWidgets('Create button is disabled when name is empty', (tester) async {
    await tester.pumpWidget(buildSubject());

    final createButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Create'));
    expect(createButton.onPressed, isNull);
  });

  testWidgets('Create button is enabled when name is non-empty', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'My Pack');
    await tester.pump();

    final createButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Create'));
    expect(createButton.onPressed, isNotNull);
  });

  testWidgets('shows Members and Feeds sections', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Feeds'), findsOneWidget);
  });

  testWidgets('adds a member via search and displays as chip', (tester) async {
    const profile = ProfileViewBasic(did: 'did:plc:member', handle: 'member.bsky.social', displayName: 'Alice');

    when(
      () => mockListRepo.searchActorsTypeahead(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [profile]);

    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.widgetWithText(TextField, 'Search for people to add'), 'alice');
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
  });

  testWidgets('dispatches StarterPackCreated on Create tap', (tester) async {
    when(
      () => mockRepo.createStarterPack(
        userDid: any(named: 'userDid'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        memberDids: any(named: 'memberDids'),
        feedUris: any(named: 'feedUris'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return packUri;
    });

    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'My Pack');
    await tester.pump();

    await tester.tap(find.text('Create'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows error snackbar when creation fails', (tester) async {
    when(
      () => mockRepo.createStarterPack(
        userDid: any(named: 'userDid'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        memberDids: any(named: 'memberDids'),
        feedUris: any(named: 'feedUris'),
      ),
    ).thenThrow(Exception('network error'));

    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'My Pack');
    await tester.pump();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('shows loading spinner on submit and hides Create button', (tester) async {
    when(
      () => mockRepo.createStarterPack(
        userDid: any(named: 'userDid'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        memberDids: any(named: 'memberDids'),
        feedUris: any(named: 'feedUris'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return packUri;
    });

    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'New Pack');
    await tester.pump();

    await tester.tap(find.text('Create'));
    await tester.pump();

    expect(find.text('Create'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows Add feed button when fewer than 3 feeds selected', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Add feed'), findsOneWidget);
  });

  testWidgets('feed picker sheet shows loading indicator while fetching', (tester) async {
    when(() => mockRepo.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return const [];
    });

    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Add feed'));
    await tester.pump();

    expect(find.text('Select a feed'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('feed picker shows suggested feeds', (tester) async {
    final feed = GeneratorView(
      uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/test-feed'),
      cid: 'cid-feed',
      did: 'did:plc:feedcreator',
      creator: const ProfileView(did: 'did:plc:feedcreator', handle: 'creator.bsky.social'),
      displayName: 'Cool Feed',
      indexedAt: DateTime.utc(2026, 3, 22),
    );

    when(() => mockRepo.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => [feed]);

    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Add feed'));
    await tester.pumpAndSettle();

    expect(find.text('Cool Feed'), findsOneWidget);
  });

  testWidgets('selecting a feed from picker adds it to the list', (tester) async {
    final feed = GeneratorView(
      uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/test-feed'),
      cid: 'cid-feed',
      did: 'did:plc:feedcreator',
      creator: const ProfileView(did: 'did:plc:feedcreator', handle: 'creator.bsky.social'),
      displayName: 'Cool Feed',
      indexedAt: DateTime.utc(2026, 3, 22),
    );

    when(() => mockRepo.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => [feed]);

    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Add feed'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cool Feed'));
    await tester.pumpAndSettle();

    expect(find.text('Cool Feed'), findsOneWidget);
  });

  testWidgets('hides Add feed button when 3 feeds are selected', (tester) async {
    final feeds = List.generate(
      3,
      (i) => GeneratorView(
        uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/feed-$i'),
        cid: 'cid-feed-$i',
        did: 'did:plc:feedcreator',
        creator: const ProfileView(did: 'did:plc:feedcreator', handle: 'creator.bsky.social'),
        displayName: 'Feed $i',
        indexedAt: DateTime.utc(2026, 3, 22),
      ),
    );

    when(() => mockRepo.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => feeds);

    await tester.pumpWidget(buildSubject());

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Add feed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Feed $i').last);
      await tester.pumpAndSettle();
    }

    expect(find.text('Add feed'), findsNothing);
  });

  testWidgets('can remove a selected feed', (tester) async {
    final feed = GeneratorView(
      uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/test-feed'),
      cid: 'cid-feed',
      did: 'did:plc:feedcreator',
      creator: const ProfileView(did: 'did:plc:feedcreator', handle: 'creator.bsky.social'),
      displayName: 'Cool Feed',
      indexedAt: DateTime.utc(2026, 3, 22),
    );

    when(() => mockRepo.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => [feed]);

    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Add feed'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cool Feed'));
    await tester.pumpAndSettle();

    expect(find.text('Cool Feed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();

    expect(find.text('Cool Feed'), findsNothing);
  });
}
