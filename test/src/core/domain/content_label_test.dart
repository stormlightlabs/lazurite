import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/content_label.dart';

void main() {
  group('ContentLabel', () {
    group('fromJson', () {
      test('parses all fields from valid JSON', () {
        final json = {
          'src': 'did:plc:labeler123',
          'uri': 'at://did:plc:user/app.bsky.feed.post/abc',
          'val': 'spam',
          'cts': '2024-01-15T10:30:00.000Z',
          'cid': 'bafyrei123',
          'neg': false,
          'ver': 1,
        };

        final label = ContentLabel.fromJson(json);

        expect(label.src, 'did:plc:labeler123');
        expect(label.uri, 'at://did:plc:user/app.bsky.feed.post/abc');
        expect(label.val, 'spam');
        expect(label.cts, DateTime.utc(2024, 1, 15, 10, 30));
        expect(label.cid, 'bafyrei123');
        expect(label.neg, false);
        expect(label.ver, 1);
      });

      test('handles minimal required fields', () {
        final json = {
          'src': 'did:plc:labeler',
          'uri': 'at://did:plc:user/app.bsky.feed.post/123',
          'val': 'porn',
          'cts': '2024-06-01T00:00:00.000Z',
        };

        final label = ContentLabel.fromJson(json);

        expect(label.src, 'did:plc:labeler');
        expect(label.val, 'porn');
        expect(label.cid, isNull);
        expect(label.neg, isNull);
        expect(label.ver, isNull);
      });

      test('parses negation label', () {
        final json = {
          'src': 'did:plc:mod',
          'uri': 'at://did:plc:user/app.bsky.actor.profile/self',
          'val': 'verified',
          'cts': '2024-01-01T00:00:00.000Z',
          'neg': true,
        };

        final label = ContentLabel.fromJson(json);

        expect(label.neg, true);
        expect(label.isNegation, true);
      });
    });

    group('parseFromJsonString', () {
      test('parses array of labels from JSON string', () {
        final labels = [
          {
            'src': 'did:plc:labeler1',
            'uri': 'at://did:plc:user/post/1',
            'val': 'spam',
            'cts': '2024-01-01T00:00:00.000Z',
          },
          {
            'src': 'did:plc:labeler2',
            'uri': 'at://did:plc:user/post/1',
            'val': 'scam',
            'cts': '2024-01-02T00:00:00.000Z',
          },
        ];
        final jsonString = jsonEncode(labels);

        final result = ContentLabel.parseFromJsonString(jsonString);

        expect(result, hasLength(2));
        expect(result[0].val, 'spam');
        expect(result[0].labelerDid, 'did:plc:labeler1');
        expect(result[1].val, 'scam');
        expect(result[1].labelerDid, 'did:plc:labeler2');
      });

      test('returns empty list for null input', () {
        final result = ContentLabel.parseFromJsonString(null);
        expect(result, isEmpty);
      });

      test('returns empty list for empty string', () {
        final result = ContentLabel.parseFromJsonString('');
        expect(result, isEmpty);
      });

      test('returns empty list for invalid JSON', () {
        final result = ContentLabel.parseFromJsonString('not valid json');
        expect(result, isEmpty);
      });

      test('returns empty list for non-array JSON', () {
        final result = ContentLabel.parseFromJsonString('{"foo": "bar"}');
        expect(result, isEmpty);
      });
    });

    group('convenience getters', () {
      test('labelerDid returns src field', () {
        final label = ContentLabel(
          src: 'did:plc:bluesky-mod',
          uri: 'at://did:plc:user/post/1',
          val: 'porn',
          cts: DateTime.now(),
        );

        expect(label.labelerDid, 'did:plc:bluesky-mod');
      });

      test('isNegation returns false for null neg', () {
        final label = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: DateTime.now(),
        );

        expect(label.isNegation, false);
      });

      test('isNegation returns true when neg is true', () {
        final label = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: DateTime.now(),
          neg: true,
        );

        expect(label.isNegation, true);
      });

      test('isSystemLabel detects ! prefix', () {
        final systemLabel = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: '!hide',
          cts: DateTime.now(),
        );

        final regularLabel = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: DateTime.now(),
        );

        expect(systemLabel.isSystemLabel, true);
        expect(regularLabel.isSystemLabel, false);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final label = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: DateTime.utc(2024, 1, 15, 10, 30),
          cid: 'bafyrei123',
          neg: true,
          ver: 1,
        );

        final json = label.toJson();

        expect(json['src'], 'did:plc:mod');
        expect(json['uri'], 'at://did:plc:user/post/1');
        expect(json['val'], 'spam');
        expect(json['cts'], '2024-01-15T10:30:00.000Z');
        expect(json['cid'], 'bafyrei123');
        expect(json['neg'], true);
        expect(json['ver'], 1);
      });

      test('omits null optional fields', () {
        final label = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: DateTime.utc(2024, 1, 15),
        );

        final json = label.toJson();

        expect(json.containsKey('cid'), false);
        expect(json.containsKey('neg'), false);
        expect(json.containsKey('ver'), false);
      });
    });

    group('equality', () {
      test('two labels with same src, uri, val, cts are equal', () {
        final cts = DateTime.utc(2024, 1, 1);
        final label1 = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: cts,
        );
        final label2 = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: cts,
        );

        expect(label1, equals(label2));
        expect(label1.hashCode, equals(label2.hashCode));
      });

      test('different val makes labels unequal', () {
        final cts = DateTime.utc(2024, 1, 1);
        final label1 = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'spam',
          cts: cts,
        );
        final label2 = ContentLabel(
          src: 'did:plc:mod',
          uri: 'at://did:plc:user/post/1',
          val: 'scam',
          cts: cts,
        );

        expect(label1, isNot(equals(label2)));
      });
    });
  });
}
