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
  Future<int> deleteFeed(String uri, String ownerDid) {
    return (delete(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .go();
  }

  /// Deletes all saved feeds for a specific owner.
  ///
  /// Used when clearing cache or during user logout.
  Future<int> deleteAllFeeds(String ownerDid) {
    return (delete(savedFeeds)..where((t) => t.ownerDid.equals(ownerDid))).go();
  }

  /// Gets a saved feed by URI.
  Future<SavedFeed?> getFeed(String uri, String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .getSingleOrNull();
  }

  /// Watches a saved feed reactively.
  Stream<SavedFeed?> watchFeed(String uri, String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .watchSingleOrNull();
  }

  /// Gets all saved feeds ordered by sortOrder.
  Future<List<SavedFeed>> getAllFeeds(String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Watches all saved feeds reactively, ordered by sortOrder.
  Stream<List<SavedFeed>> watchAllFeeds(String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Gets all pinned feeds ordered by sortOrder.
  Future<List<SavedFeed>> getPinnedFeeds(String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.isPinned.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Watches pinned feeds reactively, ordered by sortOrder.
  Stream<List<SavedFeed>> watchPinnedFeeds(String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.isPinned.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Gets feeds that haven't been synced recently (stale metadata).
  ///
  /// Returns feeds where lastSynced is older than the given threshold.
  Future<List<SavedFeed>> getStaleFeeds(DateTime threshold, String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.lastSynced.isSmallerThanValue(threshold)))
        .get();
  }

  /// Updates the sortOrder for a feed and marks it as locally modified.
  Future<int> updateSortOrder(String uri, int sortOrder, String ownerDid) {
    return (update(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .write(
          SavedFeedsCompanion(sortOrder: Value(sortOrder), localUpdatedAt: Value(DateTime.now())),
        );
  }

  /// Updates the isPinned status for a feed.
  Future<int> updatePinnedStatus(String uri, bool isPinned, String ownerDid) {
    return (update(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .write(
          SavedFeedsCompanion(isPinned: Value(isPinned), localUpdatedAt: Value(DateTime.now())),
        );
  }

  /// Clears the localUpdatedAt timestamp after successful remote sync.
  ///
  /// This marks the feed as "in sync" with the remote state.
  Future<int> clearLocalModification(String uri, String ownerDid) {
    return (update(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid)))
        .write(const SavedFeedsCompanion(localUpdatedAt: Value(null)));
  }

  /// Updates sync-related fields for an existing feed.
  ///
  /// Used during sync merge operations to update sort order, pin status, and
  /// sync timestamps without requiring all fields. This only affects existing
  /// records - it will not insert a new record if the feed doesn't exist.
  ///
  /// We only apply sync updates if the user hasn't modified it locally since
  /// the sync started (implied by localUpdatedAt being null).
  ///
  /// If clearLocalModification is true, we clear the localUpdatedAt timestamp
  /// after successful remote sync.
  Future<int> updateSyncState({
    required String uri,
    required int sortOrder,
    required bool isPinned,
    required DateTime lastSynced,
    required String ownerDid,
    bool clearLocalModification = false,
  }) {
    return (update(savedFeeds)
          ..where((t) => t.uri.equals(uri))
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.localUpdatedAt.isNull()))
        .write(
          SavedFeedsCompanion(
            sortOrder: Value(sortOrder),
            isPinned: Value(isPinned),
            lastSynced: Value(lastSynced),
            localUpdatedAt: clearLocalModification ? const Value(null) : const Value.absent(),
          ),
        );
  }

  /// Gets feeds with pending local modifications (localUpdatedAt != null).
  Future<List<SavedFeed>> getLocallyModifiedFeeds(String ownerDid) {
    return (select(savedFeeds)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.localUpdatedAt.isNotNull()))
        .get();
  }
}
