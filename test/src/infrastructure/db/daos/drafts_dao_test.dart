import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/drafts_dao.dart';

void main() {
  late AppDatabase db;
  late DraftsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.draftsDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('watchDrafts emits drafts with media changes', () async {
    final stream = dao.watchDrafts();

    final now = DateTime.now();
    await dao.insertDraft(
      DraftsCompanion.insert(
        id: 'draft-1',
        content: const Value('Hello world'),
        status: 'draft',
        errorMessage: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await dao.insertMedia([
      DraftMediaCompanion.insert(
        draftId: 'draft-1',
        localPath: '/tmp/image.png',
        mimeType: 'image/png',
        altText: const Value('alt'),
        uploadCid: const Value(null),
        blobRefJson: const Value(null),
        status: 'pending',
        sortOrder: 0,
        createdAt: now,
      ),
    ]);

    final emission = await stream.firstWhere((drafts) => drafts.isNotEmpty);
    expect(emission.single.draft.id, 'draft-1');
    expect(emission.single.media, hasLength(1));
    expect(emission.single.media.first.mimeType, 'image/png');
  });

  test('getDraft orders media by sortOrder', () async {
    final now = DateTime.now();
    await dao.insertDraft(
      DraftsCompanion.insert(
        id: 'draft-ordered',
        content: const Value('Ordering'),
        status: 'draft',
        errorMessage: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await dao.insertMedia([
      DraftMediaCompanion.insert(
        draftId: 'draft-ordered',
        localPath: '/tmp/second.png',
        mimeType: 'image/png',
        altText: const Value(null),
        uploadCid: const Value(null),
        blobRefJson: const Value(null),
        status: 'pending',
        sortOrder: 1,
        createdAt: now,
      ),
      DraftMediaCompanion.insert(
        draftId: 'draft-ordered',
        localPath: '/tmp/first.png',
        mimeType: 'image/png',
        altText: const Value(null),
        uploadCid: const Value(null),
        blobRefJson: const Value(null),
        status: 'pending',
        sortOrder: 0,
        createdAt: now,
      ),
    ]);

    final record = await dao.getDraft('draft-ordered');
    expect(record, isNotNull);
    expect(record!.media.map((m) => m.localPath), ['/tmp/first.png', '/tmp/second.png']);
  });
}
