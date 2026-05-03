import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum MediaAssetType { image, video }

class MediaActions {
  MediaActions._();

  static Future<void> shareImage(BuildContext context, String imageUrl) async {
    await ShareHelper.shareText(context, imageUrl);
  }

  static Future<void> downloadImage(
    BuildContext context,
    String imageUrl, {
    String? suggestedName,
    ValueChanged<double>? onProgress,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final granted = await _requestMediaPermission(MediaAssetType.image);
      if (!granted) {
        _showPermissionDeniedSnackBar(messenger, label: 'images');
        return;
      }

      final filePath = await _downloadFile(
        imageUrl,
        suggestedName: suggestedName,
        fallbackExtension: '.jpg',
        onProgress: onProgress,
      );
      await Gal.putImage(filePath);
      await _deleteTempFile(filePath);
      messenger.showSnackBar(const SnackBar(content: Text('Image saved to your gallery.')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save image: $error')));
    } finally {
      onProgress?.call(0);
    }
  }

  static Future<void> downloadVideo(
    BuildContext context,
    String playlistUrl, {
    String? preferredDownloadUrl,
    String? suggestedName,
    ValueChanged<double>? onProgress,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final granted = await _requestMediaPermission(MediaAssetType.video);
      if (!granted) {
        _showPermissionDeniedSnackBar(messenger, label: 'videos');
        return;
      }

      final candidateUrls = await _resolveVideoDownloadCandidates(
        playlistUrl,
        preferredDownloadUrl: preferredDownloadUrl,
      );

      if (candidateUrls.isEmpty) {
        throw StateError('No downloadable video URL was available for this post.');
      }

      Object? lastError;
      for (final downloadUrl in candidateUrls) {
        String? filePath;
        try {
          filePath = await _downloadFile(
            downloadUrl,
            suggestedName: suggestedName,
            fallbackExtension: '.mp4',
            onProgress: onProgress,
          );
          await Gal.putVideo(filePath);
          messenger.showSnackBar(const SnackBar(content: Text('Video saved to your gallery.')));
          return;
        } catch (error, stackTrace) {
          lastError = error;
          log.w('Failed to save video using candidate URL: $downloadUrl', error: error, stackTrace: stackTrace);
        } finally {
          if (filePath != null) {
            await _deleteTempFile(filePath);
          }
        }
      }

      throw lastError ?? StateError('Video download failed.');
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save video: $error')));
    } finally {
      onProgress?.call(0);
    }
  }

  static String? buildBlueskyBlobDownloadUrl({required String playlistUrl}) {
    final parsed = _extractDidAndCidFromPlaylistUrl(playlistUrl);
    if (parsed == null) {
      return null;
    }
    return Uri.https('bsky.social', '/xrpc/com.atproto.sync.getBlob', {
      'did': parsed.did,
      'cid': parsed.cid,
    }).toString();
  }

  static Future<String> _downloadFile(
    String url, {
    String? suggestedName,
    String fallbackExtension = '',
    ValueChanged<double>? onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = _normalizedFileName(url, suggestedName: suggestedName, fallbackExtension: fallbackExtension);
    final filePath = p.join(tempDir.path, fileName);
    final dio = Dio();

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total <= 0) {
          return;
        }
        onProgress?.call(received / total);
      },
    );

    return filePath;
  }

  static Future<bool> _requestMediaPermission(MediaAssetType type) async {
    final hasAccess = await Gal.hasAccess();
    if (hasAccess) {
      return true;
    }

    final grantedByGal = await Gal.requestAccess();
    if (grantedByGal) {
      return true;
    }

    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      final requested = switch (type) {
        MediaAssetType.image => [Permission.photos, Permission.storage],
        MediaAssetType.video => [Permission.videos, Permission.storage],
      };
      final statuses = await requested.request();
      return statuses.values.any((status) => status.isGranted || status.isLimited);
    }

    return true;
  }

  static Future<List<String>> _resolveVideoDownloadCandidates(
    String playlistUrl, {
    String? preferredDownloadUrl,
  }) async {
    final candidates = <String>{};

    if (preferredDownloadUrl?.trim().isNotEmpty ?? false) {
      candidates.add(preferredDownloadUrl!.trim());
    }

    final blobUrls = await _resolveBlobDownloadUrls(playlistUrl);
    for (final blobUrl in blobUrls) {
      candidates.add(blobUrl);
    }

    final resolvedFromManifest = await _resolveBestVideoDownloadUrl(playlistUrl);
    if (resolvedFromManifest != null) {
      candidates.add(resolvedFromManifest);
    }

    return candidates.toList(growable: false);
  }

  static Future<List<String>> _resolveBlobDownloadUrls(String playlistUrl) async {
    final parsed = _extractDidAndCidFromPlaylistUrl(playlistUrl);
    if (parsed == null) {
      return const [];
    }

    final urls = <String>[
      Uri.https('bsky.social', '/xrpc/com.atproto.sync.getBlob', {'did': parsed.did, 'cid': parsed.cid}).toString(),
    ];

    final pdsUrl = await _buildPdsBlobDownloadUrl(did: parsed.did, cid: parsed.cid);
    if (pdsUrl != null) {
      urls.add(pdsUrl);
    }

    return urls;
  }

  static Future<String?> _buildPdsBlobDownloadUrl({required String did, required String cid}) async {
    try {
      final response = await Dio().get<Map<String, dynamic>>(
        'https://plc.directory/$did',
        options: Options(responseType: ResponseType.json),
      );
      final body = response.data;
      if (body == null) {
        return null;
      }

      final services = body['service'];
      if (services is! List) {
        return null;
      }

      for (final entry in services) {
        if (entry is! Map) {
          continue;
        }
        final type = entry['type'];
        final endpoint = entry['serviceEndpoint'];
        if (type == 'AtprotoPersonalDataServer' && endpoint is String && endpoint.isNotEmpty) {
          final endpointUri = Uri.tryParse(endpoint);
          if (endpointUri == null || endpointUri.scheme.isEmpty || endpointUri.host.isEmpty) {
            continue;
          }
          return endpointUri
              .replace(path: '/xrpc/com.atproto.sync.getBlob', queryParameters: {'did': did, 'cid': cid})
              .toString();
        }
      }
    } catch (error, stackTrace) {
      log.w('Failed to resolve PDS endpoint from PLC directory', error: error, stackTrace: stackTrace);
    }

    return null;
  }

  static Future<String?> _resolveBestVideoDownloadUrl(String playlistUrl) async {
    final dio = Dio();
    final playlistUri = Uri.parse(playlistUrl);
    final manifest = await dio.get<String>(playlistUrl, options: Options(responseType: ResponseType.plain));
    final body = manifest.data ?? '';

    final variantUri = _parseHighestBandwidthVariantUri(playlistUri, body);
    if (variantUri != null) {
      if (_isPlaylistUri(variantUri)) {
        final nestedManifest = await dio.get<String>(
          variantUri.toString(),
          options: Options(responseType: ResponseType.plain),
        );
        final mediaUri = _parseDirectMediaUri(variantUri, nestedManifest.data ?? '');
        return mediaUri?.toString();
      }
      final extension = p.extension(variantUri.path).toLowerCase();
      if (extension == '.mp4' || extension == '.mov' || extension == '.m4v') {
        return variantUri.toString();
      }
      return null;
    }

    final directMediaUri = _parseDirectMediaUri(playlistUri, body);
    return directMediaUri?.toString();
  }

  static Uri? _parseHighestBandwidthVariantUri(Uri baseUri, String manifestBody) {
    final lines = manifestBody.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    Uri? bestUri;
    var bestBandwidth = -1;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.startsWith('#EXT-X-STREAM-INF:')) {
        continue;
      }

      final match = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
      final bandwidth = int.tryParse(match?.group(1) ?? '') ?? 0;
      final nextUriLine = _nextUriLine(lines, i + 1);
      if (nextUriLine == null) {
        continue;
      }

      if (bandwidth >= bestBandwidth) {
        bestBandwidth = bandwidth;
        bestUri = baseUri.resolve(nextUriLine);
      }
    }

    return bestUri;
  }

  static Uri? _parseDirectMediaUri(Uri baseUri, String manifestBody) {
    final lines = manifestBody
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();

    for (final line in lines) {
      final candidate = baseUri.resolve(line);
      final extension = p.extension(candidate.path).toLowerCase();
      if (extension == '.mp4' || extension == '.mov' || extension == '.m4v') {
        return candidate;
      }
    }

    return null;
  }

  static String? _nextUriLine(List<String> lines, int startIndex) {
    for (var i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      if (!line.startsWith('#')) {
        return line;
      }
    }
    return null;
  }

  static bool _isPlaylistUri(Uri uri) => p.extension(uri.path).toLowerCase() == '.m3u8';

  static ({String did, String cid})? _extractDidAndCidFromPlaylistUrl(String playlistUrl) {
    final uri = Uri.tryParse(playlistUrl);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    final watchIndex = segments.indexOf('watch');
    if (watchIndex != -1 && segments.length > watchIndex + 2) {
      final did = segments[watchIndex + 1];
      final cid = segments[watchIndex + 2];
      if (did.startsWith('did:') && cid.isNotEmpty) {
        return (did: did, cid: cid);
      }
    }

    final hlsIndex = segments.indexOf('hls');
    if (hlsIndex != -1 && segments.length > hlsIndex + 2) {
      final did = segments[hlsIndex + 1];
      final cid = segments[hlsIndex + 2];
      if (did.startsWith('did:') && cid.isNotEmpty) {
        return (did: did, cid: cid);
      }
    }

    return null;
  }

  static void _showPermissionDeniedSnackBar(ScaffoldMessengerState messenger, {required String label}) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Photo access is required to save $label.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  static String _normalizedFileName(String url, {String? suggestedName, String fallbackExtension = ''}) {
    final uri = Uri.tryParse(url);
    final rawName = suggestedName ?? (uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : 'download');
    final sanitizedName = rawName.split('?').first;
    if (p.extension(sanitizedName).isNotEmpty) {
      return sanitizedName;
    }
    return '$sanitizedName$fallbackExtension';
  }

  static Future<void> _deleteTempFile(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (e) {
      log.d('failed to delete temp file $filePath', error: e);
    }
  }
}
