import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/presentation/screens/composer_screen.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';
import 'package:mocktail/mocktail.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  late MockDraftRepository mockRepository;

  setUp(() {
    mockRepository = MockDraftRepository();
  });

  Draft createMockDraft({
    String id = 'test-draft-id',
    String text = '',
    DraftStatus status = DraftStatus.draft,
    List<DraftMediaAttachment> media = const [],
  }) => Draft(
    id: id,
    text: text,
    status: status,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    media: media,
  );

  Widget buildTestWidget({String? draftId, Draft? existingDraft}) {
    final draft = existingDraft ?? createMockDraft();

    when(
      () => mockRepository.createDraft(
        text: any(named: 'text'),
        replyParentUri: any(named: 'replyParentUri'),
        replyParentCid: any(named: 'replyParentCid'),
        replyRootUri: any(named: 'replyRootUri'),
        replyRootCid: any(named: 'replyRootCid'),
      ),
    ).thenAnswer((_) async => createMockDraft(id: 'new-draft-id'));

    when(() => mockRepository.getDraft(any())).thenAnswer((_) async => draft);
    when(
      () => mockRepository.updateDraftContent(
        any(),
        text: any(named: 'text'),
        replyRootUri: any(named: 'replyRootUri'),
        replyRootCid: any(named: 'replyRootCid'),
      ),
    ).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/compose?draftId=$draftId',
      routes: [
        GoRoute(
          path: '/compose',
          builder: (context, state) =>
              ComposerScreen(draftId: state.uri.queryParameters['draftId']),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        draftRepositoryProvider.overrideWithValue(mockRepository),
        composerProvider.overrideWith(() => _MockComposerNotifier(draft)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('ComposerScreen', () {
    testWidgets('renders text field and publish button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(PublishButton), findsOneWidget);
    });

    testWidgets('renders close button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders Compose title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Compose'), findsOneWidget);
    });

    testWidgets('publish button is disabled when text is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isTrue);
    });

    testWidgets('character counter shows 300 when empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('300'), findsWidgets);
    });

    testWidgets('character counter updates as user types', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.text('295'), findsWidgets);
    });

    testWidgets('publish button enabled when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isFalse);
    });

    testWidgets('shows negative count when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      expect(find.text('-5'), findsWidgets);
    });

    testWidgets('publish button disabled when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isTrue);
    });

    testWidgets('shows Split button when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      expect(find.text('Split'), findsOneWidget);
    });

    testWidgets('Split button splits text and updates UI', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text.length, 300);

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isFalse);
      expect(publishButton.label, 'Next');
    });

    testWidgets('splits text at nearest whitespace', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final text = '${'a' * 290} ${'b' * 15}';
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '${'a' * 290} ');
      expect(textField.controller?.text.length, 291);
    });

    testWidgets('force splits huge words if no whitespace', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final text = 'a' * 305;
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'a' * 300);
    });

    testWidgets('preserves reply root when continuing existing thread', (tester) async {
      final replyDraft = Draft(
        id: 'reply-draft',
        text: 'Reply content',
        status: DraftStatus.draft,
        media: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        replyRootUri: 'at://root',
        replyRootCid: 'cid-root',
        replyParentUri: 'at://parent',
        replyParentCid: 'cid-parent',
      );

      await tester.pumpWidget(buildTestWidget(existingDraft: replyDraft));
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.createDraft(
          text: any(named: 'text'),
          replyParentUri: 'at://test',
          replyParentCid: 'cid-test',
          replyRootUri: 'at://root',
          replyRootCid: 'cid-root',
        ),
      ).called(1);
    });

    testWidgets('tapping Next publishes and creates creating new thread root if none exists', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final longText = 'a' * 305;
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.createDraft(
          text: any(named: 'text'),
          replyParentUri: 'at://test',
          replyParentCid: 'cid-test',
          replyRootUri: 'at://test',
          replyRootCid: 'cid-test',
        ),
      ).called(1);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("What's on your mind?"), findsOneWidget);
    });

    testWidgets('loads existing draft text', (tester) async {
      final draft = createMockDraft(text: 'Existing draft content');
      await tester.pumpWidget(buildTestWidget(existingDraft: draft));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Existing draft content');
    });
  });
}

/// Mock notifier that returns a fixed state for testing.
class _MockComposerNotifier extends ComposerNotifier {
  _MockComposerNotifier(this._draft);

  final Draft _draft;

  @override
  Future<ComposerState> build(String? draftId) async {
    return ComposerState(draft: _draft);
  }

  @override
  void updateText(String text) {
    /* No-op for widget tests to avoid pending timers */
  }

  @override
  Future<({String uri, String cid})?> publish() async {
    return (uri: 'at://test', cid: 'cid-test');
  }

  @override
  Future<void> cancel() async {}
}
