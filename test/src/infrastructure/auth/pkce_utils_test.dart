import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/pkce_utils.dart';

void main() {
  group('PkceUtils', () {
    group('generateVerifier', () {
      test('produces verifier within valid length range (43-128)', () {
        final verifier = PkceUtils.generateVerifier();
        expect(verifier.length, greaterThanOrEqualTo(43));
        expect(verifier.length, lessThanOrEqualTo(128));
      });

      test('produces unique verifiers on each call', () {
        final verifier1 = PkceUtils.generateVerifier();
        final verifier2 = PkceUtils.generateVerifier();
        expect(verifier1, isNot(equals(verifier2)));
      });

      test('produces verifiers containing only valid characters', () {
        final validChars = RegExp(r'^[a-zA-Z0-9\-._~]+$');
        final verifier = PkceUtils.generateVerifier();
        expect(verifier, matches(validChars));
      });

      test('produces verifiers with reasonable length distribution', () {
        final lengths = <int>{};
        for (var i = 0; i < 20; i++) {
          final verifier = PkceUtils.generateVerifier();
          lengths.add(verifier.length);
        }

        expect(lengths.length, greaterThan(1));
      });
    });

    group('generateChallenge', () {
      test('produces valid base64url-encoded SHA256 hash', () {
        const verifier = 'test_verifier_value';
        final challenge = PkceUtils.generateChallenge(verifier);

        expect(challenge, isNot(contains('=')));
        expect(challenge, isNot(contains('+')));
        expect(challenge, isNot(contains('/')));

        final bytes = utf8.encode(verifier);
        final digest = sha256.convert(bytes);
        final expected = base64Url.encode(digest.bytes).replaceAll('=', '');
        expect(challenge, equals(expected));
      });

      test('produces deterministic output for same input', () {
        const verifier = 'deterministic_test';
        final challenge1 = PkceUtils.generateChallenge(verifier);
        final challenge2 = PkceUtils.generateChallenge(verifier);
        expect(challenge1, equals(challenge2));
      });

      test('produces different challenges for different verifiers', () {
        final challenge1 = PkceUtils.generateChallenge('verifier1');
        final challenge2 = PkceUtils.generateChallenge('verifier2');
        expect(challenge1, isNot(equals(challenge2)));
      });

      test('handles empty string verifier', () {
        final challenge = PkceUtils.generateChallenge('');
        expect(challenge.isNotEmpty, isTrue);
        expect(challenge, matches(RegExp(r'^[a-zA-Z0-9_-]+$')));
      });

      test('handles special characters in verifier', () {
        const verifier = 'test-with_special.chars~123';
        final challenge = PkceUtils.generateChallenge(verifier);
        expect(challenge, isNotEmpty);
        expect(challenge, matches(RegExp(r'^[a-zA-Z0-9_-]+$')));
      });

      test('roundtrip: verifier → challenge is one-way', () {
        final verifier = PkceUtils.generateVerifier();
        final challenge = PkceUtils.generateChallenge(verifier);

        expect(challenge, isNot(equals(verifier)));

        final challenge2 = PkceUtils.generateChallenge(verifier);
        expect(challenge, equals(challenge2));
      });
    });
  });
}
