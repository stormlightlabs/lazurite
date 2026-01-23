import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_preview_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DraftPreviewCard', () {
    final baseDraft = Draft(
      id: '1',
      text: 'Hello world',
      status: DraftStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      media: [],
    );

    testWidgets('renders basic draft information', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: baseDraft, onTap: () {}),
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsNothing);
    });

    testWidgets('renders untitled draft when text is empty', (tester) async {
      final draft = Draft(
        id: '1',
        text: '',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: draft, onTap: () {}),
        ),
      );

      expect(find.text('Untitled Draft'), findsOneWidget);
    });

    testWidgets('renders media badge when attachments exist', (tester) async {
      final draft = Draft(
        id: '1',
        text: 'With media',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [
          const DraftMediaAttachment(
            id: 1,
            draftId: '1',
            localPath: '/tmp/img1.jpg',
            mimeType: 'image/jpeg',
            status: DraftMediaStatus.pending,
            sortOrder: 0,
          ),
          const DraftMediaAttachment(
            id: 2,
            draftId: '1',
            localPath: '/tmp/img2.jpg',
            mimeType: 'image/jpeg',
            status: DraftMediaStatus.pending,
            sortOrder: 1,
          ),
        ],
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: draft, onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders reply and quote badges', (tester) async {
      final draft = Draft(
        id: '1',
        text: 'Reply and quote',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        replyParentUri: 'at://reply',
        quoteUri: 'at://quote',
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: draft, onTap: () {}),
        ),
      );

      expect(find.text('Reply'), findsOneWidget);
      expect(find.byIcon(Icons.reply), findsOneWidget);
      expect(find.text('Quote'), findsOneWidget);
      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('renders error message for failed drafts', (tester) async {
      final draft = Draft(
        id: '1',
        text: 'Failed draft',
        status: DraftStatus.failed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        errorMessage: 'Upload failed',
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: draft, onTap: () {}),
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Upload failed'), findsOneWidget);
    });

    testWidgets('callbacks onTap', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: baseDraft, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(DraftPreviewCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows retry button for failed drafts when onRetry provided', (tester) async {
      final failedDraft = Draft(
        id: '1',
        text: 'Failed draft',
        status: DraftStatus.failed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        errorMessage: 'Upload failed',
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: failedDraft, onTap: () {}, onRetry: () {}),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('does not show retry button for non-failed drafts', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: baseDraft, onTap: () {}, onRetry: () {}),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      final failedDraft = Draft(
        id: '1',
        text: 'Failed draft',
        status: DraftStatus.failed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        errorMessage: 'Upload failed',
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: failedDraft, onTap: () {}),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('callbacks onRetry when retry button tapped', (tester) async {
      bool retried = false;
      final failedDraft = Draft(
        id: '1',
        text: 'Failed draft',
        status: DraftStatus.failed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        errorMessage: 'Upload failed',
      );

      await tester.pumpApp(
        Scaffold(
          body: DraftPreviewCard(draft: failedDraft, onTap: () {}, onRetry: () => retried = true),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
