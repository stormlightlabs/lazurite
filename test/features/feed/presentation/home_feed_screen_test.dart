import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/widgets/feed_layout_view.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/connectivity_helpers.dart';
import '../../../helpers/fixtures/feed.dart';

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

SettingsState _settingsState(FeedLayout architecture) => SettingsState(
  themePalette: AppThemePalette.oxocarbon,
  themeVariant: AppThemeVariant.dark,
  useSystemTheme: false,
  feedLayout: architecture,
);

const _homeFeedState = FeedPreferencesState.loaded(
  feeds: [
    SavedFeed(
      id: 'timeline',
      type: SavedFeedType.knownValue(data: KnownSavedFeedType.timeline),
      value: 'timeline',
      pinned: true,
    ),
  ],
);

Widget _buildSubject({required FeedLayout architecture, double screenWidth = 400, int itemCount = 3}) {
  final cubit = MockSettingsCubit();
  when(() => cubit.state).thenReturn(_settingsState(architecture));

  return MediaQuery(
    data: MediaQueryData(size: Size(screenWidth, 800)),
    child: MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: FeedLayoutView(
            itemCount: itemCount,
            scrollController: ScrollController(),
            isLoadingMore: false,
            onRefresh: () async {},
            gridItemBuilder: (_, i) => SizedBox(key: ValueKey('grid-$i'), child: Text('grid $i')),
            linearItemBuilder: (_, i) => SizedBox(key: ValueKey('linear-$i'), child: Text('linear $i')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  Widget buildHomeSubject({
    required FeedPreferencesCubit feedPreferencesCubit,
    required FeedRepository feedRepository,
    ConnectivityState connectivityState = const ConnectivityState.online(),
  }) {
    final connectivityCubit = MockConnectivityCubit();
    final settingsCubit = MockSettingsCubit();
    final authBloc = MockAuthBloc();
    final postActionRepository = MockPostActionRepository();
    final savedPostsCubit = MockSavedPostsCubit();
    stubConnectivityCubit(connectivityCubit, state: connectivityState);
    when(() => settingsCubit.state).thenReturn(_settingsState(FeedLayout.comfortable));
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: _settingsState(FeedLayout.comfortable),
    );
    when(() => savedPostsCubit.state).thenReturn(const SavedPostsState());
    whenListen(savedPostsCubit, const Stream<SavedPostsState>.empty(), initialState: const SavedPostsState());
    when(() => authBloc.state).thenReturn(
      const AuthState.authenticated(AuthTokens(accessToken: 'access', did: 'did:plc:test', handle: 'test.bsky.social')),
    );
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticated(
        AuthTokens(accessToken: 'access', did: 'did:plc:test', handle: 'test.bsky.social'),
      ),
    );

    return MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<FeedRepository>.value(value: feedRepository),
          RepositoryProvider<PostActionRepository>.value(value: postActionRepository),
          RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            BlocProvider<SavedPostsCubit>.value(value: savedPostsCubit),
          ],
          child: const HomeFeedScreen(),
        ),
      ),
    );
  }

  group('feedColumnCount', () {
    test('returns 1 column for width < 600', () {
      expect(feedColumnCount(599), 1);
      expect(feedColumnCount(400), 1);
      expect(feedColumnCount(0), 1);
    });

    test('returns 2 columns for width 600–839', () {
      expect(feedColumnCount(600), 2);
      expect(feedColumnCount(720), 2);
      expect(feedColumnCount(839), 2);
    });

    test('returns 3 columns for width 840–1199', () {
      expect(feedColumnCount(840), 3);
      expect(feedColumnCount(1000), 3);
      expect(feedColumnCount(1199), 3);
    });

    test('returns 4 columns for width >= 1200', () {
      expect(feedColumnCount(1200), 4);
      expect(feedColumnCount(1600), 4);
    });
  });

  group('FeedLayoutView — compact architecture', () {
    testWidgets('shows compact sliver list when layout is compact', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.compact, screenWidth: 720));
      expect(find.byType(SliverGrid), findsNothing);
      expect(find.byType(SliverList), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      final refresh = tester.widget<AnimatedRefreshIndicator>(find.byType(AnimatedRefreshIndicator));
      expect(refresh.showCornerSpinner, isFalse);
    });

    testWidgets('uses compact item builder in compact mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.compact));
      expect(find.text('grid 0'), findsOneWidget);
      expect(find.text('linear 0'), findsNothing);
    });

    testWidgets('uses compact padding in compact mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.compact, screenWidth: 400));

      final padding = tester.widget<SliverPadding>(find.byType(SliverPadding));
      expect(padding.padding, const EdgeInsets.fromLTRB(8, 4, 8, 8));
    });
  });

  group('FeedLayoutView — card architecture', () {
    testWidgets('shows ListView when layout is card', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.comfortable));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SliverGrid), findsNothing);
      final refresh = tester.widget<AnimatedRefreshIndicator>(find.byType(AnimatedRefreshIndicator));
      expect(refresh.showCornerSpinner, isFalse);
    });

    testWidgets('uses card item builder in card mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.comfortable));

      expect(find.text('linear 0'), findsOneWidget);
      expect(find.text('linear 1'), findsOneWidget);
      expect(find.text('linear 2'), findsOneWidget);
    });

    testWidgets('uses tighter vertical spacing in card mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedLayout.comfortable));

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.symmetric(vertical: 4));
    });

    testWidgets('wraps rendered rows in repaint boundaries with stable keys', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(_settingsState(FeedLayout.comfortable));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<SettingsCubit>.value(
              value: cubit,
              child: FeedLayoutView(
                itemCount: 1,
                scrollController: ScrollController(),
                isLoadingMore: false,
                onRefresh: () async {},
                itemKeyBuilder: (index) => ValueKey('post-$index'),
                gridItemBuilder: (_, i) => Text('grid $i'),
                linearItemBuilder: (_, i) => Text('linear $i'),
              ),
            ),
          ),
        ),
      );

      final keyedRow = find.byKey(const ValueKey('post-0'));
      expect(keyedRow, findsOneWidget);
      expect(find.descendant(of: keyedRow, matching: find.byType(RepaintBoundary)), findsOneWidget);
    });
  });

  group('FeedLayoutView — architecture switching', () {
    testWidgets('switches from compact to card without re-fetch', (tester) async {
      final cubit = MockSettingsCubit();
      final streamController = StreamController<SettingsState>.broadcast();

      when(() => cubit.state).thenReturn(_settingsState(FeedLayout.compact));
      when(() => cubit.stream).thenAnswer((_) => streamController.stream);

      var buildCount = 0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(720, 800)),
          child: MaterialApp(
            home: Scaffold(
              body: BlocProvider<SettingsCubit>.value(
                value: cubit,
                child: FeedLayoutView(
                  itemCount: 1,
                  scrollController: ScrollController(),
                  isLoadingMore: false,
                  onRefresh: () async => buildCount++,
                  gridItemBuilder: (_, i) => const Text('grid'),
                  linearItemBuilder: (_, i) => const Text('linear'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SliverList), findsOneWidget);

      when(() => cubit.state).thenReturn(_settingsState(FeedLayout.comfortable));
      streamController.add(_settingsState(FeedLayout.comfortable));
      await tester.pump();

      expect(find.byType(CustomScrollView), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(buildCount, 0);

      await streamController.close();
    });

    testWidgets('loading indicator appears when isLoadingMore is true in compact mode', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(_settingsState(FeedLayout.compact));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: Scaffold(
              body: BlocProvider<SettingsCubit>.value(
                value: cubit,
                child: FeedLayoutView(
                  itemCount: 0,
                  scrollController: ScrollController(),
                  isLoadingMore: true,
                  onRefresh: () async {},
                  gridItemBuilder: (_, i) => const Text('item'),
                  linearItemBuilder: (_, i) => const Text('item'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading indicator appears when isLoadingMore is true in card mode', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(_settingsState(FeedLayout.comfortable));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: Scaffold(
              body: BlocProvider<SettingsCubit>.value(
                value: cubit,
                child: FeedLayoutView(
                  itemCount: 1,
                  scrollController: ScrollController(),
                  isLoadingMore: true,
                  onRefresh: () async {},
                  gridItemBuilder: (_, i) => const Text('item'),
                  linearItemBuilder: (_, i) => const Text('item'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('HomeFeedScreen', () {
    testWidgets('shows trending and feeds actions without the messages shortcut in the app bar', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();
      final completer = Completer<FeedResult>();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pump();

      expect(find.byType(AppScreenEntrance), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.rss_feed), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    });

    testWidgets('uses a non-default compose hero tag', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();
      final completer = Completer<FeedResult>();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pump();

      final fab = tester
          .widgetList<FloatingActionButton>(find.byType(FloatingActionButton))
          .firstWhere((candidate) => candidate.heroTag == 'home-compose-fab');
      expect(fab.heroTag, 'home-compose-fab');
    });

    testWidgets('shows a left jump-to-top FAB', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: const []));

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Jump to top'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });

    testWidgets('keeps floating buttons equally inset from horizontal edges', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: const []));

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pumpAndSettle();

      final jumpRect = tester.getRect(find.byTooltip('Jump to top'));
      final composeRect = tester.getRect(find.byTooltip('Compose'));
      final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;

      expect(jumpRect.left, moreOrLessEquals(screenWidth - composeRect.right, epsilon: 0.1));
    });

    testWidgets('caps the initially rendered feed window for large result sets', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();
      final posts = List.generate(
        400,
        (index) => testFeedViewPost(
          uri: 'at://did:plc:author/app.bsky.feed.post/$index',
          record: testPostRecordJson(text: 'Post $index'),
        ),
      );

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: posts, cursor: 'cursor-1'));

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView));
      final delegate = listView.childrenDelegate as SliverChildBuilderDelegate;
      expect(delegate.estimatedChildCount, 320);
    });

    testWidgets('re-tapping selected feed tab reloads the feed', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedResult(posts: const [], cursor: 'cursor-1'));

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('FOLLOWING'), findsOneWidget);
      await tester.tap(find.text('FOLLOWING'));
      await tester.pump();

      verify(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).called(2);
    });

    testWidgets('does not call setState after dispose when feed loading completes', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();
      final completer = Completer<FeedResult>();
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;

      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previousOnError);

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);
      when(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildHomeSubject(feedPreferencesCubit: feedPreferencesCubit, feedRepository: feedRepository),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());

      completer.complete(FeedResult(posts: const []));
      await tester.pump();

      expect(errors.where((error) => error.exceptionAsString().contains('setState() called after dispose()')), isEmpty);
    });

    testWidgets('does not fetch the feed when offline and shows an offline message', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
      when(() => feedRepository.getCachedFeedPage(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildHomeSubject(
          feedPreferencesCubit: feedPreferencesCubit,
          feedRepository: feedRepository,
          connectivityState: const ConnectivityState.online(isSimulatedOffline: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load feed'), findsOneWidget);
      expect(find.textContaining('You\'re offline'), findsOneWidget);
      verifyNever(
        () => feedRepository.getTimeline(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      );
    });
  });
}
