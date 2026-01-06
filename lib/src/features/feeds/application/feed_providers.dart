import 'dart:async';

import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_providers.g.dart';

@riverpod
FeedRepository feedRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('FeedRepository'));
  return FeedRepository(api, db.savedFeedsDao, db.preferenceSyncQueueDao, db.profileDao, logger);
}

/// Domain model for saved feed data (mirrors SavedFeed but is code-generator compatible).
class SavedFeedData {
  SavedFeedData({
    required this.uri,
    required this.displayName,
    this.description,
    this.avatar,
    required this.creatorDid,
    required this.likeCount,
    required this.sortOrder,
    required this.isPinned,
    required this.lastSynced,
  });

  final String uri;
  final String displayName;
  final String? description;
  final String? avatar;
  final String creatorDid;
  final int likeCount;
  final int sortOrder;
  final bool isPinned;
  final DateTime lastSynced;

  /// Creates a SavedFeedData from a Drift SavedFeed entity.
  static SavedFeedData fromEntity(SavedFeed entity) {
    return SavedFeedData(
      uri: entity.uri,
      displayName: entity.displayName,
      description: entity.description,
      avatar: entity.avatar,
      creatorDid: entity.creatorDid,
      likeCount: entity.likeCount,
      sortOrder: entity.sortOrder,
      isPinned: entity.isPinned,
      lastSynced: entity.lastSynced,
    );
  }
}

/// Notifier for watching all saved feeds reactively.
@riverpod
class AllFeedsNotifier extends _$AllFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() {
    final repository = ref.watch(feedRepositoryProvider);
    return repository.watchAllFeeds().map((list) => list.map(SavedFeedData.fromEntity).toList());
  }
}

/// Notifier for watching pinned feeds reactively.
@riverpod
class PinnedFeedsNotifier extends _$PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() {
    final repository = ref.watch(feedRepositoryProvider);
    return repository.watchPinnedFeeds().map(
      (list) => list.map(SavedFeedData.fromEntity).toList(),
    );
  }
}

/// Notifier for syncing saved feeds from remote preferences.
@riverpod
class SavedFeedsNotifier extends _$SavedFeedsNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Syncs saved feeds from user preferences (app.bsky.actor.getPreferences).
  Future<void> sync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.syncPreferences();
    });
  }

  /// Refreshes stale feed metadata (not synced in 24 hours).
  Future<void> refreshStaleMetadata() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.refreshStaleMetadata();
    });
  }
}

/// Notifier for feed mutations (save, remove, pin).
@riverpod
class FeedMutationNotifier extends _$FeedMutationNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Saves a feed to user preferences and local cache.
  Future<void> saveFeed(String feedUri, {bool pin = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.saveFeed(feedUri, pin: pin);
    });
  }

  /// Removes a feed from user preferences and local cache.
  Future<void> removeFeed(String feedUri) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.removeFeed(feedUri);
    });
  }

  /// Reorders feeds according to the provided URI list.
  Future<void> reorder(List<String> orderedUris) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.reorderFeeds(orderedUris);
    });
  }
}

/// Notifier for discovering trending feeds.
@riverpod
class DiscoverFeedsNotifier extends _$DiscoverFeedsNotifier {
  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    return const AsyncData([]);
  }

  /// Discovers trending feeds from app.bsky.unspecced.getPopularFeedGenerators.
  Future<void> discover({int limit = 50}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      return repository.discoverFeeds(limit: limit);
    });
  }
}

/// Notifier for tracking the currently active feed.
///
/// This notifier maintains the URI of the currently selected feed and allows
/// switching between feeds. The feed content will reactively update based on this value.
///
/// For authenticated users, defaults to their top pinned feed (by sort order).
/// Falls back to home feed if no pinned feeds exist.
/// For unauthenticated users, defaults to the Discover (What's Hot) feed.
@riverpod
class ActiveFeed extends _$ActiveFeed {
  bool _hasUserSwitched = false;

  @override
  String build() {
    final authState = ref.watch(authProvider);

    if (authState is AuthStateAuthenticated) {
      ref.listen(pinnedFeedsProvider, (previous, next) {
        if (_hasUserSwitched) return;

        next.whenData((feeds) {
          if (feeds.isNotEmpty && state == FeedRepository.kHomeFeedUri) {
            state = feeds.first.uri;
          }
        });
      });

      return FeedRepository.kHomeFeedUri;
    }
    return FeedRepository.kDiscoverFeedUri;
  }

  /// Switches to a different feed.
  ///
  /// Updates the active feed URI, which will trigger feed content reload in FeedContentNotifier.
  void switchFeed(String feedUri) {
    _hasUserSwitched = true;
    state = feedUri;
  }

  /// Switches to the home feed.
  void switchToHome() {
    _hasUserSwitched = true;
    state = FeedRepository.kHomeFeedUri;
  }

  /// Switches to the discover feed.
  void switchToDiscover() {
    _hasUserSwitched = true;
    state = FeedRepository.kDiscoverFeedUri;
  }
}

enum FeedSortOption { popularity, name }

class FeedSearchState {
  const FeedSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.localFilter = '',
    this.sortBy = FeedSortOption.popularity,
  });

  final String query;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? error;
  final String localFilter;
  final FeedSortOption sortBy;

  FeedSearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    bool? isLoading,
    String? error,
    String? localFilter,
    FeedSortOption? sortBy,
  }) {
    return FeedSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      localFilter: localFilter ?? this.localFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  List<Map<String, dynamic>> get filteredResults {
    var filtered = List<Map<String, dynamic>>.from(results);

    if (localFilter.isNotEmpty) {
      final filter = localFilter.toLowerCase();
      filtered = filtered.where((feed) {
        final name = (feed['displayName'] as String? ?? '').toLowerCase();
        final description = (feed['description'] as String? ?? '').toLowerCase();
        return name.contains(filter) || description.contains(filter);
      }).toList();
    }

    if (sortBy == FeedSortOption.name) {
      filtered.sort((a, b) {
        final nameA = (a['displayName'] as String? ?? '').toLowerCase();
        final nameB = (b['displayName'] as String? ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });
    } else {
      filtered.sort((a, b) {
        final likesA = (a['likeCount'] as int? ?? 0);
        final likesB = (b['likeCount'] as int? ?? 0);
        return likesB.compareTo(likesA);
      });
    }
    return filtered;
  }
}

@riverpod
class FeedSearch extends _$FeedSearch {
  Timer? _debounceTimer;

  @override
  FeedSearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    Future.microtask(() => _search());
    return const FeedSearchState();
  }

  void setQuery(String query) {
    if (query == state.query) return;

    _debounceTimer?.cancel();
    state = state.copyWith(query: query, error: null);

    if (query.isEmpty) {
      _search();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        state = state.copyWith(isLoading: true);
        _search();
      });
    }
  }

  void setLocalFilter(String filter) {
    state = state.copyWith(localFilter: filter);
  }

  void setSortOption(FeedSortOption option) {
    state = state.copyWith(sortBy: option);
  }

  Future<void> _search() async {
    try {
      if (!state.isLoading) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final repository = ref.read(feedRepositoryProvider);
      final results = await repository.discoverFeeds(
        query: state.query.isEmpty ? null : state.query,
      );
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    _search();
  }
}
