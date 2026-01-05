import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockSessionStorage extends Mock implements SessionStorage {}

class MockLogger extends Mock implements Logger {}

void main() {
  setUpAll(() {
    registerFallbackValue(FormData());
  });

  late AppDatabase db;
  late DraftRepository repository;
  late MockXrpcClient mockApi;
  late MockSessionStorage mockSessionStorage;
  late MockLogger mockLogger;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockApi = MockXrpcClient();
    mockSessionStorage = MockSessionStorage();
    mockLogger = MockLogger();
    repository = DraftRepository(
      dao: db.draftsDao,
      api: mockApi,
      sessionStorage: mockSessionStorage,
      logger: mockLogger,
    );
    tempDir = Directory.systemTemp.createTempSync('draft_repo_test');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<File> createTempFile(String name) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(List<int>.filled(16, 1));
    return file;
  }

  Session buildTestSession() {
    return Session(
      did: 'did:web:test',
      handle: 'test',
      pdsUrl: 'https://pds.test',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'atproto',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const {'kty': 'EC'},
    );
  }

  test('createDraft emits via watchDrafts', () async {
    final stream = repository.watchDrafts();
    final emissionFuture = stream.firstWhere((drafts) => drafts.isNotEmpty);

    await repository.createDraft(text: 'Hello drafts');

    final drafts = await emissionFuture;
    expect(drafts.single.text, 'Hello drafts');
    expect(drafts.single.status, composer.DraftStatus.draft);
  });

  test('addMedia stores attachments in order', () async {
    final draft = await repository.createDraft(text: 'Media test');
    final firstFile = await createTempFile('first.png');
    final secondFile = await createTempFile('second.png');

    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: firstFile.path, mimeType: 'image/png'),
    );
    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: secondFile.path, mimeType: 'image/png'),
    );

    final updated = await repository.getDraft(draft.id);
    expect(updated.media, hasLength(2));
    expect(updated.media.map((m) => m.localPath.split(Platform.pathSeparator).last), [
      'first.png',
      'second.png',
    ]);
  });

  test('publishDraft uploads media and marks draft posted', () async {
    final draft = await repository.createDraft(text: 'Publish me');
    final file = await createTempFile('image.png');

    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: file.path, mimeType: 'image/png', altText: 'alt'),
    );

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());
    when(
      () => mockApi.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-test'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      ),
    );
    when(
      () => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body')),
    ).thenAnswer((_) async => {'uri': 'at://did:web:test/app.bsky.feed.post/123'});

    await repository.publishDraft(draft.id);

    final posted = await repository.getDraft(draft.id);
    expect(posted.status, composer.DraftStatus.posted);
    expect(posted.media.single.uploadCid, 'cid-test');
    expect(posted.media.single.blobRefJson, contains('cid-test'));
  });

  test('publishDraft failure keeps draft and marks failed', () async {
    final draft = await repository.createDraft(text: 'Failure case');
    final file = await createTempFile('image.png');
    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: file.path, mimeType: 'image/png'),
    );

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());
    when(
      () => mockApi.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-test'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      ),
    );
    when(
      () => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body')),
    ).thenThrow(Exception('publish failed'));

    await expectLater(repository.publishDraft(draft.id), throwsException);

    final failed = await repository.getDraft(draft.id);
    expect(failed.status, composer.DraftStatus.failed);
    expect(failed.errorMessage, contains('publish failed'));
    expect(failed.media.single.uploadCid, 'cid-test');
  });

  test('drafts remain editable offline (airplane mode)', () async {
    final draft = await repository.createDraft(text: 'Offline');

    await repository.updateDraftContent(draft.id, text: 'Offline updated');

    final updated = await repository.getDraft(draft.id);
    expect(updated.text, 'Offline updated');
    verifyNever(() => mockApi.call(any(), body: any(named: 'body')));
  });
}
