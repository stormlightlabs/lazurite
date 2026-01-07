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

    group('theming', () {
      testWidgets('uses onSurfaceVariant for handle text', (tester) async {
        const testColor = Color(0xFF123456);
        final author = Profile(
          did: 'did:1',
          handle: 'test.bsky.social',
          displayName: 'Test User',
          indexedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: const ColorScheme.dark(onSurfaceVariant: testColor)),
            home: Scaffold(
              body: PostHeader(author: author, indexedAt: DateTime.now()),
            ),
          ),
        );

        final handleFinder = find.text('@test.bsky.social');
        expect(handleFinder, findsOneWidget);

        final handleWidget = tester.widget<Text>(handleFinder);
        expect(handleWidget.style?.color, equals(testColor));
      });

      testWidgets('uses onSurfaceVariant for timestamp text', (tester) async {
        const testColor = Color(0xFF654321);
        final author = Profile(
          did: 'did:1',
          handle: 'test.bsky.social',
          displayName: 'Test User',
          indexedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: const ColorScheme.dark(onSurfaceVariant: testColor)),
            home: Scaffold(
              body: PostHeader(
                author: author,
                indexedAt: DateTime.now().subtract(const Duration(minutes: 5)),
              ),
            ),
          ),
        );

        final timestampFinder = find.text('• 5m');
        expect(timestampFinder, findsOneWidget);

        final timestampWidget = tester.widget<Text>(timestampFinder);
        expect(timestampWidget.style?.color, equals(testColor));
      });

      testWidgets('uses onSurface for display name text', (tester) async {
        const testColor = Color(0xFFABCDEF);
        final author = Profile(
          did: 'did:1',
          handle: 'test.bsky.social',
          displayName: 'Test User',
          indexedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: const ColorScheme.dark(onSurface: testColor)),
            home: Scaffold(
              body: PostHeader(author: author, indexedAt: DateTime.now()),
            ),
          ),
        );

        final displayNameFinder = find.text('Test User');
        expect(displayNameFinder, findsOneWidget);

        final displayNameWidget = tester.widget<Text>(displayNameFinder);
        expect(displayNameWidget.style?.color, equals(testColor));
      });
    });
  });
}
