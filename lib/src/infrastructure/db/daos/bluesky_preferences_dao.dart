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
  Future<BlueskyPreference?> getPreferenceByType(String type) async {
    final query = select(blueskyPreferences)..where((t) => t.type.equals(type));
    return query.getSingleOrNull();
  }

  /// Watches a preference by its type identifier.
  ///
  /// Emits null if no preference of that type exists.
  Stream<BlueskyPreference?> watchPreferenceByType(String type) {
    final query = select(blueskyPreferences)..where((t) => t.type.equals(type));
    return query.watchSingleOrNull();
  }

  /// Gets all cached preferences.
  Future<List<BlueskyPreference>> getAllPreferences() async {
    return select(blueskyPreferences).get();
  }

  /// Watches all cached preferences.
  Stream<List<BlueskyPreference>> watchAllPreferences() {
    return select(blueskyPreferences).watch();
  }

  /// Inserts or updates a preference.
  ///
  /// If a preference with the same type exists, it will be updated.
  Future<void> upsertPreference({
    required String type,
    required String data,
    required DateTime lastSynced,
  }) async {
    await into(blueskyPreferences).insertOnConflictUpdate(
      BlueskyPreferencesCompanion.insert(type: type, data: data, lastSynced: lastSynced),
    );
  }

  /// Deletes a preference by its type identifier.
  ///
  /// Returns 1 if deleted, 0 if not found.
  Future<int> deletePreference(String type) async {
    return (delete(blueskyPreferences)..where((t) => t.type.equals(type))).go();
  }

  /// Clears all cached preferences.
  ///
  /// Useful when signing out or resetting the app.
  Future<int> clearAll() async {
    return delete(blueskyPreferences).go();
  }
}
