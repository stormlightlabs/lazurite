import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/trending_join.dart';
import 'package:lazurite/features/feed/presentation/trending_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockFeedRepository feedRepository;
  late MockSettingsCubit settingsCubit;

  setUp(() {
    feedRepository = MockFeedRepository();
    settingsCubit = MockSettingsCubit();
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      home: RepositoryProvider<FeedRepository>.value(
        value: feedRepository,
        child: BlocProvider<SettingsCubit>.value(value: settingsCubit, child: const TrendingScreen()),
      ),
    );
  }

  testWidgets('shows loading state while data is in flight', (tester) async {
    final completer = Completer<TrendingScreenData>();
    when(() => feedRepository.getTrendingScreenData(limit: any(named: 'limit'))).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(_data(topics: [_topic('Dart', '/topic/dart')], suggested: const []));
  });

  testWidgets('shows empty state when provider returns no topics', (tester) async {
    when(
      () => feedRepository.getTrendingScreenData(limit: any(named: 'limit')),
    ).thenAnswer((_) async => _data(topics: const [], suggested: const []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('No trending topics right now'), findsOneWidget);
  });

  testWidgets('hides suggested section when it is empty', (tester) async {
    when(
      () => feedRepository.getTrendingScreenData(limit: any(named: 'limit')),
    ).thenAnswer((_) async => _data(topics: [_topic('Dart', '/topic/dart')], suggested: const []));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Topics'), findsOneWidget);
    expect(find.text('Suggested'), findsNothing);
  });

  testWidgets('shows suggested section when data is present', (tester) async {
    when(() => feedRepository.getTrendingScreenData(limit: any(named: 'limit'))).thenAnswer(
      (_) async => _data(topics: [_topic('Dart', '/topic/dart')], suggested: [_topic('Flutter', '/topic/flutter')]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Topics'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('shows metadata unavailable banner in degraded mode', (tester) async {
    when(() => feedRepository.getTrendingScreenData(limit: any(named: 'limit'))).thenAnswer(
      (_) async => _data(topics: [_topic('Dart', '/topic/dart')], suggested: const [], metadataUnavailable: true),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Metadata temporarily unavailable'), findsOneWidget);
  });

  testWidgets('shows error state and retries loading', (tester) async {
    when(() => feedRepository.getTrendingScreenData(limit: any(named: 'limit'))).thenThrow(Exception('boom'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Failed to load trending'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => feedRepository.getTrendingScreenData(limit: 10)).called(greaterThanOrEqualTo(2));
  });
}

TrendingScreenData _data({
  required List<TrendingTopic> topics,
  required List<TrendingTopic> suggested,
  bool metadataUnavailable = false,
}) {
  return TrendingScreenData(
    topics: topics.map((topic) => EnrichedTrendingTopic(topic: topic)).toList(growable: false),
    suggested: suggested.map((topic) => EnrichedTrendingTopic(topic: topic)).toList(growable: false),
    metadataUnavailable: metadataUnavailable,
  );
}

TrendingTopic _topic(String topic, String link) =>
    TrendingTopic(topic: topic, displayName: topic, link: link, description: 'About $topic');
