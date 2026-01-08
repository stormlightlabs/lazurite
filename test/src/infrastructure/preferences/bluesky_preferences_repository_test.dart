import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  const ownerDid = 'did:web:tester';
  late AppDatabase db;
  late MockXrpcClient mockApi;
  late Logger logger;
  late BlueskyPreferencesRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockApi = MockXrpcClient();
    logger = const Logger('BlueskyPreferencesRepositoryTest');
    repository = BlueskyPreferencesRepository(
      mockApi,
      db.blueskyPreferencesDao,
      db.preferenceSyncQueueDao,
      logger,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('syncPreferencesFromRemote', () {
    test('skips sync for unauthenticated user', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      await repository.syncPreferencesFromRemote(ownerDid);

      verifyNever(() => mockApi.call(any()));
    });

    test('parses and stores adult content preference', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {r'$type': 'app.bsky.actor.defs#adultContentPref', 'enabled': true},
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getAdultContentPref(ownerDid);
      expect(pref.enabled, isTrue);
    });

    test('parses and stores content label preferences', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#contentLabelPref',
              'label': 'sexual',
              'visibility': 'hide',
            },
            {
              r'$type': 'app.bsky.actor.defs#contentLabelPref',
              'label': 'nudity',
              'visibility': 'warn',
            },
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final prefs = await repository.getContentLabelPrefs(ownerDid);
      expect(prefs.items, hasLength(2));
      expect(prefs.getVisibility('sexual'), LabelVisibility.hide);
      expect(prefs.getVisibility('nudity'), LabelVisibility.warn);
    });

    test('parses and stores labelers preference', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#labelersPref',
              'labelers': [
                {'did': 'did:plc:test1'},
                {'did': 'did:plc:test2'},
              ],
            },
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getLabelersPref(ownerDid);
      expect(pref.labelerDids, ['did:plc:test1', 'did:plc:test2']);
    });

    test('parses and stores feed view preference', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#feedViewPref',
              'hideReplies': true,
              'hideReposts': true,
            },
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getFeedViewPref(ownerDid);
      expect(pref.hideReplies, isTrue);
      expect(pref.hideReposts, isTrue);
    });

    test('parses and stores thread view preference', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#threadViewPref',
              'sort': 'newest',
              'prioritizeFollowedUsers': false,
            },
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getThreadViewPref(ownerDid);
      expect(pref.sort, ThreadSortOrder.newest);
      expect(pref.prioritizeFollowedUsers, isFalse);
    });

    test('parses and stores muted words preference', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {
              r'$type': 'app.bsky.actor.defs#mutedWordsPref',
              'items': [
                {
                  'id': '1',
                  'value': 'test-word',
                  'targets': ['content'],
                },
              ],
            },
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getMutedWordsPref(ownerDid);
      expect(pref.items, hasLength(1));
      expect(pref.items[0].value, 'test-word');
    });

    test('handles all preference types in single response', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {r'$type': 'app.bsky.actor.defs#adultContentPref', 'enabled': true},
            {
              r'$type': 'app.bsky.actor.defs#contentLabelPref',
              'label': 'gore',
              'visibility': 'hide',
            },
            {r'$type': 'app.bsky.actor.defs#labelersPref', 'labelers': []},
            {r'$type': 'app.bsky.actor.defs#feedViewPref', 'hideQuotePosts': true},
            {r'$type': 'app.bsky.actor.defs#threadViewPref', 'sort': 'hotness'},
            {r'$type': 'app.bsky.actor.defs#mutedWordsPref', 'items': []},
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      expect((await repository.getAdultContentPref(ownerDid)).enabled, isTrue);
      expect((await repository.getContentLabelPrefs(ownerDid)).items, hasLength(1));
      expect((await repository.getLabelersPref(ownerDid)).labelers, isEmpty);
      expect((await repository.getFeedViewPref(ownerDid)).hideQuotePosts, isTrue);
      expect((await repository.getThreadViewPref(ownerDid)).sort, ThreadSortOrder.hotness);
      expect((await repository.getMutedWordsPref(ownerDid)).items, isEmpty);
    });

    test('handles malformed preference gracefully', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            'not-a-map',
            {r'$type': 'app.bsky.actor.defs#adultContentPref', 'enabled': true},
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);

      final pref = await repository.getAdultContentPref(ownerDid);
      expect(pref.enabled, isTrue);
    });
  });

  group('getters return defaults when not synced', () {
    test('getAdultContentPref returns false by default', () async {
      final pref = await repository.getAdultContentPref(ownerDid);
      expect(pref.enabled, isFalse);
    });

    test('getContentLabelPrefs returns empty by default', () async {
      final prefs = await repository.getContentLabelPrefs(ownerDid);
      expect(prefs.items, isEmpty);
    });

    test('getLabelersPref returns empty by default', () async {
      final pref = await repository.getLabelersPref(ownerDid);
      expect(pref.labelers, isEmpty);
    });

    test('getFeedViewPref returns defaults', () async {
      final pref = await repository.getFeedViewPref(ownerDid);
      expect(pref.hideReplies, isFalse);
      expect(pref.hideReposts, isFalse);
    });

    test('getThreadViewPref returns defaults', () async {
      final pref = await repository.getThreadViewPref(ownerDid);
      expect(pref.sort, ThreadSortOrder.oldest);
      expect(pref.prioritizeFollowedUsers, isTrue);
    });

    test('getMutedWordsPref returns empty by default', () async {
      final pref = await repository.getMutedWordsPref(ownerDid);
      expect(pref.items, isEmpty);
    });
  });

  group('watchers', () {
    test('watchAdultContentPref emits updates', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {r'$type': 'app.bsky.actor.defs#adultContentPref', 'enabled': true},
          ],
        },
      );

      final stream = repository.watchAdultContentPref(ownerDid);
      expect((await stream.first).enabled, isFalse);

      await repository.syncPreferencesFromRemote(ownerDid);
      expect((await stream.first).enabled, isTrue);
    });
  });

  group('clearAll', () {
    test('removes all stored preferences', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(() => mockApi.call('app.bsky.actor.getPreferences')).thenAnswer(
        (_) async => {
          'preferences': [
            {r'$type': 'app.bsky.actor.defs#adultContentPref', 'enabled': true},
          ],
        },
      );

      await repository.syncPreferencesFromRemote(ownerDid);
      expect((await repository.getAdultContentPref(ownerDid)).enabled, isTrue);

      await repository.clearAll(ownerDid);

      expect((await repository.getAdultContentPref(ownerDid)).enabled, isFalse);
    });
  });

  group('updateFeedViewPref', () {
    test('persists preference to database', () async {
      const pref = FeedViewPref(hideReplies: true, hideReposts: true, hideQuotePosts: false);

      await repository.updateFeedViewPref(pref, ownerDid);

      final stored = await repository.getFeedViewPref(ownerDid);
      expect(stored.hideReplies, isTrue);
      expect(stored.hideReposts, isTrue);
      expect(stored.hideQuotePosts, isFalse);
    });

    test('queues sync item', () async {
      const pref = FeedViewPref(hideReplies: true);

      await repository.updateFeedViewPref(pref, ownerDid);

      final queued = await db.preferenceSyncQueueDao.getPendingItems(ownerDid);
      expect(queued, hasLength(1));
      expect(queued[0].type, 'feedView');
    });
  });

  group('updateThreadViewPref', () {
    test('persists preference to database', () async {
      const pref = ThreadViewPref(sort: ThreadSortOrder.newest, prioritizeFollowedUsers: false);

      await repository.updateThreadViewPref(pref, ownerDid);

      final stored = await repository.getThreadViewPref(ownerDid);
      expect(stored.sort, ThreadSortOrder.newest);
      expect(stored.prioritizeFollowedUsers, isFalse);
    });

    test('queues sync item', () async {
      const pref = ThreadViewPref(sort: ThreadSortOrder.mostLikes);

      await repository.updateThreadViewPref(pref, ownerDid);

      final queued = await db.preferenceSyncQueueDao.getPendingItems(ownerDid);
      expect(queued, hasLength(1));
      expect(queued[0].type, 'threadView');
    });
  });

  group('updateAdultContentPref', () {
    test('persists preference to database', () async {
      const pref = AdultContentPref(enabled: true);

      await repository.updateAdultContentPref(pref, ownerDid);

      final stored = await repository.getAdultContentPref(ownerDid);
      expect(stored.enabled, isTrue);
    });

    test('queues sync item', () async {
      const pref = AdultContentPref(enabled: true);

      await repository.updateAdultContentPref(pref, ownerDid);

      final queued = await db.preferenceSyncQueueDao.getPendingItems(ownerDid);
      expect(queued, hasLength(1));
      expect(queued[0].type, 'adultContent');
    });

    test('updates from enabled to disabled', () async {
      await repository.updateAdultContentPref(const AdultContentPref(enabled: true), ownerDid);
      expect((await repository.getAdultContentPref(ownerDid)).enabled, isTrue);

      await repository.updateAdultContentPref(const AdultContentPref(enabled: false), ownerDid);
      expect((await repository.getAdultContentPref(ownerDid)).enabled, isFalse);
    });
  });

  group('updateContentLabelPrefs', () {
    test('persists preferences to database', () async {
      const prefs = ContentLabelPrefs(
        items: [
          ContentLabelPref(label: 'sexual', visibility: LabelVisibility.hide),
          ContentLabelPref(label: 'gore', visibility: LabelVisibility.warn),
        ],
      );

      await repository.updateContentLabelPrefs(prefs, ownerDid);

      final stored = await repository.getContentLabelPrefs(ownerDid);
      expect(stored.items, hasLength(2));
      expect(stored.getVisibility('sexual'), LabelVisibility.hide);
      expect(stored.getVisibility('gore'), LabelVisibility.warn);
    });

    test('queues sync item', () async {
      const prefs = ContentLabelPrefs(
        items: [ContentLabelPref(label: 'spam', visibility: LabelVisibility.hide)],
      );

      await repository.updateContentLabelPrefs(prefs, ownerDid);

      final queued = await db.preferenceSyncQueueDao.getPendingItems(ownerDid);
      expect(queued, hasLength(1));
      expect(queued[0].type, 'contentLabels');
    });

    test('overwrites existing preferences', () async {
      await repository.updateContentLabelPrefs(
        const ContentLabelPrefs(
          items: [ContentLabelPref(label: 'sexual', visibility: LabelVisibility.hide)],
        ),
        ownerDid,
      );

      await repository.updateContentLabelPrefs(
        const ContentLabelPrefs(
          items: [ContentLabelPref(label: 'gore', visibility: LabelVisibility.warn)],
        ),
        ownerDid,
      );

      final stored = await repository.getContentLabelPrefs(ownerDid);
      expect(stored.items, hasLength(1));
      expect(stored.getVisibility('gore'), LabelVisibility.warn);
      expect(stored.getVisibility('sexual'), isNull);
    });
  });

  group('updateMutedWordsPref', () {
    test('persists preference to database', () async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          MutedWord(
            id: '2',
            value: 'scam',
            targets: [MutedWordTarget.tags],
            actorTarget: MutedWordActorTarget.excludeFollowing,
          ),
        ],
      );

      await repository.updateMutedWordsPref(pref, ownerDid);

      final stored = await repository.getMutedWordsPref(ownerDid);
      expect(stored.items, hasLength(2));
      expect(stored.items[0].value, 'spam');
      expect(stored.items[1].value, 'scam');
      expect(stored.items[1].actorTarget, MutedWordActorTarget.excludeFollowing);
    });

    test('queues sync item', () async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(id: '1', value: 'test', targets: [MutedWordTarget.content]),
        ],
      );

      await repository.updateMutedWordsPref(pref, ownerDid);

      final queued = await db.preferenceSyncQueueDao.getPendingItems(ownerDid);
      expect(queued, hasLength(1));
      expect(queued[0].type, 'mutedWords');
    });

    test('overwrites existing muted words', () async {
      await repository.updateMutedWordsPref(
        const MutedWordsPref(
          items: [
            MutedWord(id: '1', value: 'old', targets: [MutedWordTarget.content]),
          ],
        ),
        ownerDid,
      );

      await repository.updateMutedWordsPref(
        const MutedWordsPref(
          items: [
            MutedWord(id: '2', value: 'new', targets: [MutedWordTarget.content]),
          ],
        ),
        ownerDid,
      );

      final stored = await repository.getMutedWordsPref(ownerDid);
      expect(stored.items, hasLength(1));
      expect(stored.items[0].value, 'new');
    });
  });
}
