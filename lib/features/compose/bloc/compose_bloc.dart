import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:atproto_core/atproto_core.dart' show Blob, BlobRef;
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/app_bsky_video_defs.dart' show KnownJobStatusState;
import 'package:bluesky_text/bluesky_text.dart';
import 'package:characters/characters.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/scheduler/post_scheduler.dart';

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
  }

  final ComposeRepository _composeRepository;
  final AppDatabase _database;
  final String _accountDid;

  Future<void> _onTextChanged(TextChanged event, Emitter<ComposeState> emit) async {
    final text = event.text;
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

    emit(state.copyWith(mediaAttachments: attachments, isEmpty: isEmpty, canSubmit: !state.isOverLimit && !isEmpty, isDraftDirty: true));
  }

  Future<void> _onMediaRemoved(MediaRemoved event, Emitter<ComposeState> emit) async {
    if (event.index < 0 || event.index >= state.mediaAttachments.length) return;

    final attachments = List<MediaAttachment>.from(state.mediaAttachments)..removeAt(event.index);
    final isEmpty = state.text.trim().isEmpty && attachments.isEmpty && state.videoAttachment == null;

    emit(state.copyWith(mediaAttachments: attachments, isEmpty: isEmpty, canSubmit: !state.isOverLimit && !isEmpty, isDraftDirty: true));
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
      final embedJson = _buildEmbedJson();
      final draft = DraftsCompanion(
        id: state.draftId != null ? Value(state.draftId!) : const Value.absent(),
        accountDid: Value(_accountDid),
        content: Value(state.text),
        replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
        replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
        rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
        rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
        embedJson: embedJson != null ? Value(jsonEncode(embedJson)) : const Value.absent(),
        mediaPaths: state.mediaAttachments.isNotEmpty
            ? Value(jsonEncode(state.mediaAttachments.map((m) => m.localPath).toList()))
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

      if (draft.embedJson != null) {
        try {
          final decoded = jsonDecode(draft.embedJson!) as Map<String, dynamic>;
          final type = decoded['type'] as String?;
          if (type == 'images') {
            final paths = decoded['paths'] as List<dynamic>? ?? [];
            final alts = decoded['altTexts'] as List<dynamic>? ?? [];
            attachments = paths.asMap().entries.where((e) => File(e.value as String).existsSync()).map((e) {
              return MediaAttachment(
                localPath: e.value as String,
                altText: e.key < alts.length ? (alts[e.key] as String? ?? '') : '',
              );
            }).toList();
          }
        } catch (e) {
          log.w('Failed to parse embedJson from draft', error: e);
        }
      }

      if (attachments.isEmpty && draft.mediaPaths != null) {
        try {
          final paths = jsonDecode(draft.mediaPaths!) as List<dynamic>;
          attachments = paths
              .whereType<String>()
              .where((path) => File(path).existsSync())
              .map((path) => MediaAttachment(localPath: path))
              .toList();
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
    emit(state.copyWith(scheduledAt: event.scheduledAt));
  }

  Future<void> _onScheduleCleared(ScheduleCleared event, Emitter<ComposeState> emit) async {
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

  Future<void> _onPostSubmitted(PostSubmitted event, Emitter<ComposeState> emit) async {
    if (!state.canSubmit || state.isOverLimit) return;

    emit(state.copyWith(status: ComposeStatus.submitting, canSubmit: false));

    try {
      if (state.scheduledAt != null && state.scheduledAt!.isAfter(DateTime.now())) {
        final embedJson = _buildEmbedJson();
        final draft = DraftsCompanion(
          accountDid: Value(_accountDid),
          content: Value(state.text),
          replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
          replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
          rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
          rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
          embedJson: embedJson != null ? Value(jsonEncode(embedJson)) : const Value.absent(),
          mediaPaths: state.mediaAttachments.isNotEmpty
              ? Value(jsonEncode(state.mediaAttachments.map((m) => m.localPath).toList()))
              : const Value.absent(),
          scheduledAt: Value(state.scheduledAt!),
          updatedAt: Value(DateTime.now()),
        );
        final draftId = await _database.saveDraft(draft);
        await PostScheduler.schedulePost(draftId: draftId, scheduledAt: state.scheduledAt!);
        emit(state.copyWith(status: ComposeStatus.success, canSubmit: false));
        return;
      }

      final blueskyText = BlueskyText(state.text);
      final facets = <Map<String, dynamic>>[];
      for (final entity in blueskyText.entities) {
        try {
          final facet = await entity.toFacet().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              log.w('Timeout resolving @${entity.value}; facet dropped.');
              return {};
            },
          );
          if (facet.isNotEmpty) facets.add(facet);
        } catch (e) {
          log.w('Could not resolve facet for "${entity.value}": $e');
        }
      }

      Map<String, dynamic>? embed;

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

          final blob = await _composeRepository.uploadBlob(bytes, mimeType: mime);
          if (blob == null) {
            _emitError(emit, 'Failed to upload image. Please try again.');
            return;
          }
          uploaded.add(
            _UploadedImage(
              blobRef: blob,
              altText: attachment.altText,
              width: attachment.width,
              height: attachment.height,
            ),
          );
        }

        embed = {
          '\$type': 'app.bsky.embed.images',
          'images': uploaded.map((img) {
            final entry = <String, dynamic>{'image': img.blobRef.toJson(), 'alt': img.altText};
            if (img.width != null && img.height != null) {
              entry['aspectRatio'] = {'width': img.width, 'height': img.height};
            }
            return entry;
          }).toList(),
        };
      } else if (state.videoAttachment?.isReady == true) {
        final blob = state.videoAttachment!.blob!;
        embed = {r'$type': 'app.bsky.embed.video', 'video': blob.toJson(), 'alt': state.videoAttachment!.altText};
      } else if (state.quoteUri != null && state.quoteCid != null) {
        embed = {
          r'$type': 'app.bsky.embed.record',
          'record': {'uri': state.quoteUri, 'cid': state.quoteCid},
        };
      }

      Map<String, dynamic>? reply;
      if (state.replyParentUri != null && state.replyParentCid != null) {
        reply = {
          'parent': {'uri': state.replyParentUri, 'cid': state.replyParentCid},
          'root': {
            'uri': state.replyRootUri ?? state.replyParentUri,
            'cid': state.replyRootCid ?? state.replyParentCid,
          },
        };
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

      try {
        final embedJson = _buildEmbedJson();
        final draft = DraftsCompanion(
          accountDid: Value(_accountDid),
          content: Value(state.text),
          replyUri: state.replyParentUri != null ? Value(state.replyParentUri!) : const Value.absent(),
          replyCid: state.replyParentCid != null ? Value(state.replyParentCid!) : const Value.absent(),
          rootUri: state.replyRootUri != null ? Value(state.replyRootUri!) : const Value.absent(),
          rootCid: state.replyRootCid != null ? Value(state.replyRootCid!) : const Value.absent(),
          embedJson: embedJson != null ? Value(jsonEncode(embedJson)) : const Value.absent(),
          mediaPaths: state.mediaAttachments.isNotEmpty
              ? Value(jsonEncode(state.mediaAttachments.map((m) => m.localPath).toList()))
              : const Value.absent(),
          scheduledAt: state.scheduledAt != null ? Value(state.scheduledAt!) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        );
        await _database.saveDraft(draft);
        _emitError(emit, 'Network error — post saved as draft.');
      } catch (_) {
        _emitError(emit, 'Failed to submit post: $e');
      }
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

  Map<String, dynamic>? _buildEmbedJson() {
    if (state.mediaAttachments.isNotEmpty) {
      return {
        'type': 'images',
        'paths': state.mediaAttachments.map((m) => m.localPath).toList(),
        'altTexts': state.mediaAttachments.map((m) => m.altText).toList(),
      };
    }
    if (state.videoAttachment != null) {
      return {'type': 'video', 'path': state.videoAttachment!.localPath, 'alt': state.videoAttachment!.altText};
    }
    return null;
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
  const _UploadedImage({required this.blobRef, required this.altText, this.width, this.height});

  final BlobRef blobRef;
  final String altText;
  final int? width;
  final int? height;
}

class ComposeRepository {
  ComposeRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<BlobRef?> uploadBlob(List<int> bytes, {String mimeType = 'image/jpeg'}) async {
    try {
      final response = await _bluesky.atproto.repo.uploadBlob(
        bytes: Uint8List.fromList(bytes),
        $headers: {'Content-Type': mimeType},
      );
      return response.data.blob.ref;
    } catch (e, stackTrace) {
      log.e('Failed to upload blob', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Uploads video bytes and returns the job ID, or null on failure.
  Future<String?> uploadVideo(Uint8List bytes) async {
    try {
      final response = await _bluesky.video.uploadVideo(bytes: bytes);
      return response.data.jobId;
    } catch (e, stackTrace) {
      log.e('Failed to upload video', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<dynamic> getJobStatus(String jobId) async {
    try {
      final response = await _bluesky.video.getJobStatus(jobId: jobId);
      return response.data.jobStatus;
    } catch (e, stackTrace) {
      log.e('Failed to get job status', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<({bool canUpload, String? message})?> getUploadLimits() async {
    try {
      final response = await _bluesky.video.getUploadLimits();
      final d = response.data;
      return (canUpload: d.canUpload, message: d.message ?? d.error);
    } catch (e, stackTrace) {
      log.e('Failed to get upload limits', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> createPost({
    required String text,
    required List<Map<String, dynamic>> facets,
    Map<String, dynamic>? embed,
    Map<String, dynamic>? reply,
    required String repo,
  }) async {
    try {
      final record = <String, dynamic>{
        '\$type': 'app.bsky.feed.post',
        'text': text,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'langs': ['en'],
      };
      if (facets.isNotEmpty) record['facets'] = facets;
      if (embed != null) record['embed'] = embed;
      if (reply != null) record['reply'] = reply;

      await _bluesky.atproto.repo.createRecord(repo: repo, collection: 'app.bsky.feed.post', record: record);
      return true;
    } catch (e, stackTrace) {
      log.e('Failed to create post', error: e, stackTrace: stackTrace);
      return false;
    }
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
  } catch (_) {
    return null;
  }
}
