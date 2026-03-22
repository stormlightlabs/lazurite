import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/actor_starter_packs_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

void main() {
  late MockStarterPackRepository mockRepository;

  const actor = 'did:plc:creator';

  setUp(() {
    mockRepository = MockStarterPackRepository();
  });

  StarterPackViewBasic buildPack(AtUri uri, String name) {
    return StarterPackViewBasic(
      uri: uri,
      cid: 'cid-${uri.rkey}',
      record: <String, dynamic>{
        r'$type': 'app.bsky.graph.starterpack',
        'name': name,
        'list': 'at://did:plc:creator/app.bsky.graph.list/ref',
        'createdAt': '2026-03-22T00:00:00.000Z',
      },
      creator: const ProfileViewBasic(did: actor, handle: 'creator.bsky.social'),
      listItemCount: 5,
      joinedWeekCount: 3,
      joinedAllTimeCount: 100,
      indexedAt: DateTime.utc(2026, 3, 22),
    );
  }

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider<StarterPackRepository>.value(value: mockRepository)],
      child: const MaterialApp(home: ActorStarterPacksScreen(actor: actor)),
    );
  }

  testWidgets('shows loading state initially', (tester) async {
    when(
      () => mockRepository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(hours: 1));
      return const ActorStarterPacksResult(starterPacks: []);
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('shows empty state when no packs', (tester) async {
    when(
      () => mockRepository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ActorStarterPacksResult(starterPacks: []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('No starter packs yet'), findsOneWidget);
  });

  testWidgets('shows pack cards after loading', (tester) async {
    final pack1 = buildPack(AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1'), 'Pack One');
    final pack2 = buildPack(AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-2'), 'Pack Two');

    when(
      () => mockRepository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => ActorStarterPacksResult(starterPacks: [pack1, pack2]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Pack One'), findsOneWidget);
    expect(find.text('Pack Two'), findsOneWidget);
  });

  testWidgets('shows error state with retry button when load fails', (tester) async {
    when(
      () => mockRepository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('network error'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows Starter Packs in app bar', (tester) async {
    when(
      () => mockRepository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ActorStarterPacksResult(starterPacks: []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Starter Packs'), findsOneWidget);
  });
}
