import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for compressing images before upload.
///
/// Uses flutter_image_compress which runs natively on iOS/Android for
/// performant compression with automatic EXIF rotation handling.
class ImageCompressor {
  const ImageCompressor();

  /// Maximum dimension (width or height) for compressed images.
  static const int maxDimension = 2000;

  /// JPEG quality percentage (0-100).
  static const int quality = 85;

  /// Compresses an image file and returns path to compressed file.
  ///
  /// The compressed file is stored in a temporary directory and should be
  /// cleaned up after upload. Returns the original path if compression fails
  /// or the image is already small enough.
  ///
  /// Compression behavior:
  /// - Resizes to fit within [maxDimension] while maintaining aspect ratio
  /// - Converts to JPEG at [quality] percentage
  /// - Handles EXIF rotation automatically
  Future<String> compress(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      throw ArgumentError.value(sourcePath, 'sourcePath', 'File does not exist');
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = path.join(tempDir.path, 'lazurite_compress', fileName);

      await Directory(path.dirname(targetPath)).create(recursive: true);

      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null) {
        return sourcePath;
      }

      return result.path;
    } catch (e) {
      return sourcePath;
    }
  }

  /// Compresses image bytes and returns compressed bytes.
  ///
  /// Useful when source image is already in memory.
  Future<Uint8List> compressBytes(Uint8List bytes) async {
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  /// Cleans up compressed image files in the temporary directory.
  ///
  /// Call this periodically to free disk space.
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final compressDir = Directory(path.join(tempDir.path, 'lazurite_compress'));
      if (await compressDir.exists()) {
        await compressDir.delete(recursive: true);
      }
    } catch (_) {
      /* Ignore cleanup errors */
    }
  }
}
