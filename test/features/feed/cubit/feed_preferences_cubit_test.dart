import 'dart:async';

import 'package:poptart_core/poptart_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late AppDatabase database;
  late MockFeedRepository mockFeedRepository;

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.feed.generator/fallback'));
  });

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    mockFeedRepository = MockFeedRepository();
  });

  tearDown(() async {
    await database.close();
  });

  SavedFeed createTestFeed({
    required String id,
    String value = 'at://did:plc:test/app.bsky.feed.generator/test',
    bool pinned = false,
    SavedFeedType? type,
  }) {
    return SavedFeed(
      id: id,
      type: type ?? const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
      value: value,
      pinned: pinned,
    );
  }

  group('FeedPreferencesCubit', () {
    test('initial state is initial', () {
      final cubit = FeedPreferencesCubit(
        feedRepository: mockFeedRepository,
        database: database,
        accountDid: 'did:plc:test',
      );
      expect(cubit.state.status, FeedPreferencesStatus.initial);
      expect(cubit.state.feeds, isEmpty);
    });

    test('loadPreferences does not throw if cubit closes before async completion', () async {
      final completer = Completer<PreferencesResult>();
      when(() => mockFeedRepository.getPreferences()).thenAnswer((_) => completer.future);
      final cubit = FeedPreferencesCubit(
        feedRepository: mockFeedRepository,
        database: database,
        accountDid: 'did:plc:test',
      );

      final future = cubit.loadPreferences();
      await cubit.close();
      completer.complete(PreferencesResult(preferences: []));

      await expectLater(future, completes);
    });

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences loads from API and caches to database',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: [
              UPreferences.savedFeedsPrefV2(
                data: SavedFeedsPrefV2(
                  items: [
                    createTestFeed(id: 'feed-1', pinned: true),
                    createTestFeed(id: 'feed-2', pinned: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 2)
            .having((s) => s.pinnedFeeds.length, 'pinnedFeeds.length', 1)
            .having((s) => s.unpinnedFeeds.length, 'unpinnedFeeds.length', 1),
      ],
      verify: (cubit) async {
        final cached = await database.getSavedFeeds('did:plc:test');
        expect(cached.length, 2);
      },
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences creates default timeline feed when no preferences exist',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 1)
            .having((s) => s.pinnedFeeds.length, 'pinnedFeeds.length', 1),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences falls back to cached data on API error',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () async {
        await database.replaceSavedFeeds('did:plc:test', [
          SavedFeedsCompanion(
            id: const Value('cached-1'),
            accountDid: const Value('did:plc:test'),
            type: const Value('{"\$type":"app.bsky.actor.defs#savedFeedTypeKnownValue","data":"feed"}'),
            value: const Value('at://test'),
            pinned: const Value(true),
            sortOrder: const Value(0),
            updatedAt: Value(DateTime.now()),
          ),
        ]);
        when(() => mockFeedRepository.getPreferences()).thenThrow(Exception('Network error'));
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 1)
            .having((s) => s.message, 'message', null),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 1)
            .having((s) => s.message, 'message', 'Could not refresh feed preferences; showing cached feeds.'),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences can skip cached first emit for explicit refresh',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () async {
        await database.replaceSavedFeeds('did:plc:test', [
          SavedFeedsCompanion(
            id: const Value('cached-1'),
            accountDid: const Value('did:plc:test'),
            type: const Value('{"\$type":"app.bsky.actor.defs#savedFeedTypeKnownValue","data":"feed"}'),
            value: const Value('at://did:plc:test/app.bsky.feed.generator/cached'),
            pinned: const Value(true),
            sortOrder: const Value(0),
            updatedAt: Value(DateTime.now()),
          ),
        ]);
        when(() => mockFeedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: [
              UPreferences.savedFeedsPrefV2(
                data: SavedFeedsPrefV2(
                  items: [
                    createTestFeed(
                      id: 'remote-1',
                      value: 'at://did:plc:test/app.bsky.feed.generator/remote',
                      pinned: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        when(() => mockFeedRepository.getFeedGenerators(any())).thenAnswer((_) async => const []);
      },
      act: (cubit) => cubit.loadPreferences(emitCachedFirst: false),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.single.id, 'feed id', 'remote-1'),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences falls back to per-feed hydration when batch getFeedGenerators fails',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () {
        final feed = createTestFeed(id: 'feed-1', pinned: true);
        final generatorView = GeneratorView(
          uri: AtUri.parse(feed.value),
          cid: 'cid-1',
          creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
          did: 'did:plc:test',
          displayName: 'Recovered Feed',
          indexedAt: DateTime.utc(2026, 3, 16),
        );
        when(() => mockFeedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: [
              UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: [feed])),
            ],
          ),
        );
        when(() => mockFeedRepository.getFeedGenerators(any())).thenThrow(Exception('batch failed'));
        when(() => mockFeedRepository.getFeedGenerator(any())).thenAnswer((_) async => generatorView);
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loaded),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.generatorViews.length, 'generatorViews.length', 1)
            .having((s) => s.displayNameFor(s.feeds.single), 'displayNameFor', 'Recovered Feed'),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'loadPreferences hydrates generator views in bounded batches',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      setUp: () {
        final feeds = List.generate(
          65,
          (i) =>
              createTestFeed(id: 'feed-$i', pinned: i == 0, value: 'at://did:plc:test/app.bsky.feed.generator/feed-$i'),
        );

        when(() => mockFeedRepository.getPreferences()).thenAnswer(
          (_) async => PreferencesResult(
            preferences: [UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: feeds))],
          ),
        );

        when(() => mockFeedRepository.getFeedGenerators(any())).thenAnswer((invocation) async {
          final chunk = invocation.positionalArguments.first as List<AtUri>;
          return [
            for (final uri in chunk)
              GeneratorView(
                uri: uri,
                cid: 'cid-${uri.rkey}',
                creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
                did: 'did:plc:test',
                displayName: uri.rkey,
                indexedAt: DateTime.utc(2026, 3, 16),
              ),
          ];
        });
      },
      act: (cubit) => cubit.loadPreferences(),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loading),
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.loaded),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.generatorViews.length, 'generatorViews.length', 65),
      ],
      verify: (_) {
        final captured = verify(() => mockFeedRepository.getFeedGenerators(captureAny())).captured.cast<List<AtUri>>();
        expect(captured.length, 3);
        expect(captured[0].length, 25);
        expect(captured[1].length, 25);
        expect(captured[2].length, 15);
        verifyNever(() => mockFeedRepository.getFeedGenerator(any()));
      },
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'pinFeed moves feed to pinned section',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: 'feed-1', pinned: true),
          createTestFeed(id: 'feed-2', pinned: false),
        ],
      ),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => mockFeedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.pinFeed('feed-2'),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.pinnedFeeds.length, 'pinnedFeeds.length', 2),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'unpinFeed moves feed to unpinned section',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: 'feed-1', pinned: true),
          createTestFeed(id: 'feed-2', pinned: true),
          createTestFeed(id: 'feed-3', pinned: false),
        ],
      ),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => mockFeedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.unpinFeed('feed-1'),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.pinnedFeeds.length, 'pinnedFeeds.length', 1)
            .having((s) => s.unpinnedFeeds.length, 'unpinnedFeeds.length', 2)
            .having((s) => s.pinnedFeeds.first.id, 'remaining pinned', 'feed-2'),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'reorderPinnedFeeds reorders within pinned section only',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: 'pinned-1', value: 'at://a', pinned: true),
          createTestFeed(id: 'pinned-2', value: 'at://b', pinned: true),
          createTestFeed(id: 'pinned-3', value: 'at://c', pinned: true),
          createTestFeed(id: 'unpinned-1', value: 'at://d', pinned: false),
        ],
      ),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => mockFeedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.reorderPinnedFeeds(0, 3),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        predicate<FeedPreferencesState>(
          (s) =>
              s.status == FeedPreferencesStatus.loaded &&
              s.pinnedFeeds[0].id == 'pinned-2' &&
              s.pinnedFeeds[1].id == 'pinned-3' &&
              s.pinnedFeeds[2].id == 'pinned-1' &&
              s.unpinnedFeeds.length == 1,
        ),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'removeFeed removes feed from list',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: 'feed-1', pinned: true),
          createTestFeed(id: 'feed-2', pinned: false),
        ],
      ),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => mockFeedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.removeFeed('feed-2'),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 1)
            .having((s) => s.feeds.first.id, 'remaining feed', 'feed-1'),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'addFeed appends new feed to list',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(feeds: [createTestFeed(id: 'feed-1', pinned: true)]),
      setUp: () {
        when(() => mockFeedRepository.getPreferences()).thenAnswer((_) async => PreferencesResult(preferences: []));
        when(() => mockFeedRepository.putPreferences(preferences: any(named: 'preferences'))).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.addFeed(
        type: const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
        value: 'at://new-feed',
        pinned: true,
      ),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.length, 'feeds.length', 2)
            .having((s) => s.pinnedFeeds.length, 'pinnedFeeds.length', 2),
      ],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      '_savePreferences emits saveError on API failure',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(feeds: [createTestFeed(id: 'feed-1', pinned: true)]),
      setUp: () async {
        await database.replaceSavedFeeds('did:plc:test', [
          SavedFeedsCompanion(
            id: const Value('feed-1'),
            accountDid: const Value('did:plc:test'),
            type: const Value('{"\$type":"app.bsky.actor.defs#savedFeedTypeKnownValue","data":"feed"}'),
            value: const Value('at://did:plc:test/app.bsky.feed.generator/test'),
            pinned: const Value(false),
            sortOrder: const Value(0),
            updatedAt: Value(DateTime.now()),
          ),
        ]);
        when(() => mockFeedRepository.getPreferences()).thenThrow(Exception('API error'));
      },
      act: (cubit) => cubit.pinFeed('feed-1'),
      expect: () => [
        isA<FeedPreferencesState>().having((s) => s.status, 'status', FeedPreferencesStatus.saving),
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.saveError)
            .having((s) => s.feeds.first.pinned, 'pinned', true)
            .having((s) => s.message, 'message', isNotNull),
      ],
      verify: (_) async {
        final cached = await database.getSavedFeeds('did:plc:test');
        expect(cached.single.pinned, isFalse);
      },
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'addFeed ignores duplicate feed values',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.loaded(feeds: [createTestFeed(id: 'feed-1', pinned: true)]),
      act: (cubit) => cubit.addFeed(
        type: const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
        value: 'at://did:plc:test/app.bsky.feed.generator/test',
      ),
      expect: () => [],
    );

    blocTest<FeedPreferencesCubit, FeedPreferencesState>(
      'clearError restores previous state',
      build: () =>
          FeedPreferencesCubit(feedRepository: mockFeedRepository, database: database, accountDid: 'did:plc:test'),
      seed: () => FeedPreferencesState.saveError(
        feeds: [createTestFeed(id: 'feed-1', pinned: true)],
        generatorViews: const [],
        message: 'Error',
        previousState: FeedPreferencesState.loaded(feeds: [createTestFeed(id: 'feed-1', pinned: false)]),
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<FeedPreferencesState>()
            .having((s) => s.status, 'status', FeedPreferencesStatus.loaded)
            .having((s) => s.feeds.first.pinned, 'pinned', false),
      ],
    );
  });

  group('FeedPreferencesState', () {
    test('pinnedFeeds returns only pinned feeds', () {
      final state = FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: '1', pinned: true),
          createTestFeed(id: '2', pinned: false),
          createTestFeed(id: '3', pinned: true),
        ],
      );

      expect(state.pinnedFeeds.length, 2);
      expect(state.pinnedFeeds.every((f) => f.pinned), isTrue);
    });

    test('unpinnedFeeds returns only unpinned feeds', () {
      final state = FeedPreferencesState.loaded(
        feeds: [
          createTestFeed(id: '1', pinned: true),
          createTestFeed(id: '2', pinned: false),
          createTestFeed(id: '3', pinned: true),
        ],
      );

      expect(state.unpinnedFeeds.length, 1);
      expect(state.unpinnedFeeds.every((f) => !f.pinned), isTrue);
    });

    test('copyWith preserves unspecified values', () {
      final state = FeedPreferencesState.loaded(feeds: [createTestFeed(id: '1', pinned: true)]);

      final copied = state.copyWith(status: FeedPreferencesStatus.saving);

      expect(copied.status, FeedPreferencesStatus.saving);
      expect(copied.feeds.length, 1);
    });

    test('displayNameFor prefers hydrated generator metadata', () {
      final state = FeedPreferencesState.loaded(
        feeds: [createTestFeed(id: '1')],
        generatorViews: [
          GeneratorView(
            uri: const AtUri('at://did:plc:test/app.bsky.feed.generator/test'),
            cid: 'cid-1',
            creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
            did: 'did:plc:test',
            displayName: 'What\'s Hot',
            indexedAt: DateTime.utc(2026, 3, 16),
          ),
        ],
      );

      expect(state.displayNameFor(state.feeds.single), 'What\'s Hot');
    });

    test('displayNameFor falls back to URI rkey when hydrated displayName is empty', () {
      final feed = createTestFeed(id: '1');
      final state = FeedPreferencesState.loaded(
        feeds: [feed],
        generatorViews: [
          GeneratorView(
            uri: AtUri.parse(feed.value),
            cid: 'cid-1',
            creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
            did: 'did:plc:test',
            displayName: '   ',
            indexedAt: DateTime.utc(2026, 3, 16),
          ),
        ],
      );

      expect(state.displayNameFor(feed), 'test');
    });

    test('containsFeedValue matches exact saved feed value', () {
      final state = FeedPreferencesState.loaded(feeds: [createTestFeed(id: '1')]);

      expect(state.containsFeedValue('at://did:plc:test/app.bsky.feed.generator/test'), isTrue);
      expect(state.containsFeedValue('at://did:plc:test/app.bsky.feed.generator/other'), isFalse);
    });
  });
}
