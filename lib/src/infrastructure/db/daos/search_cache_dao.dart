import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'search_cache_dao.g.dart';

/// DAO for managing search result caching.
///
/// Caches search results for offline access and performance.
/// Uses 7-day retention policy matching feed content caching.
@DriftAccessor(tables: [Posts, Profiles, SearchCacheItems, SearchCacheCursors])
class SearchCacheDao extends DatabaseAccessor<AppDatabase> with _$SearchCacheDaoMixin {
  SearchCacheDao(super.db);

  /// Inserts or updates a batch of posts, profiles, and search cache items.
  /// Also updates the cursor for the given [queryKey].
  Future<void> insertSearchBatch({
    required List<PostsCompanion> newPosts,
    required List<ProfilesCompanion> newProfiles,
    required List<SearchCacheItemsCompanion> newItems,
    required String queryKey,
    String? newCursor,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(posts, newPosts, mode: InsertMode.insertOrReplace);
        batch.insertAll(
          searchCacheItems,
          newItems.map(
            (item) => SearchCacheItemsCompanion.insert(
              queryKey: item.queryKey.value,
              postUri: item.postUri.value,
              sortKey: item.sortKey.value,
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });

      if (newCursor != null) {
        await into(searchCacheCursors).insertOnConflictUpdate(
          SearchCacheCursorsCompanion.insert(
            queryKey: queryKey,
            cursor: newCursor,
            lastUpdated: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Watches cached search results for a given query.
  Stream<List<SearchPost>> watchSearchResults(String queryKey) {
    final query = select(searchCacheItems).join([
      innerJoin(posts, posts.uri.equalsExp(searchCacheItems.postUri)),
      innerJoin(profiles, profiles.did.equalsExp(posts.authorDid)),
    ]);

    query.where(searchCacheItems.queryKey.equals(queryKey));
    query.orderBy([OrderingTerm.asc(searchCacheItems.sortKey)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return SearchPost(post: row.readTable(posts), author: row.readTable(profiles));
      }).toList();
    });
  }

  /// Gets cached search results for a given query (non-reactive).
  Future<List<SearchPost>> getSearchResults(String queryKey) async {
    final query = select(searchCacheItems).join([
      innerJoin(posts, posts.uri.equalsExp(searchCacheItems.postUri)),
      innerJoin(profiles, profiles.did.equalsExp(posts.authorDid)),
    ]);

    query.where(searchCacheItems.queryKey.equals(queryKey));
    query.orderBy([OrderingTerm.asc(searchCacheItems.sortKey)]);

    final rows = await query.get();
    return rows.map((row) {
      return SearchPost(post: row.readTable(posts), author: row.readTable(profiles));
    }).toList();
  }

  /// Gets the cursor for a specific query.
  Future<String?> getCursor(String queryKey) async {
    final query = select(searchCacheCursors)..where((t) => t.queryKey.equals(queryKey));
    final result = await query.getSingleOrNull();
    return result?.cursor;
  }

  /// Clears all cached items for a specific query.
  Future<void> clearSearchCache(String queryKey) async {
    await (delete(searchCacheItems)..where((t) => t.queryKey.equals(queryKey))).go();
    await (delete(searchCacheCursors)..where((t) => t.queryKey.equals(queryKey))).go();
  }

  /// Deletes search cache items and cursors not updated since [threshold].
  Future<int> deleteStaleCacheItems(DateTime threshold) async {
    return transaction(() async {
      final staleCursors = await (select(
        searchCacheCursors,
      )..where((t) => t.lastUpdated.isSmallerThanValue(threshold))).get();

      int deletedCount = 0;

      for (final cursor in staleCursors) {
        deletedCount += await (delete(
          searchCacheItems,
        )..where((t) => t.queryKey.equals(cursor.queryKey))).go();
        await (delete(searchCacheCursors)..where((t) => t.queryKey.equals(cursor.queryKey))).go();
      }

      return deletedCount;
    });
  }
}

/// Represents a post from search results with its author.
class SearchPost {
  SearchPost({required this.post, required this.author});

  final Post post;
  final Profile author;
}
