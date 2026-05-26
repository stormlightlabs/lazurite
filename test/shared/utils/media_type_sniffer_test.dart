import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/utils/media_type_sniffer.dart';

void main() {
  group('detectImageMimeType', () {
    test('detects supported image signatures', () {
      expect(detectImageMimeType([0xFF, 0xD8, 0xFF, 0, 0, 0, 0, 0, 0, 0, 0, 0]), 'image/jpeg');
      expect(detectImageMimeType([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0, 0, 0, 0, 0]), 'image/png');
      expect(detectImageMimeType([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50]), 'image/webp');
    });

    test('returns null for short or unknown data', () {
      expect(detectImageMimeType([0xFF, 0xD8, 0xFF]), isNull);
      expect(detectImageMimeType(List<int>.filled(12, 0)), isNull);
    });
  });
}
