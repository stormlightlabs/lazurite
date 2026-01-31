import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/background_infrastructure.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/post_publisher.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_callback_dispatcher.dart';
import 'package:mocktail/mocktail.dart';

class MockBackgroundInfrastructure extends Mock implements BackgroundInfrastructure {}

class MockPostPublisher extends Mock implements PostPublisher {}

void main() {
  late MockBackgroundInfrastructure mockInfra;
  late MockPostPublisher mockPostPublisher;

  setUp(() {
    mockInfra = MockBackgroundInfrastructure();
    mockPostPublisher = MockPostPublisher();
    when(() => mockInfra.postPublisher).thenReturn(mockPostPublisher);
  });

  group('handleTask', () {
    const taskName = 'test_task';
    const draftId = 'test_draft';
    const inputData = {'draftId': draftId};

    test('successfully initializes infrastructure and publishes draft', () async {
      when(
        () => mockPostPublisher.publishDraft(draftId),
      ).thenAnswer((_) async => (uri: 'at://post', cid: 'cid'));

      final result = await handleTask(taskName, inputData, initInfra: () async => mockInfra);

      expect(result, isTrue);
      verify(() => mockPostPublisher.publishDraft(draftId)).called(1);
    });

    test('returns false when draftId is missing', () async {
      final result = await handleTask(taskName, {}, initInfra: () async => mockInfra);

      expect(result, isFalse);
      verifyNever(() => mockPostPublisher.publishDraft(any()));
    });

    test('returns false when publishDraft fails', () async {
      when(() => mockPostPublisher.publishDraft(draftId)).thenThrow(Exception('Publish failed'));

      final result = await handleTask(taskName, inputData, initInfra: () async => mockInfra);

      expect(result, isFalse);
      verify(() => mockPostPublisher.publishDraft(draftId)).called(1);
    });
  });
}
