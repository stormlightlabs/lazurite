import 'dart:async';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/core/theme/ui_density.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/widgets/feed_layout_view.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockFeedRepository extends Mock implements FeedRepository {}

SettingsState _settingsState(FeedArchitecture architecture) => SettingsState(
  themePalette: AppThemePalette.oxocarbon,
  themeVariant: AppThemeVariant.dark,
  useSystemTheme: false,
  uiDensity: UiDensity.standard,
  feedArchitecture: architecture,
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

Widget _buildSubject({required FeedArchitecture architecture, double screenWidth = 400, int itemCount = 3}) {
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
  }) {
    return MaterialApp(
      home: RepositoryProvider<FeedRepository>.value(
        value: feedRepository,
        child: BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit, child: const HomeFeedScreen()),
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

  group('FeedLayoutView — grid architecture', () {
    testWidgets('shows SliverGrid when architecture is grid', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 720));
      expect(find.byType(SliverGrid), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('uses gridItemBuilder in grid mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid));
      expect(find.text('grid 0'), findsOneWidget);
      expect(find.text('linear 0'), findsNothing);
    });

    testWidgets('uses 1 column at width < 600', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 400));

      expect(find.byType(SliverGrid), findsNothing);
      expect(find.byType(SliverList), findsOneWidget);
    });

    testWidgets('uses tighter single-column padding at phone widths', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 400));

      final padding = tester.widget<SliverPadding>(find.byType(SliverPadding));
      expect(padding.padding, const EdgeInsets.fromLTRB(12, 8, 12, 12));
    });

    testWidgets('uses 2 columns at width 600–839', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 720));

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('uses 3 columns at width 840–1199', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 1000));

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('uses 4 columns at width >= 1200', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 1400));

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
    });

    testWidgets('allocates extra height beyond the square media region', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.grid, screenWidth: 720));

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      const tileWidth = (720.0 - 1.0) / 2;

      expect(delegate.mainAxisExtent, isNotNull);
      expect(delegate.mainAxisExtent!, greaterThan(tileWidth + 100));
    });
  });

  group('FeedLayoutView — linear architecture', () {
    testWidgets('shows ListView when architecture is linear', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.linear));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SliverGrid), findsNothing);
    });

    testWidgets('uses linearItemBuilder in linear mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.linear));

      expect(find.text('linear 0'), findsOneWidget);
      expect(find.text('linear 1'), findsOneWidget);
      expect(find.text('linear 2'), findsOneWidget);
    });

    testWidgets('uses tighter vertical spacing in linear mode', (tester) async {
      await tester.pumpWidget(_buildSubject(architecture: FeedArchitecture.linear));

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.symmetric(vertical: 4));
    });
  });

  group('FeedLayoutView — architecture switching', () {
    testWidgets('switches from grid to linear without re-fetch', (tester) async {
      final cubit = MockSettingsCubit();
      final streamController = StreamController<SettingsState>.broadcast();

      when(() => cubit.state).thenReturn(_settingsState(FeedArchitecture.grid));
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

      expect(find.byType(SliverGrid), findsOneWidget);

      when(() => cubit.state).thenReturn(_settingsState(FeedArchitecture.linear));
      streamController.add(_settingsState(FeedArchitecture.linear));
      await tester.pump();

      expect(find.byType(SliverGrid), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(buildCount, 0);

      await streamController.close();
    });

    testWidgets('loading indicator appears when isLoadingMore is true in grid mode', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(_settingsState(FeedArchitecture.grid));

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

    testWidgets('loading indicator appears when isLoadingMore is true in linear mode', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(_settingsState(FeedArchitecture.linear));

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
    testWidgets('uses a non-default compose hero tag', (tester) async {
      final feedPreferencesCubit = MockFeedPreferencesCubit();
      final feedRepository = MockFeedRepository();
      final completer = Completer<FeedResult>();

      when(() => feedPreferencesCubit.state).thenReturn(_homeFeedState);
      whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: _homeFeedState);
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

      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.heroTag, 'home-compose-fab');
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
  });
}
