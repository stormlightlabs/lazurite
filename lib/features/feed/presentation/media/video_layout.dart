import 'dart:ui';

const double kDefaultVideoAspectRatio = 16 / 9;

double normalizeVideoAspectRatio(double? value, {double fallback = kDefaultVideoAspectRatio}) {
  if (value == null || !value.isFinite || value <= 0) {
    return fallback;
  }
  return value;
}

Size containedVideoSize({required Size availableSize, required double aspectRatio}) {
  final safeAspectRatio = normalizeVideoAspectRatio(aspectRatio);
  final safeWidth = availableSize.width.isFinite && availableSize.width > 0 ? availableSize.width : 0.0;
  final safeHeight = availableSize.height.isFinite && availableSize.height > 0 ? availableSize.height : 0.0;

  if (safeWidth == 0 || safeHeight == 0) {
    return Size.zero;
  }

  final availableRatio = safeWidth / safeHeight;
  if (availableRatio > safeAspectRatio) {
    return Size(safeHeight * safeAspectRatio, safeHeight);
  }
  return Size(safeWidth, safeWidth / safeAspectRatio);
}
