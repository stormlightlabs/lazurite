import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/application/draft_recovery_controller.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  late MockDraftRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockDraftRepository();
    container = ProviderContainer(
      overrides: [draftRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final draft = Draft(
    id: '123',
    text: 'Test draft',
    status: DraftStatus.publishing,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    media: [],
  );

  test('build fetches crashed drafts', () async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);

    final controller = container.read(draftRecoveryControllerProvider.future);
    await expectLater(controller, completion([draft]));
  });

  test('retry calls publishDraft', () async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
    when(
      () => mockRepository.publishDraft('123'),
    ).thenAnswer((_) async => (uri: 'uri', cid: 'cid'));

    await container.read(draftRecoveryControllerProvider.future);

    await container.read(draftRecoveryControllerProvider.notifier).retry(draft);

    verify(() => mockRepository.publishDraft('123')).called(1);

    final state = await container.read(draftRecoveryControllerProvider.future);
    expect(state, isEmpty);
  });

  test(
    'retry removes draft even if publish fails (assuming optimistic update or let it fail elsewhere)',
    () async {
      when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
      when(() => mockRepository.publishDraft('123')).thenThrow('Error');

      await container.read(draftRecoveryControllerProvider.future);

      await container.read(draftRecoveryControllerProvider.notifier).retry(draft);

      verify(() => mockRepository.publishDraft('123')).called(1);

      final state = await container.read(draftRecoveryControllerProvider.future);
      expect(state, isEmpty);
    },
  );

  test('delete calls deleteDraft', () async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
    when(() => mockRepository.deleteDraft('123')).thenAnswer((_) async {});

    await container.read(draftRecoveryControllerProvider.future);

    await container.read(draftRecoveryControllerProvider.notifier).delete(draft);

    verify(() => mockRepository.deleteDraft('123')).called(1);

    final state = await container.read(draftRecoveryControllerProvider.future);
    expect(state, isEmpty);
  });

  test('dismiss calls markAsFailed', () async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
    when(() => mockRepository.markAsFailed('123', any())).thenAnswer((_) async {});

    await container.read(draftRecoveryControllerProvider.future);

    await container.read(draftRecoveryControllerProvider.notifier).dismiss(draft);

    verify(() => mockRepository.markAsFailed('123', any())).called(1);

    final state = await container.read(draftRecoveryControllerProvider.future);
    expect(state, isEmpty);
  });
}
