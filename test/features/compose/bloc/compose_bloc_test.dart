import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' show Blob, BlobRef;
import 'package:bluesky_poptart/app/bsky/embed/external.dart';
import 'package:bluesky_poptart/app/bsky/embed/record_with_media.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class FakeDraftsCompanion extends Fake implements DraftsCompanion {}

final _jpegBytes = <int>[0xFF, 0xD8, 0xFF, 0xE0, 0, 16, 0x4A, 0x46, 0x49, 0x46, 0, 1];

DraftEntry _makeDraft({
  int id = 1,
  String content = 'Draft',
  String? mediaPaths,
  String? embedJson,
  String? replyUri,
  String? replyCid,
  String? rootUri,
  String? rootCid,
  DateTime? scheduledAt,
}) => DraftEntry(
  id: id,
  accountDid: 'did:plc:test',
  content: content,
  mediaPaths: mediaPaths,
  embedJson: embedJson,
  replyUri: replyUri,
  replyCid: replyCid,
  rootUri: rootUri,
  rootCid: rootCid,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
  scheduledAt: scheduledAt,
);

File _writeTempImage(String name, List<int> bytes) {
  final dir = Directory.systemTemp.createTempSync('lazurite_compose_test_');
  addTearDown(() {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(bytes);
  return file;
}

void main() {
  group('ComposeBloc', () {
    late ComposeBloc composeBloc;
    late MockAppDatabase mockDatabase;
    late MockComposeRepository mockRepository;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockRepository = MockComposeRepository();
      when(() => mockRepository.fetchLinkPreview(any())).thenAnswer((_) async => null);
      when(() => mockRepository.buildExternalEmbedFromLink(any())).thenAnswer((_) async => null);
      when(
        () => mockRepository.resolveReplyReferences(
          parentUri: any(named: 'parentUri'),
          parentCid: any(named: 'parentCid'),
          fallbackRootUri: any(named: 'fallbackRootUri'),
          fallbackRootCid: any(named: 'fallbackRootCid'),
        ),
      ).thenAnswer((_) async => null);
      composeBloc = ComposeBloc(composeRepository: mockRepository, database: mockDatabase, accountDid: 'did:plc:test');
      registerFallbackValue(FakeDraftsCompanion());
    });

    tearDown(() {
      composeBloc.close();
    });

    test('initial state is correct', () {
      expect(composeBloc.state.status, ComposeStatus.ready);
      expect(composeBloc.state.isEmpty, true);
      expect(composeBloc.state.canSubmit, false);
    });

    group('isDraftDirty', () {
      test('initial state has isDraftDirty true', () {
        expect(composeBloc.state.isDraftDirty, true);
      });

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty is true after text changed',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(isDraftDirty: false),
        act: (bloc) => bloc.add(const TextChanged('Hello')),
        expect: () => [isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', true)],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty is true after media attached',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(isDraftDirty: false),
        act: (bloc) => bloc.add(const MediaAttached('/path/to/image.jpg')),
        expect: () => [isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', true)],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty is true after media removed',
        build: () => composeBloc,
        seed: () =>
            const ComposeState.ready(mediaAttachments: [MediaAttachment(localPath: '/1.jpg')], isDraftDirty: false),
        act: (bloc) => bloc.add(const MediaRemoved(0)),
        expect: () => [isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', true)],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty is false after draft saved successfully',
        build: () {
          when(() => mockDatabase.saveDraft(any())).thenAnswer((_) async => 1);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Hello', isDraftDirty: true),
        act: (bloc) => bloc.add(const DraftSaved()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSavingDraft, 'isSavingDraft', true),
          isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', false),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty is false after draft loaded',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer((_) async => _makeDraft(content: 'Draft text'));
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', false)],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isDraftDirty becomes true after editing a loaded draft',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer((_) async => _makeDraft(content: 'Draft text'));
          return composeBloc;
        },
        act: (bloc) async {
          bloc.add(const DraftLoaded(1));
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TextChanged('Draft text edited'));
        },
        expect: () => [
          isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', false),
          isA<ComposeState>().having((s) => s.isDraftDirty, 'isDraftDirty', true),
        ],
      );
    });

    group('TextChanged', () {
      blocTest<ComposeBloc, ComposeState>(
        'emits correct state when text changes',
        build: () => composeBloc,
        act: (bloc) => bloc.add(const TextChanged('Hello world')),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.text, 'text', 'Hello world')
              .having((s) => s.graphemeCount, 'graphemeCount', 11)
              .having((s) => s.isEmpty, 'isEmpty', false)
              .having((s) => s.canSubmit, 'canSubmit', true),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does not emit when text is unchanged',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(text: 'Hello world', graphemeCount: 11, isEmpty: false),
        act: (bloc) => bloc.add(const TextChanged('Hello world')),
        expect: () => <ComposeState>[],
      );

      blocTest<ComposeBloc, ComposeState>(
        'emits overLimit when text exceeds 300 graphemes',
        build: () => composeBloc,
        act: (bloc) => bloc.add(TextChanged('a' * 301)),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.graphemeCount, 'graphemeCount', 301)
              .having((s) => s.isOverLimit, 'isOverLimit', true)
              .having((s) => s.canSubmit, 'canSubmit', false),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does not emit when empty text is unchanged',
        build: () => composeBloc,
        act: (bloc) => bloc.add(const TextChanged('')),
        expect: () => <ComposeState>[],
      );
    });

    group('MediaAttached', () {
      blocTest<ComposeBloc, ComposeState>(
        'emits correct state when media is attached',
        build: () => composeBloc,
        act: (bloc) => bloc.add(const MediaAttached('/path/to/image.jpg')),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.mediaAttachments.length, 'mediaAttachments.length', 1)
              .having((s) => s.canAddMoreMedia, 'canAddMoreMedia', true)
              .having((s) => s.isEmpty, 'isEmpty', false),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'stores width and height when provided',
        build: () => composeBloc,
        act: (bloc) => bloc.add(const MediaAttached('/path/to/image.jpg', width: 1920, height: 1080)),
        expect: () => [
          isA<ComposeState>().having(
            (s) => s.mediaAttachments.first,
            'attachment',
            isA<MediaAttachment>().having((a) => a.width, 'width', 1920).having((a) => a.height, 'height', 1080),
          ),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does not add media when already at max',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          mediaAttachments: [
            MediaAttachment(localPath: '/1.jpg'),
            MediaAttachment(localPath: '/2.jpg'),
            MediaAttachment(localPath: '/3.jpg'),
            MediaAttachment(localPath: '/4.jpg'),
          ],
        ),
        act: (bloc) => bloc.add(const MediaAttached('/path/to/image.jpg')),
        expect: () => [],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does not add media when video is attached',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          videoAttachment: VideoAttachment(localPath: '/video.mp4', status: VideoUploadStatus.ready),
        ),
        act: (bloc) => bloc.add(const MediaAttached('/image.jpg')),
        expect: () => [],
      );
    });

    group('MediaRemoved', () {
      blocTest<ComposeBloc, ComposeState>(
        'removes attachment at given index',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(mediaAttachments: [MediaAttachment(localPath: '/path/to/image.jpg')]),
        act: (bloc) => bloc.add(const MediaRemoved(0)),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.mediaAttachments.length, 'mediaAttachments.length', 0)
              .having((s) => s.isEmpty, 'isEmpty', true),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'preserves other attachments when removing from start',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          mediaAttachments: [
            MediaAttachment(localPath: '/1.jpg', altText: 'First'),
            MediaAttachment(localPath: '/2.jpg', altText: 'Second'),
          ],
        ),
        act: (bloc) => bloc.add(const MediaRemoved(0)),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.mediaAttachments.length, 'mediaAttachments.length', 1)
              .having((s) => s.mediaAttachments.first.localPath, 'localPath', '/2.jpg')
              .having((s) => s.mediaAttachments.first.altText, 'altText', 'Second'),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does nothing when index is out of bounds',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(mediaAttachments: [MediaAttachment(localPath: '/path/to/image.jpg')]),
        act: (bloc) => bloc.add(const MediaRemoved(5)),
        expect: () => [],
      );
    });

    group('AltTextUpdated', () {
      blocTest<ComposeBloc, ComposeState>(
        'updates alt text for media attachment',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(mediaAttachments: [MediaAttachment(localPath: '/path/to/image.jpg')]),
        act: (bloc) => bloc.add(const AltTextUpdated(index: 0, altText: 'Description of image')),
        expect: () => [
          isA<ComposeState>().having(
            (s) => s.mediaAttachments.first.altText,
            'attachment.altText',
            'Description of image',
          ),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does nothing when index is out of bounds',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(mediaAttachments: [MediaAttachment(localPath: '/path/to/image.jpg')]),
        act: (bloc) => bloc.add(const AltTextUpdated(index: 5, altText: 'Description')),
        expect: () => [],
      );
    });

    group('VideoRemoved', () {
      blocTest<ComposeBloc, ComposeState>(
        'removes video attachment and allows media to be added again',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          videoAttachment: VideoAttachment(localPath: '/video.mp4', status: VideoUploadStatus.ready),
        ),
        act: (bloc) => bloc.add(const VideoRemoved()),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.videoAttachment, 'videoAttachment', isNull)
              .having((s) => s.canAddVideo, 'canAddVideo', true)
              .having((s) => s.canAddMoreMedia, 'canAddMoreMedia', true),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'isEmpty is true after video removed with no text',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          videoAttachment: VideoAttachment(localPath: '/video.mp4', status: VideoUploadStatus.ready),
        ),
        act: (bloc) => bloc.add(const VideoRemoved()),
        expect: () => [isA<ComposeState>().having((s) => s.isEmpty, 'isEmpty', true)],
      );
    });

    group('VideoAltTextUpdated', () {
      blocTest<ComposeBloc, ComposeState>(
        'updates video alt text',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          videoAttachment: VideoAttachment(localPath: '/video.mp4', status: VideoUploadStatus.ready),
        ),
        act: (bloc) => bloc.add(const VideoAltTextUpdated('A cat playing piano')),
        expect: () => [
          isA<ComposeState>().having(
            (s) => s.videoAttachment?.altText,
            'videoAttachment.altText',
            'A cat playing piano',
          ),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does nothing when no video is attached',
        build: () => composeBloc,
        act: (bloc) => bloc.add(const VideoAltTextUpdated('Something')),
        expect: () => [],
      );
    });

    group('PostScheduled', () {
      blocTest<ComposeBloc, ComposeState>(
        'sets scheduledAt',
        build: () => composeBloc,
        act: (bloc) => bloc.add(PostScheduled(DateTime(2025, 1, 1))),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.hasScheduledTime, 'hasScheduledTime', true)
              .having((s) => s.scheduledAt, 'scheduledAt', DateTime(2025, 1, 1)),
        ],
      );
    });

    group('ScheduleCleared', () {
      blocTest<ComposeBloc, ComposeState>(
        'clears scheduledAt',
        build: () => composeBloc,
        seed: () => ComposeState.ready(scheduledAt: DateTime(2025, 1, 1)),
        act: (bloc) => bloc.add(const ScheduleCleared()),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.hasScheduledTime, 'hasScheduledTime', false)
              .having((s) => s.scheduledAt, 'scheduledAt', null),
        ],
      );
    });

    group('ReplyContextSet', () {
      blocTest<ComposeBloc, ComposeState>(
        'sets reply context',
        build: () => composeBloc,
        act: (bloc) => bloc.add(
          const ReplyContextSet(parentUri: 'at://parent', parentCid: 'cid123', rootUri: 'at://root', rootCid: 'cid456'),
        ),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.isReply, 'isReply', true)
              .having((s) => s.replyParentUri, 'replyParentUri', 'at://parent')
              .having((s) => s.replyParentCid, 'replyParentCid', 'cid123')
              .having((s) => s.replyRootUri, 'replyRootUri', 'at://root')
              .having((s) => s.replyRootCid, 'replyRootCid', 'cid456'),
        ],
      );
    });

    group('ReplyContextCleared', () {
      blocTest<ComposeBloc, ComposeState>(
        'clears reply context',
        build: () => composeBloc,
        seed: () => const ComposeState.ready(
          replyParentUri: 'at://parent',
          replyParentCid: 'cid123',
          replyRootUri: 'at://root',
          replyRootCid: 'cid456',
        ),
        act: (bloc) => bloc.add(const ReplyContextCleared()),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.isReply, 'isReply', false)
              .having((s) => s.replyParentUri, 'replyParentUri', null)
              .having((s) => s.replyParentCid, 'replyParentCid', null)
              .having((s) => s.replyRootUri, 'replyRootUri', null)
              .having((s) => s.replyRootCid, 'replyRootCid', null),
        ],
      );
    });

    group('DraftSaved', () {
      blocTest<ComposeBloc, ComposeState>(
        'saves draft and updates draftId',
        build: () {
          when(() => mockDatabase.saveDraft(any())).thenAnswer((_) async => 42);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Test content'),
        act: (bloc) => bloc.add(const DraftSaved()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSavingDraft, 'isSavingDraft', true),
          isA<ComposeState>()
              .having((s) => s.draftId, 'draftId', 42)
              .having((s) => s.isSavingDraft, 'isSavingDraft', false),
        ],
        verify: (_) {
          verify(() => mockDatabase.saveDraft(any())).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'handles save error gracefully',
        build: () {
          when(() => mockDatabase.saveDraft(any())).thenThrow(Exception('DB error'));
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftSaved()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSavingDraft, 'isSavingDraft', true),
          isA<ComposeState>().having((s) => s.isSavingDraft, 'isSavingDraft', false),
        ],
      );
    });

    group('DraftLoaded', () {
      blocTest<ComposeBloc, ComposeState>(
        'loads draft text and id',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer((_) async => _makeDraft(content: 'Loaded content'));
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [
          isA<ComposeState>().having((s) => s.text, 'text', 'Loaded content').having((s) => s.draftId, 'draftId', 1),
        ],
        verify: (_) {
          verify(() => mockDatabase.getDraft(1)).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'loads scheduled time from draft',
        build: () {
          when(
            () => mockDatabase.getDraft(1),
          ).thenAnswer((_) async => _makeDraft(scheduledAt: DateTime(2026, 6, 1, 12)));
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [isA<ComposeState>().having((s) => s.scheduledAt, 'scheduledAt', DateTime(2026, 6, 1, 12))],
      );

      blocTest<ComposeBloc, ComposeState>(
        'loads reply context from draft',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer(
            (_) async => _makeDraft(replyUri: 'at://parent', replyCid: 'cid1', rootUri: 'at://root', rootCid: 'cid2'),
          );
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [
          isA<ComposeState>()
              .having((s) => s.replyParentUri, 'replyParentUri', 'at://parent')
              .having((s) => s.isReply, 'isReply', true),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'parses embedJson with images format',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer(
            (_) async => _makeDraft(
              content: 'Content',
              embedJson: '{"type":"images","paths":["/nonexistent.jpg"],"altTexts":["Alt"]}',
            ),
          );
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [
          isA<ComposeState>().having((s) => s.text, 'text', 'Content').having((s) => s.draftId, 'draftId', 1),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'does nothing when draft not found',
        build: () {
          when(() => mockDatabase.getDraft(1)).thenAnswer((_) async => null);
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftLoaded(1)),
        expect: () => [],
      );
    });

    group('DraftsRequested', () {
      blocTest<ComposeBloc, ComposeState>(
        'loads list of drafts',
        build: () {
          when(
            () => mockDatabase.getDrafts('did:plc:test'),
          ).thenAnswer((_) async => [_makeDraft(id: 1, content: 'Draft 1')]);
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftsRequested()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isLoadingDrafts, 'isLoadingDrafts', true),
          isA<ComposeState>()
              .having((s) => s.drafts.length, 'drafts.length', 1)
              .having((s) => s.isLoadingDrafts, 'isLoadingDrafts', false),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'handles database error gracefully',
        build: () {
          when(() => mockDatabase.getDrafts(any())).thenThrow(Exception('DB error'));
          return composeBloc;
        },
        act: (bloc) => bloc.add(const DraftsRequested()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isLoadingDrafts, 'isLoadingDrafts', true),
          isA<ComposeState>().having((s) => s.isLoadingDrafts, 'isLoadingDrafts', false),
        ],
      );
    });

    group('DraftDeleted', () {
      blocTest<ComposeBloc, ComposeState>(
        'deletes draft from DB and removes from in-memory list',
        build: () {
          when(() => mockDatabase.deleteDraft(1)).thenAnswer((_) async => 1);
          return composeBloc;
        },
        seed: () => const ComposeState.ready().copyWith(
          drafts: [
            DraftEntry(
              id: 1,
              accountDid: 'did:plc:test',
              content: 'Draft 1',
              mediaPaths: null,
              embedJson: null,
              replyUri: null,
              replyCid: null,
              rootUri: null,
              rootCid: null,
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              scheduledAt: null,
            ),
            DraftEntry(
              id: 2,
              accountDid: 'did:plc:test',
              content: 'Draft 2',
              mediaPaths: null,
              embedJson: null,
              replyUri: null,
              replyCid: null,
              rootUri: null,
              rootCid: null,
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              scheduledAt: null,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const DraftDeleted(1)),
        expect: () => [isA<ComposeState>().having((s) => s.drafts.length, 'drafts.length', 1)],
        verify: (_) {
          verify(() => mockDatabase.deleteDraft(1)).called(1);
          verifyNever(() => mockDatabase.getDrafts(any()));
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'handles delete error gracefully',
        build: () {
          when(() => mockDatabase.deleteDraft(any())).thenThrow(Exception('DB error'));
          return composeBloc;
        },
        seed: () => const ComposeState.ready().copyWith(
          drafts: [
            DraftEntry(
              id: 1,
              accountDid: 'did:plc:test',
              content: 'Draft 1',
              mediaPaths: null,
              embedJson: null,
              replyUri: null,
              replyCid: null,
              rootUri: null,
              rootCid: null,
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              scheduledAt: null,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const DraftDeleted(1)),

        expect: () => [],
      );
    });

    group('PostSubmitted', () {
      blocTest<ComposeBloc, ComposeState>(
        'creates post and emits success on happy path',
        build: () {
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Hello', graphemeCount: 5, isEmpty: false),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>().having((s) => s.isSuccess, 'isSuccess', true),
        ],
        verify: (_) {
          verify(
            () => mockRepository.createPost(
              text: 'Hello',
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: 'did:plc:test',
            ),
          ).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'builds Bluesky external embed from detected link preview metadata',
        build: () {
          when(() => mockRepository.buildExternalEmbedFromLink('https://example.com/article')).thenAnswer(
            (_) async => const UFeedPostEmbed.embedExternal(
              data: EmbedExternal(
                external: EmbedExternalExternal(
                  uri: 'https://example.com/article',
                  title: 'Example Article',
                  description: 'Example description',
                ),
              ),
            ),
          );
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () =>
            const ComposeState.ready(text: 'Read this https://example.com/article', graphemeCount: 37, isEmpty: false),
        act: (bloc) => bloc.add(const PostSubmitted()),
        verify: (_) {
          final embed =
              verify(
                    () => mockRepository.createPost(
                      text: any(named: 'text'),
                      facets: any(named: 'facets'),
                      embed: captureAny(named: 'embed'),
                      reply: any(named: 'reply'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as UFeedPostEmbed?;

          expect(embed, isNotNull);
          expect(embed!.isEmbedExternal, isTrue);
          final external = embed.embedExternal!.external;
          expect(external.uri, 'https://example.com/article');
          expect(external.title, 'Example Article');
          expect(external.description, 'Example description');
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'does not build external embed when link is explicitly suppressed',
        build: () {
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () =>
            const ComposeState.ready(text: 'Read this https://example.com/article', graphemeCount: 37, isEmpty: false),
        act: (bloc) => bloc.add(const PostSubmitted(suppressedLinkUri: 'https://example.com/article')),
        verify: (_) {
          verifyNever(() => mockRepository.buildExternalEmbedFromLink(any()));
          final embed = verify(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: captureAny(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).captured.single;
          expect(embed, isNull);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'uploads images and creates image embed with full blob records',
        build: () {
          when(() => mockRepository.uploadBlobRecord(any(), mimeType: any(named: 'mimeType'))).thenAnswer(
            (_) async => const Blob(
              ref: BlobRef(link: 'bafkreiimageblob'),
              mimeType: 'image/jpeg',
              size: 12,
            ),
          );
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () {
          final image = _writeTempImage('photo.jpg', _jpegBytes);
          return ComposeState.ready(
            text: 'Photo',
            graphemeCount: 5,
            isEmpty: false,
            mediaAttachments: [MediaAttachment(localPath: image.path, altText: 'A photo', width: 640, height: 480)],
          );
        },
        act: (bloc) => bloc.add(const PostSubmitted()),
        wait: const Duration(milliseconds: 10),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>().having((s) => s.isSuccess, 'isSuccess', true),
        ],
        verify: (_) {
          final uploadedBytes =
              verify(() => mockRepository.uploadBlobRecord(captureAny(), mimeType: 'image/jpeg')).captured.single
                  as List<int>;
          expect(uploadedBytes, _jpegBytes);
          final embed =
              verify(
                    () => mockRepository.createPost(
                      text: any(named: 'text'),
                      facets: any(named: 'facets'),
                      embed: captureAny(named: 'embed'),
                      reply: any(named: 'reply'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as UFeedPostEmbed;

          expect(embed.isEmbedImages, isTrue);
          final images = embed.embedImages!.images;
          expect(images, hasLength(1));
          final image = images.single;
          expect(image.alt, 'A photo');
          expect(image.aspectRatio?.width, 640);
          expect(image.aspectRatio?.height, 480);
          expect(image.image.ref.link, 'bafkreiimageblob');
          expect(image.image.mimeType, 'image/jpeg');
          expect(image.image.size, 12);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'builds recordWithMedia when quoting and link preview embed both exist',
        build: () {
          when(() => mockRepository.buildExternalEmbedFromLink('https://example.com/article')).thenAnswer(
            (_) async => const UFeedPostEmbed.embedExternal(
              data: EmbedExternal(
                external: EmbedExternalExternal(
                  uri: 'https://example.com/article',
                  title: 'Example Article',
                  description: 'Example description',
                ),
              ),
            ),
          );
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'Quote this https://example.com/article',
          graphemeCount: 36,
          isEmpty: false,
          quoteUri: 'at://did:plc:test/app.bsky.feed.post/quote',
          quoteCid: 'cid-quote',
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        verify: (_) {
          final embed =
              verify(
                    () => mockRepository.createPost(
                      text: any(named: 'text'),
                      facets: any(named: 'facets'),
                      embed: captureAny(named: 'embed'),
                      reply: any(named: 'reply'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as UFeedPostEmbed?;

          expect(embed, isNotNull);
          expect(embed!.isEmbedRecordWithMedia, isTrue);
          final recordWithMedia = embed.embedRecordWithMedia!;
          expect(recordWithMedia.record.record.uri.toString(), 'at://did:plc:test/app.bsky.feed.post/quote');
          expect(recordWithMedia.media.isEmbedExternal, isTrue);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'resolves latest reply parent/root references before posting reply',
        build: () {
          when(
            () => mockRepository.resolveReplyReferences(
              parentUri: any(named: 'parentUri'),
              parentCid: any(named: 'parentCid'),
              fallbackRootUri: any(named: 'fallbackRootUri'),
              fallbackRootCid: any(named: 'fallbackRootCid'),
            ),
          ).thenAnswer(
            (_) async => (
              parentCid: 'cid-parent-latest',
              rootUri: 'at://did:plc:test/app.bsky.feed.post/root-latest',
              rootCid: 'cid-root-latest',
            ),
          );
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'reply text',
          graphemeCount: 10,
          isEmpty: false,
          replyParentUri: 'at://did:plc:test/app.bsky.feed.post/parent',
          replyParentCid: 'cid-parent-old',
          replyRootUri: 'at://did:plc:test/app.bsky.feed.post/root-old',
          replyRootCid: 'cid-root-old',
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        verify: (_) {
          final reply =
              verify(
                    () => mockRepository.createPost(
                      text: any(named: 'text'),
                      facets: any(named: 'facets'),
                      embed: any(named: 'embed'),
                      reply: captureAny(named: 'reply'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as ReplyRef?;

          expect(reply, isNotNull);
          expect(reply!.parent.cid, 'cid-parent-latest');
          expect(reply.root.uri.toString(), 'at://did:plc:test/app.bsky.feed.post/root-latest');
          expect(reply.root.cid, 'cid-root-latest');
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'emits error and returns to ready when createPost returns false',
        build: () {
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => false);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Hello', graphemeCount: 5, isEmpty: false),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>().having((s) => s.hasError, 'hasError', true),

          isA<ComposeState>().having((s) => s.isReady, 'isReady', true),
        ],
      );

      blocTest<ComposeBloc, ComposeState>(
        'saves draft on network failure and emits error',
        build: () {
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenThrow(Exception('Network error'));
          when(() => mockDatabase.saveDraft(any())).thenAnswer((_) async => 99);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Hello', graphemeCount: 5, isEmpty: false),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>()
              .having((s) => s.hasError, 'hasError', true)
              .having((s) => s.errorMessage, 'errorMessage', contains('draft')),
          isA<ComposeState>().having((s) => s.isReady, 'isReady', true),
        ],
        verify: (_) {
          verify(() => mockDatabase.saveDraft(any())).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'does nothing when canSubmit is false',
        build: () => composeBloc,

        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [],
      );

      blocTest<ComposeBloc, ComposeState>(
        'deletes associated draft on success',
        build: () {
          when(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => true);
          when(() => mockDatabase.deleteDraft(7)).thenAnswer((_) async => 1);
          return composeBloc;
        },
        seed: () => const ComposeState.ready(text: 'Hello', graphemeCount: 5, isEmpty: false, draftId: 7),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>().having((s) => s.isSuccess, 'isSuccess', true),
        ],
        verify: (_) {
          verify(() => mockDatabase.deleteDraft(7)).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'edits post via repository when edit context is set',
        build: () {
          when(
            () => mockRepository.editPost(
              postUri: any(named: 'postUri'),
              currentCid: any(named: 'currentCid'),
              originalRecord: any(named: 'originalRecord'),
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => const EditPostResult.success(cid: 'cid-new'));
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'Updated text',
          graphemeCount: 12,
          isEmpty: false,
          editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
          editPostCid: 'cid-current',
          editRecord: {r'$type': 'app.bsky.feed.post', 'text': 'Original', 'createdAt': '2026-04-14T10:00:00.000Z'},
          isDraftDirty: true,
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>()
              .having((s) => s.isSuccess, 'isSuccess', true)
              .having((s) => s.isDraftDirty, 'isDraftDirty', false),
        ],
        verify: (_) {
          verifyNever(
            () => mockRepository.createPost(
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              embed: any(named: 'embed'),
              reply: any(named: 'reply'),
              repo: any(named: 'repo'),
            ),
          );
          verify(
            () => mockRepository.editPost(
              postUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
              currentCid: 'cid-current',
              originalRecord: any(named: 'originalRecord'),
              text: 'Updated text',
              facets: any(named: 'facets'),
              repo: 'did:plc:test',
            ),
          ).called(1);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'passes original non-text fields and keeps createdAt when editing',
        build: () {
          when(
            () => mockRepository.editPost(
              postUri: any(named: 'postUri'),
              currentCid: any(named: 'currentCid'),
              originalRecord: any(named: 'originalRecord'),
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => const EditPostResult.success(cid: 'cid-new'));
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'Revised post body',
          graphemeCount: 16,
          isEmpty: false,
          editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
          editPostCid: 'cid-current',
          editRecord: {
            r'$type': 'app.bsky.feed.post',
            'text': 'Original post body',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'reply': {
              'parent': {'uri': 'at://did:plc:test/app.bsky.feed.post/parent', 'cid': 'cid-parent'},
              'root': {'uri': 'at://did:plc:test/app.bsky.feed.post/root', 'cid': 'cid-root'},
            },
            'embed': {
              r'$type': 'app.bsky.embed.record',
              'record': {'uri': 'at://did:plc:test/app.bsky.feed.post/quote', 'cid': 'cid-quote'},
            },
          },
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        verify: (_) {
          final invocation =
              verify(
                    () => mockRepository.editPost(
                      postUri: any(named: 'postUri'),
                      currentCid: any(named: 'currentCid'),
                      originalRecord: captureAny(named: 'originalRecord'),
                      text: any(named: 'text'),
                      facets: any(named: 'facets'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as Map<String, dynamic>;

          expect(invocation['createdAt'], '2025-01-01T00:00:00.000Z');
          expect(invocation['reply'], isNotNull);
          expect(invocation['embed'], isNotNull);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'passes empty facets list for plain text edits',
        build: () {
          when(
            () => mockRepository.editPost(
              postUri: any(named: 'postUri'),
              currentCid: any(named: 'currentCid'),
              originalRecord: any(named: 'originalRecord'),
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer((_) async => const EditPostResult.success(cid: 'cid-new'));
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'No facets here',
          graphemeCount: 13,
          isEmpty: false,
          editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
          editPostCid: 'cid-current',
          editRecord: {r'$type': 'app.bsky.feed.post', 'text': 'Original', 'createdAt': '2026-04-14T10:00:00.000Z'},
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        verify: (_) {
          final facets =
              verify(
                    () => mockRepository.editPost(
                      postUri: any(named: 'postUri'),
                      currentCid: any(named: 'currentCid'),
                      originalRecord: any(named: 'originalRecord'),
                      text: any(named: 'text'),
                      facets: captureAny(named: 'facets'),
                      repo: any(named: 'repo'),
                    ),
                  ).captured.single
                  as List;
          expect(facets, isEmpty);
        },
      );

      blocTest<ComposeBloc, ComposeState>(
        'surfaces InvalidSwap edit failures as user-visible errors',
        build: () {
          when(
            () => mockRepository.editPost(
              postUri: any(named: 'postUri'),
              currentCid: any(named: 'currentCid'),
              originalRecord: any(named: 'originalRecord'),
              text: any(named: 'text'),
              facets: any(named: 'facets'),
              repo: any(named: 'repo'),
            ),
          ).thenAnswer(
            (_) async =>
                const EditPostResult.failure('This post was changed elsewhere. Reopen it and try editing again.'),
          );
          return composeBloc;
        },
        seed: () => const ComposeState.ready(
          text: 'Updated text',
          graphemeCount: 12,
          isEmpty: false,
          editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
          editPostCid: 'cid-current',
          editRecord: {r'$type': 'app.bsky.feed.post', 'text': 'Original', 'createdAt': '2026-04-14T10:00:00.000Z'},
        ),
        act: (bloc) => bloc.add(const PostSubmitted()),
        expect: () => [
          isA<ComposeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<ComposeState>()
              .having((s) => s.hasError, 'hasError', true)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'This post was changed elsewhere. Reopen it and try editing again.',
              ),
          isA<ComposeState>().having((s) => s.isReady, 'isReady', true),
        ],
      );
    });
  });
}
