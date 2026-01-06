import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'profile_relationship_dao.g.dart';

@DriftAccessor(tables: [ProfileRelationships])
class ProfileRelationshipDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileRelationshipDaoMixin {
  ProfileRelationshipDao(super.db);

  /// Inserts or updates a viewer relationship.
  Future<void> upsertRelationship(ProfileRelationshipsCompanion relationship) {
    return into(profileRelationships).insertOnConflictUpdate(relationship);
  }

  /// Gets a viewer relationship by profile DID.
  Future<ProfileRelationship?> getRelationship(String profileDid) {
    return (select(
      profileRelationships,
    )..where((t) => t.profileDid.equals(profileDid))).getSingleOrNull();
  }

  /// Watches a viewer relationship by profile DID.
  Stream<ProfileRelationship?> watchRelationship(String profileDid) {
    return (select(
      profileRelationships,
    )..where((t) => t.profileDid.equals(profileDid))).watchSingleOrNull();
  }

  /// Updates the mute status for a profile.
  Future<void> updateMuteStatus(String profileDid, bool muted) {
    return (update(profileRelationships)..where((t) => t.profileDid.equals(profileDid))).write(
      ProfileRelationshipsCompanion(muted: Value(muted), updatedAt: Value(DateTime.now())),
    );
  }

  /// Updates the block status for a profile.
  Future<void> updateBlockStatus(String profileDid, bool blocked, {String? blockingUri}) {
    return (update(profileRelationships)..where((t) => t.profileDid.equals(profileDid))).write(
      ProfileRelationshipsCompanion(
        blocked: Value(blocked),
        blockingUri: Value(blockingUri),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
