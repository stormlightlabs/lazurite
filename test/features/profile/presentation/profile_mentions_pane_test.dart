import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_mentions_pane.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  testWidgets('loads mentions for the actor DID and renders the empty state', (tester) async {
    final repository = MockProfileRepository();
    when(
      () => repository.getActorMentions(actor: 'did:plc:mentioned', limit: 50),
    ).thenAnswer((_) async => const ProfileMentionsResult(posts: []));

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileMentionsPane(actorDid: 'did:plc:mentioned', profileRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No mentions yet'), findsOneWidget);
    verify(() => repository.getActorMentions(actor: 'did:plc:mentioned', limit: 50)).called(1);
  });
}
