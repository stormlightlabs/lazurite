import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_starter_packs_pane.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

void main() {
  late MockStarterPackRepository repository;

  setUp(() {
    repository = MockStarterPackRepository();
  });

  testWidgets('shows empty state when actor has no starter packs', (tester) async {
    when(
      () => repository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ActorStarterPacksResult(starterPacks: [], cursor: null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileStarterPacksPane(actor: 'did:plc:actor', starterPackRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No starter packs yet'), findsOneWidget);
  });

  testWidgets('shows retry state when starter packs load fails', (tester) async {
    when(
      () => repository.getActorStarterPacks(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('boom'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileStarterPacksPane(actor: 'did:plc:actor', starterPackRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load starter packs'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
