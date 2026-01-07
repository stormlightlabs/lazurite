import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  late MockDraftRepository mockRepository;
  late Draft mockDraft;

  setUp(() {
    mockRepository = MockDraftRepository();
    mockDraft = Draft(
      id: 'test-draft-id',
      text: '',
      status: DraftStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      media: [],
    );

    when(() => mockRepository.getDraft(any())).thenAnswer((_) async => mockDraft);
    when(
      () => mockRepository.updateDraftContent(any(), text: any(named: 'text')),
    ).thenAnswer((_) async {});
    when(() => mockRepository.createDraft()).thenAnswer((_) async => mockDraft);
    when(() => mockRepository.deleteDraft(any())).thenAnswer((_) => Future.value());
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [draftRepositoryProvider.overrideWithValue(mockRepository)],
    );
  }

  group('ComposerNotifier', () {
    test('updateText uses debouncing', () {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(composerProvider(null), (previous, next) {}, fireImmediately: true);
        final notifier = container.read(composerProvider(null).notifier);

        async.flushMicrotasks();

        notifier.updateText('Hello');
        async.elapse(const Duration(milliseconds: 200));
        verifyNever(() => mockRepository.updateDraftContent(any(), text: any(named: 'text')));

        notifier.updateText('Hello W');
        async.elapse(const Duration(milliseconds: 200));
        verifyNever(() => mockRepository.updateDraftContent(any(), text: any(named: 'text')));

        notifier.updateText('Hello World');
        async.elapse(const Duration(milliseconds: 600));

        verify(
          () => mockRepository.updateDraftContent(mockDraft.id, text: 'Hello World'),
        ).called(1);
      });
    });

    test('updateText is cancelled by forceSave', () {
      fakeAsync((async) {
        final container = createContainer();

        container.listen(composerProvider(null), (previous, next) {}, fireImmediately: true);
        final notifier = container.read(composerProvider(null).notifier);

        async.flushMicrotasks();

        notifier.updateText('Hello');
        async.elapse(const Duration(milliseconds: 200));

        notifier.forceSave('Hello Forced');
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 400));

        verify(
          () => mockRepository.updateDraftContent(mockDraft.id, text: 'Hello Forced'),
        ).called(1);
      });
    });

    test('forceSave saves immediately without delay', () {
      fakeAsync((async) {
        final container = createContainer();

        container.listen(composerProvider(null), (previous, next) {}, fireImmediately: true);
        final notifier = container.read(composerProvider(null).notifier);

        async.flushMicrotasks();

        notifier.forceSave('Immediate Save');
        async.flushMicrotasks();

        verify(
          () => mockRepository.updateDraftContent(mockDraft.id, text: 'Immediate Save'),
        ).called(1);
      });
    });
    test('deleteDraft calls repository deleteDraft', () {
      fakeAsync((async) {
        final container = createContainer();

        container.listen(composerProvider(null), (previous, next) {}, fireImmediately: true);
        final notifier = container.read(composerProvider(null).notifier);

        async.flushMicrotasks();

        notifier.deleteDraft();
        async.flushMicrotasks();

        verify(() => mockRepository.deleteDraft(mockDraft.id)).called(1);
      });
    });

    test('initializes with replyTo/quoteTo args', () {
      fakeAsync((async) {
        final container = createContainer();
        const args = ComposerArgs(replyTo: 'at://reply', quoteTo: 'at://quote');

        when(
          () => mockRepository.createDraft(
            replyParentUri: any(named: 'replyParentUri'),
            quoteUri: any(named: 'quoteUri'),
          ),
        ).thenAnswer((_) async => mockDraft);

        container.listen(composerProvider(args), (previous, next) {}, fireImmediately: true);
        container.read(composerProvider(args).notifier); // Force build

        async.flushMicrotasks();

        verify(
          () => mockRepository.createDraft(replyParentUri: 'at://reply', quoteUri: 'at://quote'),
        ).called(1);
      });
    });
  });
}
