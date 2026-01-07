import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late FacetParser parser;
  late MockXrpcClient mockApi;
  late MockLogger mockLogger;

  setUp(() {
    mockApi = MockXrpcClient();
    mockLogger = MockLogger();
    parser = FacetParser(api: mockApi, logger: mockLogger);
  });

  group('FacetParser - Mentions', () {
    test('detects and resolves single mention', () async {
      const text = 'Hello @alice.bsky.social how are you?';
      const did = 'did:plc:alice123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': did});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect(facet['index']['byteStart'], 6);
      expect(facet['index']['byteEnd'], 24);

      final features = facet['features'] as List<dynamic>;
      expect(features.first['\$type'], 'app.bsky.richtext.facet#mention');
      expect(features.first['did'], did);
    });

    test('detects multiple mentions', () async {
      const text = 'Hey @alice.bsky.social and @bob.bsky.social!';
      const aliceDid = 'did:plc:alice123';
      const bobDid = 'did:plc:bob456';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': aliceDid});
      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'bob.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': bobDid});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(2));

      final aliceFacet = facets[0] as Map<String, dynamic>;
      expect((aliceFacet['features'] as List).first['did'], aliceDid);

      final bobFacet = facets[1] as Map<String, dynamic>;
      expect((bobFacet['features'] as List).first['did'], bobDid);
    });

    test('skips mention if DID resolution fails', () async {
      const text = 'Hello @invalid.handle world';

      when(
        () => mockApi.call('com.atproto.identity.resolveHandle', params: any(named: 'params')),
      ).thenThrow(Exception('Not found'));

      final result = await parser.parse(text);

      expect(result, isNull);
      verify(() => mockLogger.warning(any(), any(), any())).called(1);
    });

    test('continues parsing other mentions if one fails', () async {
      const text = '@invalid.handle and @alice.bsky.social';
      const aliceDid = 'did:plc:alice123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'invalid.handle'},
        ),
      ).thenThrow(Exception('Not found'));
      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': aliceDid});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect((facet['features'] as List).first['did'], aliceDid);
    });
  });

  group('FacetParser - Links', () {
    test('detects URL with https protocol', () async {
      const text = 'Check out https://example.com for more info';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect(facet['index']['byteStart'], 10);
      expect(facet['index']['byteEnd'], 29);

      final features = facet['features'] as List<dynamic>;
      expect(features.first['\$type'], 'app.bsky.richtext.facet#link');
      expect(features.first['uri'], 'https://example.com');
    });

    test('detects URL with http protocol', () async {
      const text = 'Visit http://example.org today';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final features = (facets.first as Map<String, dynamic>)['features'] as List<dynamic>;
      expect(features.first['uri'], 'http://example.org');
    });

    test('detects URL without protocol and adds https', () async {
      const text = 'Check example.com for details';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final features = (facets.first as Map<String, dynamic>)['features'] as List<dynamic>;
      expect(features.first['uri'], 'https://example.com');
    });

    test('detects URL with www prefix', () async {
      const text = 'Go to www.example.com now';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final features = (facets.first as Map<String, dynamic>)['features'] as List<dynamic>;
      expect(features.first['uri'], 'https://www.example.com');
    });

    test('detects URL with path and query params', () async {
      const text = 'See https://example.com/path/to/page?foo=bar&baz=qux';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final features = (facets.first as Map<String, dynamic>)['features'] as List<dynamic>;
      expect(features.first['uri'], 'https://example.com/path/to/page?foo=bar&baz=qux');
    });

    test('detects multiple URLs', () async {
      const text = 'Visit https://example.com and https://another.org';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(2));

      final firstUri = ((facets[0] as Map<String, dynamic>)['features'] as List).first['uri'];
      final secondUri = ((facets[1] as Map<String, dynamic>)['features'] as List).first['uri'];

      expect(firstUri, 'https://example.com');
      expect(secondUri, 'https://another.org');
    });
  });

  group('FacetParser - Hashtags', () {
    test('detects single hashtag', () async {
      const text = 'This is a #test post';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect(facet['index']['byteStart'], 10);
      expect(facet['index']['byteEnd'], 15);

      final features = facet['features'] as List<dynamic>;
      expect(features.first['\$type'], 'app.bsky.richtext.facet#tag');
      expect(features.first['tag'], 'test');
    });

    test('detects multiple hashtags', () async {
      const text = 'I love #coding and #testing!';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(2));

      final firstTag = ((facets[0] as Map<String, dynamic>)['features'] as List).first['tag'];
      final secondTag = ((facets[1] as Map<String, dynamic>)['features'] as List).first['tag'];

      expect(firstTag, 'coding');
      expect(secondTag, 'testing');
    });

    test('detects hashtag with underscores', () async {
      const text = 'Check out #my_cool_tag';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final tag = ((facets.first as Map<String, dynamic>)['features'] as List).first['tag'];
      expect(tag, 'my_cool_tag');
    });

    test('detects hashtag with numbers', () async {
      const text = 'Join #event2024 now';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final tag = ((facets.first as Map<String, dynamic>)['features'] as List).first['tag'];
      expect(tag, 'event2024');
    });
  });

  group('FacetParser - Byte Offsets', () {
    test('calculates correct byte offsets for ASCII text', () async {
      const text = 'Hello #world';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      final facet = facets.first as Map<String, dynamic>;

      expect(facet['index']['byteStart'], 6);
      expect(facet['index']['byteEnd'], 12);
    });

    test('calculates correct byte offsets for emoji', () async {
      const text = '👋 #hello';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      final facet = facets.first as Map<String, dynamic>;

      expect(facet['index']['byteStart'], 5);
      expect(facet['index']['byteEnd'], 11);
    });

    test('calculates correct byte offsets for multi-byte unicode', () async {
      const text = 'こんにちは #test';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      final facet = facets.first as Map<String, dynamic>;

      expect(facet['index']['byteStart'], 16);
      expect(facet['index']['byteEnd'], 21);
    });

    test('calculates correct byte offsets for complex emoji', () async {
      const text = '👨‍👩‍👧‍👦 #family';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      final facet = facets.first as Map<String, dynamic>;

      final expectedStart = utf8.encode('👨‍👩‍👧‍👦 ').length;
      expect(facet['index']['byteStart'], expectedStart);
      expect(facet['index']['byteEnd'], expectedStart + 7); // "#family" = 7 bytes
    });

    test('calculates correct byte offsets with mixed content', () async {
      const text = 'Hello 👋 世界 #test';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      final facet = facets.first as Map<String, dynamic>;

      const prefix = 'Hello 👋 世界 ';
      final expectedStart = utf8.encode(prefix).length;

      expect(facet['index']['byteStart'], expectedStart);
      expect(facet['index']['byteEnd'], expectedStart + 5); // "#test" = 5 bytes
    });
  });

  group('FacetParser - Mixed Facets', () {
    test('detects mention, link, and hashtag together', () async {
      const text = 'Hey @alice.bsky.social check https://example.com #cool';
      const did = 'did:plc:alice123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': did});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(3));

      final types = facets.map((f) {
        final features = (f as Map<String, dynamic>)['features'] as List<dynamic>;
        return features.first['\$type'] as String;
      }).toList();

      expect(types, contains('app.bsky.richtext.facet#mention'));
      expect(types, contains('app.bsky.richtext.facet#link'));
      expect(types, contains('app.bsky.richtext.facet#tag'));
    });

    test('sorts facets by byte offset', () async {
      const text = '#first https://example.com @alice.bsky.social #last';
      const did = 'did:plc:alice123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': did});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(4));

      final offsets = facets
          .map((f) => (f as Map<String, dynamic>)['index']['byteStart'] as int)
          .toList();
      final sortedOffsets = List<int>.from(offsets)..sort();
      expect(offsets, equals(sortedOffsets));
    });
  });

  group('FacetParser - Edge Cases', () {
    test('returns null for empty text', () async {
      const text = '';

      final result = await parser.parse(text);

      expect(result, isNull);
    });

    test('returns null when no facets detected', () async {
      const text = 'Just plain text with nothing special';

      final result = await parser.parse(text);

      expect(result, isNull);
    });

    test('handles text with only whitespace', () async {
      const text = '   \n\t  ';

      final result = await parser.parse(text);

      expect(result, isNull);
    });

    test('handles mention at start of text', () async {
      const text = '@alice.bsky.social hello';
      const did = 'did:plc:alice123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'alice.bsky.social'},
        ),
      ).thenAnswer((_) async => {'did': did});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect(facet['index']['byteStart'], 0);
    });

    test('handles hashtag at end of text', () async {
      const text = 'This is the end #final';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final facet = facets.first as Map<String, dynamic>;
      expect(facet['index']['byteEnd'], utf8.encode(text).length);
    });

    test('handles very long text with multiple facets', () async {
      final mentions = List.generate(10, (i) => '@user$i.bsky.social');
      final text = mentions.join(' ');

      for (var i = 0; i < 10; i++) {
        when(
          () => mockApi.call(
            'com.atproto.identity.resolveHandle',
            params: {'handle': 'user$i.bsky.social'},
          ),
        ).thenAnswer((_) async => {'did': 'did:plc:user$i'});
      }

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(10));
    });

    test('handles special characters in text', () async {
      const text = 'Special chars: !@#\$%^&*() with #hashtag';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final tag = ((facets.first as Map<String, dynamic>)['features'] as List).first['tag'];
      expect(tag, 'hashtag');
    });

    test('handles newlines and multiple lines', () async {
      const text = 'Line 1 #first\nLine 2 #second\nLine 3 #third';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(3));
    });
  });

  group('FacetParser - URL Validation', () {
    test('detects domain-like patterns even if not real TLDs', () async {
      const text = 'Not a URL: abc.123 or xyz';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));
      expect(
        ((facets.first as Map<String, dynamic>)['features'] as List).first['uri'],
        'https://abc.123',
      );
    });

    test('detects URL with subdomain', () async {
      const text = 'Visit api.example.com for API docs';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final uri = ((facets.first as Map<String, dynamic>)['features'] as List).first['uri'];
      expect(uri, 'https://api.example.com');
    });

    test('handles URL with port', () async {
      const text = 'Connect to example.com:8080';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final uri = ((facets.first as Map<String, dynamic>)['features'] as List).first['uri'];
      expect(uri, contains(':8080'));
    });

    test('handles URL with fragment', () async {
      const text = 'See https://example.com/page#section';

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));

      final uri = ((facets.first as Map<String, dynamic>)['features'] as List).first['uri'];
      expect(uri, 'https://example.com/page#section');
    });
  });

  group('FacetParser - Mention Validation', () {
    test('requires mention to have valid handle format', () async {
      const text = 'Invalid @123 or @-invalid or @.invalid';

      final result = await parser.parse(text);

      expect(result, isNull);
      verifyNever(() => mockApi.call(any(), params: any(named: 'params')));
    });

    test('handles mention with subdomain', () async {
      const text = 'Hey @user.subdomain.example.com';
      const did = 'did:plc:user123';

      when(
        () => mockApi.call(
          'com.atproto.identity.resolveHandle',
          params: {'handle': 'user.subdomain.example.com'},
        ),
      ).thenAnswer((_) async => {'did': did});

      final result = await parser.parse(text);

      expect(result, isNotNull);
      final facets = jsonDecode(result!) as List<dynamic>;
      expect(facets, hasLength(1));
    });
  });

  group('FacetParser - toJson serialization', () {
    test('Facet serializes correctly', () {
      final facet = Facet(
        index: FacetIndex(byteStart: 0, byteEnd: 10),
        features: [MentionFeature(did: 'did:plc:test')],
      );

      final json = facet.toJson();

      expect(json['index']['byteStart'], 0);
      expect(json['index']['byteEnd'], 10);
      expect(json['features'], hasLength(1));
      expect(json['features'][0]['\$type'], 'app.bsky.richtext.facet#mention');
      expect(json['features'][0]['did'], 'did:plc:test');
    });

    test('MentionFeature serializes correctly', () {
      final feature = MentionFeature(did: 'did:plc:alice');
      final json = feature.toJson();

      expect(json['\$type'], 'app.bsky.richtext.facet#mention');
      expect(json['did'], 'did:plc:alice');
    });

    test('LinkFeature serializes correctly', () {
      final feature = LinkFeature(uri: 'https://example.com');
      final json = feature.toJson();

      expect(json['\$type'], 'app.bsky.richtext.facet#link');
      expect(json['uri'], 'https://example.com');
    });

    test('HashtagFeature serializes correctly', () {
      final feature = HashtagFeature(tag: 'flutter');
      final json = feature.toJson();

      expect(json['\$type'], 'app.bsky.richtext.facet#tag');
      expect(json['tag'], 'flutter');
    });
  });
}
