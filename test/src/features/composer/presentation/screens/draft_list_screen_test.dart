import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/presentation/screens/draft_list_screen.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_preview_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/pump_app.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  late MockDraftRepository mockDraftRepository;

  setUp(() {
    mockDraftRepository = MockDraftRepository();
    when(() => mockDraftRepository.deleteDraft(any())).thenAnswer((_) async {});
  });

  group('DraftListScreen', () {
    testWidgets('renders loading state', (tester) async {
      final controller = StreamController<List<Draft>>();

      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [draftsProvider.overrideWith((ref) => controller.stream)],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [draftsProvider.overrideWith((ref) => Stream.value([]))],
      );

      await tester.pumpAndSettle();

      expect(find.text('No drafts yet'), findsOneWidget);
      expect(find.byIcon(Icons.drafts_outlined), findsOneWidget);
    });

    testWidgets('renders list of drafts sorted by updatedAt', (tester) async {
      final oldDraft = Draft(
        id: '1',
        text: 'Old draft',
        status: DraftStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        media: [],
      );
      final newDraft = Draft(
        id: '2',
        text: 'New draft',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      );

      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [
          draftsProvider.overrideWith((ref) => Stream.value([oldDraft, newDraft])),
        ],
      );

      await tester.pumpAndSettle();

      expect(find.byType(DraftPreviewCard), findsNWidgets(2));

      final cards = tester.widgetList<DraftPreviewCard>(find.byType(DraftPreviewCard));
      expect(cards.first.draft.id, equals(newDraft.id));
      expect(cards.last.draft.id, equals(oldDraft.id));
    });

    testWidgets('navigates to composer on tap', (tester) async {
      final draft = Draft(
        id: '1',
        text: 'Test draft',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      );

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DraftListScreen()),
          GoRoute(
            path: '/compose',
            builder: (context, state) =>
                Scaffold(body: Text('Compose: ${state.uri.queryParameters['draftId']}')),
          ),
        ],
      );

      await tester.pumpApp(
        MaterialApp.router(routerConfig: router),
        overrides: [
          draftsProvider.overrideWith((ref) => Stream.value([draft])),
        ],
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(DraftPreviewCard));
      await tester.pumpAndSettle();

      expect(find.text('Compose: 1'), findsOneWidget);
    });

    testWidgets('swiping draft deletes it', (tester) async {
      final draft = Draft(
        id: '1',
        text: 'Draft to delete',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      );

      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [
          draftsProvider.overrideWith((ref) => Stream.value([draft])),
          draftRepositoryProvider.overrideWithValue(mockDraftRepository),
        ],
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(DraftPreviewCard), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete Draft?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockDraftRepository.deleteDraft('1')).called(1);
    });

    testWidgets('pull to refresh calls deletePostedDrafts', (tester) async {
      when(() => mockDraftRepository.deletePostedDrafts()).thenAnswer((_) async => 0);

      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [
          draftsProvider.overrideWith((ref) => Stream.value([])),
          draftRepositoryProvider.overrideWithValue(mockDraftRepository),
        ],
      );

      await tester.pumpAndSettle();

      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(() => mockDraftRepository.deletePostedDrafts()).called(1);
    });

    testWidgets('retry button triggers publishDraft for failed drafts', (tester) async {
      final failedDraft = Draft(
        id: '1',
        text: 'Failed draft',
        status: DraftStatus.failed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        errorMessage: 'Upload failed',
      );

      when(
        () => mockDraftRepository.publishDraft('1'),
      ).thenAnswer((_) async => (uri: 'at://example', cid: 'cid'));

      await tester.pumpApp(
        const DraftListScreen(),
        overrides: [
          draftsProvider.overrideWith((ref) => Stream.value([failedDraft])),
          draftRepositoryProvider.overrideWithValue(mockDraftRepository),
        ],
      );

      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(() => mockDraftRepository.publishDraft('1')).called(1);
    });
  });
}
