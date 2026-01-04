import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  /// Inserts or updates a single profile.
  Future<void> upsertProfile(ProfilesCompanion profile) {
    return into(profiles).insertOnConflictUpdate(profile);
  }

  /// Batch inserts or updates multiple profiles.
  Future<void> upsertProfiles(List<ProfilesCompanion> profileList) {
    return batch((batch) {
      batch.insertAll(profiles, profileList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Gets a single profile by DID.
  Future<Profile?> getProfile(String did) {
    return (select(profiles)..where((t) => t.did.equals(did))).getSingleOrNull();
  }

  /// Watches a single profile by DID.
  Stream<Profile?> watchProfile(String did) {
    return (select(profiles)..where((t) => t.did.equals(did))).watchSingleOrNull();
  }

  /// Gets all cached profiles.
  Future<List<Profile>> getAllProfiles() {
    return select(profiles).get();
  }

  /// Deletes a profile by DID.
  Future<int> deleteProfile(String did) {
    return (delete(profiles)..where((t) => t.did.equals(did))).go();
  }
}
