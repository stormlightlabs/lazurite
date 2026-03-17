import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
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

  final FeedRepository _feedRepository;
  final AppDatabase _database;
  final String _accountDid;

  Future<void> loadPreferences() async {
    emit(state.copyWith(status: FeedPreferencesStatus.loading));

    try {
      final cachedFeeds = await _database.getSavedFeeds(_accountDid);

      if (cachedFeeds.isNotEmpty) {
        final feeds = cachedFeeds.map(_mapFromCached).toList();
        emit(FeedPreferencesState.loaded(feeds: feeds));
      }

      final result = await _feedRepository.getPreferences();
      final savedFeedsPref = result.preferences.whereType<UPreferencesSavedFeedsPrefV2>().firstOrNull;

      if (savedFeedsPref != null) {
        final feeds = savedFeedsPref.data.items;
        await _cacheFeeds(feeds);
        emit(FeedPreferencesState.loaded(feeds: feeds));
      } else {
        final defaultFeeds = [_createDefaultTimelineFeed()];
        await _cacheFeeds(defaultFeeds);
        emit(FeedPreferencesState.loaded(feeds: defaultFeeds));
      }
    } catch (e) {
      final cachedFeeds = await _database.getSavedFeeds(_accountDid);
      if (cachedFeeds.isNotEmpty) {
        final feeds = cachedFeeds.map(_mapFromCached).toList();
        emit(FeedPreferencesState.loaded(feeds: feeds));
      } else {
        emit(FeedPreferencesState.error(message: e.toString()));
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

    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = pinnedFeeds.removeAt(oldIndex);
    pinnedFeeds.insert(adjustedNewIndex, item);

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
    final newFeed = SavedFeed(id: _generateId(), type: type, value: value, pinned: pinned);
    final feeds = [...state.feeds, newFeed];
    await _savePreferences(feeds);
  }

  Future<bool> _savePreferences(List<SavedFeed> feeds) async {
    final previousState = state;
    emit(state.copyWith(status: FeedPreferencesStatus.saving));

    try {
      await _cacheFeeds(feeds);

      final result = await _feedRepository.getPreferences();
      final preferences = List<UPreferences>.from(result.preferences);

      preferences.removeWhere((p) => p is UPreferencesSavedFeedsPrefV2);
      preferences.add(UPreferences.savedFeedsPrefV2(data: SavedFeedsPrefV2(items: feeds)));

      await _feedRepository.putPreferences(preferences: preferences);

      emit(FeedPreferencesState.loaded(feeds: feeds));
      return true;
    } catch (e) {
      emit(FeedPreferencesState.saveError(feeds: feeds, message: e.toString(), previousState: previousState));
      return false;
    }
  }

  void clearError() {
    if (state.status == FeedPreferencesStatus.saveError && state.previousState != null) {
      emit(state.previousState!);
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

  SavedFeed _mapFromCached(SavedFeedEntry entry) {
    return SavedFeed(
      id: entry.id,
      type: SavedFeedType.valueOf(entry.type) ?? const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
      value: entry.value,
      pinned: entry.pinned,
    );
  }

  String _generateId() => const Uuid().v4();

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
  const FeedPreferencesState._({required this.status, this.feeds = const [], this.message, this.previousState});

  const FeedPreferencesState.initial() : this._(status: FeedPreferencesStatus.initial);

  const FeedPreferencesState.loaded({required List<SavedFeed> feeds})
    : this._(status: FeedPreferencesStatus.loaded, feeds: feeds);

  const FeedPreferencesState.error({required String message})
    : this._(status: FeedPreferencesStatus.error, message: message);

  const FeedPreferencesState.saveError({
    required List<SavedFeed> feeds,
    required String message,
    required FeedPreferencesState previousState,
  }) : this._(status: FeedPreferencesStatus.saveError, feeds: feeds, message: message, previousState: previousState);

  final FeedPreferencesStatus status;
  final List<SavedFeed> feeds;
  final String? message;
  final FeedPreferencesState? previousState;

  List<SavedFeed> get pinnedFeeds => feeds.where((f) => f.pinned).toList();

  List<SavedFeed> get unpinnedFeeds => feeds.where((f) => !f.pinned).toList();

  FeedPreferencesState copyWith({
    FeedPreferencesStatus? status,
    List<SavedFeed>? feeds,
    String? message,
    FeedPreferencesState? previousState,
  }) {
    return FeedPreferencesState._(
      status: status ?? this.status,
      feeds: feeds ?? this.feeds,
      message: message ?? this.message,
      previousState: previousState ?? this.previousState,
    );
  }

  @override
  List<Object?> get props => [status, feeds, message, previousState];
}
