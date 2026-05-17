import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository feedRepository;

  setUp(() {
    feedRepository = MockFeedRepository();
  });

  group('AccountSettingsCubit', () {
    test('initial state uses requested feed', () {
      final cubit = AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
      );

      expect(cubit.state.status, AccountSettingsStatus.initial);
      expect(cubit.state.feed, homeFeedPreferenceId);
      expect(cubit.state.feedDisplayName, 'Following');
    });

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'loadPreferences creates default feed preference when one does not exist',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
      ),
      setUp: () {
        when(() => feedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<AccountSettingsState>().having((state) => state.status, 'status', AccountSettingsStatus.loading),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.feedViewPref?.feed, 'feed', homeFeedPreferenceId)
            .having((state) => state.feedViewPref?.hideRepliesByUnfollowed, 'hideRepliesByUnfollowed', true),
      ],
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'loadPreferences uses existing feed preference for the requested feed',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: 'at://did:plc:test/app.bsky.feed.generator/custom',
        feedDisplayName: 'Custom',
      ),
      setUp: () {
        when(() => feedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: const [
              UPreferences.feedViewPref(data: FeedViewPref(feed: homeFeedPreferenceId, hideReplies: true)),
              UPreferences.feedViewPref(
                data: FeedViewPref(
                  feed: 'at://did:plc:test/app.bsky.feed.generator/custom',
                  hideReposts: true,
                  hideQuotePosts: true,
                ),
              ),
            ],
          ),
        );
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<AccountSettingsState>().having((state) => state.status, 'status', AccountSettingsStatus.loading),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.feedViewPref?.hideReplies, 'hideReplies', null)
            .having((state) => state.feedViewPref?.hideReposts, 'hideReposts', true)
            .having((state) => state.feedViewPref?.hideQuotePosts, 'hideQuotePosts', true),
      ],
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'setHideReposts replaces only the matching feed preference',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
      ),
      seed: () => const AccountSettingsState.initial(feed: homeFeedPreferenceId, feedDisplayName: 'Following').copyWith(
        status: AccountSettingsStatus.loaded,
        feedViewPref: const FeedViewPref(feed: homeFeedPreferenceId, hideReplies: true),
      ),
      setUp: () {
        when(() => feedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: const [
              UPreferences.feedViewPref(data: FeedViewPref(feed: homeFeedPreferenceId, hideReplies: false)),
              UPreferences.feedViewPref(
                data: FeedViewPref(feed: 'at://did:plc:test/app.bsky.feed.generator/custom', hideReposts: true),
              ),
            ],
          ),
        );
        when(() => feedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.setHideReposts(true),
      expect: () => [
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.saving)
            .having((state) => state.feedViewPref?.hideReplies, 'hideReplies', true)
            .having((state) => state.feedViewPref?.hideReposts, 'hideReposts', true),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.feedViewPref?.hideReplies, 'hideReplies', true)
            .having((state) => state.feedViewPref?.hideReposts, 'hideReposts', true),
      ],
      verify: (_) {
        final captured =
            verify(() => feedRepository.putPreferences(preferences: captureAny(named: 'preferences'))).captured.single
                as List<UPreferences>;

        final feedViewPrefs = captured.map((preference) => preference.feedViewPref).nonNulls.toList();
        expect(feedViewPrefs, hasLength(2));
        expect(feedViewPrefs.firstWhere((pref) => pref.feed == homeFeedPreferenceId).hideReplies, true);
        expect(feedViewPrefs.firstWhere((pref) => pref.feed == homeFeedPreferenceId).hideReposts, true);
        expect(
          feedViewPrefs
              .firstWhere((pref) => pref.feed == 'at://did:plc:test/app.bsky.feed.generator/custom')
              .hideReposts,
          true,
        );
      },
    );
  });
}
