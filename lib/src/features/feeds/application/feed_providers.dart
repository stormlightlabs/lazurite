import 'dart:async';

import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
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
    final authState = ref.watch(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      return const Stream.empty();
    }

    final repository = ref.watch(feedRepositoryProvider);
    return repository.watchAllFeeds(ownerDid).map((list) {
      return list.map(SavedFeedData.fromEntity).toList();
    });
  }
}

/// Notifier for watching pinned feeds reactively.
@riverpod
class PinnedFeedsNotifier extends _$PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() {
    final authState = ref.watch(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      return const Stream.empty();
    }

    final logger = ref.watch(loggerProvider('PinnedFeedsNotifier'));
    final repository = ref.watch(feedRepositoryProvider);
    return repository.watchPinnedFeeds(ownerDid).map((list) {
      final data = list.map(SavedFeedData.fromEntity).toList();
      if (data.isNotEmpty) {
        logger.debug(
          'Emitting ${data.length} feeds, first: ${data.first.displayName} (sortOrder=${data.first.sortOrder})',
        );
      } else {
        logger.debug('Emitting empty list');
      }
      return data;
    });
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
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.syncPreferences(authState.session.did);
    });
  }

  /// Refreshes stale feed metadata (not synced in 24 hours).
  Future<void> refreshStaleMetadata() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.refreshStaleMetadata(authState.session.did);
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
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      state = AsyncError(StateError('Must be authenticated'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.saveFeed(feedUri, authState.session.did, pin: pin);
    });
  }

  /// Removes a feed from user preferences and local cache.
  Future<void> removeFeed(String feedUri) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      state = AsyncError(StateError('Must be authenticated'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.removeFeed(feedUri, authState.session.did);
    });
  }

  /// Reorders feeds according to the provided URI list.
  Future<void> reorder(List<String> orderedUris) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      state = AsyncError(StateError('Must be authenticated'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      await repository.reorderFeeds(orderedUris, authState.session.did);
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
  String? _lastResolvedFeed;

  @override
  String build() {
    final authState = ref.watch(authProvider);
    final logger = ref.watch(loggerProvider('ActiveFeed'));

    if (authState is AuthStateAuthenticated) {
      ref.listen(pinnedFeedsProvider, _handlePinnedFeedsChanged);
      final pinnedFeeds = ref.watch(pinnedFeedsProvider).asData?.value;

      if (!_hasUserSwitched && pinnedFeeds != null && pinnedFeeds.isNotEmpty) {
        _lastResolvedFeed = pinnedFeeds.first.uri;
        logger.debug('Initial build: using first pinned feed ${pinnedFeeds.first.displayName}');
        return _lastResolvedFeed!;
      }

      logger.debug(
        'Initial build: falling back to ${_lastResolvedFeed ?? FeedRepository.kDiscoverFeedUri}',
      );
      return _lastResolvedFeed ?? FeedRepository.kDiscoverFeedUri;
    }
    _hasUserSwitched = false;
    _lastResolvedFeed = null;
    return FeedRepository.kDiscoverFeedUri;
  }

  /// Switches to a different feed.
  ///
  /// Updates the active feed URI, which will trigger feed content reload in FeedContentNotifier.
  void switchFeed(String feedUri) {
    _hasUserSwitched = true;
    _lastResolvedFeed = feedUri;
    state = feedUri;
  }

  /// Switches to the discover feed.
  void switchToDiscover() {
    _hasUserSwitched = true;
    _lastResolvedFeed = FeedRepository.kDiscoverFeedUri;
    state = FeedRepository.kDiscoverFeedUri;
  }

  /// Resets to the default feed based on authentication status.
  void resetToDefault({required bool isAuthenticated}) {
    _hasUserSwitched = false;

    if (isAuthenticated) {
      final feeds = ref.read(pinnedFeedsProvider).asData?.value;
      if (feeds != null && feeds.isNotEmpty) {
        _updateState(feeds.first.uri);
        return;
      }
    }

    _updateState(FeedRepository.kDiscoverFeedUri);
  }

  void _handlePinnedFeedsChanged(
    AsyncValue<List<SavedFeedData>>? previous,
    AsyncValue<List<SavedFeedData>> next,
  ) {
    final logger = ref.read(loggerProvider('ActiveFeed'));
    next.whenData((feeds) {
      if (feeds.isEmpty) {
        logger.debug('Pinned feeds empty, switching to Discover');
        if (!_hasUserSwitched) {
          _updateState(FeedRepository.kDiscoverFeedUri);
        }
        return;
      }

      final currentExists = feeds.any((feed) => feed.uri == state);
      if (!currentExists) {
        logger.debug('Current feed no longer exists, resetting hasUserSwitched');
        _hasUserSwitched = false;
      }

      if (!_hasUserSwitched) {
        final firstFeed = feeds.first;
        logger.debug(
          'Switching to first pinned feed: ${firstFeed.displayName} (sortOrder=${firstFeed.sortOrder}, uri=${firstFeed.uri})',
        );
        _updateState(feeds.first.uri);
      }
    });
  }

  void _updateState(String feedUri) {
    _lastResolvedFeed = feedUri;
    state = feedUri;
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
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void refresh() {
    _search();
  }
}
