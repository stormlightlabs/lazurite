import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:uuid/uuid.dart';

class FeedPreferencesCubit extends Cubit<FeedPreferencesState> {
  FeedPreferencesCubit({
    required FeedRepository feedRepository,
    required AppDatabase database,
    required String accountDid,
  }) : _feedRepository = feedRepository,
       _database = database,
       _accountDid = accountDid,
       super(const FeedPreferencesState.initial());

  static const int _generatorHydrationBatchSize = 25;

  final FeedRepository _feedRepository;
  final AppDatabase _database;
  final String _accountDid;

  Future<void> loadPreferences({bool emitCachedFirst = true}) async {
    log.d('FeedPreferencesCubit: Loading feed preferences for $_accountDid');
    _safeEmit(state.copyWith(status: FeedPreferencesStatus.loading));

    try {
      final cachedFeeds = await _database.getSavedFeeds(_accountDid);

      if (emitCachedFirst && cachedFeeds.isNotEmpty) {
        final feeds = cachedFeeds.map(_mapFromCached).toList();
        log.d('FeedPreferencesCubit: Loaded ${feeds.length} cached feeds for $_accountDid');
        _emitLoaded(feeds);
      }

      final result = await _feedRepository.getPreferences();
      final savedFeedsPref = result.preferences.whereType<UPreferencesSavedFeedsPrefV2>().firstOrNull;

      if (savedFeedsPref != null) {
        final feeds = _ensureDefaultFeeds(savedFeedsPref.data.items);
        await _cacheFeeds(feeds);
        log.i('FeedPreferencesCubit: Loaded ${feeds.length} feed preferences from server for $_accountDid');
        _emitLoaded(feeds);
        await _hydrateGeneratorViews(feeds);
      } else {
        final defaultFeeds = [_createDefaultTimelineFeed()];
        await _cacheFeeds(defaultFeeds);
        log.i('FeedPreferencesCubit: No server feed preferences found, creating default timeline for $_accountDid');
        _emitLoaded(defaultFeeds);
      }
    } catch (e, stackTrace) {
      final cachedFeeds = await _database.getSavedFeeds(_accountDid);
      if (cachedFeeds.isNotEmpty) {
        final feeds = cachedFeeds.map(_mapFromCached).toList();
        const message = 'Could not refresh feed preferences; showing cached feeds.';
        log.w(
          'FeedPreferencesCubit: Falling back to ${feeds.length} cached feeds for $_accountDid after load failure',
          error: e,
          stackTrace: stackTrace,
        );
        _emitLoaded(feeds, message: message);
        await _hydrateGeneratorViews(feeds);
      } else {
        log.e(
          'FeedPreferencesCubit: Failed to load feed preferences for $_accountDid with no cached fallback',
          error: e,
          stackTrace: stackTrace,
        );
        _safeEmit(FeedPreferencesState.error(message: e.toString()));
      }
    }
  }

  Future<void> pinFeed(String feedId) async {
    final currentFeeds = state.feeds;
    final feedToPin = currentFeeds.firstWhere((f) => f.id == feedId);
    final pinnedFeeds = currentFeeds.where((f) => f.pinned).toList();
    final unpinnedFeeds = currentFeeds.where((f) => !f.pinned && f.id != feedId).toList();

    final updatedFeed = SavedFeed(id: feedToPin.id, type: feedToPin.type, value: feedToPin.value, pinned: true);
    final newFeeds = [...pinnedFeeds, updatedFeed, ...unpinnedFeeds];

    await _savePreferences(newFeeds);
  }

  Future<void> unpinFeed(String feedId) async {
    final currentFeeds = state.feeds;
    final feedToUnpin = currentFeeds.firstWhere((f) => f.id == feedId);
    final pinnedFeeds = currentFeeds.where((f) => f.pinned && f.id != feedId).toList();
    final unpinnedFeeds = currentFeeds.where((f) => !f.pinned).toList();

    final updatedFeed = SavedFeed(id: feedToUnpin.id, type: feedToUnpin.type, value: feedToUnpin.value, pinned: false);
    final newFeeds = [...pinnedFeeds, ...unpinnedFeeds, updatedFeed];

    await _savePreferences(newFeeds);
  }

  Future<void> reorderPinnedFeeds(int oldIndex, int newIndex) async {
    final pinnedFeeds = List<SavedFeed>.from(state.pinnedFeeds);
    final unpinnedFeeds = state.unpinnedFeeds;

    if (oldIndex < 0 || oldIndex >= pinnedFeeds.length) return;
    if (newIndex < 0) return;

    final item = pinnedFeeds.removeAt(oldIndex);
    pinnedFeeds.insert(newIndex.clamp(0, pinnedFeeds.length), item);

    final newFeeds = [...pinnedFeeds, ...unpinnedFeeds];
    await _savePreferences(newFeeds);
  }

  Future<void> reorderFeeds(int oldIndex, int newIndex) async {
    final feeds = List<SavedFeed>.from(state.feeds);
    if (oldIndex < 0 || oldIndex >= feeds.length) return;

    final item = feeds.removeAt(oldIndex);
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    feeds.insert(adjustedNewIndex, item);

    await _savePreferences(feeds);
  }

  Future<void> removeFeed(String feedId) async {
    final feeds = state.feeds.where((f) => f.id != feedId).toList();
    await _savePreferences(feeds);
  }

  Future<void> addFeed({required SavedFeedType type, required String value, bool pinned = false}) async {
    if (state.containsFeedValue(value)) {
      log.d('FeedPreferencesCubit: Ignoring duplicate feed $value for $_accountDid');
      return;
    }

    final newFeed = SavedFeed(id: _generateId(), type: type, value: value, pinned: pinned);
    final feeds = [...state.feeds, newFeed];
    await _savePreferences(feeds);
  }

  Future<bool> _savePreferences(List<SavedFeed> feeds) async {
    final previousState = state;
    log.d('FeedPreferencesCubit: Saving ${feeds.length} feed preferences for $_accountDid');
    _safeEmit(state.copyWith(status: FeedPreferencesStatus.saving));

    try {
      final result = await _feedRepository.getPreferences();
      final preferences = List<UPreferences>.from(result.preferences);

      preferences.removeWhere((p) => p is UPreferencesSavedFeedsPrefV2);
      preferences.add(UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: feeds)));

      await _feedRepository.putPreferences(preferences: preferences);
      await _cacheFeeds(feeds);

      log.i('FeedPreferencesCubit: Saved ${feeds.length} feed preferences for $_accountDid');
      _emitLoaded(feeds);
      await _hydrateGeneratorViews(feeds);
      return true;
    } catch (e, stackTrace) {
      log.e('FeedPreferencesCubit: Failed to save feed preferences for $_accountDid', error: e, stackTrace: stackTrace);
      _safeEmit(
        FeedPreferencesState.saveError(
          feeds: previousState.feeds,
          generatorViews: previousState.generatorViews,
          message: e.toString(),
          previousState: previousState,
        ),
      );
      return false;
    }
  }

  void clearError() {
    if (state.status == FeedPreferencesStatus.saveError && state.previousState != null) {
      _safeEmit(state.previousState!);
    }
  }

  Future<void> _cacheFeeds(List<SavedFeed> feeds) async {
    final companions = feeds.asMap().entries.map((entry) {
      final index = entry.key;
      final feed = entry.value;
      return SavedFeedsCompanion(
        id: Value(feed.id),
        accountDid: Value(_accountDid),
        type: Value(feed.type.toJson()),
        value: Value(feed.value),
        pinned: Value(feed.pinned),
        sortOrder: Value(index),
        updatedAt: Value(DateTime.now()),
      );
    }).toList();

    await _database.replaceSavedFeeds(_accountDid, companions);
  }

  SavedFeed _mapFromCached(SavedFeedEntry entry) => SavedFeed(
    id: entry.id,
    type: SavedFeedType.valueOf(entry.type) ?? const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
    value: entry.value,
    pinned: entry.pinned,
  );

  String _generateId() => const Uuid().v4();

  void _emitLoaded(List<SavedFeed> feeds, {String? message}) {
    _safeEmit(
      FeedPreferencesState.loaded(feeds: feeds, generatorViews: _retainGeneratorViews(feeds), message: message),
    );
  }

  List<SavedFeed> _ensureDefaultFeeds(List<SavedFeed> feeds) {
    if (feeds.isNotEmpty) {
      return feeds;
    }

    return [_createDefaultTimelineFeed()];
  }

  List<GeneratorView> _retainGeneratorViews(List<SavedFeed> feeds) => state.generatorViews
      .where((view) => feeds.any((feed) => _isSameFeedValue(feed.value, view.uri.toString())))
      .toList(growable: false);

  Future<void> _hydrateGeneratorViews(List<SavedFeed> feeds) async {
    final feedUris = <AtUri>[];
    final seenUris = <String>{};

    for (final feed in feeds) {
      if (!_isGeneratorFeed(feed)) {
        continue;
      }

      try {
        final parsed = AtUri.parse(feed.value);
        final key = '${parsed.hostname}/${parsed.collection}/${parsed.rkey}';
        if (!seenUris.add(key)) {
          continue;
        }
        feedUris.add(parsed);
      } catch (error, stackTrace) {
        log.d(
          'FeedPreferencesCubit: skipping malformed saved feed URI ${feed.value}',
          error: error,
          stackTrace: stackTrace,
        );
        continue;
      }
    }

    if (feedUris.isEmpty) {
      if (state.generatorViews.isNotEmpty) {
        _safeEmit(state.copyWith(generatorViews: const [], status: FeedPreferencesStatus.loaded));
      }
      return;
    }

    final generatorViews = <GeneratorView>[];

    for (var i = 0; i < feedUris.length; i += _generatorHydrationBatchSize) {
      final end = i + _generatorHydrationBatchSize > feedUris.length
          ? feedUris.length
          : i + _generatorHydrationBatchSize;
      final chunk = feedUris.sublist(i, end);

      try {
        final chunkViews = await _feedRepository.getFeedGenerators(chunk);
        generatorViews.addAll(chunkViews);
        continue;
      } catch (error, stackTrace) {
        log.d(
          'FeedPreferencesCubit: Batch hydration failed for ${chunk.length} generators, falling back to individual fetches for $_accountDid',
          error: error,
          stackTrace: stackTrace,
        );
      }

      for (final feedUri in chunk) {
        try {
          generatorViews.add(await _feedRepository.getFeedGenerator(feedUri));
        } catch (error, stackTrace) {
          log.w(
            'FeedPreferencesCubit: Failed to hydrate feed generator $feedUri for $_accountDid',
            error: error,
            stackTrace: stackTrace,
          );
          continue;
        }
      }
    }

    if (generatorViews.isNotEmpty) {
      log.d(
        'FeedPreferencesCubit: Hydrated ${generatorViews.length}/${feedUris.length} generator views for $_accountDid',
      );
      _safeEmit(state.copyWith(generatorViews: generatorViews, status: FeedPreferencesStatus.loaded, feeds: feeds));
    } else if (state.generatorViews.isNotEmpty) {
      _safeEmit(state.copyWith(generatorViews: const [], status: FeedPreferencesStatus.loaded, feeds: feeds));
    }
  }

  void _safeEmit(FeedPreferencesState nextState) {
    if (isClosed) {
      return;
    }
    emit(nextState);
  }

  bool _isGeneratorFeed(SavedFeed feed) =>
      feed.type is SavedFeedTypeKnownValue && feed.type.data == KnownSavedFeedType.feed;

  bool _isSameFeedValue(String lhs, String rhs) {
    if (lhs == rhs) {
      return true;
    }

    try {
      final left = AtUri.parse(lhs);
      final right = AtUri.parse(rhs);
      return left.hostname == right.hostname && left.collection == right.collection && left.rkey == right.rkey;
    } catch (error, stackTrace) {
      log.d('FeedPreferencesCubit: cannot compare malformed feed URIs', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  SavedFeed _createDefaultTimelineFeed() {
    return SavedFeed(
      id: _generateId(),
      type: const SavedFeedType.knownValue(data: KnownSavedFeedType.timeline),
      value: 'timeline',
      pinned: true,
    );
  }
}

enum FeedPreferencesStatus { initial, loading, loaded, saving, saveError, error }

class FeedPreferencesState extends Equatable {
  const FeedPreferencesState._({
    required this.status,
    this.feeds = const [],
    this.generatorViews = const [],
    this.message,
    this.previousState,
  });

  const FeedPreferencesState.initial() : this._(status: FeedPreferencesStatus.initial);

  const FeedPreferencesState.loaded({
    required List<SavedFeed> feeds,
    List<GeneratorView> generatorViews = const [],
    String? message,
  }) : this._(status: FeedPreferencesStatus.loaded, feeds: feeds, generatorViews: generatorViews, message: message);

  const FeedPreferencesState.error({required String message})
    : this._(status: FeedPreferencesStatus.error, message: message);

  const FeedPreferencesState.saveError({
    required List<SavedFeed> feeds,
    required List<GeneratorView> generatorViews,
    required String message,
    required FeedPreferencesState previousState,
  }) : this._(
         status: FeedPreferencesStatus.saveError,
         feeds: feeds,
         generatorViews: generatorViews,
         message: message,
         previousState: previousState,
       );

  final FeedPreferencesStatus status;
  final List<SavedFeed> feeds;
  final List<GeneratorView> generatorViews;
  final String? message;
  final FeedPreferencesState? previousState;

  List<SavedFeed> get pinnedFeeds => feeds.where((f) => f.pinned).toList();

  List<SavedFeed> get unpinnedFeeds => feeds.where((f) => !f.pinned).toList();

  bool isTimeline(SavedFeed feed) {
    final feedType = feed.type;
    return feedType is SavedFeedTypeKnownValue && feedType.data == KnownSavedFeedType.timeline;
  }

  bool containsFeedValue(String value) {
    return feeds.any((feed) => _isSameFeedValue(feed.value, value));
  }

  GeneratorView? generatorFor(SavedFeed feed) {
    for (final view in generatorViews) {
      if (_isSameFeedValue(view.uri.toString(), feed.value)) {
        return view;
      }
    }

    return null;
  }

  String displayNameFor(SavedFeed feed) {
    if (isTimeline(feed)) {
      return 'Following';
    }

    final generator = generatorFor(feed);
    if (generator != null && generator.displayName.trim().isNotEmpty) {
      return generator.displayName;
    }

    final segments = feed.value.split('/');
    return segments.isEmpty ? 'Feed' : segments.last;
  }

  String subtitleFor(SavedFeed feed) {
    if (isTimeline(feed)) {
      return 'Timeline';
    }

    final generator = generatorFor(feed);
    if (generator != null) {
      return 'by ${generator.creator.displayName ?? generator.creator.handle}';
    }

    return 'Custom Feed';
  }

  String? descriptionFor(SavedFeed feed) => generatorFor(feed)?.description;

  bool _isSameFeedValue(String lhs, String rhs) {
    if (lhs == rhs) {
      return true;
    }

    try {
      final left = AtUri.parse(lhs);
      final right = AtUri.parse(rhs);
      return left.hostname == right.hostname && left.collection == right.collection && left.rkey == right.rkey;
    } catch (error, stackTrace) {
      log.d('FeedPreferencesState: cannot compare malformed feed URIs', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  FeedPreferencesState copyWith({
    FeedPreferencesStatus? status,
    List<SavedFeed>? feeds,
    List<GeneratorView>? generatorViews,
    String? message,
    FeedPreferencesState? previousState,
  }) {
    return FeedPreferencesState._(
      status: status ?? this.status,
      feeds: feeds ?? this.feeds,
      generatorViews: generatorViews ?? this.generatorViews,
      message: message ?? this.message,
      previousState: previousState ?? this.previousState,
    );
  }

  @override
  List<Object?> get props => [status, feeds, generatorViews, message, previousState];
}
