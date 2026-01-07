import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/actor_row.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/following_page.dart';
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
      child: const MaterialApp(home: FollowingPage(did: 'did:plc:test')),
    );
  }

  group('FollowingPage', () {
    testWidgets('renders list of ActorRow widgets', (tester) async {
      when(() => mockRepository.getFollows(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => FollowsResult(
          follows: [
            ActorBasic(
              did: 'did:plc:following1',
              handle: 'following1.bsky.social',
              displayName: 'Following One',
            ),
            ActorBasic(did: 'did:plc:following2', handle: 'following2.bsky.social'),
          ],
        ),
      );

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ActorRow), findsNWidgets(2));
      expect(find.text('Following One'), findsOneWidget);
      expect(find.text('@following1.bsky.social'), findsOneWidget);
    });

    testWidgets('shows empty state when not following anyone', (tester) async {
      when(
        () => mockRepository.getFollows(any(), cursor: any(named: 'cursor')),
      ).thenAnswer((_) async => FollowsResult(follows: []));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Not following anyone yet'), findsOneWidget);
    });

    testWidgets('displays correct app bar title', (tester) async {
      when(
        () => mockRepository.getFollows(any(), cursor: any(named: 'cursor')),
      ).thenAnswer((_) async => FollowsResult(follows: []));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Following'), findsOneWidget);
    });
  });
}
