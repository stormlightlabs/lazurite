import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPostActionRepository extends Mock implements PostActionRepository {}

void main() {
  late MockPostActionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:test/app.bsky.feed.post/fallback'));
  });

  setUp(() {
    mockRepository = MockPostActionRepository();
  });

  const testPostUri = 'at://did:plc:test/app.bsky.feed.post/abc123';
  const testPostCid = 'bafyreie5cvv4hhpwo4y6x4f4m6fsq3xrm5f3p5vzum5h5uv5x5x5x5x5x5';
  const testLikeUri = 'at://did:plc:test/app.bsky.feed.like/like456';
  const testRepostUri = 'at://did:plc:test/app.bsky.feed.repost/repost789';

  group('PostActionCubit', () {
    test('initial state has correct values', () {
      final cubit = PostActionCubit(postActionRepository: mockRepository, postUri: testPostUri, postCid: testPostCid);

      expect(cubit.state.postUri, testPostUri);
      expect(cubit.state.isLiked, isFalse);
      expect(cubit.state.isReposted, isFalse);
      expect(cubit.state.likeCount, 0);
      expect(cubit.state.repostCount, 0);
      expect(cubit.state.isLoadingLike, isFalse);
      expect(cubit.state.isLoadingRepost, isFalse);
    });

    test('initial state respects provided values', () {
      final cubit = PostActionCubit(
        postActionRepository: mockRepository,
        postUri: testPostUri,
        postCid: testPostCid,
        isLiked: true,
        isReposted: true,
        likeCount: 10,
        repostCount: 5,
        likeUri: testLikeUri,
        repostUri: testRepostUri,
      );

      expect(cubit.state.isLiked, isTrue);
      expect(cubit.state.isReposted, isTrue);
      expect(cubit.state.likeCount, 10);
      expect(cubit.state.repostCount, 5);
      expect(cubit.state.likeUri, testLikeUri);
      expect(cubit.state.repostUri, testRepostUri);
    });

    group('toggleLike', () {
      blocTest<PostActionCubit, PostActionState>(
        'emits loading state then liked state when liking',
        build: () {
          when(
            () => mockRepository.likePost(
              uri: any(named: 'uri'),
              cid: any(named: 'cid'),
            ),
          ).thenAnswer((_) async => testLikeUri);
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            likeCount: 5,
          );
        },
        act: (cubit) => cubit.toggleLike(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isTrue)
              .having((s) => s.likeCount, 'likeCount', 6)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isTrue)
              .having((s) => s.error, 'error', isNull),
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isTrue)
              .having((s) => s.likeCount, 'likeCount', 6)
              .having((s) => s.likeUri, 'likeUri', testLikeUri)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isFalse),
        ],
      );

      blocTest<PostActionCubit, PostActionState>(
        'emits loading state then unliked state when unliking',
        build: () {
          when(() => mockRepository.unlikePost(likeUri: testLikeUri)).thenAnswer((_) async => {});
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            isLiked: true,
            likeCount: 5,
            likeUri: testLikeUri,
          );
        },
        act: (cubit) => cubit.toggleLike(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isFalse)
              .having((s) => s.likeCount, 'likeCount', 4)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isTrue),
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isFalse)
              .having((s) => s.likeCount, 'likeCount', 4)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isFalse),
        ],
      );

      blocTest<PostActionCubit, PostActionState>(
        'rolls back state on like failure',
        build: () {
          when(
            () => mockRepository.likePost(
              uri: any(named: 'uri'),
              cid: any(named: 'cid'),
            ),
          ).thenThrow(Exception('Network error'));
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            likeCount: 5,
          );
        },
        act: (cubit) => cubit.toggleLike(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isTrue)
              .having((s) => s.likeCount, 'likeCount', 6)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isTrue),
          isA<PostActionState>()
              .having((s) => s.isLiked, 'isLiked', isFalse)
              .having((s) => s.likeCount, 'likeCount', 5)
              .having((s) => s.isLoadingLike, 'isLoadingLike', isFalse)
              .having((s) => s.error, 'error', 'Failed to like post'),
        ],
      );

      blocTest<PostActionCubit, PostActionState>(
        'does nothing when already loading like',
        build: () => PostActionCubit(postActionRepository: mockRepository, postUri: testPostUri, postCid: testPostCid),
        seed: () => const PostActionState(postUri: testPostUri, isLoadingLike: true),
        act: (cubit) => cubit.toggleLike(),
        expect: () => [],
      );
    });

    group('toggleRepost', () {
      blocTest<PostActionCubit, PostActionState>(
        'emits loading state then reposted state when reposting',
        build: () {
          when(
            () => mockRepository.repostPost(
              uri: any(named: 'uri'),
              cid: any(named: 'cid'),
            ),
          ).thenAnswer((_) async => testRepostUri);
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            repostCount: 3,
          );
        },
        act: (cubit) => cubit.toggleRepost(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isTrue)
              .having((s) => s.repostCount, 'repostCount', 4)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isTrue),
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isTrue)
              .having((s) => s.repostCount, 'repostCount', 4)
              .having((s) => s.repostUri, 'repostUri', testRepostUri)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isFalse),
        ],
      );

      blocTest<PostActionCubit, PostActionState>(
        'emits loading state then unreposted state when unreposting',
        build: () {
          when(() => mockRepository.unrepostPost(repostUri: testRepostUri)).thenAnswer((_) async => {});
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            isReposted: true,
            repostCount: 3,
            repostUri: testRepostUri,
          );
        },
        act: (cubit) => cubit.toggleRepost(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isFalse)
              .having((s) => s.repostCount, 'repostCount', 2)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isTrue),
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isFalse)
              .having((s) => s.repostCount, 'repostCount', 2)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isFalse),
        ],
      );

      blocTest<PostActionCubit, PostActionState>(
        'rolls back state on repost failure',
        build: () {
          when(
            () => mockRepository.repostPost(
              uri: any(named: 'uri'),
              cid: any(named: 'cid'),
            ),
          ).thenThrow(Exception('Network error'));
          return PostActionCubit(
            postActionRepository: mockRepository,
            postUri: testPostUri,
            postCid: testPostCid,
            repostCount: 3,
          );
        },
        act: (cubit) => cubit.toggleRepost(),
        expect: () => [
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isTrue)
              .having((s) => s.repostCount, 'repostCount', 4)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isTrue),
          isA<PostActionState>()
              .having((s) => s.isReposted, 'isReposted', isFalse)
              .having((s) => s.repostCount, 'repostCount', 3)
              .having((s) => s.isLoadingRepost, 'isLoadingRepost', isFalse)
              .having((s) => s.error, 'error', 'Failed to repost post'),
        ],
      );
    });

    group('deletePost', () {
      blocTest<PostActionCubit, PostActionState>(
        'calls deletePost on repository',
        build: () {
          when(() => mockRepository.deletePost(postUri: testPostUri)).thenAnswer((_) async => {});
          return PostActionCubit(postActionRepository: mockRepository, postUri: testPostUri, postCid: testPostCid);
        },
        act: (cubit) => cubit.deletePost(),
        verify: (_) {
          verify(() => mockRepository.deletePost(postUri: testPostUri)).called(1);
        },
      );

      blocTest<PostActionCubit, PostActionState>(
        'emits error when delete fails',
        build: () {
          when(() => mockRepository.deletePost(postUri: testPostUri)).thenThrow(Exception('Network error'));
          return PostActionCubit(postActionRepository: mockRepository, postUri: testPostUri, postCid: testPostCid);
        },
        act: (cubit) => cubit.deletePost(),
        expect: () => [isA<PostActionState>().having((s) => s.error, 'error', 'Failed to delete post')],
      );
    });
  });

  group('PostActionState', () {
    test('props includes all fields', () {
      const state1 = PostActionState(
        postUri: testPostUri,
        isLiked: true,
        isReposted: false,
        likeCount: 5,
        repostCount: 3,
        likeUri: testLikeUri,
        repostUri: testRepostUri,
        isLoadingLike: true,
        isLoadingRepost: false,
        error: 'test error',
      );

      const state2 = PostActionState(
        postUri: testPostUri,
        isLiked: true,
        isReposted: false,
        likeCount: 5,
        repostCount: 3,
        likeUri: testLikeUri,
        repostUri: testRepostUri,
        isLoadingLike: true,
        isLoadingRepost: false,
        error: 'test error',
      );

      expect(state1, equals(state2));
    });

    test('copyWith creates new instance with updated values', () {
      const state = PostActionState(postUri: testPostUri, isLiked: false, likeCount: 0);

      final copied = state.copyWith(isLiked: true, likeCount: 1);

      expect(copied.isLiked, isTrue);
      expect(copied.likeCount, 1);
      expect(copied.postUri, testPostUri);
    });
  });
}
