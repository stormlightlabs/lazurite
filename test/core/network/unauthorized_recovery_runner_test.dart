import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:poptart_core/poptart_core.dart' show UnauthorizedException;

import '../../helpers/fixtures/auth.dart';
import '../../helpers/fixtures/network.dart';

void main() {
  group('UnauthorizedRecoveryRunner', () {
    test('does not rebuild client when recovered tokens are for a different DID', () async {
      final runner = UnauthorizedRecoveryRunner<_Client>(
        initialClient: const _Client('initial'),
        onUnauthorized: () async => testAuthTokens(did: 'did:plc:other'),
        clientFactory: (tokens) => _Client(tokens.did),
        expectedDid: 'did:plc:expected',
      );

      await expectLater(
        runner.run<String>((client) async => throw testUnauthorizedException('app.bsky.feed.getTimeline')),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(runner.client.id, 'initial');
    });

    test('rebuilds client and retries when recovered tokens match expected DID', () async {
      final runner = UnauthorizedRecoveryRunner<_Client>(
        initialClient: const _Client('initial'),
        onUnauthorized: () async => testAuthTokens(did: 'did:plc:expected'),
        clientFactory: (tokens) => _Client(tokens.did),
        expectedDid: 'did:plc:expected',
      );
      var calls = 0;

      final result = await runner.run<String>((client) async {
        calls += 1;
        if (calls == 1) {
          throw testUnauthorizedException('app.bsky.feed.getTimeline');
        }
        return client.id;
      });

      expect(result, 'did:plc:expected');
      expect(calls, 2);
    });
  });
}

class _Client {
  const _Client(this.id);

  final String id;
}
