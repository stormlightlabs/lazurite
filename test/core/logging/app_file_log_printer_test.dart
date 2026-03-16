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
  });
}
