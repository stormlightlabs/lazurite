import 'package:poptart_core/poptart_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/bookmark/get_bookmarks.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_likes.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_quotes.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_reposted_by.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_action_bar.dart';
import 'package:lazurite/features/search/data/search_scope.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class _FakePostActionRepository implements PostActionRepository {
  @override
  Future<void> createBookmark({required AtUri uri, required String cid}) async {}

  @override
  Future<void> deleteBookmark({required AtUri uri}) async {}

  @override
  Future<void> deletePost({required String postUri}) async {}

  @override
  Future<BookmarkGetBookmarksOutput> getBookmarks({int? limit, String? cursor}) async {
    return const BookmarkGetBookmarksOutput(bookmarks: []);
  }

  @override
  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    return FeedGetLikesOutput(uri: uri, likes: []);
  }

  @override
  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    return FeedGetRepostedByOutput(uri: uri, repostedBy: []);
  }

  @override
  Future<FeedGetQuotesOutput> getQuotes({required AtUri uri, String? cursor}) async {
    return FeedGetQuotesOutput(uri: uri, posts: []);
  }

  @override
  Future<String> likePost({required AtUri uri, required String cid}) async => 'at://did:plc:test/app.bsky.feed.like/1';

  @override
  Future<String> repostPost({required AtUri uri, required String cid}) async {
    return 'at://did:plc:test/app.bsky.feed.repost/1';
  }

  @override
  Future<void> unlikePost({required String likeUri}) async {}

  @override
  Future<void> unrepostPost({required String repostUri}) async {}
}

PostView _makePost({
  required String did,
  required String handle,
  required String rkey,
  required String text,
  int? replyCount,
  DateTime? createdAt,
}) {
  final time = createdAt ?? DateTime.utc(2026, 4, 14, 12);
  return PostView(
    uri: AtUri('at://$did/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: ProfileViewBasic(did: did, handle: handle),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': time.toIso8601String()},
    indexedAt: time,
    replyCount: replyCount,
  );
}

ThreadViewPost _makeThread({
  required String did,
  required String handle,
  required String rkey,
  required String text,
  int? replyCount,
  List<ThreadViewPost> replies = const [],
}) {
  return ThreadViewPost(
    post: _makePost(did: did, handle: handle, rkey: rkey, text: text, replyCount: replyCount),
    replies: replies.map((reply) => UThreadViewPostReplies.threadViewPost(data: reply)).toList(),
  );
}

SettingsState _settingsState({FeedLayout feedLayout = FeedLayout.comfortable}) {
  return SettingsState(
    themePalette: AppThemePalette.lazurite,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
    searchScope: SearchScope.both,
    feedLayout: feedLayout,
  );
}

void main() {
  late MockPostThreadRepository postThreadRepository;
  late MockSavedPostsCubit savedPostsCubit;
  late MockConnectivityCubit connectivityCubit;
  late MockSettingsCubit settingsCubit;
  final postActionRepository = _FakePostActionRepository();

  const postUri = 'at://did:plc:owner/app.bsky.feed.post/root';

  setUpAll(() {
    registerFallbackValue(
      _makePost(did: 'did:plc:fallback', handle: 'fallback.bsky.social', rkey: 'fallback', text: ''),
    );
  });

  setUp(() {
    postThreadRepository = MockPostThreadRepository();
    savedPostsCubit = MockSavedPostsCubit();
    connectivityCubit = MockConnectivityCubit();
    settingsCubit = MockSettingsCubit();

    const savedState = SavedPostsState(status: SavedPostsStatus.loaded, savedPosts: [], savedUris: {});
    when(() => savedPostsCubit.state).thenReturn(savedState);
    whenListen(savedPostsCubit, const Stream<SavedPostsState>.empty(), initialState: savedState);

    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );

    final settingsState = _settingsState();
    when(() => settingsCubit.state).thenReturn(settingsState);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: settingsState);
  });

  Widget createSubjectWidget({
    required String accountDid,
    required ThreadViewPost thread,
    required ValueSetter<ComposeRouteArgs> onComposeArgs,
    Object? composePopResult = true,
    bool stubThreadLoad = true,
  }) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PostThreadScreen(postUri: postUri),
        ),
        GoRoute(
          path: '/compose',
          builder: (context, state) {
            final args = state.extra as ComposeRouteArgs;
            onComposeArgs(args);
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('complete-edit'),
                  onPressed: () => Navigator.of(context).pop(composePopResult),
                  child: const Text('Complete Edit'),
                ),
              ),
            );
          },
        ),
      ],
    );

    if (stubThreadLoad) {
      when(() => postThreadRepository.getPostThread(postUri)).thenAnswer((_) async => thread);
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostThreadRepository>.value(value: postThreadRepository),
        RepositoryProvider<PostActionRepository>.value(value: postActionRepository),
        RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        RepositoryProvider<String>.value(value: accountDid),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SavedPostsCubit>.value(value: savedPostsCubit),
          BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('shows Edit Post only for the author and sends edit payload to compose', (tester) async {
    ComposeRouteArgs? capturedArgs;
    final thread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Original post body',
    );

    await tester.pumpWidget(
      createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (args) => capturedArgs = args),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Post'), findsOneWidget);

    await tester.tap(find.text('Edit Post'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('complete-edit')), findsOneWidget);
    expect(capturedArgs, isNotNull);
    expect(capturedArgs!.editPostUri, postUri);
    expect(capturedArgs!.editPostCid, 'cid-root');
    expect(capturedArgs!.initialText, 'Original post body');
    expect(capturedArgs!.editRecord?['text'], 'Original post body');
  });

  testWidgets('focused thread post uses compact card when compact feed layout is selected', (tester) async {
    final compactSettingsState = _settingsState(feedLayout: FeedLayout.compact);
    when(() => settingsCubit.state).thenReturn(compactSettingsState);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: compactSettingsState);

    final thread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Compact focused thread post',
    );

    await tester.pumpWidget(createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Compact focused thread post', findRichText: true), findsOneWidget);
    expect(find.byType(CompactPostCard), findsOneWidget);
    expect(find.byType(PostCard), findsNothing);
  });

  testWidgets('does not show Edit Post when viewing someone else\'s post', (tester) async {
    final thread = _makeThread(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      rkey: 'root',
      text: 'Other user post',
    );

    await tester.pumpWidget(createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Post'), findsNothing);
  });

  testWidgets('reloads thread after edit flow returns success', (tester) async {
    final thread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Original post body',
    );

    await tester.pumpWidget(createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (_) {}));
    await tester.pumpAndSettle();

    verify(() => postThreadRepository.getPostThread(postUri)).called(1);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Post'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('complete-edit')));
    await tester.pumpAndSettle();

    verify(() => postThreadRepository.getPostThread(postUri)).called(1);
  });

  testWidgets('reloads thread after reply flow returns posted result', (tester) async {
    final initialThread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Original post body',
      replyCount: 0,
    );
    final refreshedThread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Original post body',
      replyCount: 1,
      replies: [_makeThread(did: 'did:plc:replier', handle: 'replier.bsky.social', rkey: 'child', text: 'New reply')],
    );

    var loadCount = 0;
    when(() => postThreadRepository.getPostThread(postUri)).thenAnswer((_) async {
      loadCount += 1;
      return loadCount >= 2 ? refreshedThread : initialThread;
    });

    await tester.pumpWidget(
      createSubjectWidget(
        accountDid: 'did:plc:owner',
        thread: initialThread,
        onComposeArgs: (_) {},
        composePopResult: {'status': 'posted', 'isReply': true, 'replyParentUri': postUri, 'replyRootUri': postUri},
        stubThreadLoad: false,
      ),
    );
    await tester.pumpAndSettle();

    verify(() => postThreadRepository.getPostThread(postUri)).called(1);

    await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('complete-edit')));
    await tester.pumpAndSettle();

    expect(loadCount, greaterThanOrEqualTo(2));
  });

  testWidgets('pull to refresh reloads the thread', (tester) async {
    final thread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Refreshable post body',
    );

    await tester.pumpWidget(createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (_) {}));
    await tester.pumpAndSettle();

    verify(() => postThreadRepository.getPostThread(postUri)).called(1);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => postThreadRepository.getPostThread(postUri)).called(1);
  });

  testWidgets('focused post save sheet can save to Bluesky', (tester) async {
    final thread = _makeThread(
      did: 'did:plc:owner',
      handle: 'owner.bsky.social',
      rkey: 'root',
      text: 'Cloud-saveable post body',
    );
    when(() => savedPostsCubit.cloudSave(any())).thenAnswer((_) async => true);

    await tester.pumpWidget(createSubjectWidget(accountDid: 'did:plc:owner', thread: thread, onComposeArgs: (_) {}));
    await tester.pumpAndSettle();

    expect(tester.widget<PostActionBar>(find.byType(PostActionBar)).onCloudSave, isNotNull);

    await tester.tap(
      find.descendant(of: find.byType(PostActionBar), matching: find.byIcon(Icons.bookmark_outline)).first,
    );
    await tester.pumpAndSettle();

    final cloudTile = find.widgetWithText(ListTile, 'Save to Bluesky');
    expect(tester.widget<ListTile>(cloudTile).onTap, isNotNull);

    await tester.tap(cloudTile);
    await tester.pumpAndSettle();

    verify(
      () => savedPostsCubit.cloudSave(any(that: isA<PostView>().having((post) => post.uri.toString(), 'uri', postUri))),
    ).called(1);
  });
}
