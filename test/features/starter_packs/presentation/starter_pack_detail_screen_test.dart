import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider<StarterPackRepository>.value(value: mockRepository)],
      child: MaterialApp(home: StarterPackDetailScreen(packUri: packUri)),
    );
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
