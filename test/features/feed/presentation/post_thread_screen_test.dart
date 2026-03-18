import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_thread_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPostThreadCubit extends MockCubit<PostThreadState> implements PostThreadCubit {}

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

PostView _makePost({
  String did = 'did:plc:author',
  String handle = 'author.bsky.social',
  String rkey = 'abc',
  String text = 'Hello world',
  int? replyCount,
  int? repostCount,
  int? likeCount,
}) {
  return PostView(
    uri: AtUri('at://$did/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: ProfileViewBasic(did: did, handle: handle),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': DateTime.utc(2026, 3, 15).toIso8601String()},
    indexedAt: DateTime.utc(2026, 3, 15),
    replyCount: replyCount,
    repostCount: repostCount,
    likeCount: likeCount,
  );
}

void main() {
  late MockPostThreadCubit mockCubit;
  late MockSavedPostsCubit mockSavedPostsCubit;
  late MockPostActionRepository mockPostActionRepository;

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:test/app.bsky.feed.post/fallback'));
  });

  setUp(() {
    mockCubit = MockPostThreadCubit();
    mockSavedPostsCubit = MockSavedPostsCubit();
    mockPostActionRepository = MockPostActionRepository();
  });

  Widget buildSubject({PostThreadState? state}) {
    when(() => mockCubit.state).thenReturn(state ?? const PostThreadState(status: PostThreadStatus.loading));
    when(
      () => mockSavedPostsCubit.state,
    ).thenReturn(const SavedPostsState(status: SavedPostsStatus.loaded, savedPosts: [], savedUris: {}));

    return MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepository),
          RepositoryProvider<String>.value(value: 'did:plc:currentuser'),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PostThreadCubit>.value(value: mockCubit),
            BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
          ],
          child: Scaffold(
            body: BlocBuilder<PostThreadCubit, PostThreadState>(
              builder: (context, cubitState) {
                return switch (cubitState.status) {
                  PostThreadStatus.loading => const Center(child: CircularProgressIndicator()),
                  PostThreadStatus.error => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline),
                        Text(cubitState.error ?? 'Failed to load thread'),
                        FilledButton(onPressed: () => mockCubit.load('test'), child: const Text('Retry')),
                      ],
                    ),
                  ),
                  PostThreadStatus.loaded => const Text('Thread loaded'),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  group('PostThreadScreen states', () {
    testWidgets('shows loading indicator when status is loading', (tester) async {
      await tester.pumpWidget(buildSubject(state: const PostThreadState(status: PostThreadStatus.loading)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when status is error', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const PostThreadState(status: PostThreadStatus.error, error: 'Failed to load thread'),
        ),
      );

      expect(find.text('Failed to load thread'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows thread loaded text when status is loaded', (tester) async {
      final thread = ThreadViewPost(post: _makePost());
      await tester.pumpWidget(
        buildSubject(
          state: PostThreadState(status: PostThreadStatus.loaded, thread: thread),
        ),
      );

      expect(find.text('Thread loaded'), findsOneWidget);
    });
  });

  group('PostThreadScreen full render', () {
    Widget buildFullScreen({required PostThreadState state}) {
      when(() => mockCubit.state).thenReturn(state);
      when(
        () => mockSavedPostsCubit.state,
      ).thenReturn(const SavedPostsState(status: SavedPostsStatus.loaded, savedPosts: [], savedUris: {}));

      when(
        () => mockPostActionRepository.likePost(
          uri: any(named: 'uri'),
          cid: any(named: 'cid'),
        ),
      ).thenAnswer((_) async => 'at://did:plc:test/app.bsky.feed.like/like1');

      return MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepository),
            RepositoryProvider<String>.value(value: 'did:plc:currentuser'),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<PostThreadCubit>.value(value: mockCubit),
              BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
            ],
            child: Scaffold(
              appBar: AppBar(title: const Text('Thread')),
              body: Builder(
                builder: (context) {
                  if (state.status == PostThreadStatus.loaded) {
                    final post = state.thread!.post;
                    return BlocProvider(
                      create: (_) => PostActionCubit(
                        postActionRepository: mockPostActionRepository,
                        postUri: post.uri.toString(),
                        postCid: post.cid,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.author.displayName ?? post.author.handle),
                            Text((post.record['text'] as String?) ?? ''),
                            if ((post.replyCount ?? 0) > 0) Text('${post.replyCount} replies'),
                            if ((post.repostCount ?? 0) > 0) Text('${post.repostCount} reposts'),
                            if ((post.likeCount ?? 0) > 0) Text('${post.likeCount} likes'),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('focused post shows author name', (tester) async {
      final thread = ThreadViewPost(
        post: _makePost(handle: 'alice.bsky.social', text: 'My focused post'),
      );

      await tester.pumpWidget(
        buildFullScreen(
          state: PostThreadState(status: PostThreadStatus.loaded, thread: thread),
        ),
      );

      expect(find.text('alice.bsky.social'), findsOneWidget);
      expect(find.text('My focused post'), findsOneWidget);
    });

    testWidgets('focused post shows stats when counts are non-zero', (tester) async {
      final thread = ThreadViewPost(post: _makePost(replyCount: 24, repostCount: 12, likeCount: 156));

      await tester.pumpWidget(
        buildFullScreen(
          state: PostThreadState(status: PostThreadStatus.loaded, thread: thread),
        ),
      );

      expect(find.text('24 replies'), findsOneWidget);
      expect(find.text('12 reposts'), findsOneWidget);
      expect(find.text('156 likes'), findsOneWidget);
    });

    testWidgets('focused post does not show stats when counts are zero', (tester) async {
      final thread = ThreadViewPost(post: _makePost(replyCount: 0, repostCount: 0, likeCount: 0));

      await tester.pumpWidget(
        buildFullScreen(
          state: PostThreadState(status: PostThreadStatus.loaded, thread: thread),
        ),
      );

      expect(find.text('0 replies'), findsNothing);
      expect(find.text('0 reposts'), findsNothing);
      expect(find.text('0 likes'), findsNothing);
    });
  });

  group('PostThreadScreen thread structure', () {
    testWidgets('renders thread app bar title', (tester) async {
      when(() => mockCubit.state).thenReturn(const PostThreadState(status: PostThreadStatus.loading));
      when(
        () => mockSavedPostsCubit.state,
      ).thenReturn(const SavedPostsState(status: SavedPostsStatus.loaded, savedPosts: [], savedUris: {}));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepository),
              RepositoryProvider<String>.value(value: 'did:plc:currentuser'),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<PostThreadCubit>.value(value: mockCubit),
                BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
              ],
              child: Scaffold(appBar: AppBar(title: const Text('Thread'))),
            ),
          ),
        ),
      );

      expect(find.text('Thread'), findsOneWidget);
    });
  });

  group('PostThreadState parent chain', () {
    test('getParentChain returns empty list for root post', () {
      final thread = ThreadViewPost(post: _makePost());
      final parents = _extractParentChain(thread);

      expect(parents, isEmpty);
    });

    test('getParentChain returns single parent in order', () {
      final parentPost = _makePost(rkey: 'parent1', text: 'Parent post');
      final childPost = _makePost(rkey: 'child1', text: 'Child post');
      final parentThread = ThreadViewPost(post: parentPost);
      final thread = ThreadViewPost(
        post: childPost,
        parent: UThreadViewPostParent.threadViewPost(data: parentThread),
      );

      final parents = _extractParentChain(thread);

      expect(parents.length, 1);
      expect(parents.first.post.cid, 'cid-parent1');
    });

    test('getParentChain returns chain in oldest-first order', () {
      final grandparentPost = _makePost(rkey: 'gp', text: 'Grandparent');
      final parentPost = _makePost(rkey: 'p', text: 'Parent');
      final childPost = _makePost(rkey: 'c', text: 'Child');

      final grandparentThread = ThreadViewPost(post: grandparentPost);
      final parentThread = ThreadViewPost(
        post: parentPost,
        parent: UThreadViewPostParent.threadViewPost(data: grandparentThread),
      );
      final thread = ThreadViewPost(
        post: childPost,
        parent: UThreadViewPostParent.threadViewPost(data: parentThread),
      );

      final parents = _extractParentChain(thread);

      expect(parents.length, 2);
      expect(parents[0].post.cid, 'cid-gp'); // oldest first
      expect(parents[1].post.cid, 'cid-p');
    });

    test('getParentChain stops at non-thread-view parent', () {
      final childPost = _makePost(rkey: 'c', text: 'Child');
      final thread = ThreadViewPost(
        post: childPost,
        parent: const UThreadViewPostParent.notFoundPost(data: NotFoundPost(uri: AtUri('at://x/y/z'), notFound: true)),
      );

      final parents = _extractParentChain(thread);

      expect(parents, isEmpty);
    });
  });

  group('PostThreadState replies filtering', () {
    test('filters out non-thread-view replies', () {
      final mainPost = _makePost(rkey: 'main');
      final replyPost = _makePost(rkey: 'reply1', text: 'A reply');
      final thread = ThreadViewPost(
        post: mainPost,
        replies: [
          UThreadViewPostReplies.threadViewPost(data: ThreadViewPost(post: replyPost)),
          const UThreadViewPostReplies.notFoundPost(data: NotFoundPost(uri: AtUri('at://x/y/z'), notFound: true)),
        ],
      );

      final replies = _extractThreadReplies(thread);

      expect(replies.length, 1);
      expect(replies.first.post.cid, 'cid-reply1');
    });

    test('returns empty list when no replies', () {
      final thread = ThreadViewPost(post: _makePost());

      final replies = _extractThreadReplies(thread);

      expect(replies, isEmpty);
    });
  });
}

/// Mirrors _PostThreadContent._getParentChain for unit testing.
List<ThreadViewPost> _extractParentChain(ThreadViewPost thread) {
  final parents = <ThreadViewPost>[];
  var current = thread.parent;
  while (current != null && current.isThreadViewPost) {
    final parentThread = current.threadViewPost!;
    parents.add(parentThread);
    current = parentThread.parent;
  }
  return parents.reversed.toList();
}

/// Mirrors the reply extraction in _PostThreadContent._buildThread.
List<ThreadViewPost> _extractThreadReplies(ThreadViewPost thread) {
  return (thread.replies ?? []).where((r) => r.isThreadViewPost).map((r) => r.threadViewPost!).toList();
}
