import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  const ShareHelper._();

  static Future<void> shareText(BuildContext context, String text) {
    return Share.share(text, sharePositionOrigin: _sharePositionOrigin(context));
  }

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
