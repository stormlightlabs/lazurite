import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/facet/facet_helper.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

void main() {
  group('FacetHelper.byteOffsetToCharOffset', () {
    group('ASCII Characters', () {
      test('Converts byte offset for single ASCII character', () {
        const text = 'abc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 2);
        expect(FacetHelper.byteOffsetToCharOffset(text, 3), 3);
      });

      test('Converts byte offset for multiple ASCII characters', () {
        const text = 'Hello World';
        expect(FacetHelper.byteOffsetToCharOffset(text, 5), 5);
        expect(FacetHelper.byteOffsetToCharOffset(text, 6), 6);
        expect(FacetHelper.byteOffsetToCharOffset(text, 11), 11);
      });

      test('Returns 0 for byte offset 0', () {
        const text = 'any text';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
      });

      test('Returns text length for byte offset beyond text length', () {
        const text = 'abc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 100), 3);
        expect(FacetHelper.byteOffsetToCharOffset(text, 3), 3);
      });

      test('Handles empty string', () {
        const text = '';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 5), 0);
      });
    });

    group('UTF-8 Multi-byte Sequences', () {
      test('Converts byte offset for 2-byte UTF-8 characters', () {
        const text = 'aébc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 3), 2);
        expect(FacetHelper.byteOffsetToCharOffset(text, 4), 3);
      });

      test('Converts byte offset for 3-byte UTF-8 characters', () {
        const text = 'a€bc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 3), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 4), 2);
      });

      test('Converts byte offset for 4-byte UTF-8 characters (emoji)', () {
        const text = '🚀abc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 0), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 4), 2);
        expect(FacetHelper.byteOffsetToCharOffset(text, 5), 3);
      });

      test('Handles mixed ASCII and multi-byte characters', () {
        const text = 'Hello é World €';
        expect(FacetHelper.byteOffsetToCharOffset(text, 5), 5);
        expect(FacetHelper.byteOffsetToCharOffset(text, 7), 6);
        expect(FacetHelper.byteOffsetToCharOffset(text, 13), 12);
      });

      test('Handles emoji sequences (modifiers, skin tones)', () {
        const text = 'a 👨🏽 b';
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 2);
        expect(FacetHelper.byteOffsetToCharOffset(text, 6), 4);
        expect(FacetHelper.byteOffsetToCharOffset(text, 10), 6);
      });

      test('Handles grapheme clusters (flag emojis)', () {
        const text = 'a🇺🇸b';
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 5), 3);
        expect(FacetHelper.byteOffsetToCharOffset(text, 9), 5);
        expect(FacetHelper.byteOffsetToCharOffset(text, 10), 6);
      });
    });

    group('Edge Cases', () {
      test('Byte offset in middle of multi-byte sequence returns previous character', () {
        const text = 'é';
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 1);
      });

      test('Byte offset at exact character boundary', () {
        const text = 'abc';
        expect(FacetHelper.byteOffsetToCharOffset(text, 1), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 2), 2);
      });

      test('Negative byte offset returns 0', () {
        const text = 'abc';
        expect(FacetHelper.byteOffsetToCharOffset(text, -1), 0);
        expect(FacetHelper.byteOffsetToCharOffset(text, -100), 0);
      });

      test('Large text with many multi-byte characters', () {
        final text = 'éééééééééé' * 30;
        expect(FacetHelper.byteOffsetToCharOffset(text, 100), 50);
        expect(FacetHelper.byteOffsetToCharOffset(text, 600), 300);
      });

      test('Text with only multi-byte characters', () {
        const text = '€€€€€';
        expect(FacetHelper.byteOffsetToCharOffset(text, 3), 1);
        expect(FacetHelper.byteOffsetToCharOffset(text, 6), 2);
        expect(FacetHelper.byteOffsetToCharOffset(text, 15), 5);
      });
    });
  });

  group('FacetHelper.parseFacets', () {
    group('Valid JSON', () {
      test('Parses empty facets array', () {
        final json = jsonEncode([]);
        expect(FacetHelper.parseFacets(json), isEmpty);
      });

      test('Parses single mention facet', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 10},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:abc123'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(1));
        expect(facets[0].index.byteStart, 0);
        expect(facets[0].index.byteEnd, 10);
        expect(FacetHelper.getMentionFeature(facets[0])?.did, 'did:plc:abc123');
      });

      test('Parses single link facet', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 23},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#link', 'uri': 'https://example.com'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(1));
        expect(FacetHelper.getLinkFeature(facets[0])?.uri, 'https://example.com');
      });

      test('Parses single hashtag facet', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 7},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#tag', 'tag': 'dartlang'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(1));
        expect(FacetHelper.getHashtagFeature(facets[0])?.tag, 'dartlang');
      });

      test('Parses multiple facets of same type', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 10},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:abc123'},
            ],
          },
          {
            'index': {'byteStart': 15, 'byteEnd': 25},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:def456'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(2));
        expect(FacetHelper.getMentionFeature(facets[0])?.did, 'did:plc:abc123');
        expect(FacetHelper.getMentionFeature(facets[1])?.did, 'did:plc:def456');
      });

      test('Parses multiple facets of different types', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 10},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:abc123'},
            ],
          },
          {
            'index': {'byteStart': 15, 'byteEnd': 35},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#link', 'uri': 'https://example.com'},
            ],
          },
          {
            'index': {'byteStart': 40, 'byteEnd': 50},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#tag', 'tag': 'test'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(3));
        expect(FacetHelper.getFacetType(facets[0]), FacetType.mention);
        expect(FacetHelper.getFacetType(facets[1]), FacetType.link);
        expect(FacetHelper.getFacetType(facets[2]), FacetType.hashtag);
      });

      test('Preserves byte start and end positions', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 100, 'byteEnd': 200},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#link', 'uri': 'https://example.com'},
            ],
          },
        ]);
        final facets = FacetHelper.parseFacets(json);
        expect(facets[0].index.byteStart, 100);
        expect(facets[0].index.byteEnd, 200);
      });
    });

    group('Invalid JSON', () {
      test('Returns empty list for null input', () {
        expect(FacetHelper.parseFacets(null), isEmpty);
      });

      test('Returns empty list for empty string', () {
        expect(FacetHelper.parseFacets(''), isEmpty);
      });

      test('Handles malformed JSON gracefully', () {
        expect(FacetHelper.parseFacets('not json'), isEmpty);
        expect(FacetHelper.parseFacets('{invalid}'), isEmpty);
      });

      test('Handles missing required fields', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0},
          },
        ]);

        expect(FacetHelper.parseFacets(json), isEmpty);
      });

      test('Handles invalid byte offsets', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': -1, 'byteEnd': 10},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#link', 'uri': 'https://example.com'},
            ],
          },
        ]);

        final facets = FacetHelper.parseFacets(json);
        expect(facets, hasLength(1));
        expect(facets[0].index.byteStart, -1);
      });

      test('Handles missing features array', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 10},
          },
        ]);
        expect(FacetHelper.parseFacets(json), isEmpty);
      });

      test('Handles unknown feature types', () {
        final json = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 10},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#unknown', 'data': 'test'},
            ],
          },
        ]);
        expect(FacetHelper.parseFacets(json), isEmpty);
      });
    });
  });

  group('Facet Model Construction', () {
    test('Creates facet with mention feature', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [MentionFeature(did: 'did:plc:abc123')],
      );
      expect(facet.index.byteStart, 0);
      expect(facet.index.byteEnd, 10);
      expect(FacetHelper.getMentionFeature(facet)?.did, 'did:plc:abc123');
    });

    test('Creates facet with link feature', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 23),
        features: [LinkFeature(uri: 'https://example.com')],
      );
      expect(FacetHelper.getLinkFeature(facet)?.uri, 'https://example.com');
    });

    test('Creates facet with hashtag feature', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 7),
        features: [HashtagFeature(tag: 'dartlang')],
      );
      expect(FacetHelper.getHashtagFeature(facet)?.tag, 'dartlang');
    });

    test('Handles facet with multiple features', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [
          MentionFeature(did: 'did:plc:abc123'),
          LinkFeature(uri: 'https://example.com'),
        ],
      );

      expect(FacetHelper.getFacetType(facet), FacetType.mention);
      expect(FacetHelper.getMentionFeature(facet)?.did, 'did:plc:abc123');
      expect(FacetHelper.getLinkFeature(facet)?.uri, 'https://example.com');
    });

    test('FacetIndex implements equality correctly', () {
      final index1 = FacetIndex(byteStart: 0, byteEnd: 10);
      final index2 = FacetIndex(byteStart: 0, byteEnd: 10);
      final index3 = FacetIndex(byteStart: 5, byteEnd: 15);

      expect(index1, equals(index2));
      expect(index1, isNot(equals(index3)));
    });

    test('FacetIndex implements hashCode correctly', () {
      final index1 = FacetIndex(byteStart: 0, byteEnd: 10);
      final index2 = FacetIndex(byteStart: 0, byteEnd: 10);

      expect(index1.hashCode, equals(index2.hashCode));
    });
  });

  group('FacetHelper feature extractors', () {
    test('getMentionFeature returns mention or null', () {
      final mentionFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [MentionFeature(did: 'did:plc:abc123')],
      );
      final linkFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [LinkFeature(uri: 'https://example.com')],
      );

      expect(FacetHelper.getMentionFeature(mentionFacet), isA<MentionFeature>());
      expect(FacetHelper.getMentionFeature(linkFacet), isNull);
    });

    test('getLinkFeature returns link or null', () {
      final linkFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [LinkFeature(uri: 'https://example.com')],
      );
      final hashtagFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [HashtagFeature(tag: 'test')],
      );

      expect(FacetHelper.getLinkFeature(linkFacet), isA<LinkFeature>());
      expect(FacetHelper.getLinkFeature(hashtagFacet), isNull);
    });

    test('getHashtagFeature returns hashtag or null', () {
      final hashtagFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [HashtagFeature(tag: 'test')],
      );
      final mentionFacet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [MentionFeature(did: 'did:plc:abc123')],
      );

      expect(FacetHelper.getHashtagFeature(hashtagFacet), isA<HashtagFeature>());
      expect(FacetHelper.getHashtagFeature(mentionFacet), isNull);
    });

    test('getFacetType prioritizes mentions over links', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [
          LinkFeature(uri: 'https://example.com'),
          MentionFeature(did: 'did:plc:abc123'),
        ],
      );
      expect(FacetHelper.getFacetType(facet), FacetType.mention);
    });

    test('getFacetType prioritizes links over hashtags', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [
          HashtagFeature(tag: 'test'),
          LinkFeature(uri: 'https://example.com'),
        ],
      );
      expect(FacetHelper.getFacetType(facet), FacetType.link);
    });

    test('getFacetType returns unknown for empty features', () {
      final facet = Facet(index: FacetIndex(byteStart: 0, byteEnd: 10), features: []);
      expect(FacetHelper.getFacetType(facet), FacetType.unknown);
    });
  });
}
