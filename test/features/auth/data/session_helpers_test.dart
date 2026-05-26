import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/session_identity.dart';
import 'package:lazurite/features/auth/data/session_recovery.dart';

void main() {
  group('resolveCurrentSessionDid', () {
    test('prefers normalized session DID over OAuth subject', () {
      expect(
        resolveCurrentSessionDid(sessionDid: '  DID:PLC:SESSION  ', oauthSubject: 'did:plc:oauth'),
        'did:plc:session',
      );
    });

    test('falls back to normalized OAuth subject', () {
      expect(resolveCurrentSessionDid(sessionDid: ' ', oauthSubject: '  DID:PLC:OAUTH  '), 'did:plc:oauth');
    });

    test('returns null when both identifiers are empty', () {
      expect(resolveCurrentSessionDid(sessionDid: '', oauthSubject: '  '), isNull);
    });
  });

  group('refreshCurrentAccountSession', () {
    const current = AuthTokens(accessToken: 'old', did: 'did:plc:account', handle: 'alice.test');
    const refreshed = AuthTokens(accessToken: 'new', did: 'did:plc:account', handle: 'alice.test');

    test('stores and returns refreshed tokens for the same account', () async {
      AuthTokens? stored;

      final result = await refreshCurrentAccountSession(
        currentTokens: current,
        accountDid: current.did,
        refresh: (_) async => refreshed,
        onRefreshed: (tokens) => stored = tokens,
      );

      expect(result, refreshed);
      expect(stored, refreshed);
    });

    test('returns null without storing when there are no current tokens', () async {
      var stored = false;

      final result = await refreshCurrentAccountSession(
        currentTokens: null,
        accountDid: current.did,
        refresh: (_) async => refreshed,
        onRefreshed: (_) => stored = true,
      );

      expect(result, isNull);
      expect(stored, isFalse);
    });

    test('rejects refreshed tokens for a different account', () async {
      var stored = false;

      final result = await refreshCurrentAccountSession(
        currentTokens: current,
        accountDid: current.did,
        refresh: (_) async => const AuthTokens(accessToken: 'other', did: 'did:plc:other', handle: 'bob.test'),
        onRefreshed: (_) => stored = true,
      );

      expect(result, isNull);
      expect(stored, isFalse);
    });
  });
}
