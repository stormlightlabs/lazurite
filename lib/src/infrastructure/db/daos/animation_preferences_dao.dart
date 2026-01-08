import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'animation_preferences_dao.g.dart';

/// Keys for animation preference settings.
abstract final class AnimationPreferenceKeys {
  /// Animation mode setting (full/reduced/minimal/system).
  static const mode = 'mode';

  /// Speed multiplier setting (0.5 to 2.0).
  static const speedMultiplier = 'speedMultiplier';
}

/// Data access object for animation preferences.
///
/// Stores and retrieves animation settings using key-value pairs
/// for flexibility and easy extensibility.
@DriftAccessor(tables: [AnimationPreferencesTable])
class AnimationPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$AnimationPreferencesDaoMixin {
  AnimationPreferencesDao(super.db);

  /// Gets a preference value by key, or null if not set.
  Future<String?> get(String key) async {
    final query = select(animationPreferencesTable)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  /// Sets a preference value, creating or updating as needed.
  Future<void> set(String key, String value) async {
    await into(animationPreferencesTable).insertOnConflictUpdate(
      AnimationPreferencesTableCompanion.insert(key: key, value: value, updatedAt: DateTime.now()),
    );
  }

  /// Watches a preference value reactively.
  Stream<String?> watch(String key) {
    final query = select(animationPreferencesTable)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  /// Removes a preference by key. Returns 1 if removed, 0 if not found.
  Future<int> remove(String key) async {
    return (delete(animationPreferencesTable)..where((t) => t.key.equals(key))).go();
  }

  /// Gets all animation preferences as a map.
  Future<Map<String, String>> getAll() async {
    final rows = await select(animationPreferencesTable).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Clears all animation preferences.
  Future<int> clearAll() async {
    return delete(animationPreferencesTable).go();
  }
}
