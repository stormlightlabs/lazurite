import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/atproto_identifier.dart';

void main() {
  group('normalizeAtProtoIdentifierForAuth', () {
    test('normalizes did:web casing', () {
      final normalized = normalizeAtProtoIdentifierForAuth('DID:WEB:Example.com');
      expect(normalized, equals('did:web:example.com'));
    });

    test('normalizes did:plc casing', () {
      final normalized = normalizeAtProtoIdentifierForAuth('DID:PLC:EWVI7NXZYOUN6ZHXRHS64OIZ');
      expect(normalized, equals('did:plc:ewvi7nxzyoun6zhxrhs64oiz'));
    });
  });

  group('validateAtProtoIdentifierForAuth', () {
    test('accepts valid did:plc identifier', () {
      final error = validateAtProtoIdentifierForAuth('did:plc:ewvi7nxzyoun6zhxrhs64oiz');
      expect(error, isNull);
    });

    test('accepts known valid did:plc identifiers', () {
      const identifiers = <String>[
        'did:plc:xg2vq45muivyy3xwatcehspu',
        'did:plc:bmw5siutico6v4tmtbj5377q',
        'did:plc:526rjityvizz4ism2ihd77mm',
      ];

      for (final identifier in identifiers) {
        final error = validateAtProtoIdentifierForAuth(identifier);
        expect(error, isNull, reason: '$identifier should be valid');
      }
    });

    test('rejects did:plc identifier with non-base32 digits', () {
      final error = validateAtProtoIdentifierForAuth('did:plc:ewvi7nxzyoun6zhxrhs64oi9');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('accepts valid did:web host', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example.com');
      expect(error, isNull);
    });

    test('accepts did:web localhost with encoded port', () {
      final error = validateAtProtoIdentifierForAuth('did:web:LOCALHOST%3A3000');
      expect(error, isNull);
    });

    test('rejects did:web localhost with encoded port outside development mode', () {
      final error = validateAtProtoIdentifierForAuth('did:web:localhost%3A3000', allowDevelopmentDidWebHosts: false);
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web with single-label non-localhost host', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web values with fragment', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example.com#frag');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web values with whitespace', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example .com');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects path-based did:web in atproto context', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example.com:user:alice');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web values with empty suffix', () {
      final error = validateAtProtoIdentifierForAuth('did:web:');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web with consecutive dots', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example..com');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web with trailing dot', () {
      final error = validateAtProtoIdentifierForAuth('did:web:example.com.');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web label starting with hyphen', () {
      final error = validateAtProtoIdentifierForAuth('did:web:-bad.example.com');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web label ending with hyphen', () {
      final error = validateAtProtoIdentifierForAuth('did:web:bad-.example.com');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });

    test('rejects did:web with disallowed top-level domain', () {
      final error = validateAtProtoIdentifierForAuth('did:web:name.arpa');
      expect(error?.code, equals(AtProtoIdentifierValidationErrorCode.invalidDid));
    });
  });
}
