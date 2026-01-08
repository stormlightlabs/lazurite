import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FormData());
  });

  late AppDatabase db;
  late DraftRepository repository;
  late MockXrpcClient mockApi;
  late MockSessionStorage mockSessionStorage;
  late MockLogger mockLogger;
  late MockFacetParser mockFacetParser;
  late Directory tempDir;
  const testOwnerDid = 'did:plc:test';

  Session buildTestSession() {
    return Session(
      did: testOwnerDid,
      handle: 'test',
      pdsUrl: 'https://pds.test',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'atproto',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const {'kty': 'EC'},
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockApi = MockXrpcClient();
    mockSessionStorage = MockSessionStorage();
    mockLogger = MockLogger();
    mockFacetParser = MockFacetParser();

    when(() => mockFacetParser.parse(any())).thenAnswer((_) async => null);
    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());

    repository = DraftRepository(
      dao: db.draftsDao,
      api: mockApi,
      sessionStorage: mockSessionStorage,
      logger: mockLogger,
      facetParser: mockFacetParser,
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
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
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
    when(() => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body'))).thenAnswer(
      (_) async => {'uri': 'at://did:web:test/app.bsky.feed.post/123', 'cid': 'cid-123'},
    );

    final result = await repository.publishDraft(draft.id);

    final posted = await repository.getDraft(draft.id);
    expect(posted.status, composer.DraftStatus.posted);
    expect(posted.media.single.uploadCid, 'cid-test');
    expect(posted.media.single.blobRefJson, contains('cid-test'));
    expect(result.uri, 'at://did:web:test/app.bsky.feed.post/123');
    expect(result.cid, 'cid-123');
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
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
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

  test('deletePostedDrafts removes posted drafts only', () async {
    final draft1 = await repository.createDraft(text: 'Draft 1');
    final draft2 = await repository.createDraft(text: 'Draft 2');
    final draft3 = await repository.createDraft(text: 'Draft 3');

    await db.draftsDao.updateDraftFields(
      draft2.id,
      testOwnerDid,
      DraftsCompanion(status: Value(composer.DraftStatus.posted.name)),
    );
    await db.draftsDao.updateDraftFields(
      draft3.id,
      testOwnerDid,
      DraftsCompanion(status: Value(composer.DraftStatus.failed.name)),
    );

    final deletedCount = await repository.deletePostedDrafts();

    expect(deletedCount, 1);
    final remaining = await repository.watchDrafts().first;
    expect(remaining, hasLength(2));
    expect(remaining.map((d) => d.id), containsAll([draft1.id, draft3.id]));
  });

  test('retryMediaUpload resets status and re-uploads', () async {
    final draft = await repository.createDraft(text: 'Retry test');
    final file = await createTempFile('retry.png');

    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: file.path, mimeType: 'image/png'),
    );

    final draftWithMedia = await repository.getDraft(draft.id);
    await db.draftsDao.updateMedia(
      draftWithMedia.media.first.id,
      DraftMediaCompanion(status: Value(composer.DraftMediaStatus.failed.name)),
    );

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());
    when(
      () => mockApi.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: any(named: 'body'),
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-retry'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      ),
    );

    await repository.retryMediaUpload(draft.id, draftWithMedia.media.first.id);

    final updated = await repository.getDraft(draft.id);
    expect(updated.media.single.status, composer.DraftMediaStatus.uploaded);
    expect(updated.media.single.uploadCid, 'cid-retry');
  });

  test('cancelUpload calls cancel on the upload token', () async {
    final draft = await repository.createDraft(text: 'Cancel test');
    final file = await createTempFile('cancel.png');

    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: file.path, mimeType: 'image/png'),
    );

    final draftWithMedia = await repository.getDraft(draft.id);
    final mediaId = draftWithMedia.media.first.id;

    CancelToken? capturedToken;
    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());
    when(
      () => mockApi.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: any(named: 'body'),
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((invocation) async {
      capturedToken = invocation.namedArguments[const Symbol('cancelToken')] as CancelToken?;

      await Future<void>.delayed(const Duration(seconds: 5));
      return Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-test'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      );
    });

    unawaited(
      // ignore: body_might_complete_normally_catch_error
      repository.publishDraft(draft.id).catchError((_) {}),
    );

    await Future<void>.delayed(const Duration(milliseconds: 100));

    repository.cancelUpload(mediaId);

    expect(capturedToken, isNotNull);
    expect(capturedToken!.isCancelled, isTrue);
  });

  test('publishDraft calls progress callback during upload', () async {
    final draft = await repository.createDraft(text: 'Progress test');
    final file = await createTempFile('progress.png');

    await repository.addMedia(
      draft.id,
      composer.DraftMediaInput(localPath: file.path, mimeType: 'image/png'),
    );

    final draftWithMedia = await repository.getDraft(draft.id);
    final progressUpdates = <(int, double)>[];

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => buildTestSession());
    when(
      () => mockApi.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: any(named: 'body'),
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((invocation) async {
      final onProgress =
          invocation.namedArguments[const Symbol('onSendProgress')] as void Function(int, int)?;
      onProgress?.call(50, 100);
      onProgress?.call(100, 100);

      return Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-progress'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      );
    });
    when(() => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body'))).thenAnswer(
      (_) async => {'uri': 'at://did:web:test/app.bsky.feed.post/123', 'cid': 'cid-123'},
    );

    await repository.publishDraft(
      draft.id,
      onMediaProgress: (mediaId, progress) => progressUpdates.add((mediaId, progress)),
    );

    expect(progressUpdates, hasLength(2));
    expect(progressUpdates.first.$1, draftWithMedia.media.first.id);
    expect(progressUpdates.first.$2, 0.5);
    expect(progressUpdates.last.$2, 1.0);
  });

  test('publishDraft with quote and media creates recordWithMedia embed', () async {
    final draft = await repository.createDraft(
      text: 'Quote + Image',
      quoteUri: 'at://did:web:test/app.bsky.feed.post/quoted',
      quoteCid: 'cid-quoted',
    );
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
        onSendProgress: any(named: 'onSendProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: {
          'blob': {
            '\$type': 'blob',
            'ref': {'\$link': 'cid-image'},
            'mimeType': 'image/png',
            'size': 16,
          },
        },
        requestOptions: RequestOptions(path: ''),
      ),
    );

    Map<String, dynamic>? capturedRecord;
    when(() => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body'))).thenAnswer(
      (invocation) async {
        final body = invocation.namedArguments[const Symbol('body')] as Map<String, dynamic>;
        capturedRecord = body['record'] as Map<String, dynamic>;
        return {'uri': 'at://did:web:test/app.bsky.feed.post/123', 'cid': 'cid-123'};
      },
    );

    await repository.publishDraft(draft.id);

    expect(capturedRecord, isNotNull);
    final embed = capturedRecord!['embed'] as Map<String, dynamic>;
    expect(embed['\$type'], 'app.bsky.embed.recordWithMedia');

    final recordEmbed = embed['record'] as Map<String, dynamic>;
    expect(recordEmbed['\$type'], 'app.bsky.embed.record');
    expect(recordEmbed['record'], {
      'uri': 'at://did:web:test/app.bsky.feed.post/quoted',
      'cid': 'cid-quoted',
    });

    final mediaEmbed = embed['media'] as Map<String, dynamic>;
    expect(mediaEmbed['\$type'], 'app.bsky.embed.images');
    expect((mediaEmbed['images'] as List).length, 1);
  });
}
