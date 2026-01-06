import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/verification_badge.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

void main() {
  group('PostHeader', () {
    testWidgets('renders author info correctly', (tester) async {
      final author = Profile(
        did: 'did:1',
        handle: 'alice.bsky.social',
        displayName: 'Alice',
        description: 'Bio',
        avatar: 'avatar.jpg',
        indexedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostHeader(
              author: author,
              indexedAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('@alice.bsky.social'), findsOneWidget);
      expect(find.text('• 5m'), findsOneWidget);
    });

    testWidgets('handles missing display name', (tester) async {
      final author = Profile(did: 'did:1', handle: 'bob.bsky.social', indexedAt: DateTime.now());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostHeader(author: author, indexedAt: DateTime.now()),
          ),
        ),
      );

      expect(find.text('bob.bsky.social'), findsOneWidget);
    });

    group('verification badge', () {
      testWidgets('renders verification badge when verificationStatus provided', (tester) async {
        final author = Profile(
          did: 'did:1',
          handle: 'verified.bsky.social',
          displayName: 'Verified User',
          indexedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostHeader(
                author: author,
                indexedAt: DateTime.now(),
                verificationStatus: 'official',
              ),
            ),
          ),
        );

        expect(find.byType(VerificationBadge), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('does not render verification badge when verificationStatus is null', (
        tester,
      ) async {
        final author = Profile(
          did: 'did:1',
          handle: 'regular.bsky.social',
          displayName: 'Regular User',
          indexedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostHeader(author: author, indexedAt: DateTime.now()),
            ),
          ),
        );

        expect(find.byType(VerificationBadge), findsNothing);
      });
    });
  });
}
