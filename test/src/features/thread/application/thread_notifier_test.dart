import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/application/thread_notifier.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockThreadRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockThreadRepository();

    container = ProviderContainer(
      overrides: [threadRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const postUri = 'at://did:example:123/app.bsky.feed.post/123';
  final expectedThread = ThreadViewPost(
    post: ThreadPost(
      uri: postUri,
      cid: 'cid',
      author: ThreadAuthor(did: 'did:123', handle: 'handle'),
      record: {},
      indexedAt: DateTime.now(),
    ),
  );

  group('ThreadNotifier', () {
    test('build fetches thread successfully', () async {
      when(
        () => mockRepository.getPostThread(postUri, any()),
      ).thenAnswer((_) async => expectedThread);

      final result = await container.read(threadProvider(postUri).future);

      expect(result, expectedThread);
      verify(() => mockRepository.getPostThread(postUri, any())).called(1);
    });

    test('refresh re-fetches thread', () async {
      when(
        () => mockRepository.getPostThread(postUri, any()),
      ).thenAnswer((_) async => expectedThread);

      await container.read(threadProvider(postUri).future);

      container.listen(threadProvider(postUri), (_, _) {});
      await container.read(threadProvider(postUri).notifier).refresh();

      verify(() => mockRepository.getPostThread(postUri, any())).called(2);
    });
  });
}
