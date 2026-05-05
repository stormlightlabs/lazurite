import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  const ShareHelper._();

  static Future<void> shareText(BuildContext context, String text) {
    return Share.share(text, sharePositionOrigin: sharePositionOriginForContext(context));
  }

  static Future<void> shareFiles(BuildContext context, List<XFile> files, {String? text, String? subject}) {
    return shareFilesAtOrigin(sharePositionOriginForContext(context), files, text: text, subject: subject);
  }

  static Future<void> shareFilesAtOrigin(Rect sharePositionOrigin, List<XFile> files, {String? text, String? subject}) {
    return Share.shareXFiles(files, text: text, subject: subject, sharePositionOrigin: sharePositionOrigin);
  }

  static Future<void> shareFilePaths(BuildContext context, List<String> filePaths, {String? text, String? subject}) {
    return shareFilePathsAtOrigin(sharePositionOriginForContext(context), filePaths, text: text, subject: subject);
  }

  static Future<void> shareFilePathsAtOrigin(
    Rect sharePositionOrigin,
    List<String> filePaths, {
    String? text,
    String? subject,
  }) {
    final files = [for (final path in filePaths) XFile(path)];
    return shareFilesAtOrigin(sharePositionOrigin, files, text: text, subject: subject);
  }

  static Rect sharePositionOriginForContext(BuildContext context) => _sharePositionOrigin(context);

  static Rect _sharePositionOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize && !renderObject.size.isEmpty) {
      final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      if (!rect.isEmpty) {
        return rect;
      }
    }

    final mediaQuerySize = MediaQuery.maybeSizeOf(context);
    if (mediaQuerySize != null && !mediaQuerySize.isEmpty) {
      return Rect.fromLTWH(0, 0, mediaQuerySize.width, mediaQuerySize.height);
    }

    return const Rect.fromLTWH(0, 0, 1, 1);
  }
}
