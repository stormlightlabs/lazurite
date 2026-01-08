import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/presentation/screens/feed_preferences_screen.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBlueskyPreferencesRepository extends Mock implements BlueskyPreferencesRepository {}

void main() {
  late MockBlueskyPreferencesRepository mockRepository;
  late Session testSession;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();
    testSession = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );

    when(
      () => mockRepository.watchFeedViewPref(testSession.did),
    ).thenAnswer((_) => Stream.value(FeedViewPref.defaultPref));
    when(
      () => mockRepository.watchThreadViewPref(testSession.did),
    ).thenAnswer((_) => Stream.value(ThreadViewPref.defaultPref));
    when(() => mockRepository.updateFeedViewPref(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.updateThreadViewPref(any(), any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(FeedViewPref.defaultPref);
    registerFallbackValue(ThreadViewPref.defaultPref);
  });

  Widget buildTestWidget({
    FeedViewPref feedPref = FeedViewPref.defaultPref,
    ThreadViewPref threadPref = ThreadViewPref.defaultPref,
  }) {
    when(
      () => mockRepository.watchFeedViewPref(testSession.did),
    ).thenAnswer((_) => Stream.value(feedPref));
    when(
      () => mockRepository.watchThreadViewPref(testSession.did),
    ).thenAnswer((_) => Stream.value(threadPref));

    return ProviderScope(
      overrides: [
        blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      ],
      child: const MaterialApp(home: FeedPreferencesScreen()),
    );
  }

  group('FeedPreferencesScreen', () {
    testWidgets('renders all sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Feed Preferences'), findsOneWidget);
      expect(find.text('FEED VIEW'), findsOneWidget);
      expect(find.text('THREAD VIEW'), findsOneWidget);
    });

    testWidgets('displays feed view toggles with default values', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hide Replies'), findsOneWidget);
      expect(find.text('Hide Replies by Unfollowed'), findsOneWidget);
      expect(find.text('Hide Reposts'), findsOneWidget);
      expect(find.text('Hide Quote Posts'), findsOneWidget);
    });

    testWidgets('displays thread view controls', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reply Sort Order'), findsOneWidget);
      expect(find.text('Prioritize Followed Users'), findsOneWidget);
      expect(find.text('Oldest'), findsOneWidget);
      expect(find.text('Newest'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('tapping hideReplies toggle calls updateFeedViewPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Hide Replies'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateFeedViewPref(
          any(that: predicate<FeedViewPref>((p) => p.hideReplies == true)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('tapping hideReposts toggle calls updateFeedViewPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Hide Reposts'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateFeedViewPref(
          any(that: predicate<FeedViewPref>((p) => p.hideReposts == true)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('tapping hideQuotePosts toggle calls updateFeedViewPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Hide Quote Posts'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateFeedViewPref(
          any(that: predicate<FeedViewPref>((p) => p.hideQuotePosts == true)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('hideRepliesByUnfollowed is disabled when hideReplies is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(feedPref: const FeedViewPref(hideReplies: true)));
      await tester.pumpAndSettle();

      final unfollowedSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Replies by Unfollowed'),
      );
      expect(unfollowedSwitch.onChanged, isNull);
    });

    testWidgets('selecting sort order calls updateThreadViewPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Newest'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateThreadViewPref(
          any(that: predicate<ThreadViewPref>((p) => p.sort == ThreadSortOrder.newest)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('tapping prioritizeFollowed toggle calls updateThreadViewPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Prioritize Followed Users'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateThreadViewPref(
          any(that: predicate<ThreadViewPref>((p) => p.prioritizeFollowedUsers == false)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('shows current feed preference values', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          feedPref: const FeedViewPref(
            hideReplies: true,
            hideReposts: true,
            hideQuotePosts: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hideRepliesSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Replies'),
      );
      expect(hideRepliesSwitch.value, isTrue);

      final hideRepostsSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Reposts'),
      );
      expect(hideRepostsSwitch.value, isTrue);

      final hideQuotesSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Quote Posts'),
      );
      expect(hideQuotesSwitch.value, isFalse);
    });

    testWidgets('shows current thread preference values', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          threadPref: const ThreadViewPref(
            sort: ThreadSortOrder.mostLikes,
            prioritizeFollowedUsers: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final prioritizeSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Prioritize Followed Users'),
      );
      expect(prioritizeSwitch.value, isFalse);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
