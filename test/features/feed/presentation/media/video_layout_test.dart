import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/media/video_layout.dart';

void main() {
  group('normalizeVideoAspectRatio', () {
    test('falls back for null and invalid values', () {
      expect(normalizeVideoAspectRatio(null), kDefaultVideoAspectRatio);
      expect(normalizeVideoAspectRatio(0), kDefaultVideoAspectRatio);
      expect(normalizeVideoAspectRatio(-1), kDefaultVideoAspectRatio);
      expect(normalizeVideoAspectRatio(double.infinity), kDefaultVideoAspectRatio);
      expect(normalizeVideoAspectRatio(double.nan), kDefaultVideoAspectRatio);
    });

    test('returns valid values unchanged', () {
      expect(normalizeVideoAspectRatio(16 / 9), closeTo(16 / 9, 0.0001));
      expect(normalizeVideoAspectRatio(9 / 16), closeTo(9 / 16, 0.0001));
    });
  });

  group('containedVideoSize', () {
    test('fits landscape videos by width', () {
      final size = containedVideoSize(availableSize: const Size(360, 640), aspectRatio: 16 / 9);

      expect(size.width, closeTo(360, 0.001));
      expect(size.height, closeTo(202.5, 0.001));
    });

    test('fits portrait videos by height', () {
      final size = containedVideoSize(availableSize: const Size(360, 640), aspectRatio: 9 / 16);

      expect(size.width, closeTo(360, 0.001));
      expect(size.height, closeTo(640, 0.001));
    });

    test('returns zero size for non-positive constraints', () {
      expect(containedVideoSize(availableSize: const Size(0, 640), aspectRatio: 16 / 9), Size.zero);
      expect(containedVideoSize(availableSize: const Size(360, 0), aspectRatio: 16 / 9), Size.zero);
    });
  });
}
