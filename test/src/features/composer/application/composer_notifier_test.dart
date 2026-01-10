import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockFeedItem extends Mock implements FeedItem {}

void main() {
  late MockDraftRepository mockRepository;
  late MockProfileRepository mockProfileRepository;
  late Draft mockDraft;
  late MockFeedItem mockPost;

  setUp(() {
    mockRepository = MockDraftRepository();
    mockProfileRepository = MockProfileRepository();
    mockPost = MockFeedItem();

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
    when(
      () => mockRepository.createDraft(
        replyParentUri: any(named: 'replyParentUri'),
        replyParentCid: any(named: 'replyParentCid'),
        replyRootUri: any(named: 'replyRootUri'),
        replyRootCid: any(named: 'replyRootCid'),
        quoteUri: any(named: 'quoteUri'),
        quoteCid: any(named: 'quoteCid'),
      ),
    ).thenAnswer((_) async => mockDraft);

    when(() => mockRepository.deleteDraft(any())).thenAnswer((_) => Future.value());
    when(() => mockProfileRepository.getPost(any())).thenAnswer((_) async => null);
    when(() => mockPost.uri).thenReturn('at://post-uri');
    when(() => mockPost.cid).thenReturn('bafy-cid');
    when(() => mockPost.record).thenReturn({});
  });

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      draftRepositoryProvider.overrideWithValue(mockRepository),
      profileRepositoryProvider.overrideWithValue(mockProfileRepository),
    ],
  );

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

    test('initializes with replyTo/quoteTo args and fetches posts', () {
      fakeAsync((async) {
        final container = createContainer();
        const args = ComposerArgs(replyTo: 'at://reply', quoteTo: 'at://quote');

        when(() => mockProfileRepository.getPost('at://reply')).thenAnswer((_) async => mockPost);
        when(() => mockProfileRepository.getPost('at://quote')).thenAnswer((_) async => mockPost);

        when(
          () => mockRepository.createDraft(
            replyParentUri: any(named: 'replyParentUri'),
            replyParentCid: any(named: 'replyParentCid'),
            replyRootUri: any(named: 'replyRootUri'),
            replyRootCid: any(named: 'replyRootCid'),
            quoteUri: any(named: 'quoteUri'),
            quoteCid: any(named: 'quoteCid'),
          ),
        ).thenAnswer((_) async => mockDraft);

        container.listen(composerProvider(args), (previous, next) {}, fireImmediately: true);

        container.read(composerProvider(args));
        async.flushMicrotasks();

        verify(() => mockProfileRepository.getPost('at://reply')).called(1);
        verify(() => mockProfileRepository.getPost('at://quote')).called(1);

        verify(
          () => mockRepository.createDraft(
            replyParentUri: 'at://post-uri',
            replyParentCid: 'bafy-cid',
            replyRootUri: 'at://post-uri',
            replyRootCid: 'bafy-cid',
            quoteUri: 'at://post-uri',
            quoteCid: 'bafy-cid',
          ),
        ).called(1);

        final nextState = container.read(composerProvider(args)).value;
        expect(nextState?.replyPost, isNotNull);
        expect(nextState?.quotePost, isNotNull);
      });
    });

    test('build extracts root from parent reply record', () {
      fakeAsync((async) {
        final container = createContainer();
        const args = ComposerArgs(replyTo: 'at://parent');

        final parentPost = MockFeedItem();
        when(() => parentPost.uri).thenReturn('at://parent');
        when(() => parentPost.cid).thenReturn('parent-cid');
        when(() => parentPost.record).thenReturn({
          'reply': {
            'root': {'uri': 'at://root', 'cid': 'root-cid'},
          },
        });

        when(
          () => mockProfileRepository.getPost('at://parent'),
        ).thenAnswer((_) async => parentPost);

        container.listen(composerProvider(args), (previous, next) {}, fireImmediately: true);
        container.read(composerProvider(args));
        async.flushMicrotasks();

        verify(
          () => mockRepository.createDraft(
            replyParentUri: 'at://parent',
            replyParentCid: 'parent-cid',
            replyRootUri: 'at://root',
            replyRootCid: 'root-cid',
            quoteUri: null,
            quoteCid: null,
          ),
        ).called(1);
      });
    });
  });
}
