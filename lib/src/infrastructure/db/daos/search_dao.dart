import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'search_dao.g.dart';

@DriftAccessor(tables: [RecentSearches])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  /// Adds or updates a recent search entry.
  ///
  /// If the query already exists for this user, updates its timestamp.
  Future<void> addRecentSearch(String query, String ownerDid) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    await into(recentSearches).insert(
      RecentSearchesCompanion.insert(
        query: trimmed,
        ownerDid: ownerDid,
        searchedAt: DateTime.now(),
      ),
      onConflict: DoUpdate(
        (old) => RecentSearchesCompanion(searchedAt: Value(DateTime.now())),
        target: [recentSearches.ownerDid, recentSearches.query],
      ),
    );
  }

  /// Gets recent searches ordered by most recent first.
  Future<List<RecentSearche>> getRecentSearches(String ownerDid, {int limit = 10}) =>
      (select(recentSearches)
            ..where((t) => t.ownerDid.equals(ownerDid))
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(limit))
          .get();

  /// Watches recent searches as a stream.
  Stream<List<RecentSearche>> watchRecentSearches(String ownerDid, {int limit = 10}) =>
      (select(recentSearches)
            ..where((t) => t.ownerDid.equals(ownerDid))
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(limit))
          .watch();

  /// Deletes a specific recent search by query.
  Future<int> deleteRecentSearch(String query, String ownerDid) => (delete(
    recentSearches,
  )..where((t) => t.query.equals(query) & t.ownerDid.equals(ownerDid))).go();

  /// Clears all recent searches for a specific user.
  Future<int> clearAllRecentSearches(String ownerDid) =>
      (delete(recentSearches)..where((t) => t.ownerDid.equals(ownerDid))).go();
}
