import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/pinned_post_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('PinnedPostCard', () {
    const postUri = 'at://did:plc:test/app.bsky.feed.post/123';

    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpApp(
        const Material(child: PinnedPostCard(postUri)),
        overrides: [pinnedPostProvider(postUri).overrideWith((ref) => Future.value(null))],
      );

      await tester.pumpApp(
        const Material(child: PinnedPostCard(postUri)),
        overrides: [pinnedPostProvider(postUri).overrideWith((ref) => Stream.value(null).first)],
      );
    });

    testWidgets('renders pinned post content when loaded', (tester) async {
      final item = FeedItem(
        uri: postUri,
        cid: 'cid123',
        authorDid: 'did:plc:test',
        authorHandle: 'test.bsky.social',
        authorDisplayName: 'Test User',
        text: 'Hello World',
        indexedAt: DateTime.now(),
      );

      await tester.pumpApp(
        const Material(child: PinnedPostCard(postUri)),
        overrides: [pinnedPostProvider(postUri).overrideWith((ref) => Future.value(item))],
      );

      await tester.pumpAndSettle();

      expect(find.text('Pinned Post'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('renders nothing when post is null/not found', (tester) async {
      await tester.pumpApp(
        const Material(child: PinnedPostCard(postUri)),
        overrides: [pinnedPostProvider(postUri).overrideWith((ref) => Future.value(null))],
      );

      await tester.pumpAndSettle();

      expect(find.text('Pinned Post'), findsNothing);
      expect(find.text('Hello World'), findsNothing);
    });
  });
}
