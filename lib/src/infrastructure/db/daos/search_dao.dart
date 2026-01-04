import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'search_dao.g.dart';

@DriftAccessor(tables: [RecentSearches])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  /// Adds or updates a recent search entry.
  ///
  /// If the query already exists, updates its timestamp.
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    await into(recentSearches).insert(
      RecentSearchesCompanion.insert(query: trimmed, searchedAt: DateTime.now()),
      onConflict: DoUpdate(
        (old) => RecentSearchesCompanion(searchedAt: Value(DateTime.now())),
        target: [recentSearches.query],
      ),
    );
  }

  /// Gets recent searches ordered by most recent first.
  Future<List<RecentSearche>> getRecentSearches({int limit = 10}) =>
      (select(recentSearches)
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(limit))
          .get();

  /// Watches recent searches as a stream.
  Stream<List<RecentSearche>> watchRecentSearches({int limit = 10}) =>
      (select(recentSearches)
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(limit))
          .watch();

  /// Deletes a specific recent search by query.
  Future<int> deleteRecentSearch(String query) =>
      (delete(recentSearches)..where((t) => t.query.equals(query))).go();

  /// Clears all recent searches.
  Future<int> clearAllRecentSearches() => delete(recentSearches).go();
}
