import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'follows_dao.g.dart';

/// DAO for managing follow relationships.
@DriftAccessor(tables: [Follows])
class FollowsDao extends DatabaseAccessor<AppDatabase> with _$FollowsDaoMixin {
  FollowsDao(super.db);

  /// Inserts or updates a follow relationship.
  Future<void> upsertFollow(FollowsCompanion follow) {
    return into(follows).insertOnConflictUpdate(follow);
  }

  /// Deletes a follow relationship between two users.
  Future<int> deleteFollow(String actorDid, String subjectDid) {
    return (delete(
      follows,
    )..where((t) => t.actorDid.equals(actorDid) & t.subjectDid.equals(subjectDid))).go();
  }

  /// Gets a follow record if it exists.
  Future<Follow?> getFollow(String actorDid, String subjectDid) {
    return (select(follows)
          ..where((t) => t.actorDid.equals(actorDid) & t.subjectDid.equals(subjectDid)))
        .getSingleOrNull();
  }

  /// Watches a follow relationship reactively.
  Stream<Follow?> watchFollow(String actorDid, String subjectDid) {
    return (select(follows)
          ..where((t) => t.actorDid.equals(actorDid) & t.subjectDid.equals(subjectDid)))
        .watchSingleOrNull();
  }

  /// Gets all accounts the actor is following.
  Future<List<Follow>> getFollowsByActor(String actorDid) {
    return (select(follows)..where((t) => t.actorDid.equals(actorDid))).get();
  }

  /// Deletes a follow by its URI.
  Future<int> deleteFollowByUri(String uri) {
    return (delete(follows)..where((t) => t.uri.equals(uri))).go();
  }
}
