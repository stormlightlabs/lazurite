import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';
import 'package:lazurite/src/features/feeds/domain/list_view.dart';

void main() {
  group('ListView', () {
    test('fromJson parses valid list metadata correctly', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'cid': 'bafyreiabc123',
        'creator': {
          'did': 'did:plc:abc123',
          'handle': 'creator.bsky.social',
          'displayName': 'Creator',
          'avatar': 'https://example.com/avatar.jpg',
        },
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#curatelist',
        'description': 'A test list',
        'avatar': 'https://example.com/list-avatar.jpg',
        'listItemCount': 42,
        'indexedAt': '2024-01-15T10:30:00Z',
      };

      final listView = ListView.fromJson(json);

      expect(listView.uri, 'at://did:plc:abc123/app.bsky.graph.list/testlist');
      expect(listView.cid, 'bafyreiabc123');
      expect(listView.creator.did, 'did:plc:abc123');
      expect(listView.creator.handle, 'creator.bsky.social');
      expect(listView.name, 'Test List');
      expect(listView.purpose, 'app.bsky.graph.defs#curatelist');
      expect(listView.description, 'A test list');
      expect(listView.avatar, 'https://example.com/list-avatar.jpg');
      expect(listView.listItemCount, 42);
      expect(listView.indexedAt, DateTime.parse('2024-01-15T10:30:00Z'));
    });

    test('fromJson parses minimal valid list metadata', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'cid': 'bafyreiabc123',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#modlist',
      };

      final listView = ListView.fromJson(json);

      expect(listView.uri, 'at://did:plc:abc123/app.bsky.graph.list/testlist');
      expect(listView.cid, 'bafyreiabc123');
      expect(listView.creator.did, 'did:plc:abc123');
      expect(listView.creator.handle, 'creator.bsky.social');
      expect(listView.name, 'Test List');
      expect(listView.purpose, 'app.bsky.graph.defs#modlist');
      expect(listView.description, isNull);
      expect(listView.avatar, isNull);
      expect(listView.listItemCount, isNull);
      expect(listView.indexedAt, isNull);
    });

    test('fromJson throws FormatException when uri is missing', () {
      final json = {
        'cid': 'bafyreiabc123',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#curatelist',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.uri must be a non-empty string'),
          ),
        ),
      );
    });

    test('fromJson throws FormatException when uri is empty', () {
      final json = {
        'uri': '',
        'cid': 'bafyreiabc123',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#curatelist',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.uri must be a non-empty string'),
          ),
        ),
      );
    });

    test('fromJson throws FormatException when cid is missing', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#curatelist',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.cid must be a non-empty string'),
          ),
        ),
      );
    });

    test('fromJson throws FormatException when name is missing', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'cid': 'bafyreiabc123',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'purpose': 'app.bsky.graph.defs#curatelist',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.name must be a non-empty string'),
          ),
        ),
      );
    });

    test('fromJson throws FormatException when purpose is missing', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'cid': 'bafyreiabc123',
        'creator': {'did': 'did:plc:abc123', 'handle': 'creator.bsky.social'},
        'name': 'Test List',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.purpose must be a non-empty string'),
          ),
        ),
      );
    });

    test('fromJson throws FormatException when creator is not a Map', () {
      final json = {
        'uri': 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        'cid': 'bafyreiabc123',
        'creator': 'not a map',
        'name': 'Test List',
        'purpose': 'app.bsky.graph.defs#curatelist',
      };

      expect(
        () => ListView.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('ListView.creator must be a Map'),
          ),
        ),
      );
    });

    test('equality is based on uri', () {
      const list1 = ListView(
        uri: 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        cid: 'bafyreiabc123',
        creator: ActorBasic(did: 'did:plc:abc123', handle: 'creator.bsky.social'),
        name: 'Test List',
        purpose: 'app.bsky.graph.defs#curatelist',
      );

      const list2 = ListView(
        uri: 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        cid: 'different_cid',
        creator: ActorBasic(did: 'did:plc:xyz789', handle: 'other.bsky.social'),
        name: 'Different Name',
        purpose: 'app.bsky.graph.defs#modlist',
      );

      expect(list1, equals(list2));
      expect(list1.hashCode, equals(list2.hashCode));
    });

    test('inequality when uri differs', () {
      const list1 = ListView(
        uri: 'at://did:plc:abc123/app.bsky.graph.list/testlist',
        cid: 'bafyreiabc123',
        creator: ActorBasic(did: 'did:plc:abc123', handle: 'creator.bsky.social'),
        name: 'Test List',
        purpose: 'app.bsky.graph.defs#curatelist',
      );

      const list2 = ListView(
        uri: 'at://did:plc:abc123/app.bsky.graph.list/different',
        cid: 'bafyreiabc123',
        creator: ActorBasic(did: 'did:plc:abc123', handle: 'creator.bsky.social'),
        name: 'Test List',
        purpose: 'app.bsky.graph.defs#curatelist',
      );

      expect(list1, isNot(equals(list2)));
    });
  });
}
