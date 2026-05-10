import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

PostView _makePost({
  required String did,
  required String handle,
  required String rkey,
  required String text,
  DateTime? createdAt,
}) {
  final time = createdAt ?? DateTime.utc(2026, 3, 15, 12);
  return PostView(
    uri: AtUri('at://$did/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: ProfileViewBasic(did: did, handle: handle),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': time.toIso8601String()},
    indexedAt: time,
  );
}

ThreadViewPost _makeThread({
  required String did,
  required String handle,
  required String rkey,
  required String text,
  List<ThreadViewPost> replies = const [],
  ThreadViewPost? parent,
}) {
  return ThreadViewPost(
    post: _makePost(did: did, handle: handle, rkey: rkey, text: text),
    parent: parent == null ? null : UThreadViewPostParent.threadViewPost(data: parent),
    replies: replies.map((reply) => UThreadViewPostReplies.threadViewPost(data: reply)).toList(),
  );
}

class _ReplyTreeHarness extends StatefulWidget {
  const _ReplyTreeHarness({
    required this.thread,
    required this.savedPostsCubit,
    required this.postActionRepository,
    required this.connectivityCubit,
    this.initialCollapsedUris = const <String>{},
    this.onContinueThread,
  });

  final ThreadViewPost thread;
  final SavedPostsCubit savedPostsCubit;
  final PostActionRepository postActionRepository;
  final ConnectivityCubit connectivityCubit;
  final Set<String> initialCollapsedUris;
  final ValueChanged<ThreadViewPost>? onContinueThread;

  @override
  State<_ReplyTreeHarness> createState() => _ReplyTreeHarnessState();
}

class _ReplyTreeHarnessState extends State<_ReplyTreeHarness> {
  late Set<String> collapsedUris;

  @override
  void initState() {
    super.initState();
    collapsedUris = {...widget.initialCollapsedUris};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PostActionRepository>.value(value: widget.postActionRepository),
          RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        ],
        child: BlocProvider<SavedPostsCubit>.value(
          value: widget.savedPostsCubit,
          child: BlocProvider<ConnectivityCubit>.value(
            value: widget.connectivityCubit,
            child: Scaffold(
              body: SingleChildScrollView(
                child: ThreadReplyNode(
                  thread: widget.thread,
                  depth: 1,
                  accountDid: 'did:plc:current',
                  opDid: 'did:plc:op',
                  collapsedUris: collapsedUris,
                  onToggleCollapse: (postUri) {
                    setState(() {
                      if (collapsedUris.contains(postUri)) {
                        collapsedUris.remove(postUri);
                      } else {
                        collapsedUris.add(postUri);
                      }
                    });
                  },
                  onContinueThread: widget.onContinueThread,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockPostActionRepository mockPostActionRepository;
  late MockSavedPostsCubit mockSavedPostsCubit;
  late MockConnectivityCubit mockConnectivityCubit;

  setUp(() {
    mockPostActionRepository = MockPostActionRepository();
    mockSavedPostsCubit = MockSavedPostsCubit();
    mockConnectivityCubit = MockConnectivityCubit();

    const savedState = SavedPostsState(status: SavedPostsStatus.loaded, savedPosts: [], savedUris: {});
    when(() => mockSavedPostsCubit.state).thenReturn(savedState);
    whenListen(mockSavedPostsCubit, const Stream<SavedPostsState>.empty(), initialState: savedState);
    when(() => mockConnectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      mockConnectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
  });

  testWidgets('renders nested threaded replies recursively', (tester) async {
    final grandchild = _makeThread(
      did: 'did:plc:grandchild',
      handle: 'grandchild.bsky.social',
      rkey: 'grandchild',
      text: 'Grandchild reply',
    );
    final child = _makeThread(
      did: 'did:plc:child',
      handle: 'child.bsky.social',
      rkey: 'child',
      text: 'Child reply',
      replies: [grandchild],
    );
    final parent = _makeThread(
      did: 'did:plc:parent',
      handle: 'parent.bsky.social',
      rkey: 'parent',
      text: 'Parent reply',
      replies: [child],
    );

    await tester.pumpWidget(
      _ReplyTreeHarness(
        thread: parent,
        savedPostsCubit: mockSavedPostsCubit,
        postActionRepository: mockPostActionRepository,
        connectivityCubit: mockConnectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parent reply', findRichText: true), findsOneWidget);
    expect(find.text('Child reply', findRichText: true), findsOneWidget);
    expect(find.text('Grandchild reply', findRichText: true), findsOneWidget);
    expect(find.byKey(ValueKey('threadline-${parent.post.uri}')), findsOneWidget);
    expect(find.byKey(ValueKey('threadline-${child.post.uri}')), findsOneWidget);
  });

  testWidgets('tapping the threadline collapses and expands a subtree', (tester) async {
    final grandchild = _makeThread(
      did: 'did:plc:grandchild',
      handle: 'grandchild.bsky.social',
      rkey: 'grandchild',
      text: 'Grandchild reply',
    );
    final child = _makeThread(
      did: 'did:plc:child',
      handle: 'child.bsky.social',
      rkey: 'child',
      text: 'Child reply',
      replies: [grandchild],
    );
    final parent = _makeThread(
      did: 'did:plc:parent',
      handle: 'parent.bsky.social',
      rkey: 'parent',
      text: 'Parent reply',
      replies: [child],
    );

    await tester.pumpWidget(
      _ReplyTreeHarness(
        thread: parent,
        savedPostsCubit: mockSavedPostsCubit,
        postActionRepository: mockPostActionRepository,
        connectivityCubit: mockConnectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('threadline-${parent.post.uri}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Parent reply', findRichText: true), findsNothing);
    expect(find.text('Child reply', findRichText: true), findsNothing);
    expect(find.text('Grandchild reply', findRichText: true), findsNothing);
    expect(find.text('2 REPLIES HIDDEN'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('threadline-${parent.post.uri}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Parent reply', findRichText: true), findsOneWidget);
    expect(find.text('Child reply', findRichText: true), findsOneWidget);
    expect(find.text('Grandchild reply', findRichText: true), findsOneWidget);
  });

  testWidgets('long-pressing a reply body collapses the subtree', (tester) async {
    final child = _makeThread(did: 'did:plc:child', handle: 'child.bsky.social', rkey: 'child', text: 'Child reply');
    final parent = _makeThread(
      did: 'did:plc:parent',
      handle: 'parent.bsky.social',
      rkey: 'parent',
      text: 'Parent reply',
      replies: [child],
    );

    await tester.pumpWidget(
      _ReplyTreeHarness(
        thread: parent,
        savedPostsCubit: mockSavedPostsCubit,
        postActionRepository: mockPostActionRepository,
        connectivityCubit: mockConnectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Parent reply', findRichText: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Parent reply', findRichText: true), findsNothing);
    expect(find.text('Child reply', findRichText: true), findsNothing);
    expect(find.text('1 REPLY HIDDEN'), findsOneWidget);
  });

  testWidgets('shows a continue link when replies exceed depth 4', (tester) async {
    final depth5 = _makeThread(did: 'did:plc:depth5', handle: 'depth5.bsky.social', rkey: 'depth5', text: 'Depth 5');
    final depth4 = _makeThread(
      did: 'did:plc:depth4',
      handle: 'depth4.bsky.social',
      rkey: 'depth4',
      text: 'Depth 4',
      replies: [depth5],
    );
    final depth3 = _makeThread(
      did: 'did:plc:depth3',
      handle: 'depth3.bsky.social',
      rkey: 'depth3',
      text: 'Depth 3',
      replies: [depth4],
    );
    final depth2 = _makeThread(
      did: 'did:plc:depth2',
      handle: 'depth2.bsky.social',
      rkey: 'depth2',
      text: 'Depth 2',
      replies: [depth3],
    );
    final depth1 = _makeThread(
      did: 'did:plc:depth1',
      handle: 'depth1.bsky.social',
      rkey: 'depth1',
      text: 'Depth 1',
      replies: [depth2],
    );

    ThreadViewPost? continuedThread;

    await tester.pumpWidget(
      _ReplyTreeHarness(
        thread: depth1,
        savedPostsCubit: mockSavedPostsCubit,
        postActionRepository: mockPostActionRepository,
        connectivityCubit: mockConnectivityCubit,
        onContinueThread: (thread) => continuedThread = thread,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Depth 1', findRichText: true), findsOneWidget);
    expect(find.text('Depth 2', findRichText: true), findsOneWidget);
    expect(find.text('Depth 3', findRichText: true), findsOneWidget);
    expect(find.text('Depth 4', findRichText: true), findsNothing);
    expect(find.text('Depth 5', findRichText: true), findsNothing);
    expect(find.text('Continue this thread →'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Continue this thread →'), 200);
    await tester.tap(find.text('Continue this thread →'));
    await tester.pumpAndSettle();

    expect(continuedThread?.post.uri.toString(), depth4.post.uri.toString());
  });

  test('computeInitialCollapsedThreadUris skips OP replies and leaves shallow branches expanded', () {
    final leaf = _makeThread(did: 'did:plc:leaf', handle: 'leaf.bsky.social', rkey: 'leaf', text: 'Leaf');
    final deepBranch = _makeThread(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      rkey: 'deep-branch',
      text: 'Deep branch',
      replies: [leaf],
    );
    final opBranch = _makeThread(
      did: 'did:plc:op',
      handle: 'op.bsky.social',
      rkey: 'op-branch',
      text: 'OP branch',
      replies: [leaf],
    );
    final depth2 = _makeThread(
      did: 'did:plc:user2',
      handle: 'user2.bsky.social',
      rkey: 'depth2',
      text: 'Depth 2',
      replies: [deepBranch, opBranch],
    );
    final depth1 = _makeThread(
      did: 'did:plc:user1',
      handle: 'user1.bsky.social',
      rkey: 'depth1',
      text: 'Depth 1',
      replies: [depth2],
    );
    final root = _makeThread(
      did: 'did:plc:op',
      handle: 'op.bsky.social',
      rkey: 'root',
      text: 'Root',
      replies: [depth1],
    );

    final collapsedUris = computeInitialCollapsedThreadUris(root, autoCollapseDepth: 2);

    expect(collapsedUris, contains(deepBranch.post.uri.toString()));
    expect(collapsedUris, isNot(contains(opBranch.post.uri.toString())));
    expect(collapsedUris, isNot(contains(leaf.post.uri.toString())));
    expect(collapsedUris, isNot(contains(depth2.post.uri.toString())));
  });

  testWidgets('initial collapsed URIs hide deep non-OP branches on first render', (tester) async {
    final hiddenLeaf = _makeThread(
      did: 'did:plc:hidden-leaf',
      handle: 'hidden-leaf.bsky.social',
      rkey: 'hidden-leaf',
      text: 'Hidden leaf',
    );
    final visibleLeaf = _makeThread(
      did: 'did:plc:visible-leaf',
      handle: 'visible-leaf.bsky.social',
      rkey: 'visible-leaf',
      text: 'Visible leaf',
    );
    final hiddenBranch = _makeThread(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      rkey: 'hidden-branch',
      text: 'Hidden branch',
      replies: [hiddenLeaf],
    );
    final opBranch = _makeThread(
      did: 'did:plc:op',
      handle: 'op.bsky.social',
      rkey: 'op-branch',
      text: 'OP branch',
      replies: [visibleLeaf],
    );
    final depth2 = _makeThread(
      did: 'did:plc:user2',
      handle: 'user2.bsky.social',
      rkey: 'depth2',
      text: 'Depth 2',
      replies: [hiddenBranch, opBranch],
    );
    final depth1 = _makeThread(
      did: 'did:plc:user1',
      handle: 'user1.bsky.social',
      rkey: 'depth1',
      text: 'Depth 1',
      replies: [depth2],
    );
    final root = _makeThread(
      did: 'did:plc:op',
      handle: 'op.bsky.social',
      rkey: 'root',
      text: 'Root',
      replies: [depth1],
    );

    await tester.pumpWidget(
      _ReplyTreeHarness(
        thread: depth1,
        savedPostsCubit: mockSavedPostsCubit,
        postActionRepository: mockPostActionRepository,
        connectivityCubit: mockConnectivityCubit,
        initialCollapsedUris: computeInitialCollapsedThreadUris(root, autoCollapseDepth: 2),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hidden branch', findRichText: true), findsNothing);
    expect(find.text('Hidden leaf', findRichText: true), findsNothing);
    expect(find.text('1 REPLY HIDDEN'), findsOneWidget);
    expect(find.text('OP branch', findRichText: true), findsOneWidget);
    expect(find.text('Visible leaf', findRichText: true), findsNothing);
    expect(find.byKey(ValueKey('continue-thread-${visibleLeaf.post.uri}')), findsOneWidget);
  });
}
