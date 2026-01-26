import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/application/draft_recovery_controller.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/presentation/screens/draft_recovery_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/pump_app.dart';

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  late MockDraftRepository mockRepository;

  setUp(() {
    mockRepository = MockDraftRepository();
  });

  final draft = Draft(
    id: '123',
    text: 'Test failed post',
    status: DraftStatus.publishing,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    media: [],
  );

  testWidgets('DraftRecoverySheet shows draft content and actions', (tester) async {
    await tester.pumpApp(
      Scaffold(body: DraftRecoverySheet(draft: draft)),
      overrides: [
        draftRepositoryProvider.overrideWithValue(mockRepository),
        draftRecoveryControllerProvider.overrideWith(() => DraftRecoveryController()),
      ],
    );

    expect(find.text('Post Upload Interrupted'), findsOneWidget);
    expect(find.text('Test failed post'), findsOneWidget);
    expect(find.text('Retry Upload'), findsOneWidget);
    expect(find.text('Save as Draft & Close'), findsOneWidget);
    expect(find.text('Delete Post'), findsOneWidget);
  });

  testWidgets('Retry button triggers controller retry', (tester) async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
    when(
      () => mockRepository.publishDraft('123'),
    ).thenAnswer((_) async => (uri: 'uri', cid: 'cid'));

    await tester.pumpApp(
      Scaffold(body: DraftRecoverySheet(draft: draft)),
      overrides: [draftRepositoryProvider.overrideWithValue(mockRepository)],
    );

    await tester.tap(find.text('Retry Upload'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.publishDraft('123')).called(1);
    expect(find.byType(DraftRecoverySheet), findsNothing);
  });

  testWidgets('Delete button triggers controller delete', (tester) async {
    when(() => mockRepository.getCrashedDrafts()).thenAnswer((_) async => [draft]);
    when(() => mockRepository.deleteDraft('123')).thenAnswer((_) async {});

    await tester.pumpApp(
      Scaffold(body: DraftRecoverySheet(draft: draft)),
      overrides: [draftRepositoryProvider.overrideWithValue(mockRepository)],
    );

    await tester.tap(find.text('Delete Post'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.deleteDraft('123')).called(1);
    expect(find.byType(DraftRecoverySheet), findsNothing);
  });
}
