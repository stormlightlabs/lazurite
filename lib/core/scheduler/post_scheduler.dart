import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atproto_core/atproto_core.dart' show Blob;
import 'package:bluesky/app_bsky_video_defs.dart' show KnownJobStatusState;
import 'package:bluesky_text/bluesky_text.dart';
import 'package:flutter/widgets.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
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
    if (taskName != _kTaskName) return Future.value(true);

    final draftId = inputData?['draftId'] as int?;
    if (draftId == null) return Future.value(false);

    try {
      await _submitScheduledDraft(draftId);
      return Future.value(true);
    } catch (e, stackTrace) {
      log.e('Scheduled post failed for draft $draftId', error: e, stackTrace: stackTrace);
      return Future.value(false);
    }
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
    final tokens = await authRepo.restoreSession();
    if (tokens == null) {
      throw Exception('No authenticated session for scheduled draft $draftId');
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

    final composeRepo = ComposeRepository(bluesky: bluesky);

    final facets = <Map<String, dynamic>>[];
    for (final entity in BlueskyText(draft.content).entities) {
      try {
        final facet = await entity.toFacet().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            log.w('Scheduled post: timeout resolving facet for "${entity.value}"');
            return {};
          },
        );
        if (facet.isNotEmpty) facets.add(facet);
      } catch (e) {
        log.w('Scheduled post: could not resolve facet for "${entity.value}": $e');
      }
    }

    Map<String, dynamic>? embed;

    if (draft.embedJson != null) {
      final decoded = jsonDecode(draft.embedJson!) as Map<String, dynamic>;
      final type = decoded['type'] as String?;

      if (type == 'images') {
        embed = await _buildImageEmbed(composeRepo, decoded);
      } else if (type == 'video') {
        embed = await _buildVideoEmbed(composeRepo, decoded);
      }
    }

    Map<String, dynamic>? reply;
    if (draft.replyUri != null && draft.replyCid != null) {
      reply = {
        'parent': {'uri': draft.replyUri, 'cid': draft.replyCid},
        'root': {'uri': draft.rootUri ?? draft.replyUri, 'cid': draft.rootCid ?? draft.replyCid},
      };
    }

    final success = await composeRepo.createPost(
      text: draft.content,
      facets: facets,
      embed: embed,
      reply: reply,
      repo: tokens.did,
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

/// Uploads images from [embedJson] `{ "paths": [...], "altTexts": [...] }`.
Future<Map<String, dynamic>?> _buildImageEmbed(ComposeRepository repo, Map<String, dynamic> embedJson) async {
  final paths = (embedJson['paths'] as List<dynamic>? ?? []).cast<String>();
  final alts = (embedJson['altTexts'] as List<dynamic>? ?? []).cast<String>();
  final images = <Map<String, dynamic>>[];

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

    final blobRef = await repo.uploadBlob(bytes.toList(), mimeType: mime);
    if (blobRef == null) {
      throw Exception('Failed to upload image ${paths[i]}');
    }

    final altText = i < alts.length ? alts[i] : '';
    final entry = <String, dynamic>{'image': blobRef.toJson(), 'alt': altText};

    try {
      final dims = await readImageDimensions(bytes.toList());
      if (dims != null) {
        entry['aspectRatio'] = {'width': dims.width, 'height': dims.height};
      }
    } catch (_) {
      log.w('Scheduled post: could not read image dimensions for ${paths[i]}');
    }

    images.add(entry);
  }

  if (images.isEmpty) return null;
  return {'\$type': 'app.bsky.embed.images', 'images': images};
}

/// Re-uploads a video from its local path and polls the processing job.
Future<Map<String, dynamic>?> _buildVideoEmbed(ComposeRepository repo, Map<String, dynamic> embedJson) async {
  final path = embedJson['path'] as String?;
  final altText = (embedJson['alt'] as String?) ?? '';

  if (path == null) return null;

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

  return {'\$type': 'app.bsky.embed.video', 'video': blob.toJson(), 'alt': altText};
}

/// Polls `getJobStatus` until the video is ready or the deadline passes.
Future<Blob?> _pollVideoJob(ComposeRepository repo, String jobId) async {
  final deadline = DateTime.now().add(_kVideoPollTimeout);

  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(_kVideoPollInterval);
    try {
      final status = await repo.getJobStatus(jobId);
      if (status == null) continue;

      final knownState = (status as dynamic).state.knownValue;
      if (knownState == KnownJobStatusState.jOB_STATE_COMPLETED && status.blob != null) {
        return status.blob as Blob;
      }
      if (knownState == KnownJobStatusState.jOB_STATE_FAILED) {
        final error = (status as dynamic).error as String?;
        log.e('Scheduled post: video processing failed — ${error ?? 'unknown error'}');
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
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
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
