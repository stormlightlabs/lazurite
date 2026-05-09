import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/features/logs/data/log_entry.dart';

void main() {
  group('LogEntry', () {
    group('tryParse', () {
      test('parses simple log line with level prefix', () {
        final entry = LogEntry.tryParse('[I] This is an info message');
        expect(entry, isNotNull);
        expect(entry!.level, Level.info);
        expect(entry.message, 'This is an info message');
      });

      test('parses log line with all level prefixes', () {
        final levels = {
          'T': Level.trace,
          'D': Level.debug,
          'I': Level.info,
          'W': Level.warning,
          'E': Level.error,
          'F': Level.fatal,
        };

        for (final entry in levels.entries) {
          final logEntry = LogEntry.tryParse('[${entry.key}] Message');
          expect(logEntry, isNotNull, reason: 'Failed to parse [${entry.key}]');
          expect(logEntry!.level, entry.value, reason: 'Wrong level for [${entry.key}]');
        }
      });

      test('parses log line with source prefix', () {
        final entry = LogEntry.tryParse('[I] AuthBloc: User logged in');
        expect(entry, isNotNull);
        expect(entry!.level, Level.info);
        expect(entry.message, 'User logged in');
        expect(entry.source, 'AuthBloc');
      });

      test('parses log line with ISO time tag and source prefix', () {
        final entry = LogEntry.tryParse('[I] TIME: 2026-03-16T14:32:01.123 AppLogger: App started');
        expect(entry, isNotNull);
        expect(entry!.level, Level.info);
        expect(entry.source, 'AppLogger');
        expect(entry.message, 'App started');
        expect(entry.formatTimestamp(), '14:32:01.123');
      });

      test('parses fatal log lines written by the file printer', () {
        final entry = LogEntry.tryParse('[FATAL] TIME: 2026-03-16T14:32:12.450 AppLogger: Unhandled exception');
        expect(entry, isNotNull);
        expect(entry!.level, Level.fatal);
        expect(entry.source, 'AppLogger');
        expect(entry.message, 'Unhandled exception');
      });

      test('separates stack traces from the visible message', () {
        final entry = LogEntry.tryParse(
          '[E] TIME: 2026-03-16T14:32:12.450 FeedRepository: feed.cacheWindow failed  '
          'ERROR: cannot commit transaction  '
          'STACK: #0 AppDatabase.transaction | #1 FeedRepository._cacheFeedWindow',
        );

        expect(entry, isNotNull);
        expect(entry!.level, Level.error);
        expect(entry.source, 'FeedRepository');
        expect(entry.message, 'feed.cacheWindow failed  ERROR: cannot commit transaction');
        expect(entry.stackTrace, '#0 AppDatabase.transaction | #1 FeedRepository._cacheFeedWindow');
      });

      test('returns null for empty line', () {
        final entry = LogEntry.tryParse('');
        expect(entry, isNull);
      });

      test('returns null for whitespace-only line', () {
        final entry = LogEntry.tryParse('   ');
        expect(entry, isNull);
      });

      test('creates entry for line without level prefix', () {
        final entry = LogEntry.tryParse('Some random log message');
        expect(entry, isNotNull);
        expect(entry!.level, Level.debug);
        expect(entry.message, 'Some random log message');
      });

      test('redacts secret values while preserving handle and DID context', () {
        final entry = LogEntry.tryParse(
          '[I] AuthRepository: Login for did:plc:ewvi7nxzyoun6zhxrhs64oiz user.bsky.social '
          '/oauth/callback?code=abc123&state=xyz',
        );

        expect(entry, isNotNull);
        expect(entry!.message, contains('did:plc:ewvi7nxzyoun6zhxrhs64oiz'));
        expect(entry.message, contains('user.bsky.social'));
        expect(entry.message, contains('code=[REDACTED]'));
        expect(entry.message, contains('state=[REDACTED]'));
      });
    });

    group('levelPrefix', () {
      test('returns correct prefix for each level', () {
        final prefixes = {
          Level.trace: 'T',
          Level.debug: 'D',
          Level.info: 'I',
          Level.warning: 'W',
          Level.error: 'E',
          Level.fatal: 'F',
        };

        for (final entry in prefixes.entries) {
          final logEntry = LogEntry(timestamp: DateTime.now(), level: entry.key, message: 'test');
          expect(logEntry.levelPrefix, entry.value);
        }
      });
    });

    group('formatTimestamp', () {
      test('formats timestamp correctly', () {
        final timestamp = DateTime(2024, 1, 15, 14, 32, 1, 123);
        final entry = LogEntry(timestamp: timestamp, level: Level.info, message: 'test');
        expect(entry.formatTimestamp(), '14:32:01.123');
      });

      test('pads single digits with zeros', () {
        final timestamp = DateTime(2024, 1, 15, 9, 5, 3, 5);
        final entry = LogEntry(timestamp: timestamp, level: Level.info, message: 'test');
        expect(entry.formatTimestamp(), '09:05:03.005');
      });
    });

    group('copyText', () {
      test('includes the full row and stack trace', () {
        final entry = LogEntry(
          timestamp: DateTime(2026, 5, 9, 10, 15, 30, 125),
          level: Level.error,
          source: 'FeedRepository',
          message: 'feed.cacheWindow failed',
          stackTrace: '#0 AppDatabase.transaction',
        );

        expect(entry.copyText, contains('[ERROR] TIME: 2026-05-09T10:15:30.125'));
        expect(entry.copyText, contains('FeedRepository: feed.cacheWindow failed'));
        expect(entry.copyText, contains('STACK: #0 AppDatabase.transaction'));
      });
    });

    group('equality', () {
      test('entries with same values are equal', () {
        final timestamp = DateTime.now();
        final entry1 = LogEntry(timestamp: timestamp, level: Level.info, message: 'test', source: 'App');
        final entry2 = LogEntry(timestamp: timestamp, level: Level.info, message: 'test', source: 'App');
        expect(entry1, equals(entry2));
      });

      test('entries with different values are not equal', () {
        final timestamp = DateTime.now();
        final entry1 = LogEntry(timestamp: timestamp, level: Level.info, message: 'test');
        final entry2 = LogEntry(timestamp: timestamp, level: Level.error, message: 'test');
        expect(entry1, isNot(equals(entry2)));
      });
    });
  });
}
