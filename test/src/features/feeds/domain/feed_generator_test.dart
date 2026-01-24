import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';

void main() {
  group('ActorBasic', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'did': 'did:plc:test123',
        'handle': 'user.test',
        'displayName': 'Test User',
        'avatar': 'https://example.com/avatar.jpg',
        'description': 'A test user',
        'indexedAt': '2024-01-01T00:00:00Z',
        'followersCount': 100,
        'followsCount': 50,
        'postsCount': 25,
      };

      final actor = ActorBasic.fromJson(json);

      expect(actor.did, 'did:plc:test123');
      expect(actor.handle, 'user.test');
      expect(actor.displayName, 'Test User');
      expect(actor.avatar, 'https://example.com/avatar.jpg');
      expect(actor.description, 'A test user');
      expect(actor.followersCount, 100);
      expect(actor.followsCount, 50);
      expect(actor.postsCount, 25);
      expect(actor.indexedAt, isNotNull);
    });

    test('fromJson handles minimal JSON', () {
      final json = {'did': 'did:plc:test123', 'handle': 'user.test'};

      final actor = ActorBasic.fromJson(json);

      expect(actor.did, 'did:plc:test123');
      expect(actor.handle, 'user.test');
      expect(actor.displayName, isNull);
      expect(actor.avatar, isNull);
      expect(actor.description, isNull);
      expect(actor.followersCount, isNull);
      expect(actor.followsCount, isNull);
      expect(actor.postsCount, isNull);
      expect(actor.indexedAt, isNull);
    });

    test('fromJson throws on missing did', () {
      final json = {'handle': 'user.test'};

      expect(() => ActorBasic.fromJson(json), throwsA(isA<Error>()));
    });

    test('fromJson throws on missing handle', () {
      final json = {'did': 'did:plc:test123'};

      expect(() => ActorBasic.fromJson(json), throwsA(isA<Error>()));
    });

    test('fromJson throws on invalid did type', () {
      final json = {'did': 123, 'handle': 'user.test'};

      expect(() => ActorBasic.fromJson(json), throwsA(isA<Error>()));
    });
  });

  group('FeedGenerator', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'uri': 'at://did:plc:creator123/app.bsky.feed.generator/test-feed',
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'description': 'A test feed',
        'avatar': 'https://example.com/feed-avatar.jpg',
        'likeCount': 42,
        'indexedAt': '2024-01-01T00:00:00Z',
        'creator': {
          'did': 'did:plc:creator123',
          'handle': 'creator.test',
          'displayName': 'Feed Creator',
        },
      };

      final feedGenerator = FeedGenerator.fromJson(json);

      expect(feedGenerator.uri, 'at://did:plc:creator123/app.bsky.feed.generator/test-feed');
      expect(feedGenerator.cid, 'bafytest123');
      expect(feedGenerator.did, 'did:web:feedgen.test');
      expect(feedGenerator.displayName, 'Test Feed');
      expect(feedGenerator.description, 'A test feed');
      expect(feedGenerator.avatar, 'https://example.com/feed-avatar.jpg');
      expect(feedGenerator.likeCount, 42);
      expect(feedGenerator.indexedAt, isNotNull);
      expect(feedGenerator.creator.did, 'did:plc:creator123');
      expect(feedGenerator.creator.handle, 'creator.test');
    });

    test('fromJson handles minimal JSON', () {
      final json = {
        'uri': 'at://did:plc:creator123/app.bsky.feed.generator/test-feed',
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'creator': {'did': 'did:plc:creator123', 'handle': 'creator.test'},
      };

      final feedGenerator = FeedGenerator.fromJson(json);

      expect(feedGenerator.uri, 'at://did:plc:creator123/app.bsky.feed.generator/test-feed');
      expect(feedGenerator.displayName, 'Test Feed');
      expect(feedGenerator.description, isNull);
      expect(feedGenerator.avatar, isNull);
      expect(feedGenerator.likeCount, isNull);
      expect(feedGenerator.indexedAt, isNull);
    });

    test('fromJson throws on missing uri', () {
      final json = {
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'creator': {'did': 'did:plc:creator123', 'handle': 'creator.test'},
      };

      expect(() => FeedGenerator.fromJson(json), throwsA(isA<Error>()));
    });

    test('fromJson throws on missing displayName', () {
      final json = {
        'uri': 'at://did:plc:creator123/app.bsky.feed.generator/test-feed',
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'creator': {'did': 'did:plc:creator123', 'handle': 'creator.test'},
      };

      expect(() => FeedGenerator.fromJson(json), throwsA(isA<Error>()));
    });

    test('fromJson throws on invalid creator type', () {
      final json = {
        'uri': 'at://did:plc:creator123/app.bsky.feed.generator/test-feed',
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'creator': 'not-a-map',
      };

      expect(() => FeedGenerator.fromJson(json), throwsA(isA<Error>()));
    });

    test('fromJson throws on missing creator', () {
      final json = {
        'uri': 'at://did:plc:creator123/app.bsky.feed.generator/test-feed',
        'cid': 'bafytest123',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
      };

      expect(() => FeedGenerator.fromJson(json), throwsA(isA<Error>()));
    });
  });
}
