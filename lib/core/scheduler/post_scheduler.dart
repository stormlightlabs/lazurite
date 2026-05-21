import 'dart:io';
import 'dart:typed_data';

import 'package:poptart_core/poptart_core.dart' show AtUri, Blob;
import 'package:bluesky_poptart/app/bsky/embed/defs.dart' as embed_defs;
import 'package:bluesky_poptart/app/bsky/embed/images.dart';
import 'package:bluesky_poptart/app/bsky/embed/video.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:bluesky_poptart/app/bsky/richtext/facet.dart';
import 'package:bluesky_poptart/app/bsky/video/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart_bluesky_text/poptart_bluesky_text.dart';
import 'package:flutter/widgets.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/data/draft_embed_payload.dart';
import 'package:lazurite/features/notifications/background/notification_background_worker.dart';
import 'package:workmanager/workmanager.dart';

const _kTaskName = 'lazurite.scheduled_post';
const _kTaskTag = 'scheduled_post';
const _kVideoPollInterval = Duration(seconds: 2);
const _kVideoPollTimeout = Duration(minutes: 5);

/// Top-level callback required by WorkManager.
/// Runs in an isolate; must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _kTaskName) {
      final draftId = inputData?['draftId'] as int?;
      if (draftId == null) return Future.value(false);

      try {
        await _submitScheduledDraft(draftId);
        return Future.value(true);
      } catch (e, stackTrace) {
        log.e('Scheduled post failed for draft $draftId', error: e, stackTrace: stackTrace);
        return Future.value(false);
      }
    }

    final notificationTaskResult = await handleNotificationWorkmanagerTask(taskName, inputData);
    if (notificationTaskResult != null) {
      return Future.value(notificationTaskResult);
    }

    return Future.value(true);
  });
}

/// Executes a scheduled post from a persisted draft.
///
/// Opens a fresh [AppDatabase], restores the user session, rebuilds the post
/// (uploading any media blobs as needed), creates the AT Protocol record, then
/// deletes the draft on success.
Future<void> _submitScheduledDraft(int draftId) async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  try {
    final authRepo = AuthRepository(database: database);
    var tokens = await authRepo.restoreSession();
    if (tokens == null) {
      throw Exception('No authenticated session for scheduled draft $draftId');
    }
    final accountDid = tokens.did;

    Future<AuthTokens?> recoverSession() async {
      final currentTokens = tokens;
      if (currentTokens == null) {
        return null;
      }
      final refreshed = await authRepo.refreshSession(currentTokens);
      if (refreshed == null || refreshed.did != accountDid) {
        return null;
      }
      tokens = refreshed;
      return refreshed;
    }

    final bluesky = createBlueskyClient(tokens);
    if (bluesky == null) {
      throw Exception('Could not build Bluesky client for scheduled draft $draftId');
    }

    final draft = await database.getDraft(draftId);
    if (draft == null) {
      log.w('Scheduled post: draft $draftId not found — may have been manually deleted');
      return;
    }

    final composeRepo = ComposeRepository(bluesky: bluesky, onUnauthorized: recoverSession);

    final facets = <RichtextFacet>[];
    for (final entity in BlueskyText(draft.content).entities) {
      try {
        final facetJson = await entity.toFacet().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            log.w('Scheduled post: timeout resolving facet for "${entity.value}"');
            return {};
          },
        );
        if (facetJson.isNotEmpty) {
          facets.add(const RichtextFacetConverter().fromJson(Map<String, dynamic>.from(facetJson)));
        }
      } catch (e) {
        log.w('Scheduled post: could not resolve facet for "${entity.value}": $e');
      }
    }

    UFeedPostEmbed? embed;

    final embedPayload = DraftEmbedPayload.tryDecode(draft.embedJson);
    if (embedPayload is DraftImagesEmbedPayload) {
      embed = await _buildImageEmbed(composeRepo, embedPayload);
    } else if (embedPayload is DraftVideoEmbedPayload) {
      embed = await _buildVideoEmbed(composeRepo, embedPayload);
    }

    ReplyRef? reply;
    if (draft.replyUri != null && draft.replyCid != null) {
      reply = ReplyRef(
        parent: RepoStrongRef(uri: AtUri.parse(draft.replyUri!), cid: draft.replyCid!),
        root: RepoStrongRef(uri: AtUri.parse(draft.rootUri ?? draft.replyUri!), cid: draft.rootCid ?? draft.replyCid!),
      );
    }

    final success = await composeRepo.createPost(
      text: draft.content,
      facets: facets,
      embed: embed,
      reply: reply,
      repo: accountDid,
    );

    if (!success) {
      throw Exception('createPost returned false for scheduled draft $draftId');
    }

    await database.deleteDraft(draftId);
    log.i('Scheduled post: sent draft $draftId successfully');
  } finally {
    await database.close();
  }
}

/// Uploads images from a draft embed payload.
Future<UFeedPostEmbed?> _buildImageEmbed(ComposeRepository repo, DraftImagesEmbedPayload payload) async {
  final paths = payload.paths;
  final alts = payload.altTexts;
  final images = <EmbedImagesImage>[];

  for (var i = 0; i < paths.length; i++) {
    final file = File(paths[i]);
    if (!file.existsSync()) {
      log.w('Scheduled post: image not found at ${paths[i]}, skipping');
      continue;
    }

    final bytes = await file.readAsBytes();
    final mime = _detectMime(bytes);
    if (mime == null) {
      log.w('Scheduled post: unsupported image format at ${paths[i]}, skipping');
      continue;
    }

    final blob = await repo.uploadBlobRecord(bytes.toList(), mimeType: mime);
    if (blob == null) {
      throw Exception('Failed to upload image ${paths[i]}');
    }

    final altText = i < alts.length ? alts[i] : '';
    embed_defs.AspectRatio? aspectRatio;
    try {
      final dims = await readImageDimensions(bytes.toList());
      if (dims != null) {
        aspectRatio = embed_defs.AspectRatio(width: dims.width, height: dims.height);
      }
    } catch (error, stackTrace) {
      log.w('Scheduled post: could not read image dimensions for ${paths[i]}', error: error, stackTrace: stackTrace);
    }

    images.add(EmbedImagesImage(image: blob, alt: altText, aspectRatio: aspectRatio));
  }

  if (images.isEmpty) return null;
  return UFeedPostEmbed.embedImages(data: EmbedImages(images: images));
}

/// Re-uploads a video from its local path and polls the processing job.
Future<UFeedPostEmbed?> _buildVideoEmbed(ComposeRepository repo, DraftVideoEmbedPayload payload) async {
  final path = payload.path;
  final altText = payload.alt;

  final file = File(path);
  if (!file.existsSync()) {
    log.w('Scheduled post: video not found at $path');
    return null;
  }

  final bytes = await file.readAsBytes();
  if (bytes.length > kMaxVideoBytes) {
    throw Exception('Video exceeds 100 MB limit: $path');
  }

  final jobId = await repo.uploadVideo(bytes);
  if (jobId == null) throw Exception('Failed to upload video for scheduled post');

  final blob = await _pollVideoJob(repo, jobId);
  if (blob == null) throw Exception('Video processing failed for scheduled post');

  return UFeedPostEmbed.embedVideo(
    data: EmbedVideo(video: blob, alt: altText),
  );
}

/// Polls `getJobStatus` until the video is ready or the deadline passes.
Future<Blob?> _pollVideoJob(ComposeRepository repo, String jobId) async {
  final deadline = DateTime.now().add(_kVideoPollTimeout);

  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(_kVideoPollInterval);
    try {
      final status = await repo.getJobStatus(jobId);
      if (status == null) continue;

      final knownState = status.state.knownValue;
      if (knownState == KnownJobStatusState.jOB_STATE_COMPLETED && status.blob != null) {
        return status.blob;
      }
      if (knownState == KnownJobStatusState.jOB_STATE_FAILED) {
        log.e('Scheduled post: video processing failed — ${status.error ?? 'unknown error'}');
        return null;
      }
    } catch (e) {
      log.w('Scheduled post: video job poll error (retrying)', error: e);
    }
  }

  log.e('Scheduled post: video processing timed out for job $jobId');
  return null;
}

/// Returns the MIME type from magic bytes, or null for unsupported formats.
String? _detectMime(Uint8List bytes) {
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

class PostScheduler {
  PostScheduler._();

  /// Initialises WorkManager. Call once from main() before runApp().
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers a one-off background task to fire at [scheduledAt].
  static Future<void> schedulePost({required int draftId, required DateTime scheduledAt}) async {
    final delay = scheduledAt.difference(DateTime.now());
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      'scheduled_post_$draftId',
      _kTaskName,
      initialDelay: delay,
      tag: _kTaskTag,
      constraints: Constraints(networkType: NetworkType.connected),
      inputData: {'draftId': draftId},
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    log.i('Scheduled post for draft $draftId at $scheduledAt');
  }

  /// Cancels a previously scheduled post task.
  static Future<void> cancelPost(int draftId) async {
    await Workmanager().cancelByUniqueName('scheduled_post_$draftId');
  }
}
