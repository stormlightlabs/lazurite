import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/actor_row.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/followers_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [profileRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: FollowersPage(did: 'did:plc:test')),
    );
  }

  group('FollowersPage', () {
    testWidgets('renders list of ActorRow widgets', (tester) async {
      when(() => mockRepository.getFollowers(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => FollowersResult(
          followers: [
            ActorBasic(
              did: 'did:plc:follower1',
              handle: 'follower1.bsky.social',
              displayName: 'Follower One',
            ),
            ActorBasic(did: 'did:plc:follower2', handle: 'follower2.bsky.social'),
          ],
        ),
      );

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ActorRow), findsNWidgets(2));
      expect(find.text('Follower One'), findsOneWidget);
      expect(find.text('@follower1.bsky.social'), findsOneWidget);
    });

    testWidgets('shows empty state when no followers', (tester) async {
      when(
        () => mockRepository.getFollowers(any(), cursor: any(named: 'cursor')),
      ).thenAnswer((_) async => FollowersResult(followers: []));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('No followers yet'), findsOneWidget);
    });

    testWidgets('displays correct app bar title', (tester) async {
      when(
        () => mockRepository.getFollowers(any(), cursor: any(named: 'cursor')),
      ).thenAnswer((_) async => FollowersResult(followers: []));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Followers'), findsOneWidget);
    });
  });
}
