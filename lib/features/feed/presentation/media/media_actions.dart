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
        messenger.showSnackBar(const SnackBar(content: Text('Photo access is required to save images.')));
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
    String? suggestedName,
    ValueChanged<double>? onProgress,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final granted = await _requestMediaPermission(MediaAssetType.video);
      if (!granted) {
        messenger.showSnackBar(const SnackBar(content: Text('Media access is required to save videos.')));
        return;
      }

      final downloadUrl = await _resolveBestVideoDownloadUrl(playlistUrl);
      final filePath = await _downloadFile(
        downloadUrl,
        suggestedName: suggestedName,
        fallbackExtension: '.mp4',
        onProgress: onProgress,
      );
      await Gal.putVideo(filePath);
      await _deleteTempFile(filePath);
      messenger.showSnackBar(const SnackBar(content: Text('Video saved to your gallery.')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save video: $error')));
    } finally {
      onProgress?.call(0);
    }
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
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted || status.isLimited;
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

  static Future<String> _resolveBestVideoDownloadUrl(String playlistUrl) async {
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
        return (mediaUri ?? variantUri).toString();
      }
      return variantUri.toString();
    }

    final directMediaUri = _parseDirectMediaUri(playlistUri, body);
    return (directMediaUri ?? playlistUri).toString();
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
