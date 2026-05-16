import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/starter_pack_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

void main() {
  late MockStarterPackRepository mockRepository;

  final packUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1');
  final refListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/ref-1');

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.starterpack/fallback'));
  });

  setUp(() {
    mockRepository = MockStarterPackRepository();
  });

  StarterPackView buildPack({List<ListItemView>? members, List<GeneratorView>? feeds}) {
    return StarterPackView(
      uri: packUri,
      cid: 'cid-pack',
      record: <String, dynamic>{
        r'$type': 'app.bsky.graph.starterpack',
        'name': 'My Starter Pack',
        'description': 'A great pack',
        'list': refListUri.toString(),
        'createdAt': '2026-03-22T00:00:00.000Z',
      },
      creator: const ProfileViewBasic(
        did: 'did:plc:creator',
        handle: 'creator.bsky.social',
        displayName: 'The Creator',
      ),
      list: ListViewBasic(
        uri: refListUri,
        cid: 'cid-ref',
        name: 'Starter Pack Members',
        purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsReferencelist),
      ),
      listItemsSample: members,
      feeds: feeds,
      joinedWeekCount: 12,
      joinedAllTimeCount: 350,
      indexedAt: DateTime.utc(2026, 3, 22),
    );
  }

  Widget buildSubject({String? currentUserDid}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StarterPackRepository>.value(value: mockRepository),
        if (currentUserDid != null) RepositoryProvider.value(value: currentUserDid),
      ],
      child: MaterialApp(home: StarterPackDetailScreen(packUri: packUri)),
    );
  }

  Widget buildSubjectAsCreator() => buildSubject(currentUserDid: 'did:plc:creator');

  /// Builds with GoRouter so navigation calls (context.canPop, context.pop) work.
  Widget buildSubjectWithRouter({String? currentUserDid}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<StarterPackRepository>.value(value: mockRepository),
              if (currentUserDid != null) RepositoryProvider.value(value: currentUserDid),
            ],
            child: StarterPackDetailScreen(packUri: packUri),
          ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows loading state initially', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return buildPack();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows pack name and description after loading', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('My Starter Pack'), findsWidgets);
    expect(find.text('A great pack'), findsOneWidget);
  });

  testWidgets('shows creator handle', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('The Creator'), findsOneWidget);
    expect(find.text('@creator.bsky.social'), findsOneWidget);
  });

  testWidgets('shows join stats', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
    expect(find.text('joined this week'), findsOneWidget);
    expect(find.text('350'), findsOneWidget);
    expect(find.text('total joined'), findsOneWidget);
  });

  testWidgets('shows member avatars when listItemsSample is non-empty', (tester) async {
    final member = ListItemView(
      uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1'),
      subject: const ProfileView(did: 'did:plc:member', handle: 'member.bsky.social', displayName: 'A Member'),
    );

    when(
      () => mockRepository.getStarterPack(starterPackUri: packUri),
    ).thenAnswer((_) async => buildPack(members: [member]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('A Member'), findsOneWidget);
  });

  testWidgets('shows See all and Follow all buttons when list is present', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Follow all'), findsOneWidget);
  });

  testWidgets('shows Members section heading', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Members'), findsOneWidget);
  });

  testWidgets('shows error state when load fails', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenThrow(Exception('network error'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows overflow menu when current user is the creator', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) => w is PopupMenuButton), findsOneWidget);
  });

  testWidgets('does not show overflow menu when user is not the creator', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject(currentUserDid: 'did:plc:other-user'));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuButton<dynamic>), findsNothing);
  });

  testWidgets('does not show overflow menu when no user DID is available', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuButton<dynamic>), findsNothing);
  });

  testWidgets('overflow menu has Edit and Delete options', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('tapping Edit shows the edit dialog', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(() => mockRepository.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => []);

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit starter pack'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('edit dialog is pre-filled with current pack name', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(() => mockRepository.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => []);

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextField>(
      find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)).first,
    );
    expect(nameField.controller?.text, 'My Starter Pack');
  });

  testWidgets('Save in edit dialog dispatches StarterPackUpdated', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(() => mockRepository.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) async => []);
    when(
      () => mockRepository.updateStarterPack(
        packUri: any(named: 'packUri'),
        referenceListUri: any(named: 'referenceListUri'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        feedUris: any(named: 'feedUris'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.updateStarterPack(
        packUri: any(named: 'packUri'),
        referenceListUri: any(named: 'referenceListUri'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        feedUris: any(named: 'feedUris'),
      ),
    ).called(1);
  });

  testWidgets('tapping Delete shows confirmation dialog', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete starter pack'), findsOneWidget);
  });

  testWidgets('confirming delete dispatches StarterPackDeleted', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(
      () => mockRepository.deleteStarterPack(
        packUri: any(named: 'packUri'),
        referenceListUri: any(named: 'referenceListUri'),
        userDid: any(named: 'userDid'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubjectWithRouter(currentUserDid: 'did:plc:creator'));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.deleteStarterPack(
        packUri: any(named: 'packUri'),
        referenceListUri: any(named: 'referenceListUri'),
        userDid: any(named: 'userDid'),
      ),
    ).called(1);
  });

  testWidgets('cancelling delete dialog does not dispatch delete', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());

    await tester.pumpWidget(buildSubjectAsCreator());
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => mockRepository.deleteStarterPack(
        packUri: any(named: 'packUri'),
        referenceListUri: any(named: 'referenceListUri'),
        userDid: any(named: 'userDid'),
      ),
    );
  });

  testWidgets('shows Follow all loading indicator while following', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(() => mockRepository.followAll(referenceListUri: refListUri)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return 5;
    });

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Follow all'));
    await tester.pump();

    expect(find.text('Following…'), findsOneWidget);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows success snackbar after following all members', (tester) async {
    when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => buildPack());
    when(() => mockRepository.followAll(referenceListUri: refListUri)).thenAnswer((_) async => 5);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Follow all'));
    await tester.pumpAndSettle();

    expect(find.text('Followed 5 members'), findsOneWidget);
  });
}
