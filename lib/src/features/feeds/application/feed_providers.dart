import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
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
  return FeedRepository(api, db.savedFeedsDao, logger);
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
/// switching between feeds. The timeline will reactively update based on this value.
@riverpod
class ActiveFeed extends _$ActiveFeed {
  @override
  String build() {
    return FeedRepository.kHomeFeedUri;
  }

  /// Switches to a different feed.
  ///
  /// Updates the active feed URI, which will trigger timeline reload in
  /// TimelineNotifier.
  void switchFeed(String feedUri) {
    state = feedUri;
  }

  /// Switches to the home feed.
  void switchToHome() {
    state = FeedRepository.kHomeFeedUri;
  }

  /// Switches to the discover feed.
  void switchToDiscover() {
    state = FeedRepository.kDiscoverFeedUri;
  }
}
