import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/post_thread_cubit.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/feed.dart';

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

void main() {
  late MockPostThreadRepository mockRepository;

  setUp(() {
    mockRepository = MockPostThreadRepository();
  });

  const testUri = 'at://did:plc:author/app.bsky.feed.post/abc';

  final sampleThread = ThreadViewPost(post: testPostView(cid: 'cid-123'));

  group('PostThreadCubit', () {
    test('initial state is loading', () {
      final cubit = PostThreadCubit(postThreadRepository: mockRepository);

      expect(cubit.state.status, PostThreadStatus.loading);
      expect(cubit.state.thread, isNull);
      expect(cubit.state.error, isNull);
    });

    blocTest<PostThreadCubit, PostThreadState>(
      'load emits loading then loaded on success',
      build: () {
        when(() => mockRepository.getPostThread(testUri)).thenAnswer((_) async => sampleThread);
        return PostThreadCubit(postThreadRepository: mockRepository);
      },
      act: (cubit) => cubit.load(testUri),
      expect: () => [
        const PostThreadState(status: PostThreadStatus.loading),
        PostThreadState(status: PostThreadStatus.loaded, thread: sampleThread),
      ],
    );

    blocTest<PostThreadCubit, PostThreadState>(
      'load emits loading then error on failure',
      build: () {
        when(() => mockRepository.getPostThread(testUri)).thenThrow(Exception('Network error'));
        return PostThreadCubit(postThreadRepository: mockRepository);
      },
      act: (cubit) => cubit.load(testUri),
      expect: () => [
        const PostThreadState(status: PostThreadStatus.loading),
        const PostThreadState(status: PostThreadStatus.error, error: 'Failed to load thread'),
      ],
    );

    blocTest<PostThreadCubit, PostThreadState>(
      'load calls repository with correct uri',
      build: () {
        when(() => mockRepository.getPostThread(any())).thenAnswer((_) async => sampleThread);
        return PostThreadCubit(postThreadRepository: mockRepository);
      },
      act: (cubit) => cubit.load(testUri),
      verify: (_) {
        verify(() => mockRepository.getPostThread(testUri)).called(1);
      },
    );

    blocTest<PostThreadCubit, PostThreadState>(
      'calling load again resets to loading',
      build: () {
        when(() => mockRepository.getPostThread(any())).thenAnswer((_) async => sampleThread);
        return PostThreadCubit(postThreadRepository: mockRepository);
      },
      act: (cubit) async {
        await cubit.load(testUri);
        await cubit.load(testUri);
      },
      expect: () => [
        const PostThreadState(status: PostThreadStatus.loading),
        PostThreadState(status: PostThreadStatus.loaded, thread: sampleThread),
        const PostThreadState(status: PostThreadStatus.loading),
        PostThreadState(status: PostThreadStatus.loaded, thread: sampleThread),
      ],
    );
  });

  group('PostThreadState', () {
    test('initial state has loading status', () {
      const state = PostThreadState();

      expect(state.status, PostThreadStatus.loading);
      expect(state.thread, isNull);
      expect(state.error, isNull);
    });

    test('props includes all fields for equality', () {
      final state1 = PostThreadState(status: PostThreadStatus.loaded, thread: sampleThread);
      final state2 = PostThreadState(status: PostThreadStatus.loaded, thread: sampleThread);

      expect(state1, equals(state2));
    });

    test('states with different status are not equal', () {
      const state1 = PostThreadState(status: PostThreadStatus.loading);
      const state2 = PostThreadState(status: PostThreadStatus.error, error: 'error');

      expect(state1, isNot(equals(state2)));
    });
  });
}
