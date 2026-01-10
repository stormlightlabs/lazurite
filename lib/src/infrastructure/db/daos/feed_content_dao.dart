import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'feed_content_dao.g.dart';

/// DAO for managing feed content (posts from feeds).
///
/// This replaces TimelineDao with clearer naming that aligns with BlueSky's
/// feed-based architecture. Uses the same underlying tables (Posts, Profiles,
/// FeedContentItems, FeedCursors).
@DriftAccessor(
  tables: [Posts, Profiles, ProfileRelationships, PostInteractions, FeedContentItems, FeedCursors],
)
class FeedContentDao extends DatabaseAccessor<AppDatabase> with _$FeedContentDaoMixin {
  FeedContentDao(super.db);

  /// Inserts or updates a batch of posts, profiles, and feed content items.
  /// Also updates the cursor for the given [feedKey] and [ownerDid].
  Future<void> insertFeedContentBatch({
    required List<PostsCompanion> newPosts,
    required List<ProfilesCompanion> newProfiles,
    required List<ProfileRelationshipsCompanion> newRelationships,
    required List<FeedContentItemsCompanion> newItems,
    required String feedKey,
    required String ownerDid,
    String? newCursor,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(profileRelationships, newRelationships, mode: InsertMode.insertOrReplace);
        batch.insertAll(posts, newPosts, mode: InsertMode.insertOrReplace);
        batch.insertAll(
          feedContentItems,
          newItems.map(
            (item) => FeedContentItemsCompanion.insert(
              feedKey: item.feedKey.value,
              postUri: item.postUri.value,
              ownerDid: ownerDid,
              reason: item.reason,
              sortKey: item.sortKey.value,
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });

      if (newCursor != null) {
        await into(feedCursors).insertOnConflictUpdate(
          FeedCursorsCompanion.insert(
            feedKey: feedKey,
            ownerDid: ownerDid,
            cursor: newCursor,
            lastUpdated: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Get stream of feed content items for a given feed and owner.
  Stream<List<FeedPost>> watchFeedContent(String feedKey, String ownerDid) {
    final query = select(feedContentItems).join([
      innerJoin(posts, posts.uri.equalsExp(feedContentItems.postUri)),
      innerJoin(profiles, profiles.did.equalsExp(posts.authorDid)),
      leftOuterJoin(profileRelationships, profileRelationships.profileDid.equalsExp(profiles.did)),
      leftOuterJoin(
        postInteractions,
        postInteractions.postUri.equalsExp(posts.uri) &
            postInteractions.ownerDid.equalsExp(feedContentItems.ownerDid),
      ),
    ]);

    query.where(
      feedContentItems.feedKey.equals(feedKey) & feedContentItems.ownerDid.equals(ownerDid),
    );
    query.orderBy([OrderingTerm.desc(feedContentItems.sortKey)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final feedItem = row.readTable(feedContentItems);
        return FeedPost(
          post: row.readTable(posts),
          author: row.readTable(profiles),
          relationship: row.readTableOrNull(profileRelationships),
          interaction: row.readTableOrNull(postInteractions),
          reason: feedItem.reason,
        );
      }).toList();
    });
  }

  /// Gets the cursor for a specific feed and owner.
  Future<String?> getCursor(String feedKey, String ownerDid) async {
    final query = select(feedCursors)
      ..where((t) => t.feedKey.equals(feedKey) & t.ownerDid.equals(ownerDid));
    final result = await query.getSingleOrNull();
    return result?.cursor;
  }

  /// Clears all cached items for a specific feed and owner.
  Future<void> clearFeedContent(String feedKey, String ownerDid) async {
    await (delete(
      feedContentItems,
    )..where((t) => t.feedKey.equals(feedKey) & t.ownerDid.equals(ownerDid))).go();
    await (delete(
      feedCursors,
    )..where((t) => t.feedKey.equals(feedKey) & t.ownerDid.equals(ownerDid))).go();
  }

  /// Deletes feed content items and cursors for feeds not updated since [threshold] for a specific user.
  Future<int> deleteStaleFeedContentItems(DateTime threshold, String ownerDid) async {
    return transaction(() async {
      final staleCursors =
          await (select(feedCursors)
                ..where((t) => t.ownerDid.equals(ownerDid))
                ..where((t) => t.lastUpdated.isSmallerThanValue(threshold)))
              .get();

      int deletedCount = 0;

      for (final cursor in staleCursors) {
        deletedCount += await (delete(
          feedContentItems,
        )..where((t) => t.feedKey.equals(cursor.feedKey) & t.ownerDid.equals(ownerDid))).go();
        await (delete(
          feedCursors,
        )..where((t) => t.feedKey.equals(cursor.feedKey) & t.ownerDid.equals(ownerDid))).go();
      }

      return deletedCount;
    });
  }
}

/// Represents a post with its author and feed-specific metadata.
///
/// Combines post content, author profile, and feed-specific data like repost reason.
class FeedPost {
  FeedPost({
    required this.post,
    required this.author,
    this.relationship,
    this.interaction,
    this.reason,
  });

  final Post post;
  final Profile author;
  final ProfileRelationship? relationship;
  final PostInteraction? interaction;

  /// Feed-specific reason (e.g., repost information as JSON).
  final String? reason;
}
