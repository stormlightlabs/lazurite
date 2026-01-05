import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'drafts_dao.g.dart';

class DraftRecord {
  DraftRecord({required this.draft, required this.media});

  final Draft draft;
  final List<DraftMediaData> media;
}

@DriftAccessor(tables: [Drafts, DraftMedia])
class DraftsDao extends DatabaseAccessor<AppDatabase> with _$DraftsDaoMixin {
  DraftsDao(super.db);

  Future<void> insertDraft(DraftsCompanion entry) {
    return into(drafts).insert(entry);
  }

  Future<void> updateDraftFields(String id, DraftsCompanion entry) {
    return (update(drafts)..where((tbl) => tbl.id.equals(id))).write(entry);
  }

  Future<void> deleteDraft(String id) async {
    await transaction(() async {
      await (delete(draftMedia)..where((tbl) => tbl.draftId.equals(id))).go();
      await (delete(drafts)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  Future<void> insertMedia(List<DraftMediaCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAll(draftMedia, entries);
    });
  }

  Future<void> deleteMedia(int mediaId) {
    return (delete(draftMedia)..where((tbl) => tbl.id.equals(mediaId))).go();
  }

  Future<void> updateMedia(int mediaId, DraftMediaCompanion entry) {
    return (update(draftMedia)..where((tbl) => tbl.id.equals(mediaId))).write(entry);
  }

  Stream<List<DraftRecord>> watchDrafts() {
    final join = select(
      drafts,
    ).join([leftOuterJoin(draftMedia, draftMedia.draftId.equalsExp(drafts.id))]);

    join.orderBy([OrderingTerm.desc(drafts.updatedAt), OrderingTerm.asc(draftMedia.sortOrder)]);

    return join.watch().map(_mapRowsToRecords);
  }

  Stream<DraftRecord?> watchDraft(String id) {
    final join =
        select(drafts).join([leftOuterJoin(draftMedia, draftMedia.draftId.equalsExp(drafts.id))])
          ..where(drafts.id.equals(id))
          ..orderBy([OrderingTerm.desc(drafts.updatedAt), OrderingTerm.asc(draftMedia.sortOrder)]);

    return join.watch().map((rows) {
      final records = _mapRowsToRecords(rows);
      if (records.isEmpty) return null;
      return records.first;
    });
  }

  Future<DraftRecord?> getDraft(String id) async {
    final join =
        select(drafts).join([leftOuterJoin(draftMedia, draftMedia.draftId.equalsExp(drafts.id))])
          ..where(drafts.id.equals(id))
          ..orderBy([OrderingTerm.desc(drafts.updatedAt), OrderingTerm.asc(draftMedia.sortOrder)]);

    final rows = await join.get();
    final records = _mapRowsToRecords(rows);
    if (records.isEmpty) return null;
    return records.first;
  }

  List<DraftRecord> _mapRowsToRecords(List<TypedResult> rows) {
    final map = <String, DraftRecord>{};

    for (final row in rows) {
      final draft = row.readTable(drafts);
      final media = row.readTableOrNull(draftMedia);

      final existing = map[draft.id];
      if (existing == null) {
        final attachments = <DraftMediaData>[];
        if (media != null) {
          attachments.add(media);
        }
        map[draft.id] = DraftRecord(draft: draft, media: attachments);
      } else {
        if (media != null) {
          existing.media.add(media);
        }
      }
    }

    final records = map.values.toList()
      ..sort((a, b) => b.draft.updatedAt.compareTo(a.draft.updatedAt));

    for (final record in records) {
      record.media.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return records;
  }
}
