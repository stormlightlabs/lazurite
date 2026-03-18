import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ImageMediaActions {
  ImageMediaActions._();

  static Future<void> shareImage(BuildContext context, String imageUrl) async {
    await Share.share(imageUrl);
  }

  static Future<void> downloadImage(
    BuildContext context,
    String imageUrl, {
    String? suggestedName,
    ValueChanged<double>? onProgress,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final granted = await _requestPhotoPermission();
      if (!granted) {
        messenger.showSnackBar(const SnackBar(content: Text('Photo access is required to save images.')));
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = _normalizedFileName(imageUrl, suggestedName: suggestedName);
      final filePath = p.join(tempDir.path, fileName);
      final dio = Dio();

      await dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            return;
          }
          onProgress?.call(received / total);
        },
      );

      await Gal.putImage(filePath);
      try {
        await File(filePath).delete();
      } catch (_) {}
      messenger.showSnackBar(const SnackBar(content: Text('Image saved to your gallery.')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save image: $error')));
    } finally {
      onProgress?.call(0);
    }
  }

  static Future<bool> _requestPhotoPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      final statuses = await [Permission.photos, Permission.storage].request();
      return statuses.values.any((status) => status.isGranted || status.isLimited);
    }

    return true;
  }

  static String _normalizedFileName(String imageUrl, {String? suggestedName}) {
    final uri = Uri.tryParse(imageUrl);
    final rawName = suggestedName ?? (uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : 'image.jpg');
    final sanitizedName = rawName.split('?').first;
    if (p.extension(sanitizedName).isNotEmpty) {
      return sanitizedName;
    }
    return '$sanitizedName.jpg';
  }
}
