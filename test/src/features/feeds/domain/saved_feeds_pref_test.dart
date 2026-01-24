import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/domain/saved_feeds_pref.dart';

void main() {
  group('SavedFeedItem', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'value': 'at://did:plc:test/app.bsky.feed.generator/feed1',
        'pinned': true,
        'id': 'feed-123',
      };

      final item = SavedFeedItem.fromJson(json);

      expect(item.value, 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(item.pinned, true);
      expect(item.id, 'feed-123');
    });

    test('fromJson handles pinned as false by default', () {
      final json = {'value': 'at://did:plc:test/app.bsky.feed.generator/feed1', 'id': 'feed-123'};

      final item = SavedFeedItem.fromJson(json);

      expect(item.pinned, false);
    });

    test('fromJson throws on missing value', () {
      expect(() => SavedFeedItem.fromJson({'id': '123'}), throwsA(isA<Error>()));
    });

    test('fromJson throws on missing id', () {
      final json = {'value': 'at://did:plc:test/app.bsky.feed.generator/feed1', 'pinned': true};

      expect(() => SavedFeedItem.fromJson(json), throwsA(isA<Error>()));
    });

    test('toJson converts back to JSON correctly', () {
      const item = SavedFeedItem(
        value: 'at://did:plc:test/app.bsky.feed.generator/feed1',
        pinned: true,
        id: 'feed-123',
      );

      final json = item.toJson();

      expect(json['value'], 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(json['pinned'], true);
      expect(json['id'], 'feed-123');
    });
  });

  group('SavedFeedsPrefV2', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'items': [
          {
            'value': 'at://did:plc:test/app.bsky.feed.generator/feed1',
            'pinned': true,
            'id': 'feed-123',
          },
          {
            'value': 'at://did:plc:test/app.bsky.feed.generator/feed2',
            'pinned': false,
            'id': 'feed-456',
          },
        ],
      };

      final pref = SavedFeedsPrefV2.fromJson(json);

      expect(pref.items.length, 2);
      expect(pref.items[0].value, 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(pref.items[0].pinned, true);
      expect(pref.items[1].value, 'at://did:plc:test/app.bsky.feed.generator/feed2');
      expect(pref.items[1].pinned, false);
    });

    test('fromJson handles empty items list', () {
      final json = {'items': []};

      final pref = SavedFeedsPrefV2.fromJson(json);

      expect(pref.items, isEmpty);
    });

    test('fromJson throws on missing items', () {
      expect(() => SavedFeedsPrefV2.fromJson({}), throwsA(isA<Error>()));
    });

    test('fromJson throws on invalid items type', () {
      final json = {'items': 'not-a-list'};

      expect(() => SavedFeedsPrefV2.fromJson(json), throwsA(isA<Error>()));
    });

    test('savedUris returns all feed URIs', () {
      const pref = SavedFeedsPrefV2(
        items: [
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed1',
            pinned: true,
            id: 'feed-123',
          ),
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed2',
            pinned: false,
            id: 'feed-456',
          ),
        ],
      );

      final uris = pref.savedUris;

      expect(uris.length, 2);
      expect(uris[0], 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(uris[1], 'at://did:plc:test/app.bsky.feed.generator/feed2');
    });

    test('pinnedUris returns only pinned feed URIs', () {
      const pref = SavedFeedsPrefV2(
        items: [
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed1',
            pinned: true,
            id: 'feed-123',
          ),
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed2',
            pinned: false,
            id: 'feed-456',
          ),
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed3',
            pinned: true,
            id: 'feed-789',
          ),
        ],
      );

      final uris = pref.pinnedUris;

      expect(uris.length, 2);
      expect(uris[0], 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(uris[1], 'at://did:plc:test/app.bsky.feed.generator/feed3');
    });

    test('toJson converts back to JSON correctly', () {
      const pref = SavedFeedsPrefV2(
        items: [
          SavedFeedItem(
            value: 'at://did:plc:test/app.bsky.feed.generator/feed1',
            pinned: true,
            id: 'feed-123',
          ),
        ],
      );

      final json = pref.toJson();

      expect(json['\$type'], 'app.bsky.actor.defs#savedFeedsPrefV2');
      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1);
    });
  });

  group('SavedFeedsPref (V1)', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'saved': [
          'at://did:plc:test/app.bsky.feed.generator/feed1',
          'at://did:plc:test/app.bsky.feed.generator/feed2',
        ],
        'pinned': ['at://did:plc:test/app.bsky.feed.generator/feed1'],
      };

      final pref = SavedFeedsPref.fromJson(json);

      expect(pref.saved.length, 2);
      expect(pref.saved[0], 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(pref.pinned.length, 1);
      expect(pref.pinned[0], 'at://did:plc:test/app.bsky.feed.generator/feed1');
    });

    test('fromJson handles empty lists', () {
      final json = {'saved': <String>[], 'pinned': <String>[]};

      final pref = SavedFeedsPref.fromJson(json);

      expect(pref.saved, isEmpty);
      expect(pref.pinned, isEmpty);
    });

    test('fromJson handles missing saved', () {
      final json = {'pinned': <String>[]};

      final pref = SavedFeedsPref.fromJson(json);

      expect(pref.saved, isEmpty);
      expect(pref.pinned, isEmpty);
    });

    test('fromJson handles missing pinned', () {
      final json = {
        'saved': ['at://did:plc:test/app.bsky.feed.generator/feed1'],
      };

      final pref = SavedFeedsPref.fromJson(json);

      expect(pref.saved.length, 1);
      expect(pref.pinned, isEmpty);
    });

    test('fromJson throws on invalid saved type', () {
      final json = {'saved': 'not-a-list'};

      expect(() => SavedFeedsPref.fromJson(json), throwsA(isA<Error>()));
    });

    test('toJson converts back to JSON correctly', () {
      const pref = SavedFeedsPref(
        saved: [
          'at://did:plc:test/app.bsky.feed.generator/feed1',
          'at://did:plc:test/app.bsky.feed.generator/feed2',
        ],
        pinned: ['at://did:plc:test/app.bsky.feed.generator/feed1'],
      );

      final json = pref.toJson();

      expect(json['\$type'], 'app.bsky.actor.defs#savedFeedsPref');
      expect(json['saved'], isA<List>());
      expect((json['saved'] as List).length, 2);
      expect(json['pinned'], isA<List>());
      expect((json['pinned'] as List).length, 1);
    });
  });

  group('SavedFeedsPreferenceParser', () {
    test('parse finds V2 preference', () {
      final prefs = [
        {'\$type': 'app.bsky.actor.defs#personalDetailsPref', 'birthDate': '2000-01-01'},
        {
          '\$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
          'items': [
            {
              'value': 'at://did:plc:test/app.bsky.feed.generator/feed1',
              'pinned': true,
              'id': 'feed-123',
            },
          ],
        },
      ];

      final result = SavedFeedsPreferenceParser.parse(prefs);

      expect(result.v2, isNotNull);
      expect(result.v1, isNull);
      expect(result.v2!.items.length, 1);
    });

    test('parse finds V1 preference', () {
      final prefs = [
        {
          '\$type': 'app.bsky.actor.defs#savedFeedsPref',
          'saved': ['at://did:plc:test/app.bsky.feed.generator/feed1'],
          'pinned': [],
        },
      ];

      final result = SavedFeedsPreferenceParser.parse(prefs);

      expect(result.v2, isNull);
      expect(result.v1, isNotNull);
      expect(result.v1!.saved.length, 1);
    });

    test('parse prefers V2 over V1 when both exist', () {
      final prefs = [
        {
          '\$type': 'app.bsky.actor.defs#savedFeedsPref',
          'saved': ['at://did:plc:test/app.bsky.feed.generator/feed1'],
          'pinned': [],
        },
        {
          '\$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
          'items': [
            {
              'value': 'at://did:plc:test/app.bsky.feed.generator/feed2',
              'pinned': false,
              'id': 'feed-456',
            },
          ],
        },
      ];

      final result = SavedFeedsPreferenceParser.parse(prefs);

      expect(result.v2, isNotNull);
      expect(result.v1, isNotNull);
      expect(result.v2!.items[0].value, 'at://did:plc:test/app.bsky.feed.generator/feed2');
      expect(result.v1!.saved[0], 'at://did:plc:test/app.bsky.feed.generator/feed1');
    });

    test('parse returns nulls when neither preference exists', () {
      final prefs = [
        {'\$type': 'app.bsky.actor.defs#personalDetailsPref', 'birthDate': '2000-01-01'},
      ];

      final result = SavedFeedsPreferenceParser.parse(prefs);

      expect(result.v2, isNull);
      expect(result.v1, isNull);
    });

    test('parse skips invalid preference structures', () {
      final prefs = [
        {'\$type': 'app.bsky.actor.defs#savedFeedsPrefV2'},
        {'\$type': 'app.bsky.actor.defs#personalDetailsPref', 'birthDate': '2000-01-01'},
      ];

      final result = SavedFeedsPreferenceParser.parse(prefs);

      expect(result.v2, isNull);
      expect(result.v1, isNull);
    });
  });
}
