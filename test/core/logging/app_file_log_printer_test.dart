import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_file_log_printer.dart';

void main() {
  group('AppFileLogPrinter', () {
    test('prints one-line log entries with time, source, error, and stack trace', () {
      final printer = AppFileLogPrinter();
      final lines = printer.log(
        LogEvent(
          Level.error,
          'FeedBloc: Failed to decode feed post',
          time: DateTime(2026, 3, 16, 14, 32, 5, 220),
          error: StateError('boom'),
          stackTrace: StackTrace.fromString('#0 FeedBloc.load\n#1 main'),
        ),
      );

      expect(lines, hasLength(1));
      expect(lines.single, contains('[E] TIME: 2026-03-16T14:32:05.220'));
      expect(lines.single, contains('FeedBloc: Failed to decode feed post'));
      expect(lines.single, contains('ERROR: Bad state: boom'));
      expect(lines.single, contains('STACK: #0 FeedBloc.load | #1 main'));
    });

    test('uses fatal label for fatal logs', () {
      final printer = AppFileLogPrinter();
      final lines = printer.log(
        LogEvent(Level.fatal, 'AppLogger: Unhandled exception in zone', time: DateTime(2026, 3, 16, 14, 32, 12, 450)),
      );

      expect(lines.single, startsWith('[FATAL] TIME: 2026-03-16T14:32:12.450'));
    });

    test('redacts secrets while preserving handle and DID context', () {
      final printer = AppFileLogPrinter();
      const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6cGxjOnRlc3QifQ.signaturevaluehere12345';
      final lines = printer.log(
        LogEvent(
          Level.info,
          'AuthRepository: OAuth callback for did:plc:ewvi7nxzyoun6zhxrhs64oiz '
          'handle user.bsky.social redirect /oauth/callback?code=abc123&state=xyz '
          'token $jwt',
          time: DateTime(2026, 3, 16, 14, 32, 12, 450),
        ),
      );

      expect(lines.single, contains('did:plc:ewvi7nxzyoun6zhxrhs64oiz'));
      expect(lines.single, contains('user.bsky.social'));
      expect(lines.single, isNot(contains(jwt)));
      expect(lines.single, isNot(contains('code=abc123')));
      expect(lines.single, isNot(contains('state=xyz')));
      expect(lines.single, contains('[REDACTED_JWT]'));
      expect(lines.single, contains('code=[REDACTED]'));
      expect(lines.single, contains('state=[REDACTED]'));
    });

    test('redacts sensitive values in structured map logs', () {
      final printer = AppFileLogPrinter();
      final lines = printer.log(
        LogEvent(Level.info, {
          'access_token': 'token123',
          'refresh_token': 'refresh456',
          'dpop_public_key': 'pubkey',
          'dpop_private_key': 'privkey',
        }, time: DateTime(2026, 3, 16, 14, 32, 12, 450)),
      );

      expect(lines.single, contains('"access_token":"[REDACTED]"'));
      expect(lines.single, contains('"refresh_token":"[REDACTED]"'));
      expect(lines.single, contains('"dpop_public_key":"[REDACTED]"'));
      expect(lines.single, contains('"dpop_private_key":"[REDACTED]"'));
      expect(lines.single, isNot(contains('token123')));
      expect(lines.single, isNot(contains('refresh456')));
      expect(lines.single, isNot(contains('pubkey')));
      expect(lines.single, isNot(contains('privkey')));
    });
  });
}
