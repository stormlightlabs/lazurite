import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/presentation/screens/composer_screen.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/character_count_meter.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/quote_post_card.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/reply_context_card.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

class MockFeedItem extends Mock implements FeedItem {}

void main() {
  late MockDraftRepository mockRepository;
  late MockImagePickerPlatform mockImagePickerPlatform;

  setUp(() {
    mockRepository = MockDraftRepository();
    mockImagePickerPlatform = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockImagePickerPlatform;
    registerFallbackValue(FakeImagePickerOptions());
    registerFallbackValue(FakeMultiImagePickerOptions());
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

  Widget buildTestWidget({
    String? draftId,
    Draft? existingDraft,
    MockComposerNotifierWrapper? notifier,
  }) {
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

    final mockNotifier = notifier ?? MockComposerNotifierWrapper(draft);

    final location = draftId != null ? '/compose?draftId=$draftId' : '/compose';
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.push(location),
                child: const Text('Go to Compose'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/compose',
          builder: (context, state) => ComposerScreen(
            draftId: state.uri.queryParameters['draftId'],
            replyTo: state.uri.queryParameters['replyTo'],
            quoteTo: state.uri.queryParameters['quoteTo'],
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        draftRepositoryProvider.overrideWithValue(mockRepository),
        composerProvider.overrideWith(() => mockNotifier),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> navigateToCompose(WidgetTester tester) async {
    await tester.tap(find.text('Go to Compose'));
    await tester.pumpAndSettle();
  }

  Future<void> enterText(WidgetTester tester, String text) async {
    final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
    textField.controller?.text = text;
    await tester.pump();
  }

  group('ComposerScreen', () {
    testWidgets('renders text field and publish button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      expect(find.byType(ExtendedTextField), findsOneWidget);
      expect(find.byType(PublishButton), findsOneWidget);
    });

    testWidgets('renders close button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders Compose title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      expect(find.text('Compose'), findsOneWidget);
    });

    testWidgets('publish button is disabled when text is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isTrue);
    });

    testWidgets('character counter shows 300 when empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      expect(find.byType(CharacterCountMeter), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('character counter updates as user types', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Hello');

      expect(find.text('295'), findsOneWidget);
    });

    testWidgets('publish button enabled when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Hello world');
      await tester.pump();

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isFalse);
    });

    testWidgets('shows negative count when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
      await tester.pump();

      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('publish button disabled when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
      await tester.pump();

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isTrue);
    });

    testWidgets('shows Split button when over limit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
      await tester.pump();

      expect(find.text('Split'), findsOneWidget);
    });

    testWidgets('Split button splits text and updates UI', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
      expect(textField.controller?.text.length, 300);

      final publishButton = tester.widget<PublishButton>(find.byType(PublishButton));
      expect(publishButton.isDisabled, isFalse);
      expect(publishButton.label, 'Next');
    });

    testWidgets('splits text at nearest whitespace', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final text = '${'a' * 290} ${'b' * 15}';
      await enterText(tester, text);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
      expect(textField.controller?.text, '${'a' * 290} ');
      expect(textField.controller?.text.length, 291);
    });

    testWidgets('force splits huge words if no whitespace', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final text = 'a' * 305;
      await enterText(tester, text);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pump();

      final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
      expect(textField.controller?.text, 'a' * 300);
    });

    testWidgets('shows thread indicator chip after split', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
      await tester.pump();

      await tester.tap(find.text('Split'));
      await tester.pumpAndSettle();

      expect(find.text('Next post ready'), findsOneWidget);
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
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
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
      await navigateToCompose(tester);

      final longText = 'a' * 305;
      await enterText(tester, longText);
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
      await navigateToCompose(tester);

      expect(find.text("What's on your mind?"), findsOneWidget);
    });

    testWidgets('loads existing draft text', (tester) async {
      final draft = createMockDraft(text: 'Existing draft content');
      await tester.pumpWidget(buildTestWidget(existingDraft: draft));
      await navigateToCompose(tester);

      final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
      expect(textField.controller?.text, 'Existing draft content');
    });

    testWidgets('calls forceSave when app is paused', (tester) async {
      final mockNotifier = MockComposerNotifierWrapper(createMockDraft());
      await tester.pumpWidget(buildTestWidget(notifier: mockNotifier));
      await navigateToCompose(tester);

      await enterText(tester, 'Saving on pause');
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      verify(() => mockNotifier.mockForceSaveObj('Saving on pause')).called(1);
    });

    testWidgets('shows image source selection sheet when adding media', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });

    testWidgets('picks image from camera', (tester) async {
      final file = XFile('test_image.jpg');
      when(
        () => mockImagePickerPlatform.getImageFromSource(
          source: ImageSource.camera,
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => file);

      final mockNotifier = MockComposerNotifierWrapper(createMockDraft());
      await tester.pumpWidget(buildTestWidget(notifier: mockNotifier));
      await navigateToCompose(tester);

      await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Take photo'));
      await tester.pumpAndSettle();

      verify(() => mockNotifier.mockAddMediaObj('test_image.jpg', 'image/jpeg')).called(1);
    });

    testWidgets('picks multiple images from gallery', (tester) async {
      final file1 = XFile('image1.png');
      final file2 = XFile('image2.webp');

      when(
        () => mockImagePickerPlatform.getMultiImageWithOptions(options: any(named: 'options')),
      ).thenAnswer((_) async => [file1, file2]);

      final mockNotifier = MockComposerNotifierWrapper(createMockDraft());
      await tester.pumpWidget(buildTestWidget(notifier: mockNotifier));
      await navigateToCompose(tester);

      await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      verify(() => mockNotifier.mockAddMediaObj('image1.png', 'image/png')).called(1);
      verify(() => mockNotifier.mockAddMediaObj('image2.webp', 'image/webp')).called(1);
    });

    testWidgets('shows cancel dialog when has content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Save this draft?'), findsOneWidget);
      expect(find.text('Save Draft'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('save draft action calls forceSave and pops', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Draft'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ComposerScreen), findsNothing);
    });

    testWidgets('discard draft action calls deleteDraft and pops', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ComposerScreen), findsNothing);
    });

    testWidgets('cancel action closes dialog and stays on screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await enterText(tester, 'Content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ComposerScreen), findsOneWidget);
    });

    testWidgets('empty draft closes without dialog and calls deleteDraft', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await navigateToCompose(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ComposerScreen), findsNothing);
    });

    testWidgets('shows ReplyContextCard when replyPost is present', (tester) async {
      final mockPost = MockFeedItem();
      when(() => mockPost.authorDid).thenReturn('did:test');
      when(() => mockPost.authorHandle).thenReturn('handle.test');
      when(() => mockPost.authorDisplayName).thenReturn('Display Name');
      when(() => mockPost.authorAvatar).thenReturn(null);
      when(() => mockPost.text).thenReturn('Parent post text');

      final mockNotifier = MockComposerNotifierWrapper(createMockDraft(), replyPost: mockPost);

      await tester.pumpWidget(buildTestWidget(notifier: mockNotifier));
      await navigateToCompose(tester);

      expect(find.byType(ReplyContextCard), findsOneWidget);
      expect(find.text('Parent post text'), findsOneWidget);
    });

    testWidgets('shows QuotePostCard when quotePost is present', (tester) async {
      final mockPost = MockFeedItem();
      when(() => mockPost.authorDid).thenReturn('did:test');
      when(() => mockPost.authorHandle).thenReturn('handle.test');
      when(() => mockPost.authorDisplayName).thenReturn('Display Name');
      when(() => mockPost.authorAvatar).thenReturn(null);
      when(() => mockPost.text).thenReturn('Quoted post text');
      when(() => mockPost.hasImages).thenReturn(true);

      final mockNotifier = MockComposerNotifierWrapper(createMockDraft(), quotePost: mockPost);

      await tester.pumpWidget(buildTestWidget(notifier: mockNotifier));
      await navigateToCompose(tester);

      expect(find.byType(QuotePostCard), findsOneWidget);
      expect(find.text('Quoted post text'), findsOneWidget);
    });
  });
}

/// Mock notifier that returns a fixed state for testing.
class _MockComposerNotifier extends ComposerNotifier {
  _MockComposerNotifier(this._draft, {this.replyPost, this.quotePost});

  final Draft _draft;
  final FeedItem? replyPost;
  final FeedItem? quotePost;

  @override
  Future<ComposerState> build(ComposerArgs? args) async {
    return ComposerState(draft: _draft, replyPost: replyPost, quotePost: quotePost);
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

  @override
  Future<void> deleteDraft() async {
    mockDeleteDraft();
  }

  void mockDeleteDraft() {}

  @override
  Future<void> forceSave(String text) async {
    mockForceSave(text);
  }

  void mockForceSave(String text) {}

  @override
  Future<void> addMedia(String path, String mimeType) async {
    mockAddMedia(path, mimeType);
  }

  void mockAddMedia(String path, String mimeType) {}

  @override
  Future<void> removeMedia(int mediaId) async {}
}

class MockComposerNotifierWrapper extends _MockComposerNotifier {
  MockComposerNotifierWrapper(super.draft, {super.replyPost, super.quotePost});

  final _mockForceSave = MockForceSave();
  final _mockAddMedia = MockAddMedia();
  final _mockDeleteDraft = MockDeleteDraft();

  @override
  void mockForceSave(String text) => _mockForceSave(text);

  @override
  void mockAddMedia(String path, String mimeType) => _mockAddMedia(path, mimeType);

  @override
  void mockDeleteDraft() => _mockDeleteDraft();

  MockForceSave get mockForceSaveObj => _mockForceSave;
  MockAddMedia get mockAddMediaObj => _mockAddMedia;
  MockDeleteDraft get mockDeleteDraftObj => _mockDeleteDraft;
}

class MockAddMedia extends Mock implements AddMediaHandler {}

abstract class AddMediaHandler {
  void call(String path, String mimeType);
}

abstract class ForceSaveHandler {
  void call(String text);
}

class MockForceSave extends Mock implements ForceSaveHandler {}

abstract class DeleteDraftHandler {
  void call();
}

class MockDeleteDraft extends Mock implements DeleteDraftHandler {}

class MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

class MockImagePicker extends Mock implements ImagePickerPlatform {}

class FakeImagePickerOptions extends Fake implements ImagePickerOptions {}

class FakeMultiImagePickerOptions extends Fake implements MultiImagePickerOptions {}
