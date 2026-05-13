import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:poptart_lex/app/bsky/embed/defs.dart' as embed_defs;
import 'package:poptart_lex/app/bsky/embed/external.dart';
import 'package:poptart_lex/app/bsky/embed/images.dart';
import 'package:poptart_lex/app/bsky/embed/record.dart';
import 'package:poptart_lex/app/bsky/embed/record_with_media.dart';
import 'package:poptart_lex/app/bsky/embed/video.dart';
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:poptart_lex/app/bsky/richtext/facet.dart';
import 'package:poptart_lex/app/bsky/video/defs.dart';
import 'package:poptart_lex/com/atproto/repo/get_record.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart_bluesky_text/poptart_bluesky_text.dart';
import 'package:characters/characters.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/scheduler/post_scheduler.dart';
import 'package:lazurite/features/compose/data/draft_embed_payload.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/data/link_preview_service.dart';

part 'compose_event.dart';
part 'compose_state.dart';

const int kMaxGraphemes = 300;
const int kMaxImages = 4;

/// 1 MB
const int kMaxImageBytes = 1 * 1024 * 1024;

/// 100 MB
const int kMaxVideoBytes = 100 * 1024 * 1024;
const _kVideoJobPollInterval = Duration(seconds: 2);
const _kVideoJobPollTimeout = Duration(minutes: 5);

class ComposeBloc extends Bloc<ComposeEvent, ComposeState> {
  ComposeBloc({required ComposeRepository composeRepository, required AppDatabase database, required String accountDid})
    : _composeRepository = composeRepository,
      _database = database,
      _accountDid = accountDid,
      super(const ComposeState.ready()) {
    on<TextChanged>(_onTextChanged);
    on<MediaAttached>(_onMediaAttached);
    on<MediaRemoved>(_onMediaRemoved);
    on<AltTextUpdated>(_onAltTextUpdated);
    on<VideoAttached>(_onVideoAttached);
    on<VideoRemoved>(_onVideoRemoved);
    on<VideoAltTextUpdated>(_onVideoAltTextUpdated);
    on<DraftSaved>(_onDraftSaved);
    on<DraftLoaded>(_onDraftLoaded);
    on<DraftsRequested>(_onDraftsRequested);
    on<DraftDeleted>(_onDraftDeleted);
    on<PostScheduled>(_onPostScheduled);
    on<ScheduleCleared>(_onScheduleCleared);
    on<PostSubmitted>(_onPostSubmitted);
    on<ReplyContextSet>(_onReplyContextSet);
    on<ReplyContextCleared>(_onReplyContextCleared);
    on<QuoteContextSet>(_onQuoteContextSet);
    on<QuoteContextCleared>(_onQuoteContextCleared);
    on<EditContextSet>(_onEditContextSet);
  }

  final ComposeRepository _composeRepository;
  final AppDatabase _database;
  final String _accountDid;

  Future<void> _onTextChanged(TextChanged event, Emitter<ComposeState> emit) async {
    final text = event.text;
    if (text == state.text) {
      return;
    }
    final graphemeCount = text.characters.length;
    final isOverLimit = graphemeCount > kMaxGraphemes;
    final isEmpty = text.trim().isEmpty && state.mediaAttachments.isEmpty && state.videoAttachment == null;

    emit(
      state.copyWith(
        text: text,
        graphemeCount: graphemeCount,
        isOverLimit: isOverLimit,
        isEmpty: isEmpty,
        canSubmit: !isOverLimit && !isEmpty && !(state.videoAttachment?.isActive ?? false),
        isDraftDirty: true,
      ),
    );
  }

  Future<void> _onMediaAttached(MediaAttached event, Emitter<ComposeState> emit) async {
    if (!state.canAddMoreMedia) return;

    final attachments = List<MediaAttachment>.from(state.mediaAttachments)
      ..add(MediaAttachment(localPath: event.path, width: event.width, height: event.height));
    final isEmpty = state.text.trim().isEmpty && attachments.isEmpty;

    emit(
      state.copyWith(
        mediaAttachments: attachments,
        isEmpty: isEmpty,
        canSubmit: !state.isOverLimit && !isEmpty,
        isDraftDirty: true,
      ),
    );
  }

  Future<void> _onMediaRemoved(MediaRemoved event, Emitter<ComposeState> emit) async {
    if (event.index < 0 || event.index >= state.mediaAttachments.length) return;

    final attachments = List<MediaAttachment>.from(state.mediaAttachments)..removeAt(event.index);
    final isEmpty = state.text.trim().isEmpty && attachments.isEmpty && state.videoAttachment == null;

    emit(
      state.copyWith(
        mediaAttachments: attachments,
        isEmpty: isEmpty,
        canSubmit: !state.isOverLimit && !isEmpty,
        isDraftDirty: true,
      ),
    );
  }

  Future<void> _onAltTextUpdated(AltTextUpdated event, Emitter<ComposeState> emit) async {
    if (event.index < 0 || event.index >= state.mediaAttachments.length) return;

    final attachments = List<MediaAttachment>.from(state.mediaAttachments);
    attachments[event.index] = attachments[event.index].copyWith(altText: event.altText);
    emit(state.copyWith(mediaAttachments: attachments));
  }

  Future<void> _onVideoAttached(VideoAttached event, Emitter<ComposeState> emit) async {
    if (!state.canAddVideo) return;

    final file = File(event.path);
    if (!file.existsSync()) return;

    final sizeBytes = file.lengthSync();
    if (sizeBytes > kMaxVideoBytes) {
      final mb = (sizeBytes / 1024 / 1024).toStringAsFixed(1);
      _emitError(emit, 'Video is $mb MB — exceeds the 100 MB limit.');
      return;
    }

    final pendingVideo = VideoAttachment(localPath: event.path, status: VideoUploadStatus.checkingLimits);
    emit(state.copyWith(videoAttachment: pendingVideo, canSubmit: false, isEmpty: false));

    try {
      final limits = await _composeRepository.getUploadLimits();
      if (limits != null && !limits.canUpload) {
        _setVideoError(emit, limits.message ?? 'Daily video upload limit reached.');
        return;
      }

      emit(state.copyWith(videoAttachment: pendingVideo.copyWith(status: VideoUploadStatus.uploading)));
      final bytes = await file.readAsBytes();
      final jobId = await _composeRepository.uploadVideo(bytes);
      if (jobId == null) {
        _setVideoError(emit, 'Upload failed — please try again.');
        return;
      }

      emit(
        state.copyWith(
          videoAttachment: pendingVideo.copyWith(status: VideoUploadStatus.processing, jobId: jobId),
        ),
      );
      final blob = await _pollVideoJob(jobId, emit);
      if (blob == null) return;

      final readyVideo = VideoAttachment(
        localPath: event.path,
        status: VideoUploadStatus.ready,
        uploadProgress: 100,
        blob: blob,
        altText: state.videoAttachment?.altText ?? '',
        jobId: jobId,
      );
      final isEmpty = state.text.trim().isEmpty && state.mediaAttachments.isEmpty;
      emit(state.copyWith(videoAttachment: readyVideo, isEmpty: isEmpty, canSubmit: !state.isOverLimit && !isEmpty));
    } catch (e, stackTrace) {
      log.e('Video upload failed', error: e, stackTrace: stackTrace);
      _setVideoError(emit, 'Upload failed: $e');
    }
  }

  Future<Blob?> _pollVideoJob(String jobId, Emitter<ComposeState> emit) async {
    final deadline = DateTime.now().add(_kVideoJobPollTimeout);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_kVideoJobPollInterval);
      try {
        final status = await _composeRepository.getJobStatus(jobId);
        if (status == null) continue;

        final progress = status.progress ?? 0;
        final current = state.videoAttachment;
        if (current != null) {
          emit(state.copyWith(videoAttachment: current.copyWith(uploadProgress: progress)));
        }

        final knownState = status.state.knownValue;
        if (knownState == KnownJobStatusState.jOB_STATE_COMPLETED && status.blob != null) {
          return status.blob;
        }
        if (knownState == KnownJobStatusState.jOB_STATE_FAILED) {
          _setVideoError(emit, status.error ?? 'Video processing failed.');
          return null;
        }
      } catch (e) {
        log.w('Video job poll error (retrying)', error: e);
      }
    }

    _setVideoError(emit, 'Video processing timed out.');
    return null;
  }

  void _setVideoError(Emitter<ComposeState> emit, String message) {
    final current = state.videoAttachment;
    if (current != null) {
      emit(
        state.copyWith(
          videoAttachment: current.copyWith(status: VideoUploadStatus.error, errorMessage: message),
        ),
      );
    }
  }

  Future<void> _onVideoRemoved(VideoRemoved event, Emitter<ComposeState> emit) async {
    final isEmpty = state.text.trim().isEmpty && state.mediaAttachments.isEmpty;
    emit(state.copyWith(videoAttachment: null, isEmpty: isEmpty, canSubmit: !state.isOverLimit && !isEmpty));
  }

  Future<void> _onVideoAltTextUpdated(VideoAltTextUpdated event, Emitter<ComposeState> emit) async {
    final updated = state.videoAttachment?.copyWith(altText: event.altText);
    if (updated != null) emit(state.copyWith(videoAttachment: updated));
  }

  Future<void> _onDraftSaved(DraftSaved event, Emitter<ComposeState> emit) async {
    emit(state.copyWith(isSavingDraft: true));
    try {
      final embedPayload = _buildEmbedPayload();
      final draft = DraftsCompanion(
        id: state.draftId != null ? Value(state.draftId!) : const Value.absent(),
        accountDid: Value(_accountDid),
        content: Value(state.text),
        replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
        replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
        rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
        rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
        embedJson: embedPayload != null ? Value(embedPayload.encode()) : const Value.absent(),
        mediaPaths: state.mediaAttachments.isNotEmpty
            ? Value(DraftEmbedPayload.encodeMediaPaths(state.mediaAttachments.map((m) => m.localPath)))
            : const Value.absent(),
        scheduledAt: state.scheduledAt != null ? Value(state.scheduledAt!) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );
      final id = await _database.saveDraft(draft);
      emit(state.copyWith(draftId: id, isSavingDraft: false, isDraftDirty: false));
    } catch (e, stackTrace) {
      log.e('Failed to save draft', error: e, stackTrace: stackTrace);
      emit(state.copyWith(isSavingDraft: false));
    }
  }

  Future<void> _onDraftLoaded(DraftLoaded event, Emitter<ComposeState> emit) async {
    try {
      final draft = await _database.getDraft(event.draftId);
      if (draft == null) return;

      List<MediaAttachment> attachments = [];

      final embedPayload = DraftEmbedPayload.tryDecode(draft.embedJson);
      if (embedPayload is DraftImagesEmbedPayload) {
        try {
          attachments = embedPayload.paths.asMap().entries.where((e) => File(e.value).existsSync()).map((e) {
            return MediaAttachment(
              localPath: e.value,
              altText: e.key < embedPayload.altTexts.length ? embedPayload.altTexts[e.key] : '',
            );
          }).toList();
        } catch (e) {
          log.w('Failed to parse embedJson from draft', error: e);
        }
      }

      if (attachments.isEmpty && draft.mediaPaths != null) {
        try {
          attachments = DraftEmbedPayload.decodeMediaPaths(
            draft.mediaPaths!,
          ).where((path) => File(path).existsSync()).map((path) => MediaAttachment(localPath: path)).toList();
        } catch (e) {
          log.w('Failed to parse mediaPaths from draft', error: e);
        }
      }

      final text = draft.content;
      final graphemeCount = text.characters.length;
      final isOverLimit = graphemeCount > kMaxGraphemes;
      final isEmpty = text.trim().isEmpty && attachments.isEmpty;

      emit(
        ComposeState.ready(
          text: text,
          mediaAttachments: attachments,
          draftId: draft.id,
          scheduledAt: draft.scheduledAt,
          replyParentUri: draft.replyUri,
          replyParentCid: draft.replyCid,
          replyRootUri: draft.rootUri,
          replyRootCid: draft.rootCid,
          isDraftDirty: false,
        ).copyWith(
          graphemeCount: graphemeCount,
          isOverLimit: isOverLimit,
          isEmpty: isEmpty,
          canSubmit: !isOverLimit && !isEmpty,
        ),
      );
    } catch (e, stackTrace) {
      log.e('Failed to load draft', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _onDraftsRequested(DraftsRequested event, Emitter<ComposeState> emit) async {
    emit(state.copyWith(isLoadingDrafts: true));
    try {
      final drafts = await _database.getDrafts(_accountDid);
      emit(state.copyWith(drafts: drafts, isLoadingDrafts: false));
    } catch (e, stackTrace) {
      log.e('Failed to load drafts', error: e, stackTrace: stackTrace);
      emit(state.copyWith(isLoadingDrafts: false));
    }
  }

  Future<void> _onDraftDeleted(DraftDeleted event, Emitter<ComposeState> emit) async {
    try {
      await _database.deleteDraft(event.draftId);
      final drafts = List<DraftEntry>.from(state.drafts)..removeWhere((d) => d.id == event.draftId);
      emit(state.copyWith(drafts: drafts));
    } catch (e, stackTrace) {
      log.e('Failed to delete draft', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _onPostScheduled(PostScheduled event, Emitter<ComposeState> emit) async {
    if (state.isEditing) return;
    emit(state.copyWith(scheduledAt: event.scheduledAt));
  }

  Future<void> _onScheduleCleared(ScheduleCleared event, Emitter<ComposeState> emit) async {
    if (state.isEditing) return;
    emit(state.copyWith(scheduledAt: null));
  }

  Future<void> _onReplyContextSet(ReplyContextSet event, Emitter<ComposeState> emit) async {
    emit(
      state.copyWith(
        replyParentUri: event.parentUri,
        replyParentCid: event.parentCid,
        replyRootUri: event.rootUri,
        replyRootCid: event.rootCid,
      ),
    );
  }

  Future<void> _onReplyContextCleared(ReplyContextCleared event, Emitter<ComposeState> emit) async {
    emit(state.copyWith(replyParentUri: null, replyParentCid: null, replyRootUri: null, replyRootCid: null));
  }

  Future<void> _onQuoteContextSet(QuoteContextSet event, Emitter<ComposeState> emit) async {
    emit(state.copyWith(quoteUri: event.quoteUri, quoteCid: event.quoteCid));
  }

  Future<void> _onQuoteContextCleared(QuoteContextCleared event, Emitter<ComposeState> emit) async {
    emit(state.copyWith(quoteUri: null, quoteCid: null));
  }

  Future<void> _onEditContextSet(EditContextSet event, Emitter<ComposeState> emit) async {
    final text = event.initialText ?? state.text;
    final graphemeCount = text.characters.length;
    final isOverLimit = graphemeCount > kMaxGraphemes;
    final isEmpty = text.trim().isEmpty;

    emit(
      state.copyWith(
        text: text,
        graphemeCount: graphemeCount,
        isOverLimit: isOverLimit,
        isEmpty: isEmpty,
        canSubmit: !isOverLimit && !isEmpty,
        editPostUri: event.postUri,
        editPostCid: event.postCid,
        editRecord: Map<String, dynamic>.from(event.record),
        scheduledAt: null,
        isDraftDirty: false,
      ),
    );
  }

  Future<void> _onPostSubmitted(PostSubmitted event, Emitter<ComposeState> emit) async {
    if (!state.canSubmit || state.isOverLimit) return;

    emit(state.copyWith(status: ComposeStatus.submitting, canSubmit: false));

    try {
      final facets = await _collectFacets();

      if (state.isEditing) {
        final editPostUri = state.editPostUri;
        final editPostCid = state.editPostCid;
        final editRecord = state.editRecord;

        if (editPostUri == null || editPostCid == null || editRecord == null) {
          _emitError(emit, 'Edit context is missing. Please reopen the editor and try again.');
          return;
        }

        final result = await _composeRepository.editPost(
          postUri: editPostUri,
          currentCid: editPostCid,
          originalRecord: editRecord,
          text: state.text,
          facets: facets,
          repo: _accountDid,
        );

        if (result.isSuccess) {
          emit(state.copyWith(status: ComposeStatus.success, canSubmit: false, isDraftDirty: false));
        } else {
          _emitError(emit, result.errorMessage ?? 'Failed to save changes. Please try again.');
        }
        return;
      }

      if (state.scheduledAt != null && state.scheduledAt!.isAfter(DateTime.now())) {
        final embedPayload = _buildEmbedPayload();
        final draft = DraftsCompanion(
          accountDid: Value(_accountDid),
          content: Value(state.text),
          replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
          replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
          rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
          rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
          embedJson: embedPayload != null ? Value(embedPayload.encode()) : const Value.absent(),
          mediaPaths: state.mediaAttachments.isNotEmpty
              ? Value(DraftEmbedPayload.encodeMediaPaths(state.mediaAttachments.map((m) => m.localPath)))
              : const Value.absent(),
          scheduledAt: Value(state.scheduledAt!),
          updatedAt: Value(DateTime.now()),
        );
        final draftId = await _database.saveDraft(draft);
        await PostScheduler.schedulePost(draftId: draftId, scheduledAt: state.scheduledAt!);
        emit(state.copyWith(status: ComposeStatus.success, canSubmit: false));
        return;
      }

      UFeedPostEmbed? mediaEmbed;

      if (state.mediaAttachments.isNotEmpty) {
        final uploaded = <_UploadedImage>[];
        for (final attachment in state.mediaAttachments) {
          final file = File(attachment.localPath);
          if (!file.existsSync()) {
            _emitError(emit, 'Image file not found. Please re-attach and try again.');
            return;
          }
          final bytes = await file.readAsBytes();

          if (bytes.length > kMaxImageBytes) {
            final mb = (bytes.length / 1024 / 1024).toStringAsFixed(1);
            _emitError(emit, 'Image "${attachment.localPath.split('/').last}" is $mb MB — max 1 MB.');
            return;
          }

          final mime = _detectImageMime(bytes);
          if (mime == null) {
            _emitError(emit, 'Unsupported image format. Use JPEG, PNG, or WebP.');
            return;
          }

          final blob = await _composeRepository.uploadBlobRecord(bytes, mimeType: mime);
          if (blob == null) {
            _emitError(emit, 'Failed to upload image. Please try again.');
            return;
          }
          uploaded.add(
            _UploadedImage(blob: blob, altText: attachment.altText, width: attachment.width, height: attachment.height),
          );
        }

        mediaEmbed = UFeedPostEmbed.embedImages(
          data: EmbedImages(
            images: uploaded
                .map(
                  (img) => EmbedImagesImage(
                    image: img.blob,
                    alt: img.altText,
                    aspectRatio: img.width != null && img.height != null
                        ? embed_defs.AspectRatio(width: img.width!, height: img.height!)
                        : null,
                  ),
                )
                .toList(growable: false),
          ),
        );
      } else if (state.videoAttachment?.isReady == true) {
        final blob = state.videoAttachment!.blob!;
        mediaEmbed = UFeedPostEmbed.embedVideo(
          data: EmbedVideo(video: blob, alt: state.videoAttachment!.altText),
        );
      } else {
        final firstLink = LinkPreviewService.firstLink(state.text);
        if (firstLink != null && firstLink != event.suppressedLinkUri) {
          mediaEmbed = await _composeRepository.buildExternalEmbedFromLink(firstLink);
        }
      }

      UFeedPostEmbed? embed;
      if (state.quoteUri != null && state.quoteCid != null) {
        final record = EmbedRecord(
          record: RepoStrongRef(uri: AtUri.parse(state.quoteUri!), cid: state.quoteCid!),
        );
        if (mediaEmbed != null) {
          embed = UFeedPostEmbed.embedRecordWithMedia(
            data: EmbedRecordWithMedia(record: record, media: _recordWithMediaMedia(mediaEmbed)),
          );
        } else {
          embed = UFeedPostEmbed.embedRecord(data: record);
        }
      } else {
        embed = mediaEmbed;
      }

      ReplyRef? reply;
      if (state.replyParentUri != null && state.replyParentCid != null) {
        final fallbackRootUri = state.replyRootUri ?? state.replyParentUri!;
        final fallbackRootCid = state.replyRootCid ?? state.replyParentCid!;
        final resolvedReplyRefs = await _composeRepository.resolveReplyReferences(
          parentUri: state.replyParentUri!,
          parentCid: state.replyParentCid!,
          fallbackRootUri: fallbackRootUri,
          fallbackRootCid: fallbackRootCid,
        );

        final parentCid = resolvedReplyRefs?.parentCid ?? state.replyParentCid!;
        final rootUri = resolvedReplyRefs?.rootUri ?? fallbackRootUri;
        final rootCid = resolvedReplyRefs?.rootCid ?? fallbackRootCid;

        reply = ReplyRef(
          parent: RepoStrongRef(uri: AtUri.parse(state.replyParentUri!), cid: parentCid),
          root: RepoStrongRef(uri: AtUri.parse(rootUri), cid: rootCid),
        );
      }

      final success = await _composeRepository.createPost(
        text: state.text,
        facets: facets,
        embed: embed,
        reply: reply,
        repo: _accountDid,
      );

      if (success) {
        if (state.draftId != null) await _database.deleteDraft(state.draftId!);
        emit(state.copyWith(status: ComposeStatus.success, canSubmit: false));
      } else {
        _emitError(emit, 'Failed to create post. Please try again.');
      }
    } catch (e, stackTrace) {
      log.e('Failed to submit post', error: e, stackTrace: stackTrace);

      if (state.isEditing) {
        _emitError(emit, 'Failed to save changes: $e');
        return;
      }

      await _saveFailedSubmissionAsDraft(emit, e);
    }
  }

  Future<List<RichtextFacet>> _collectFacets() async {
    final blueskyText = BlueskyText(state.text);
    final facets = <RichtextFacet>[];

    for (final entity in blueskyText.entities) {
      try {
        final facetJson = await entity.toFacet().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            log.w('Timeout resolving @${entity.value}; facet dropped.');
            return {};
          },
        );
        if (facetJson.isNotEmpty) {
          facets.add(const RichtextFacetConverter().fromJson(Map<String, dynamic>.from(facetJson)));
        }
      } catch (e) {
        log.w('Could not resolve facet for "${entity.value}": $e');
      }
    }

    return facets;
  }

  Future<void> _saveFailedSubmissionAsDraft(Emitter<ComposeState> emit, Object error) async {
    try {
      final embedPayload = _buildEmbedPayload();
      final draft = DraftsCompanion(
        accountDid: Value(_accountDid),
        content: Value(state.text),
        replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
        replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
        rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
        rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
        embedJson: embedPayload != null ? Value(embedPayload.encode()) : const Value.absent(),
        mediaPaths: state.mediaAttachments.isNotEmpty
            ? Value(DraftEmbedPayload.encodeMediaPaths(state.mediaAttachments.map((m) => m.localPath)))
            : const Value.absent(),
        scheduledAt: state.scheduledAt != null ? Value(state.scheduledAt!) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );
      await _database.saveDraft(draft);
      _emitError(emit, 'Network error — post saved as draft.');
    } catch (draftError, stackTrace) {
      log.e('Failed to save failed post submission as draft', error: draftError, stackTrace: stackTrace);
      _emitError(emit, 'Failed to submit post: $error');
    }
  }

  /// Emits error state (preserving content), then transitions back to ready
  /// so the user can retry without losing their work.
  void _emitError(Emitter<ComposeState> emit, String message) {
    emit(state.copyWith(status: ComposeStatus.error, errorMessage: message, canSubmit: false));
    emit(
      state.copyWith(
        status: ComposeStatus.ready,
        errorMessage: message,
        canSubmit: !state.isOverLimit && !state.isEmpty,
      ),
    );
  }

  DraftEmbedPayload? _buildEmbedPayload() {
    if (state.mediaAttachments.isNotEmpty) {
      return DraftEmbedPayload.images(
        paths: state.mediaAttachments.map((m) => m.localPath).toList(growable: false),
        altTexts: state.mediaAttachments.map((m) => m.altText).toList(growable: false),
      );
    }
    if (state.videoAttachment != null) {
      return DraftEmbedPayload.video(path: state.videoAttachment!.localPath, alt: state.videoAttachment!.altText);
    }
    return null;
  }

  UEmbedRecordWithMediaMedia _recordWithMediaMedia(UFeedPostEmbed embed) {
    if (embed.isEmbedImages) {
      return UEmbedRecordWithMediaMedia.embedImages(data: embed.embedImages!);
    }
    if (embed.isEmbedVideo) {
      return UEmbedRecordWithMediaMedia.embedVideo(data: embed.embedVideo!);
    }
    if (embed.isEmbedExternal) {
      return UEmbedRecordWithMediaMedia.embedExternal(data: embed.embedExternal!);
    }

    return UEmbedRecordWithMediaMedia.unknown(data: embed.toJson());
  }

  /// Returns MIME type from magic bytes, or null if not an accepted image type.
  static String? _detectImageMime(List<int> bytes) {
    if (bytes.length < 12) return null;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'image/jpeg';
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'image/png';
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }
}

class _UploadedImage {
  const _UploadedImage({required this.blob, required this.altText, this.width, this.height});

  final Blob blob;
  final String altText;
  final int? width;
  final int? height;
}

class EditPostResult {
  const EditPostResult._({required this.isSuccess, this.errorMessage, this.cid});

  const EditPostResult.success({required String cid}) : this._(isSuccess: true, cid: cid);

  const EditPostResult.failure(String message) : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
  final String? cid;
}

class ComposeRepository {
  ComposeRepository({
    required Bluesky bluesky,
    LinkPreviewService? linkPreviewService,
    ActorRepositoryServiceResolver? actorRepositoryServiceResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _actorRepoResolver = actorRepositoryServiceResolver ?? ActorRepositoryServiceResolver(),
       _linkPreviewService = linkPreviewService ?? LinkPreviewService() {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('compose.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  Bluesky get _bluesky => _authRecovery.client;
  final LinkPreviewService _linkPreviewService;
  final ActorRepositoryServiceResolver _actorRepoResolver;

  Future<Blob?> uploadBlobRecord(List<int> bytes, {String mimeType = 'image/jpeg'}) async {
    try {
      final response = await _authRecovery.run(
        (client) =>
            client.atproto.repo.uploadBlob(bytes: Uint8List.fromList(bytes), $headers: {'Content-Type': mimeType}),
      );
      return response.data.blob;
    } catch (e, stackTrace) {
      log.e('Failed to upload blob', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<BlobRef?> uploadBlob(List<int> bytes, {String mimeType = 'image/jpeg'}) async {
    final blob = await uploadBlobRecord(bytes, mimeType: mimeType);
    return blob?.ref;
  }

  /// Uploads video bytes and returns the job ID, or null on failure.
  Future<String?> uploadVideo(Uint8List bytes) async {
    try {
      final response = await _authRecovery.run((client) => client.video.uploadVideo(bytes: bytes));
      return response.data.jobId;
    } catch (e, stackTrace) {
      log.e('Failed to upload video', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<JobStatus?> getJobStatus(String jobId) async {
    try {
      final response = await _authRecovery.run((client) => client.video.getJobStatus(jobId: jobId));
      return response.data.jobStatus;
    } catch (e, stackTrace) {
      log.e('Failed to get job status', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<({bool canUpload, String? message})?> getUploadLimits() async {
    try {
      final response = await _authRecovery.run((client) => client.video.getUploadLimits());
      final d = response.data;
      final canUpload = d.canUpload;
      final message = d.message ?? d.error;
      return (canUpload: canUpload == true, message: message is String ? message : null);
    } catch (e, stackTrace) {
      log.e('Failed to get upload limits', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> createPost({
    required String text,
    required List<RichtextFacet> facets,
    UFeedPostEmbed? embed,
    ReplyRef? reply,
    required String repo,
  }) async {
    try {
      final record = FeedPostRecord(
        text: text,
        facets: facets.isEmpty ? null : facets,
        embed: embed,
        reply: reply,
        langs: const ['en'],
        createdAt: DateTime.now().toUtc(),
      );

      await _authRecovery.run(
        (client) => client.atproto.repo.createRecord(
          repo: repo,
          collection: 'app.bsky.feed.post',
          record: _postRecordJson(record),
        ),
      );
      return true;
    } catch (e, stackTrace) {
      log.e('Failed to create post', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<LinkPreviewData?> fetchLinkPreview(String rawUrl) async {
    try {
      return await _linkPreviewService.fetch(rawUrl);
    } catch (error, stackTrace) {
      log.w('Failed to fetch link preview metadata', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<UFeedPostEmbed?> buildExternalEmbedFromLink(String rawUrl) async {
    final preview = await fetchLinkPreview(rawUrl);
    if (preview == null) {
      return null;
    }

    final thumbUrl = preview.thumbnailUrl;
    Blob? thumbBlob;
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      final thumb = await _uploadExternalThumb(thumbUrl);
      if (thumb != null) {
        thumbBlob = thumb;
      }
    }

    return UFeedPostEmbed.embedExternal(
      data: EmbedExternal(
        external: EmbedExternalExternal(
          uri: preview.uri,
          title: preview.title,
          description: preview.description,
          thumb: thumbBlob,
        ),
      ),
    );
  }

  Future<({String parentCid, String rootUri, String rootCid})?> resolveReplyReferences({
    required String parentUri,
    required String parentCid,
    required String fallbackRootUri,
    required String fallbackRootCid,
  }) async {
    try {
      final parentAtUri = AtUri.parse(parentUri);
      final parent = await _getRecordFromRepo(
        repo: parentAtUri.hostname,
        collection: parentAtUri.collection.toString(),
        rkey: parentAtUri.rkey,
      );

      final latestParentCid = parent.data.cid?.isNotEmpty == true ? parent.data.cid! : parentCid;
      final parentRecord = _parsePostRecord(parent.data.value);
      if (parentRecord == null) {
        return (parentCid: latestParentCid, rootUri: parentUri, rootCid: latestParentCid);
      }

      final parentReply = parentRecord.reply;
      if (parentReply == null) {
        return (parentCid: latestParentCid, rootUri: parentUri, rootCid: latestParentCid);
      }

      final rootUri = parentReply.root.uri.toString();
      final rootCid = parentReply.root.cid;
      if (rootUri.isNotEmpty && rootCid.isNotEmpty) {
        return (parentCid: latestParentCid, rootUri: rootUri, rootCid: rootCid);
      }

      return (parentCid: latestParentCid, rootUri: fallbackRootUri, rootCid: fallbackRootCid);
    } catch (error, stackTrace) {
      log.w('Failed to resolve reply references; using fallback refs', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<Blob?> _uploadExternalThumb(String thumbUrl) async {
    try {
      final thumb = await _linkPreviewService.fetchThumbnail(thumbUrl);
      if (thumb == null) {
        return null;
      }
      return await uploadBlobRecord(thumb.bytes, mimeType: thumb.mimeType);
    } catch (error, stackTrace) {
      log.w('Failed to upload external embed thumbnail blob', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<EditPostResult> editPost({
    required String postUri,
    required String currentCid,
    required Map<String, dynamic> originalRecord,
    required String text,
    required List<RichtextFacet> facets,
    required String repo,
  }) async {
    try {
      final atUri = AtUri.parse(postUri);
      final targetRepo = atUri.hostname.isNotEmpty ? atUri.hostname : repo;
      final collection = atUri.collection.toString();
      final rkey = atUri.rkey;
      final latest = await _getRecordFromRepo(repo: targetRepo, collection: collection, rkey: rkey);

      final latestValue = latest.data.value;
      final latestRecord = _parsePostRecord(latestValue);
      final originalPostRecord = _parsePostRecord(originalRecord);
      final baseRecord = latestRecord ?? originalPostRecord;
      if (baseRecord == null) {
        return const EditPostResult.failure('This post record is malformed. Reopen it and try editing again.');
      }
      final latestCid = latest.data.cid;
      final swapCid = latestCid != null && latestCid.isNotEmpty ? latestCid : currentCid;
      final updatedRecord = baseRecord.copyWith(text: text, facets: facets.isEmpty ? null : facets);

      await _authRecovery.run(
        (client) =>
            client.atproto.repo.deleteRecord(repo: targetRepo, collection: collection, rkey: rkey, swapRecord: swapCid),
      );

      late final String newCid;
      try {
        final created = await _authRecovery.run(
          (client) => client.atproto.repo.createRecord(
            repo: targetRepo,
            collection: collection,
            rkey: rkey,
            record: _postRecordJson(updatedRecord),
          ),
        );
        newCid = created.data.cid;
      } on XRPCException catch (e, stackTrace) {
        log.e('Failed to recreate post during edit; checking current state', error: e, stackTrace: stackTrace);

        final snapshot = await _tryGetRecordSnapshot(repo: targetRepo, collection: collection, rkey: rkey);
        if (snapshot != null) {
          final persistedText = snapshot.value['text'];
          if (persistedText is String && persistedText == text) {
            return EditPostResult.success(cid: snapshot.cid ?? currentCid);
          }
          return const EditPostResult.failure('This post was changed elsewhere. Reopen it and try editing again.');
        }

        final restored = await _restoreOriginalRecord(
          repo: targetRepo,
          collection: collection,
          rkey: rkey,
          originalRecord: baseRecord,
        );
        if (restored) {
          return const EditPostResult.failure('Could not save changes. Your original post was restored.');
        }

        return const EditPostResult.failure(
          'Could not save changes and we could not confirm recovery. Reopen the thread and verify the post.',
        );
      }

      final verified = await _getRecordFromRepo(repo: targetRepo, collection: collection, rkey: rkey);
      final persistedText = verified.data.value['text'];
      if (persistedText is! String || persistedText != text) {
        return const EditPostResult.failure(
          'Edit was submitted but could not be confirmed yet. Please reopen the post and verify.',
        );
      }

      return EditPostResult.success(cid: newCid);
    } on XRPCException catch (e, stackTrace) {
      final errorCode = e.response.data.error;
      final errorMessage = e.response.data.message ?? '';
      log.e('Failed to edit post', error: e, stackTrace: stackTrace);

      if (errorCode == 'InvalidSwap' || errorMessage.contains('Record was at')) {
        return const EditPostResult.failure('This post was changed elsewhere. Reopen it and try editing again.');
      }

      if (errorCode == 'RecordNotFound' || errorCode == 'NotFound') {
        return const EditPostResult.failure('This post is no longer available. Reopen the thread and try again.');
      }

      return EditPostResult.failure(
        errorMessage.isNotEmpty ? errorMessage : 'Failed to save changes. Please try again.',
      );
    } catch (e, stackTrace) {
      log.e('Failed to edit post', error: e, stackTrace: stackTrace);
      return const EditPostResult.failure('Failed to save changes. Please try again.');
    }
  }

  Future<({Map<String, dynamic> value, String? cid})?> _tryGetRecordSnapshot({
    required String repo,
    required String collection,
    required String rkey,
  }) async {
    try {
      final response = await _getRecordFromRepo(repo: repo, collection: collection, rkey: rkey);
      if (!FeedPostRecord.validate(response.data.value)) {
        return null;
      }
      return (value: response.data.value, cid: response.data.cid);
    } on XRPCException catch (e, stackTrace) {
      final errorCode = e.response.data.error;
      if (errorCode == 'RecordNotFound' || errorCode == 'NotFound') {
        return null;
      }
      log.w('Failed to read post snapshot during edit recovery', error: e, stackTrace: stackTrace);
      return null;
    } catch (e, stackTrace) {
      log.w('Failed to read post snapshot during edit recovery', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> _restoreOriginalRecord({
    required String repo,
    required String collection,
    required String rkey,
    required FeedPostRecord originalRecord,
  }) async {
    try {
      await _authRecovery.run(
        (client) => client.atproto.repo.createRecord(
          repo: repo,
          collection: collection,
          rkey: rkey,
          record: _postRecordJson(originalRecord),
        ),
      );
      return true;
    } catch (e, stackTrace) {
      log.e('Failed to restore original record after edit failure', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<XRPCResponse<RepoGetRecordOutput>> _getRecordFromRepo({
    required String repo,
    required String collection,
    required String rkey,
  }) async {
    final serviceHost = await _resolveRepoServiceHost(repo);
    return _authRecovery.run(
      (client) => client.atproto.repo.getRecord(repo: repo, collection: collection, rkey: rkey, $service: serviceHost),
    );
  }

  FeedPostRecord? _parsePostRecord(Map<String, dynamic> value) {
    if (!FeedPostRecord.validate(value)) {
      return null;
    }

    try {
      return const FeedPostRecordConverter().fromJson(value);
    } catch (error, stackTrace) {
      log.w('ComposeRepository: skipped malformed feed post record', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Map<String, dynamic> _postRecordJson(FeedPostRecord record) {
    return const FeedPostRecordConverter().toJson(record);
  }

  Future<String?> _resolveRepoServiceHost(String repo) async {
    if (_isCurrentSessionRepo(repo)) {
      return null;
    }

    try {
      final resolved = await _actorRepoResolver.resolve(repo);
      return resolved.pdsHost;
    } catch (error, stackTrace) {
      log.w(
        'ComposeRepository: Failed to resolve non-self repo host for $repo; aborting foreign repo read',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  bool _isCurrentSessionRepo(String repo) {
    final normalizedRepo = repo.trim().toLowerCase();
    if (normalizedRepo.isEmpty) {
      return false;
    }

    final sessionDid = _bluesky.session?.did.trim().toLowerCase();
    if (sessionDid != null && sessionDid.isNotEmpty && normalizedRepo == sessionDid) {
      return true;
    }

    final oauthDid = _bluesky.oAuthSession?.sub.trim().toLowerCase();
    return oauthDid != null && oauthDid.isNotEmpty && normalizedRepo == oauthDid;
  }
}

/// Image dimension helper (used by compose screen when picking images).
Future<({int width, int height})?> readImageDimensions(List<int> bytes) async {
  try {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.fromList(bytes), completer.complete);
    final image = await completer.future;
    final result = (width: image.width, height: image.height);
    image.dispose();
    return result;
  } catch (error, stackTrace) {
    log.w('Failed to read image dimensions', error: error, stackTrace: stackTrace);
    return null;
  }
}
