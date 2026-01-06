import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'post_interactions_dao.g.dart';

/// DAO for managing viewer interactions with posts.
///
/// Tracks likes, reposts, bookmarks, and thread mutes for posts.
/// This provides a normalized way to query user engagement without
/// duplicating data when posts appear in multiple feeds.
@DriftAccessor(tables: [PostInteractions])
class PostInteractionsDao extends DatabaseAccessor<AppDatabase> with _$PostInteractionsDaoMixin {
  PostInteractionsDao(super.db);

  /// Inserts or updates a viewer interaction for a post.
  Future<void> upsertInteraction(PostInteractionsCompanion interaction) {
    return into(postInteractions).insertOnConflictUpdate(interaction);
  }

  /// Gets the viewer interaction for a specific post.
  Future<PostInteraction?> getInteraction(String postUri) {
    return (select(postInteractions)..where((t) => t.postUri.equals(postUri))).getSingleOrNull();
  }

  /// Watches the viewer interaction for a specific post.
  Stream<PostInteraction?> watchInteraction(String postUri) {
    return (select(postInteractions)..where((t) => t.postUri.equals(postUri))).watchSingleOrNull();
  }

  /// Batch upserts multiple viewer interactions.
  Future<void> batchUpsert(List<PostInteractionsCompanion> interactions) {
    return batch((b) {
      b.insertAll(postInteractions, interactions, mode: InsertMode.insertOrReplace);
    });
  }

  /// Gets all liked posts (where likeUri is not null).
  Stream<List<PostInteraction>> watchLikedPosts() {
    return (select(postInteractions)..where((t) => t.likeUri.isNotNull())).watch();
  }

  /// Gets all bookmarked posts.
  Stream<List<PostInteraction>> watchBookmarkedPosts() {
    return (select(postInteractions)..where((t) => t.bookmarked.equals(true))).watch();
  }

  /// Removes interaction record for a post.
  Future<int> deleteInteraction(String postUri) {
    return (delete(postInteractions)..where((t) => t.postUri.equals(postUri))).go();
  }
}
