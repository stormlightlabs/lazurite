import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/utils/image_compressor.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/drafts_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:uuid/uuid.dart';

class DraftRepository {
  DraftRepository({
    required DraftsDao dao,
    required XrpcClient api,
    required SessionStorage sessionStorage,
    required Logger logger,
    required FacetParser facetParser,
    ImageCompressor? compressor,
  }) : _dao = dao,
       _api = api,
       _sessionStorage = sessionStorage,
       _logger = logger,
       _facetParser = facetParser,
       _compressor = compressor ?? const ImageCompressor(),
       _uuid = const Uuid();

  final DraftsDao _dao;
  final XrpcClient _api;
  final SessionStorage _sessionStorage;
  final Logger _logger;
  final FacetParser _facetParser;
  final ImageCompressor _compressor;
  final Uuid _uuid;
  final Map<int, CancelToken> _uploadCancelTokens = {};

  Stream<List<composer.Draft>> watchDrafts() async* {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    yield* _dao.watchDrafts(ownerDid).map((records) => records.map(_toDomain).toList());
  }

  Stream<composer.Draft?> watchDraft(String id) async* {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    yield* _dao
        .watchDraft(id, ownerDid)
        .map((record) => record == null ? null : _toDomain(record));
  }

  Future<composer.Draft> getDraft(String id) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final record = await _dao.getDraft(id, ownerDid);
    if (record == null) {
      throw StateError('Draft $id not found');
    }
    return _toDomain(record);
  }

  Future<composer.Draft> createDraft({
    String text = '',
    String? replyParentUri,
    String? replyParentCid,
    String? replyRootUri,
    String? replyRootCid,
    String? quoteUri,
    String? quoteCid,
    String? facetsJson,
  }) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertDraft(
      DraftsCompanion.insert(
        id: id,
        ownerDid: ownerDid,
        content: Value(text),
        replyParentUri: Value(replyParentUri),
        replyParentCid: Value(replyParentCid),
        replyRootUri: Value(replyRootUri),
        replyRootCid: Value(replyRootCid),
        quoteUri: Value(quoteUri),
        quoteCid: Value(quoteCid),
        facetsJson: Value(facetsJson),
        status: composer.DraftStatus.draft.name,
        errorMessage: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return getDraft(id);
  }

  Future<void> updateDraftContent(
    String id, {
    String? text,
    String? facetsJson,
    String? replyParentUri,
    String? replyParentCid,
    String? replyRootUri,
    String? replyRootCid,
    String? quoteUri,
    String? quoteCid,
  }) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final companion = DraftsCompanion(
      content: text != null ? Value(text) : const Value.absent(),
      facetsJson: facetsJson != null ? Value(facetsJson) : const Value.absent(),
      replyParentUri: replyParentUri != null ? Value(replyParentUri) : const Value.absent(),
      replyParentCid: replyParentCid != null ? Value(replyParentCid) : const Value.absent(),
      replyRootUri: replyRootUri != null ? Value(replyRootUri) : const Value.absent(),
      replyRootCid: replyRootCid != null ? Value(replyRootCid) : const Value.absent(),
      quoteUri: quoteUri != null ? Value(quoteUri) : const Value.absent(),
      quoteCid: quoteCid != null ? Value(quoteCid) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await _dao.updateDraftFields(id, ownerDid, companion);
  }

  Future<void> deleteDraft(String id) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    return _dao.deleteDraft(id, ownerDid);
  }

  Future<void> addMedia(String draftId, composer.DraftMediaInput media) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final draft = await _dao.getDraft(draftId, ownerDid);
    if (draft == null) {
      throw StateError('Draft $draftId not found');
    }

    String localPath = media.localPath;
    if (_isImageMimeType(media.mimeType)) {
      try {
        localPath = await _compressor.compress(media.localPath);
      } catch (e) {
        _logger.warning('Image compression failed, using original: $e');
      }
    }

    final nextOrder = draft.media.length;
    await _dao.insertMedia([
      DraftMediaCompanion.insert(
        draftId: draftId,
        ownerDid: ownerDid,
        localPath: localPath,
        mimeType: media.mimeType,
        altText: Value(media.altText),
        uploadCid: const Value(null),
        blobRefJson: const Value(null),
        status: composer.DraftMediaStatus.pending.name,
        sortOrder: nextOrder,
        createdAt: DateTime.now(),
      ),
    ]);

    await _dao.updateDraftFields(
      draftId,
      ownerDid,
      DraftsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  bool _isImageMimeType(String mimeType) {
    return mimeType.startsWith('image/');
  }

  Future<void> removeMedia(String draftId, int mediaId) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.deleteMedia(mediaId);
    await _dao.updateDraftFields(
      draftId,
      ownerDid,
      DraftsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> updateMediaAltText(String draftId, int mediaId, String altText) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.updateMedia(mediaId, DraftMediaCompanion(altText: Value(altText)));
    await _dao.updateDraftFields(
      draftId,
      ownerDid,
      DraftsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Publishes a draft with optional progress tracking.
  ///
  /// [onMediaProgress] is called with (mediaId, progress) where progress is 0.0 to 1.0.
  Future<({String uri, String cid})> publishDraft(
    String draftId, {
    void Function(int mediaId, double progress)? onMediaProgress,
  }) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final draft = await _dao.getDraft(draftId, ownerDid);
    if (draft == null) {
      throw StateError('Draft $draftId not found');
    }

    await _dao.updateDraftFields(
      draftId,
      ownerDid,
      DraftsCompanion(
        status: Value(composer.DraftStatus.publishing.name),
        errorMessage: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );

    try {
      final domain = _toDomain(draft);

      final facetsJson = await _facetParser.parse(domain.text);
      if (facetsJson != null && facetsJson != domain.facetsJson) {
        await _dao.updateDraftFields(
          draftId,
          ownerDid,
          DraftsCompanion(facetsJson: Value(facetsJson)),
        );
      }

      for (final media in domain.media) {
        if (media.requiresUpload) {
          final blob = await _uploadMedia(
            media,
            onProgress: (progress) => onMediaProgress?.call(media.id, progress),
          );
          await _dao.updateMedia(
            media.id,
            DraftMediaCompanion(
              uploadCid: Value(blob['ref']?['\$link'] as String?),
              blobRefJson: Value(jsonEncode(blob)),
              status: Value(composer.DraftMediaStatus.uploaded.name),
            ),
          );
          _uploadCancelTokens.remove(media.id);
        }
      }

      final refreshed = await _dao.getDraft(draftId, ownerDid);
      if (refreshed == null) throw StateError('Draft $draftId missing after upload');
      final draftToPublish = _toDomain(refreshed);

      final record = _buildPostRecord(draftToPublish);
      final data = await _api.call(
        'com.atproto.repo.createRecord',
        body: {'repo': ownerDid, 'collection': 'app.bsky.feed.post', 'record': record},
      );

      final uri = data['uri'] as String;
      final cid = data['cid'] as String;

      await _dao.updateDraftFields(
        draftId,
        ownerDid,
        DraftsCompanion(
          status: Value(composer.DraftStatus.posted.name),
          errorMessage: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return (uri: uri, cid: cid);
    } catch (e, stack) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _logger.info('Upload cancelled for draft $draftId');
        rethrow;
      }

      _logger.error('Failed to publish draft $draftId', e, stack);
      await _dao.updateDraftFields(
        draftId,
        ownerDid,
        DraftsCompanion(
          status: Value(composer.DraftStatus.failed.name),
          errorMessage: Value(errorMessage(e)),
          updatedAt: Value(DateTime.now()),
        ),
      );
      rethrow;
    }
  }

  /// Retries upload for a specific media attachment.
  ///
  /// Use this when a single media upload failed and the user wants to retry.
  Future<void> retryMediaUpload(
    String draftId,
    int mediaId, {
    void Function(double progress)? onProgress,
  }) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.updateMedia(
      mediaId,
      DraftMediaCompanion(
        status: Value(composer.DraftMediaStatus.pending.name),
        uploadCid: const Value(null),
        blobRefJson: const Value(null),
      ),
    );

    final draft = await _dao.getDraft(draftId, ownerDid);
    if (draft == null) {
      throw StateError('Draft $draftId not found');
    }

    final domain = _toDomain(draft);
    final media = domain.media.firstWhere(
      (m) => m.id == mediaId,
      orElse: () => throw StateError('Media $mediaId not found'),
    );

    await _dao.updateMedia(
      mediaId,
      DraftMediaCompanion(status: Value(composer.DraftMediaStatus.uploading.name)),
    );

    try {
      final blob = await _uploadMedia(media, onProgress: onProgress);
      await _dao.updateMedia(
        mediaId,
        DraftMediaCompanion(
          uploadCid: Value(blob['ref']?['\$link'] as String?),
          blobRefJson: Value(jsonEncode(blob)),
          status: Value(composer.DraftMediaStatus.uploaded.name),
        ),
      );
      _uploadCancelTokens.remove(mediaId);
    } catch (e, stack) {
      _logger.error('Retry upload failed for media $mediaId', e, stack);
      await _dao.updateMedia(
        mediaId,
        DraftMediaCompanion(status: Value(composer.DraftMediaStatus.failed.name)),
      );
      rethrow;
    }
  }

  /// Cancels an in-progress upload for a specific media attachment.
  void cancelUpload(int mediaId) {
    final cancelToken = _uploadCancelTokens[mediaId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled upload');
      _uploadCancelTokens.remove(mediaId);
    }
  }

  /// Cancels all in-progress uploads.
  void cancelAllUploads() {
    for (final token in _uploadCancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel('User cancelled all uploads');
      }
    }
    _uploadCancelTokens.clear();
  }

  Future<List<composer.Draft>> getCrashedDrafts() async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final records = await _dao.getDraftsByStatus(composer.DraftStatus.publishing.name, ownerDid);
    return records.map(_toDomain).toList();
  }

  Future<void> markAsFailed(String id, String reason) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.updateDraftFields(
      id,
      ownerDid,
      DraftsCompanion(
        status: Value(composer.DraftStatus.failed.name),
        errorMessage: Value(reason),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes all drafts with status `posted`.
  /// Returns the number of drafts deleted.
  Future<int> deletePostedDrafts() async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    return _dao.deleteDraftsByStatus(composer.DraftStatus.posted.name, ownerDid);
  }

  composer.Draft _toDomain(DraftRecord record) {
    return composer.Draft(
      id: record.draft.id,
      text: record.draft.content,
      replyParentUri: record.draft.replyParentUri,
      replyParentCid: record.draft.replyParentCid,
      replyRootUri: record.draft.replyRootUri,
      replyRootCid: record.draft.replyRootCid,
      quoteUri: record.draft.quoteUri,
      quoteCid: record.draft.quoteCid,
      facetsJson: record.draft.facetsJson,
      externalUri: record.draft.externalUri,
      externalTitle: record.draft.externalTitle,
      externalDescription: record.draft.externalDescription,
      externalThumbBlobJson: record.draft.externalThumbBlobJson,
      status: _statusFromDb(record.draft.status),
      errorMessage: record.draft.errorMessage,
      createdAt: record.draft.createdAt,
      updatedAt: record.draft.updatedAt,
      media: record.media
          .map(
            (media) => composer.DraftMediaAttachment(
              id: media.id,
              draftId: media.draftId,
              localPath: media.localPath,
              mimeType: media.mimeType,
              altText: media.altText,
              uploadCid: media.uploadCid,
              blobRefJson: media.blobRefJson,
              status: _mediaStatusFromDb(media.status),
              sortOrder: media.sortOrder,
            ),
          )
          .toList(),
    );
  }

  composer.DraftStatus _statusFromDb(String value) {
    return composer.DraftStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => composer.DraftStatus.draft,
    );
  }

  composer.DraftMediaStatus _mediaStatusFromDb(String value) {
    return composer.DraftMediaStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => composer.DraftMediaStatus.pending,
    );
  }

  Future<Map<String, dynamic>> _uploadMedia(
    composer.DraftMediaAttachment media, {
    void Function(double progress)? onProgress,
  }) async {
    final file = File(media.localPath);
    if (!file.existsSync()) {
      throw StateError('Media file missing at ${media.localPath}');
    }

    await _dao.updateMedia(
      media.id,
      DraftMediaCompanion(status: Value(composer.DraftMediaStatus.uploading.name)),
    );

    final cancelToken = CancelToken();
    _uploadCancelTokens[media.id] = cancelToken;

    final formData = FormData.fromMap({'file': await MultipartFile.fromFile(media.localPath)});

    final response = await _api.callRaw<Map<String, dynamic>>(
      'com.atproto.repo.uploadBlob',
      body: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          onProgress?.call(sent / total);
        }
      },
      cancelToken: cancelToken,
    );

    final blob = response.data?['blob'] as Map<String, dynamic>?;
    if (blob == null) {
      throw StateError('uploadBlob response missing blob payload');
    }

    return blob;
  }

  Map<String, dynamic> _buildPostRecord(composer.Draft draft) {
    final record = <String, dynamic>{
      'text': draft.text,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    if (draft.facetsJson != null) {
      try {
        final facets = jsonDecode(draft.facetsJson!);
        if (facets is List && facets.isNotEmpty) {
          record['facets'] = facets;
        }
      } catch (_) {
        _logger.warning('Failed to decode draft facets for ${draft.id}');
      }
    }

    final reply = _buildReplyReference(draft);
    if (reply != null) {
      record['reply'] = reply;
    }

    final imagesEmbed = _buildImagesEmbed(draft.media);
    final quoteEmbed = _buildQuoteEmbed(draft);
    final externalEmbed = _buildExternalEmbed(draft);

    Map<String, dynamic>? embed;
    if (imagesEmbed != null && quoteEmbed != null) {
      embed = {
        '\$type': 'app.bsky.embed.recordWithMedia',
        'record': quoteEmbed,
        'media': imagesEmbed,
      };
    } else if (imagesEmbed != null && externalEmbed != null) {
      _logger.warning('Cannot combine images and external link embed, using images only');
      embed = imagesEmbed;
    } else if (imagesEmbed != null) {
      embed = imagesEmbed;
    } else if (quoteEmbed != null) {
      embed = quoteEmbed;
    } else if (externalEmbed != null) {
      embed = externalEmbed;
    }

    if (embed != null) {
      record['embed'] = embed;
    }

    return record;
  }

  Map<String, dynamic>? _buildReplyReference(composer.Draft draft) {
    if (draft.replyRootUri == null || draft.replyParentUri == null) {
      return null;
    }

    return {
      'root': {
        'uri': draft.replyRootUri,
        if (draft.replyRootCid != null) 'cid': draft.replyRootCid,
      },
      'parent': {
        'uri': draft.replyParentUri,
        if (draft.replyParentCid != null) 'cid': draft.replyParentCid,
      },
    };
  }

  Map<String, dynamic>? _buildImagesEmbed(List<composer.DraftMediaAttachment> media) {
    final uploaded = media.where((item) => item.uploadCid != null).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (uploaded.isEmpty) {
      return null;
    }

    return {
      '\$type': 'app.bsky.embed.images',
      'images': uploaded.map((item) {
        Map<String, dynamic> blob;
        if (item.blobRefJson != null) {
          blob = Map<String, dynamic>.from(jsonDecode(item.blobRefJson!));
        } else {
          blob = {
            '\$type': 'blob',
            'ref': {'\$link': item.uploadCid},
            'mimeType': item.mimeType,
          };
        }

        return {'alt': item.altText ?? '', 'image': blob};
      }).toList(),
    };
  }

  Map<String, dynamic>? _buildQuoteEmbed(composer.Draft draft) {
    if (draft.quoteUri == null) {
      return null;
    }

    return {
      '\$type': 'app.bsky.embed.record',
      'record': {'uri': draft.quoteUri, if (draft.quoteCid != null) 'cid': draft.quoteCid},
    };
  }

  Map<String, dynamic>? _buildExternalEmbed(composer.Draft draft) {
    if (draft.externalUri == null) {
      return null;
    }

    final external = <String, dynamic>{
      'uri': draft.externalUri!,
      if (draft.externalTitle != null) 'title': draft.externalTitle!,
      if (draft.externalDescription != null) 'description': draft.externalDescription!,
    };

    if (draft.externalThumbBlobJson != null) {
      try {
        final thumbBlob = jsonDecode(draft.externalThumbBlobJson!);
        external['thumb'] = thumbBlob;
      } catch (e) {
        _logger.warning('Failed to decode external thumb blob for ${draft.id}: $e');
      }
    }

    return {'\$type': 'app.bsky.embed.external', 'external': external};
  }
}
