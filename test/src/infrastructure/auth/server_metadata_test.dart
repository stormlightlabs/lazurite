import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';

void main() {
  group('ServerMetadata HTTPS Validation', () {
    const validIssuer = 'https://example.com';
    const validAuth = 'https://example.com/oauth/authorize';
    const validToken = 'https://example.com/oauth/token';

    test('accepts valid HTTPS URLs', () {
      const metadata = ServerMetadata(
        issuer: validIssuer,
        authorizationEndpoint: validAuth,
        tokenEndpoint: validToken,
      );
      expect(() => metadata.validateRequirements(), returnsNormally);
    });

    test('accepts localhost with HTTP', () {
      const metadata = ServerMetadata(
        issuer: 'http://localhost:8080',
        authorizationEndpoint: 'http://localhost:8080/auth',
        tokenEndpoint: 'http://localhost:8080/token',
      );
      expect(() => metadata.validateRequirements(), returnsNormally);
    });

    test('accepts 127.0.0.1 with HTTP', () {
      const metadata = ServerMetadata(
        issuer: 'http://127.0.0.1:8080',
        authorizationEndpoint: 'http://127.0.0.1:8080/auth',
        tokenEndpoint: 'http://127.0.0.1:8080/token',
      );
      expect(() => metadata.validateRequirements(), returnsNormally);
    });

    test('rejects HTTP for non-local issuer', () {
      const metadata = ServerMetadata(
        issuer: 'http://example.com',
        authorizationEndpoint: validAuth,
        tokenEndpoint: validToken,
      );
      expect(() => metadata.validateRequirements(), throwsException);
    });

    test('rejects HTTP for non-local authorization endpoint', () {
      const metadata = ServerMetadata(
        issuer: validIssuer,
        authorizationEndpoint: 'http://example.com/auth',
        tokenEndpoint: validToken,
      );
      expect(() => metadata.validateRequirements(), throwsException);
    });

    test('rejects HTTP for non-local token endpoint', () {
      const metadata = ServerMetadata(
        issuer: validIssuer,
        authorizationEndpoint: validAuth,
        tokenEndpoint: 'http://example.com/token',
      );
      expect(() => metadata.validateRequirements(), throwsException);
    });

    test('rejects HTTP for non-local PAR endpoint', () {
      const metadata = ServerMetadata(
        issuer: validIssuer,
        authorizationEndpoint: validAuth,
        tokenEndpoint: validToken,
        pushedAuthorizationRequestEndpoint: 'http://example.com/par',
      );
      expect(() => metadata.validateRequirements(), throwsException);
    });

    test('rejects HTTP for non-local revocation endpoint', () {
      const metadata = ServerMetadata(
        issuer: validIssuer,
        authorizationEndpoint: validAuth,
        tokenEndpoint: validToken,
        revocationEndpoint: 'http://example.com/revoke',
      );
      expect(() => metadata.validateRequirements(), throwsException);
    });
  });
}
