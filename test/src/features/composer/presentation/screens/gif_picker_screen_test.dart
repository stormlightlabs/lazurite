import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/screens/gif_picker_screen.dart';

void main() {
  group('GifSelectionResult', () {
    test('contains required fields for GIF embed', () {
      const result = GifSelectionResult(
        uri: 'https://tenor.com/view/cat',
        title: 'Funny Cat',
        description: 'A very funny cat',
        thumbBlobJson: r'{"$type":"blob","ref":{"$link":"cid-test"}}',
      );

      expect(result.uri, 'https://tenor.com/view/cat');
      expect(result.title, 'Funny Cat');
      expect(result.description, 'A very funny cat');
      expect(result.thumbBlobJson, r'{"$type":"blob","ref":{"$link":"cid-test"}}');
    });

    test('handles missing description field', () {
      const result = GifSelectionResult(
        uri: 'https://tenor.com/view/dog',
        title: 'Cute Dog',
        thumbBlobJson: r'{"$type":"blob","ref":{"$link":"cid-test"}}',
      );

      expect(result.uri, 'https://tenor.com/view/dog');
      expect(result.title, 'Cute Dog');
      expect(result.description, isNull);
      expect(result.thumbBlobJson, r'{"$type":"blob","ref":{"$link":"cid-test"}}');
    });
  });
}
