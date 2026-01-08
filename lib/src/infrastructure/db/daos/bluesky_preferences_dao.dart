import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'bluesky_preferences_dao.g.dart';

/// Data access object for Bluesky account preferences.
///
/// Stores and retrieves preferences synced from the remote Bluesky server.
/// Each preference type (content labels, labelers, feed view, etc.) is stored
/// as a JSON blob keyed by its type identifier.
@DriftAccessor(tables: [BlueskyPreferences])
class BlueskyPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$BlueskyPreferencesDaoMixin {
  BlueskyPreferencesDao(super.db);

  /// Gets a preference by its type identifier.
  ///
  /// Returns null if no preference of that type exists.
  Future<BlueskyPreference?> getPreferenceByType(String type, String ownerDid) async {
    final query = select(blueskyPreferences)
      ..where((t) => t.type.equals(type) & t.ownerDid.equals(ownerDid));
    return query.getSingleOrNull();
  }

  /// Watches a preference by its type identifier.
  ///
  /// Emits null if no preference of that type exists.
  Stream<BlueskyPreference?> watchPreferenceByType(String type, String ownerDid) {
    final query = select(blueskyPreferences)
      ..where((t) => t.type.equals(type) & t.ownerDid.equals(ownerDid));
    return query.watchSingleOrNull();
  }

  /// Gets all cached preferences for a specific owner.
  Future<List<BlueskyPreference>> getAllPreferences(String ownerDid) async {
    return (select(blueskyPreferences)..where((t) => t.ownerDid.equals(ownerDid))).get();
  }

  /// Watches all cached preferences for a specific owner.
  Stream<List<BlueskyPreference>> watchAllPreferences(String ownerDid) {
    return (select(blueskyPreferences)..where((t) => t.ownerDid.equals(ownerDid))).watch();
  }

  /// Inserts or updates a preference.
  ///
  /// If a preference with the same type exists, it will be updated.
  Future<void> upsertPreference({
    required String type,
    required String data,
    required DateTime lastSynced,
    required String ownerDid,
  }) async {
    await into(blueskyPreferences).insertOnConflictUpdate(
      BlueskyPreferencesCompanion.insert(
        type: type,
        ownerDid: ownerDid,
        data: data,
        lastSynced: lastSynced,
      ),
    );
  }

  /// Deletes a preference by its type identifier.
  ///
  /// Returns 1 if deleted, 0 if not found.
  Future<int> deletePreference(String type, String ownerDid) async {
    return (delete(
      blueskyPreferences,
    )..where((t) => t.type.equals(type) & t.ownerDid.equals(ownerDid))).go();
  }

  /// Clears all cached preferences for a specific owner.
  ///
  /// Useful when signing out or resetting the app.
  Future<int> clearAll(String ownerDid) async {
    return (delete(blueskyPreferences)..where((t) => t.ownerDid.equals(ownerDid))).go();
  }
}
