import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'saved_feeds_dao.g.dart';

/// DAO for managing saved feed generators.
///
/// Handles local caching of user's saved feeds from preferences and enriches
/// them with metadata from app.bsky.feed.getFeedGenerator.
@DriftAccessor(tables: [SavedFeeds])
class SavedFeedsDao extends DatabaseAccessor<AppDatabase> with _$SavedFeedsDaoMixin {
  SavedFeedsDao(super.db);

  /// Inserts or updates a saved feed.
  Future<void> upsertFeed(SavedFeedsCompanion feed) {
    return into(savedFeeds).insertOnConflictUpdate(feed);
  }

  /// Batch inserts or updates saved feeds.
  ///
  /// Used during preference sync to update multiple feeds at once.
  Future<void> upsertFeeds(List<SavedFeedsCompanion> feeds) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(savedFeeds, feeds);
    });
  }

  /// Deletes a saved feed by URI.
  Future<int> deleteFeed(String uri) {
    return (delete(savedFeeds)..where((t) => t.uri.equals(uri))).go();
  }

  /// Deletes all saved feeds.
  ///
  /// Used when clearing cache or during user logout.
  Future<int> deleteAllFeeds() {
    return delete(savedFeeds).go();
  }

  /// Gets a saved feed by URI.
  Future<SavedFeed?> getFeed(String uri) {
    return (select(savedFeeds)..where((t) => t.uri.equals(uri))).getSingleOrNull();
  }

  /// Watches a saved feed reactively.
  Stream<SavedFeed?> watchFeed(String uri) {
    return (select(savedFeeds)..where((t) => t.uri.equals(uri))).watchSingleOrNull();
  }

  /// Gets all saved feeds ordered by sortOrder.
  Future<List<SavedFeed>> getAllFeeds() {
    return (select(savedFeeds)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
  }

  /// Watches all saved feeds reactively, ordered by sortOrder.
  Stream<List<SavedFeed>> watchAllFeeds() {
    return (select(savedFeeds)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  }

  /// Gets all pinned feeds ordered by sortOrder.
  Future<List<SavedFeed>> getPinnedFeeds() {
    return (select(savedFeeds)
          ..where((t) => t.isPinned.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Watches pinned feeds reactively, ordered by sortOrder.
  Stream<List<SavedFeed>> watchPinnedFeeds() {
    return (select(savedFeeds)
          ..where((t) => t.isPinned.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Gets feeds that haven't been synced recently (stale metadata).
  ///
  /// Returns feeds where lastSynced is older than the given threshold.
  Future<List<SavedFeed>> getStaleFeeds(DateTime threshold) {
    return (select(savedFeeds)..where((t) => t.lastSynced.isSmallerThanValue(threshold))).get();
  }

  /// Updates the sortOrder for a feed.
  Future<int> updateSortOrder(String uri, int sortOrder) {
    return (update(
      savedFeeds,
    )..where((t) => t.uri.equals(uri))).write(SavedFeedsCompanion(sortOrder: Value(sortOrder)));
  }

  /// Updates the isPinned status for a feed.
  Future<int> updatePinnedStatus(String uri, bool isPinned) {
    return (update(
      savedFeeds,
    )..where((t) => t.uri.equals(uri))).write(SavedFeedsCompanion(isPinned: Value(isPinned)));
  }
}
