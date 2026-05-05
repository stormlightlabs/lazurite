import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/logging/log_redactor.dart';

void main() {
  group('LogRedactor', () {
    test('preserves DID and handle identifiers for debugging context', () {
      const input = 'Profile load for did:plc:ewvi7nxzyoun6zhxrhs64oiz @river.bsky.social';
      final output = LogRedactor.redact(input);

      expect(output, contains('did:plc:ewvi7nxzyoun6zhxrhs64oiz'));
      expect(output, contains('@river.bsky.social'));
    });

    test('redacts sensitive query parameter values', () {
      const input = '/oauth/callback?code=abc123&state=xyz&did=did:plc:abc';
      final output = LogRedactor.redact(input);

      expect(output, contains('code=[REDACTED]'));
      expect(output, contains('state=[REDACTED]'));
      expect(output, contains('did=did:plc:abc'));
    });

    test('redacts sensitive key-value pairs and bearer tokens', () {
      const input = 'authorization=Bearer super-secret access_token=token123 app_password=hunter2';
      final output = LogRedactor.redact(input);

      expect(output, isNot(contains('super-secret')));
      expect(output, isNot(contains('token123')));
      expect(output, isNot(contains('hunter2')));
      expect(output, contains('authorization: [REDACTED]'));
      expect(output, contains('access_token: [REDACTED]'));
      expect(output, contains('app_password: [REDACTED]'));
    });

    test('preserves non-sensitive text', () {
      const input = 'NavObserver: Route pushed: /profile/me (from /)';
      final output = LogRedactor.redact(input);
      expect(output, input);
    });
  });
}
