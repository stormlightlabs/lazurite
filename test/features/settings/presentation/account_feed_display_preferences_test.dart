import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:lazurite/features/settings/presentation/widgets/account_feed_display_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountSettingsCubit extends MockCubit<AccountSettingsState> implements AccountSettingsCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(BlackskyAiPreferenceCategory.training);
    registerFallbackValue(BlackskyAiPreferenceValue.unset);
  });

  late MockAccountSettingsCubit cubit;

  setUp(() {
    cubit = MockAccountSettingsCubit();
    final state = const AccountSettingsState.initial(feed: homeFeedPreferenceId, feedDisplayName: 'Following').copyWith(
      status: AccountSettingsStatus.loaded,
      feedViewPref: const FeedViewPref(feed: homeFeedPreferenceId),
      threadViewPref: const ThreadViewPref(sort: ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.newest)),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<AccountSettingsState>.empty(), initialState: state);
    when(() => cubit.setThreadSort(any())).thenAnswer((_) async {});
    when(() => cubit.setBlackskyAiPreference(any(), any())).thenAnswer((_) async {});
  });

  testWidgets('renders provider-specific account settings and updates thread sort', (tester) async {
    await tester.pumpWidget(
      BlocProvider<AccountSettingsCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(body: AccountFeedDisplayPreferences(providerDisplayName: 'BlackSky')),
        ),
      ),
    );

    expect(find.text('BlackSky Settings'), findsOneWidget);
    expect(find.textContaining('app.bsky.actor.getPreferences'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('THREAD DISPLAY'), findsOneWidget);
    expect(find.text('Newest first'), findsOneWidget);

    await tester.tap(find.text('Newest first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Most likes').last);
    await tester.pumpAndSettle();

    verify(
      () => cubit.setThreadSort(const ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.mostLikes)),
    ).called(1);
  });

  testWidgets('renders BlackSky AI preferences and updates them', (tester) async {
    final state =
        const AccountSettingsState.initial(
          feed: homeFeedPreferenceId,
          feedDisplayName: 'Following',
          supportsBlackskyAiPreferences: true,
        ).copyWith(
          status: AccountSettingsStatus.loaded,
          feedViewPref: const FeedViewPref(feed: homeFeedPreferenceId),
          threadViewPref: const ThreadViewPref(),
          blackskyAiPreferences: const BlackskyAiPreferences(training: BlackskyAiPreferenceValue.unset),
        );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<AccountSettingsState>.empty(), initialState: state);

    await tester.pumpWidget(
      BlocProvider<AccountSettingsCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(body: AccountFeedDisplayPreferences(providerDisplayName: 'BlackSky')),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(find.text('BLACKSKY AI PREFERENCES'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('Not Set'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Not Set').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deny').last);
    await tester.pumpAndSettle();
    verify(
      () => cubit.setBlackskyAiPreference(BlackskyAiPreferenceCategory.embedding, BlackskyAiPreferenceValue.deny),
    ).called(1);
  });

  testWidgets('can hide thread settings when used from feed management', (tester) async {
    await tester.pumpWidget(
      BlocProvider<AccountSettingsCubit>.value(
        value: cubit,
        child: const MaterialApp(home: Scaffold(body: AccountFeedDisplayPreferences(showThreadSettings: false))),
      ),
    );

    expect(find.text('THREAD DISPLAY'), findsNothing);
  });
}
