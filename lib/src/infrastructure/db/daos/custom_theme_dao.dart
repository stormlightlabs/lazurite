import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';

import '../app_database.dart';
import '../tables.dart';

part 'custom_theme_dao.g.dart';

/// Data access object for custom user themes.
///
/// Provides CRUD operations and reactive watching for persisted custom themes.
@DriftAccessor(tables: [CustomThemes])
class CustomThemeDao extends DatabaseAccessor<AppDatabase> with _$CustomThemeDaoMixin {
  CustomThemeDao(super.db);

  /// Watches all custom themes, ordered by creation date (newest first).
  Stream<List<CustomThemeDraft>> watchAll() {
    final query = select(customThemes)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_rowToDraft).toList());
  }

  /// Gets all custom themes, ordered by creation date (newest first).
  Future<List<CustomThemeDraft>> getAll() async {
    final query = select(customThemes)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_rowToDraft).toList();
  }

  /// Gets a custom theme by ID, or null if not found.
  Future<CustomThemeDraft?> getById(String id) async {
    final query = select(customThemes)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToDraft(row) : null;
  }

  /// Watches a specific custom theme by ID.
  Stream<CustomThemeDraft?> watchById(String id) {
    final query = select(customThemes)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map((row) => row != null ? _rowToDraft(row) : null);
  }

  /// Saves a custom theme, creating or updating as needed.
  Future<void> save(CustomThemeDraft draft) async {
    await into(customThemes).insertOnConflictUpdate(_draftToCompanion(draft));
  }

  /// Deletes a custom theme by ID. Returns 1 if deleted, 0 if not found.
  Future<int> deleteById(String id) async {
    return (delete(customThemes)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all custom themes. Returns the number deleted.
  Future<int> deleteAll() async {
    return delete(customThemes).go();
  }

  /// Converts a database row to a domain model.
  CustomThemeDraft _rowToDraft(CustomTheme row) {
    final overridesJson = row.overridesJson.isNotEmpty
        ? jsonDecode(row.overridesJson) as Map<String, dynamic>
        : <String, dynamic>{};

    return CustomThemeDraft(
      id: row.id,
      name: row.name,
      basePackId: row.basePackId,
      overrides: ThemeRoleOverrides.fromJson(overridesJson),
      typographyScale: TypographyScale.fromString(row.typographyScale),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Converts a domain model to a database companion.
  CustomThemesCompanion _draftToCompanion(CustomThemeDraft draft) {
    return CustomThemesCompanion.insert(
      id: draft.id,
      name: draft.name,
      basePackId: draft.basePackId,
      overridesJson: jsonEncode(draft.overrides.toJson()),
      typographyScale: Value(draft.typographyScale.name),
      createdAt: draft.createdAt,
      updatedAt: draft.updatedAt,
    );
  }
}
