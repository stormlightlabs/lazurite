import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/recent_auth_recovery_policy.dart';

void main() {
  group('RecentAuthRecoveryPolicy', () {
    late DateTime now;
    late RecentAuthRecoveryPolicy policy;

    AuthTokens tokens({String did = 'did:plc:alice', String accessToken = 'access-1', DateTime? expiresAt}) =>
        AuthTokens(
          accessToken: accessToken,
          refreshToken: 'refresh-1',
          expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 365)),
          did: did,
          handle: 'alice.test',
          authMethod: AuthMethod.oauth,
        );

    setUp(() {
      now = DateTime.utc(2026, 5, 28, 12);
      policy = RecentAuthRecoveryPolicy(now: () => now, reuseWindow: const Duration(minutes: 1));
    });

    test('reuses matching non-expired tokens inside the reuse window', () {
      final refreshed = tokens();
      policy.recordSuccess(refreshed);
      expect(policy.shouldReuse(refreshed), isTrue);
    });

    test('does not reuse when no recovery has been recorded', () {
      expect(policy.shouldReuse(tokens()), isFalse);
    });

    test('does not reuse a different access token for the same DID', () {
      policy.recordSuccess(tokens(accessToken: 'access-1'));
      expect(policy.shouldReuse(tokens(accessToken: 'access-2')), isFalse);
    });

    test('does not reuse a recovery recorded for a different DID', () {
      policy.recordSuccess(tokens(did: 'did:plc:bob'));
      expect(policy.shouldReuse(tokens(did: 'did:plc:alice')), isFalse);
    });

    test('does not reuse tokens after the reuse window', () {
      final refreshed = tokens();
      policy.recordSuccess(refreshed);
      now = now.add(const Duration(minutes: 1, milliseconds: 1));
      expect(policy.shouldReuse(refreshed), isFalse);
    });

    test('does not reuse expired tokens', () {
      final refreshed = tokens(expiresAt: now.subtract(const Duration(minutes: 10)));
      policy.recordSuccess(refreshed);
      expect(policy.shouldReuse(refreshed), isFalse);
    });

    test('clear removes recorded recovery for a DID', () {
      final refreshed = tokens();
      policy.recordSuccess(refreshed);
      policy.clear(refreshed.did);
      expect(policy.shouldReuse(refreshed), isFalse);
    });
  });
}
