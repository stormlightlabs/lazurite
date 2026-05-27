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
              UPreferences.threadViewPref(
                data: ThreadViewPref(sort: ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.newest)),
              ),
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
            .having((state) => state.feedViewPref?.hideQuotePosts, 'hideQuotePosts', true)
            .having(
              (state) => state.threadViewPref?.sort?.knownValue,
              'threadViewPref.sort',
              KnownThreadViewPrefSort.newest,
            ),
      ],
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'loadPreferences loads BlackSky AI preference record when enabled',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
        supportsBlackskyAiPreferences: true,
      ),
      setUp: () {
        when(() => feedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => feedRepository.getBlackskyAiPreferenceRecord()).thenAnswer(
          (_) async => {
            r'$type': FeedRepository.blackskyAiPreferenceCollection,
            'preferences': {
              'training': {'allow': false, 'updatedAt': '2026-01-01T00:00:00.000Z'},
              'embedding': {'allow': true, 'updatedAt': '2026-01-01T00:00:00.000Z'},
            },
          },
        );
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<AccountSettingsState>().having((state) => state.status, 'status', AccountSettingsStatus.loading),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.blackskyAiPreferences?.training, 'training', BlackskyAiPreferenceValue.deny)
            .having((state) => state.blackskyAiPreferences?.embedding, 'embedding', BlackskyAiPreferenceValue.allow)
            .having((state) => state.blackskyAiPreferences?.inference, 'inference', BlackskyAiPreferenceValue.unset),
      ],
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'setBlackskyAiPreference writes the BlackSky preference record',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
        supportsBlackskyAiPreferences: true,
        clock: () => DateTime.utc(2026, 1, 2, 3, 4, 5),
      ),
      seed: () =>
          const AccountSettingsState.initial(
            feed: homeFeedPreferenceId,
            feedDisplayName: 'Following',
            supportsBlackskyAiPreferences: true,
          ).copyWith(
            status: AccountSettingsStatus.loaded,
            blackskyAiPreferences: const BlackskyAiPreferences(training: BlackskyAiPreferenceValue.allow),
          ),
      setUp: () {
        when(() => feedRepository.putBlackskyAiPreferenceRecord(record: any(named: 'record'))).thenAnswer((_) async {});
      },
      act: (cubit) =>
          cubit.setBlackskyAiPreference(BlackskyAiPreferenceCategory.training, BlackskyAiPreferenceValue.deny),
      expect: () => [
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.saving)
            .having((state) => state.blackskyAiPreferences?.training, 'training', BlackskyAiPreferenceValue.deny),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.blackskyAiPreferences?.training, 'training', BlackskyAiPreferenceValue.deny),
      ],
      verify: (_) {
        final record =
            verify(
                  () => feedRepository.putBlackskyAiPreferenceRecord(record: captureAny(named: 'record')),
                ).captured.single
                as Map<String, dynamic>;
        expect(record[r'$type'], FeedRepository.blackskyAiPreferenceCollection);
        expect(record['scope'], {r'$type': '${FeedRepository.blackskyAiPreferenceCollection}#globalScope'});
        expect(record['preferences'], {
          'training': {'allow': false, 'updatedAt': '2026-01-02T03:04:05.000Z'},
        });
      },
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'setThreadSort replaces only the thread preference',
      build: () => AccountSettingsCubit(
        feedRepository: feedRepository,
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
      ),
      seed: () => const AccountSettingsState.initial(feed: homeFeedPreferenceId, feedDisplayName: 'Following').copyWith(
        status: AccountSettingsStatus.loaded,
        threadViewPref: const ThreadViewPref(sort: ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.oldest)),
      ),
      setUp: () {
        when(() => feedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: const [
              UPreferences.feedViewPref(data: FeedViewPref(feed: homeFeedPreferenceId, hideReplies: true)),
              UPreferences.threadViewPref(
                data: ThreadViewPref(sort: ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.oldest)),
              ),
            ],
          ),
        );
        when(() => feedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.setThreadSort(const ThreadViewPrefSort.knownValue(data: KnownThreadViewPrefSort.mostLikes)),
      expect: () => [
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.saving)
            .having((state) => state.threadViewPref?.sort?.knownValue, 'sort', KnownThreadViewPrefSort.mostLikes),
        isA<AccountSettingsState>()
            .having((state) => state.status, 'status', AccountSettingsStatus.loaded)
            .having((state) => state.threadViewPref?.sort?.knownValue, 'sort', KnownThreadViewPrefSort.mostLikes),
      ],
      verify: (_) {
        final captured =
            verify(() => feedRepository.putPreferences(preferences: captureAny(named: 'preferences'))).captured.single
                as List<UPreferences>;

        expect(captured.map((preference) => preference.threadViewPref).nonNulls, hasLength(1));
        expect(
          captured.singleWhere((preference) => preference.threadViewPref != null).threadViewPref!.sort!.knownValue,
          KnownThreadViewPrefSort.mostLikes,
        );
        expect(captured.singleWhere((preference) => preference.feedViewPref != null).feedViewPref!.hideReplies, true);
      },
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
