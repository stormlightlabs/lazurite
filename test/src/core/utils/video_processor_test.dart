import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/video_processor.dart';

void main() {
  group('VideoProcessor', () {
    late VideoProcessor processor;

    setUp(() {
      processor = VideoProcessor();
    });

    group('isVideoMimeType', () {
      test('returns true for video MIME types', () {
        expect(processor.isVideoMimeType('video/mp4'), isTrue);
        expect(processor.isVideoMimeType('video/quicktime'), isTrue);
        expect(processor.isVideoMimeType('video/webm'), isTrue);
      });

      test('returns false for non-video MIME types', () {
        expect(processor.isVideoMimeType('image/jpeg'), isFalse);
        expect(processor.isVideoMimeType('image/png'), isFalse);
        expect(processor.isVideoMimeType('image/gif'), isFalse);
        expect(processor.isVideoMimeType('application/json'), isFalse);
      });
    });

    group('extractMetadata', () {
      test('throws StateError for non-existent file', () async {
        expect(
          () => processor.extractMetadata('/non/existent/file.mp4'),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Video file not found'),
            ),
          ),
        );
      });
    });
  });

  group('VideoMetadata', () {
    group('toJson', () {
      test('serializes metadata to JSON', () {
        const metadata = VideoMetadata(durationSeconds: 120, width: 1920, height: 1080);

        final json = metadata.toJson();

        expect(json, {'width': 1920, 'height': 1080});
      });
    });

    group('fromJson', () {
      test('deserializes metadata from JSON', () {
        final json = {'durationSeconds': 120, 'width': 1920, 'height': 1080};

        final metadata = VideoMetadata.fromJson(json);

        expect(metadata.durationSeconds, 120);
        expect(metadata.width, 1920);
        expect(metadata.height, 1080);
      });
    });

    group('roundtrip', () {
      test('toJson and fromJson are inverses', () {
        const original = VideoMetadata(durationSeconds: 60, width: 1280, height: 720);

        final json = original.toJson();
        final restored = VideoMetadata.fromJson({
          ...json,
          'durationSeconds': original.durationSeconds,
        });

        expect(restored.durationSeconds, original.durationSeconds);
        expect(restored.width, original.width);
        expect(restored.height, original.height);
      });
    });
  });
}
