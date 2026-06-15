import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/widgets/gallery_embed_adapter.dart';

void main() {
  test('parses gallery view items as image view models', () {
    final images = galleryImagesFromUnknownEmbed({
      r'$type': 'app.bsky.embed.gallery#view',
      'items': [
        {
          r'$type': 'app.bsky.embed.gallery#viewImage',
          'thumbnail': 'https://example.com/thumb.jpg',
          'fullsize': 'https://example.com/full.jpg',
          'alt': 'gallery alt',
          'aspectRatio': {'width': 4, 'height': 3},
        },
      ],
    });

    expect(images, hasLength(1));
    expect(images.single.thumb, 'https://example.com/thumb.jpg');
    expect(images.single.fullsize, 'https://example.com/full.jpg');
    expect(images.single.alt, 'gallery alt');
    expect(images.single.aspectRatio?.width, 4);
    expect(images.single.aspectRatio?.height, 3);
  });

  test('ignores non-gallery and malformed gallery items', () {
    expect(galleryImagesFromUnknownEmbed(null), isEmpty);
    expect(galleryImagesFromUnknownEmbed({r'$type': 'app.bsky.embed.images#view'}), isEmpty);

    final images = galleryImagesFromUnknownEmbed({
      r'$type': 'app.bsky.embed.gallery#view',
      'items': [
        {'thumbnail': 'https://example.com/thumb.jpg'},
        'not an item',
        {
          r'$type': 'app.bsky.embed.gallery#viewImage',
          'thumbnail': 'https://example.com/valid-thumb.jpg',
          'fullsize': 'https://example.com/valid-full.jpg',
          'alt': 'valid',
          'aspectRatio': {'width': '4', 'height': 3},
        },
      ],
    });

    expect(images, hasLength(1));
    expect(images.single.thumb, 'https://example.com/valid-thumb.jpg');
    expect(images.single.aspectRatio, isNull);
  });
}
