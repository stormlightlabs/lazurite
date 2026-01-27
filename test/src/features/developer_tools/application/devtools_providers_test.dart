import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lazurite/src/features/developer_tools/infrastructure/devtools_repository.dart';

class MockDevtoolsRepository extends Mock implements DevtoolsRepository {}

void main() {
  group('DevtoolsProviders', () {
    late MockDevtoolsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockDevtoolsRepository();
      container = ProviderContainer(
        overrides: [devtoolsRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('resolvedDid', () {
      test('returns DID directly if it starts with did:', () async {
        const input = 'did:plc:123';
        final result = await container.read(resolvedDidProvider(input).future);
        expect(result, input);
        verifyNever(() => mockRepo.resolveHandle(any()));
      });

      test('resolves handle to DID', () async {
        const handle = 'alice.bsky.social';
        const expectedDid = 'did:plc:alice123';

        when(() => mockRepo.resolveHandle(handle)).thenAnswer((_) async => expectedDid);

        final result = await container.read(resolvedDidProvider(handle).future);
        expect(result, expectedDid);
        verify(() => mockRepo.resolveHandle(handle)).called(1);
      });

      test('returns null if resolution fails', () async {
        const handle = 'invalid.handle';

        when(() => mockRepo.resolveHandle(handle)).thenThrow(Exception('Not found'));

        final result = await container.read(resolvedDidProvider(handle).future);
        expect(result, isNull);
      });
    });
  });
}
