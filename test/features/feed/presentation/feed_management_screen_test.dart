import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

void main() {
  late MockFeedRepository feedRepository;
  late MockFeedPreferencesCubit feedPreferencesCubit;

  setUp(() {
    feedRepository = MockFeedRepository();
    feedPreferencesCubit = MockFeedPreferencesCubit();

    when(() => feedPreferencesCubit.state).thenReturn(const FeedPreferencesState.loaded(feeds: []));
    whenListen(
      feedPreferencesCubit,
      const Stream<FeedPreferencesState>.empty(),
      initialState: const FeedPreferencesState.loaded(feeds: []),
    );
    when(
      () => feedPreferencesCubit.loadPreferences(emitCachedFirst: any(named: 'emitCachedFirst')),
    ).thenAnswer((_) async {});
  });

  Widget buildSubject() => MaterialApp(
    home: RepositoryProvider<FeedRepository>.value(
      value: feedRepository,
      child: BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit, child: const FeedManagementScreen()),
    ),
  );

  testWidgets('does not update state when suggestions complete after dispose', (tester) async {
    final completer = Completer<List<GeneratorView>>();
    when(() => feedRepository.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(const <GeneratorView>[]);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not update state when suggestion failure completes after dispose', (tester) async {
    final completer = Completer<List<GeneratorView>>();
    when(() => feedRepository.getSuggestedFeeds(limit: any(named: 'limit'))).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(Exception('network failed'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
