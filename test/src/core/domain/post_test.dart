import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/post.dart';

void main() {
  group('Author', () {
    test('fromJson parses API response correctly', () {
      final json = {
        'did': 'did:plc:test123',
        'handle': 'testuser.bsky.social',
        'displayName': 'Test User',
        'avatar': 'https://example.com/avatar.jpg',
      };

      final author = Author.fromJson(json);

      expect(author.did, 'did:plc:test123');
      expect(author.handle, 'testuser.bsky.social');
      expect(author.displayName, 'Test User');
      expect(author.avatar, 'https://example.com/avatar.jpg');
    });

    test('fromJson handles missing optional fields', () {
      final json = {'did': 'did:plc:test123', 'handle': 'testuser.bsky.social'};

      final author = Author.fromJson(json);

      expect(author.did, 'did:plc:test123');
      expect(author.handle, 'testuser.bsky.social');
      expect(author.displayName, isNull);
      expect(author.avatar, isNull);
    });

    test('equality compares all fields', () {
      const author1 = Author(
        did: 'did:plc:test123',
        handle: 'test.bsky',
        displayName: 'Test',
        avatar: 'https://example.com/a.jpg',
      );
      const author2 = Author(
        did: 'did:plc:test123',
        handle: 'test.bsky',
        displayName: 'Test',
        avatar: 'https://example.com/a.jpg',
      );
      const author3 = Author(did: 'did:plc:different', handle: 'test.bsky');

      expect(author1, equals(author2));
      expect(author1, isNot(equals(author3)));
    });
  });

  group('Post', () {
    test('fromJson parses API response correctly', () {
      final json = {
        'uri': 'at://did:plc:user1/app.bsky.feed.post/1',
        'cid': 'cid123',
        'author': {
          'did': 'did:plc:user1',
          'handle': 'testuser.bsky.social',
          'displayName': 'Test User',
          'avatar': 'https://example.com/avatar.jpg',
        },
        'record': {'text': 'Hello world!', r'$type': 'app.bsky.feed.post'},
        'embed': {r'$type': 'app.bsky.embed.images#view', 'images': []},
        'indexedAt': '2024-01-01T12:00:00.000Z',
        'replyCount': 5,
        'repostCount': 10,
        'likeCount': 25,
      };

      final post = Post.fromJson(json);

      expect(post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
      expect(post.cid, 'cid123');
      expect(post.author.did, 'did:plc:user1');
      expect(post.author.handle, 'testuser.bsky.social');
      expect(post.text, 'Hello world!');
      expect(post.indexedAt, DateTime.utc(2024, 1, 1, 12, 0, 0));
      expect(post.replyCount, 5);
      expect(post.repostCount, 10);
      expect(post.likeCount, 25);
      expect(post.embed, isNotNull);
      expect(post.record, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'uri': 'at://did:plc:user1/app.bsky.feed.post/1',
        'cid': 'cid123',
        'author': {'did': 'did:plc:user1', 'handle': 'testuser.bsky.social'},
        'record': {'text': 'Hello world!'},
      };

      final post = Post.fromJson(json);

      expect(post.uri, 'at://did:plc:user1/app.bsky.feed.post/1');
      expect(post.text, 'Hello world!');
      expect(post.indexedAt, isNull);
      expect(post.replyCount, 0);
      expect(post.repostCount, 0);
      expect(post.likeCount, 0);
      expect(post.embed, isNull);
    });

    test('fromJson handles null record text', () {
      final json = {
        'uri': 'at://did:plc:user1/app.bsky.feed.post/1',
        'cid': 'cid123',
        'author': {'did': 'did:plc:user1', 'handle': 'testuser.bsky.social'},
        'record': {'images': []},
      };

      final post = Post.fromJson(json);
      expect(post.text, '');
    });

    test('equality compares by uri and cid', () {
      const post1 = Post(
        uri: 'at://did:plc:user1/app.bsky.feed.post/1',
        cid: 'cid123',
        author: Author(did: 'did1', handle: 'handle1'),
        text: 'Hello',
      );
      const post2 = Post(
        uri: 'at://did:plc:user1/app.bsky.feed.post/1',
        cid: 'cid123',
        author: Author(did: 'did1', handle: 'different'),
        text: 'Different text',
        likeCount: 100,
      );
      const post3 = Post(
        uri: 'at://did:plc:user1/app.bsky.feed.post/2',
        cid: 'cid456',
        author: Author(did: 'did1', handle: 'handle1'),
        text: 'Hello',
      );

      expect(post1, equals(post2));
      expect(post1, isNot(equals(post3)));
    });

    test('hashCode is consistent for equal posts', () {
      const post1 = Post(
        uri: 'at://did:plc:user1/app.bsky.feed.post/1',
        cid: 'cid123',
        author: Author(did: 'did1', handle: 'handle1'),
        text: 'Hello',
      );
      const post2 = Post(
        uri: 'at://did:plc:user1/app.bsky.feed.post/1',
        cid: 'cid123',
        author: Author(did: 'did1', handle: 'different'),
        text: 'Different text',
      );

      expect(post1.hashCode, equals(post2.hashCode));
    });
  });
}
