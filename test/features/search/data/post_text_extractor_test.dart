import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/embed/external.dart';
import 'package:poptart_lex/app/bsky/embed/images.dart';
import 'package:poptart_lex/app/bsky/embed/record.dart';
import 'package:poptart_lex/app/bsky/embed/record_with_media.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/data/post_text_extractor.dart';

const _author = ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social');
final _uri = AtUri.parse('at://did:plc:test/app.bsky.feed.post/xyz');

PostView _post({String text = '', UPostViewEmbed? embed}) {
  final record = FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 1, 1));
  return PostView(
    uri: _uri,
    cid: 'cid-test',
    author: _author,
    record: record.toJson(),
    indexedAt: DateTime.utc(2026, 1, 1),
    embed: embed,
  );
}

UPostViewEmbed _imagesEmbed(List<String> altTexts) {
  final images = altTexts
      .map(
        (alt) => EmbedImagesViewImage(
          thumb: 'https://example.com/thumb.jpg',
          fullsize: 'https://example.com/full.jpg',
          alt: alt,
          aspectRatio: null,
        ),
      )
      .toList();
  return UPostViewEmbed.embedImagesView(data: EmbedImagesView(images: images));
}

UPostViewEmbed _externalEmbed({
  required String title,
  required String description,
  String uri = 'https://example.com',
}) {
  return UPostViewEmbed.embedExternalView(
    data: EmbedExternalView(
      external: EmbedExternalViewExternal(uri: uri, title: title, description: description),
    ),
  );
}

UPostViewEmbed _recordWithImagesEmbed(String postText, List<String> altTexts) {
  return UPostViewEmbed.embedRecordWithMediaView(
    data: EmbedRecordWithMediaView(
      record: const EmbedRecordView(record: UEmbedRecordViewRecord.unknown(data: {})),
      media: UEmbedRecordWithMediaViewMedia.embedImagesView(
        data: EmbedImagesView(
          images: altTexts
              .map(
                (alt) => EmbedImagesViewImage(
                  thumb: 'https://example.com/thumb.jpg',
                  fullsize: 'https://example.com/full.jpg',
                  alt: alt,
                  aspectRatio: null,
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

UPostViewEmbed _recordWithExternalEmbed(String postText, {required String title, required String description}) {
  return UPostViewEmbed.embedRecordWithMediaView(
    data: EmbedRecordWithMediaView(
      record: const EmbedRecordView(record: UEmbedRecordViewRecord.unknown(data: {})),
      media: UEmbedRecordWithMediaViewMedia.embedExternalView(
        data: EmbedExternalView(
          external: EmbedExternalViewExternal(uri: 'https://example.com', title: title, description: description),
        ),
      ),
    ),
  );
}

void main() {
  late PostTextExtractor extractor;

  setUp(() {
    extractor = const PostTextExtractor();
  });

  group('PostTextExtractor', () {
    group('text-only posts', () {
      test('returns the post body text', () {
        final post = _post(text: 'Hello world');
        expect(extractor.extract(post), equals('Hello world'));
      });

      test('trims surrounding whitespace from post text', () {
        final post = _post(text: '  trimmed  ');
        expect(extractor.extract(post), equals('trimmed'));
      });

      test('returns empty string for a post with no text and no embed', () {
        final post = _post(text: '');
        expect(extractor.extract(post), equals(''));
      });
    });

    group('image embeds', () {
      test('appends alt texts to post text', () {
        final post = _post(text: 'Check this out', embed: _imagesEmbed(['a cat', 'a dog']));
        expect(extractor.extract(post), equals('Check this out a cat a dog'));
      });

      test('skips images with empty alt text', () {
        final post = _post(text: 'Photo', embed: _imagesEmbed(['', 'nice view', '']));
        expect(extractor.extract(post), equals('Photo nice view'));
      });

      test('handles all-blank alt texts gracefully', () {
        final post = _post(text: 'Silent', embed: _imagesEmbed(['', '  ']));
        expect(extractor.extract(post), equals('Silent'));
      });

      test('returns only alt texts when post text is empty', () {
        final post = _post(embed: _imagesEmbed(['sunset photo']));
        expect(extractor.extract(post), equals('sunset photo'));
      });
    });

    group('external link-card embeds', () {
      test('appends title and description to post text', () {
        final post = _post(
          text: 'Read this',
          embed: _externalEmbed(title: 'Great Article', description: 'Very informative'),
        );
        expect(extractor.extract(post), equals('Read this Great Article Very informative'));
      });

      test('omits empty title', () {
        final post = _post(
          text: 'Link',
          embed: _externalEmbed(title: '', description: 'A description'),
        );
        expect(extractor.extract(post), equals('Link A description'));
      });

      test('omits empty description', () {
        final post = _post(
          text: 'Link',
          embed: _externalEmbed(title: 'Title', description: ''),
        );
        expect(extractor.extract(post), equals('Link Title'));
      });

      test('returns only title+description when post text is empty', () {
        final post = _post(
          embed: _externalEmbed(title: 'My Title', description: 'My Desc'),
        );
        expect(extractor.extract(post), equals('My Title My Desc'));
      });
    });

    group('record-with-media embeds (images)', () {
      test('appends image alt texts from media component', () {
        final post = _post(text: 'With quote', embed: _recordWithImagesEmbed('', ['alt one', 'alt two']));
        expect(extractor.extract(post), equals('With quote alt one alt two'));
      });

      test('skips empty alt texts in record-with-media', () {
        final post = _post(text: 'Post', embed: _recordWithImagesEmbed('', ['', 'valid']));
        expect(extractor.extract(post), equals('Post valid'));
      });
    });

    group('record-with-media embeds (external)', () {
      test('appends title and description from media external', () {
        final post = _post(
          text: 'Quoting with link',
          embed: _recordWithExternalEmbed('', title: 'Card Title', description: 'Card Desc'),
        );
        expect(extractor.extract(post), equals('Quoting with link Card Title Card Desc'));
      });
    });

    group('combinations', () {
      test('multiple image alt texts are space-separated between them', () {
        final post = _post(embed: _imagesEmbed(['first', 'second', 'third']));
        expect(extractor.extract(post), equals('first second third'));
      });

      test('produces a single space-joined string with no leading or trailing space', () {
        final post = _post(
          text: 'Body',
          embed: _externalEmbed(title: 'T', description: 'D'),
        );
        final result = extractor.extract(post);
        expect(result.startsWith(' '), isFalse);
        expect(result.endsWith(' '), isFalse);
      });
    });
  });
}
