import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_liked_posts_pane.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  setUp(() {
    repository = MockProfileRepository();
  });

  testWidgets('shows empty state when actor has no liked posts', (tester) async {
    when(
      () => repository.getActorLikes(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ProfileActorLikesResult(entries: [], cursor: null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileLikedPostsPane(actor: 'did:plc:actor', profileRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No liked posts yet'), findsOneWidget);
  });

  testWidgets('shows retry when liked posts load fails', (tester) async {
    when(
      () => repository.getActorLikes(
        actor: any(named: 'actor'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('boom'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileLikedPostsPane(actor: 'did:plc:actor', profileRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load liked posts'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
