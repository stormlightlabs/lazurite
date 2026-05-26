import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthTokens', () {
    test('should create AuthTokens with all fields', () {
      const tokens = AuthTokens(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        did: 'did:plc:abc123',
        handle: 'user.bsky.social',
        displayName: 'User Name',
        service: 'bsky.social',
        oauthService: 'bsky.social',
        oauthClientId: 'https://lazurite.stormlightlabs.org/client-metadata.json',
      );

      expect(tokens.accessToken, equals('access_token'));
      expect(tokens.refreshToken, equals('refresh_token'));
      expect(tokens.did, equals('did:plc:abc123'));
      expect(tokens.handle, equals('user.bsky.social'));
      expect(tokens.displayName, equals('User Name'));
      expect(tokens.service, equals('bsky.social'));
      expect(tokens.oauthService, equals('bsky.social'));
      expect(tokens.oauthClientId, equals('https://lazurite.stormlightlabs.org/client-metadata.json'));
    });

    test('should create AuthTokens without optional fields', () {
      const tokens = AuthTokens(accessToken: 'access_token', did: 'did:plc:abc123', handle: 'user.bsky.social');

      expect(tokens.accessToken, equals('access_token'));
      expect(tokens.refreshToken, isNull);
      expect(tokens.did, equals('did:plc:abc123'));
      expect(tokens.handle, equals('user.bsky.social'));
      expect(tokens.displayName, isNull);
    });

    test('should copy with new values', () {
      const tokens = AuthTokens(accessToken: 'old_token', did: 'did:plc:abc123', handle: 'user.bsky.social');

      final newTokens = tokens.copyWith(
        accessToken: 'new_token',
        displayName: 'New Name',
        oauthService: 'bsky.social',
        oauthClientId: 'client-id',
      );

      expect(newTokens.accessToken, equals('new_token'));
      expect(newTokens.did, equals('did:plc:abc123'));
      expect(newTokens.displayName, equals('New Name'));
      expect(newTokens.oauthService, equals('bsky.social'));
      expect(newTokens.oauthClientId, equals('client-id'));
    });

    test('should identify oauth-backed sessions', () {
      const tokens = AuthTokens(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        did: 'did:plc:abc123',
        handle: 'user.bsky.social',
        dpopPublicKey: 'public',
        dpopPrivateKey: 'private',
        authMethod: AuthMethod.oauth,
      );

      expect(tokens.usesOAuth, isTrue);
    });

    test('should check if tokens are expired', () {
      final expiredDate = DateTime.now().subtract(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        did: 'did:plc:abc123',
        handle: 'user.bsky.social',
        expiresAt: expiredDate,
      );

      expect(tokens.isExpired, isTrue);
    });

    test('should check if tokens are not expired', () {
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        did: 'did:plc:abc123',
        handle: 'user.bsky.social',
        expiresAt: futureDate,
      );

      expect(tokens.isExpired, isFalse);
    });

    test('should check if tokens without expiry are not expired', () {
      const tokens = AuthTokens(accessToken: 'token', did: 'did:plc:abc123', handle: 'user.bsky.social');

      expect(tokens.isExpired, isFalse);
    });


    test('should support value equality', () {
      const tokens1 = AuthTokens(accessToken: 'token', did: 'did:plc:abc123', handle: 'user.bsky.social');
      const tokens2 = AuthTokens(accessToken: 'token', did: 'did:plc:abc123', handle: 'user.bsky.social');

      expect(tokens1, equals(tokens2));
    });
  });

  group('User', () {
    test('should create User with all fields', () {
      const user = User(
        did: 'did:plc:abc123',
        handle: 'user.bsky.social',
        displayName: 'User Name',
        avatar: 'https://example.com/avatar.jpg',
        description: 'User description',
      );

      expect(user.did, equals('did:plc:abc123'));
      expect(user.handle, equals('user.bsky.social'));
      expect(user.displayName, equals('User Name'));
      expect(user.avatar, equals('https://example.com/avatar.jpg'));
      expect(user.description, equals('User description'));
    });

    test('should create User without optional fields', () {
      const user = User(did: 'did:plc:abc123', handle: 'user.bsky.social');

      expect(user.did, equals('did:plc:abc123'));
      expect(user.handle, equals('user.bsky.social'));
      expect(user.displayName, isNull);
      expect(user.avatar, isNull);
      expect(user.description, isNull);
    });

    test('should copy with new values', () {
      const user = User(did: 'did:plc:abc123', handle: 'user.bsky.social');

      final newUser = user.copyWith(displayName: 'New Name', avatar: 'https://example.com/new-avatar.jpg');

      expect(newUser.did, equals('did:plc:abc123'));
      expect(newUser.displayName, equals('New Name'));
      expect(newUser.avatar, equals('https://example.com/new-avatar.jpg'));
    });

    test('should support value equality', () {
      const user1 = User(did: 'did:plc:abc123', handle: 'user.bsky.social');
      const user2 = User(did: 'did:plc:abc123', handle: 'user.bsky.social');

      expect(user1, equals(user2));
    });
  });
}
