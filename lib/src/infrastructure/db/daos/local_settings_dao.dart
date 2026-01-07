import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'local_settings_dao.g.dart';

/// Data access object for local app settings.
///
/// Settings are stored as key-value pairs for extensibility.
@DriftAccessor(tables: [LocalSettings])
class LocalSettingsDao extends DatabaseAccessor<AppDatabase> with _$LocalSettingsDaoMixin {
  LocalSettingsDao(super.db);

  /// Gets a setting value by key, or null if not set.
  Future<String?> get(String key) async {
    final query = select(localSettings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  /// Sets a setting value, creating or updating as needed.
  Future<void> set(String key, String value) async {
    await into(localSettings).insertOnConflictUpdate(
      LocalSettingsCompanion.insert(key: key, value: value, updatedAt: DateTime.now()),
    );
  }

  /// Watches a setting value reactively.
  Stream<String?> watch(String key) {
    final query = select(localSettings)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  /// Removes a setting by key. Returns 1 if removed, 0 if not found.
  Future<int> remove(String key) async {
    return (delete(localSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Gets all settings as a map.
  Future<Map<String, String>> getAll() async {
    final rows = await select(localSettings).get();
    return {for (final row in rows) row.key: row.value};
  }
}
