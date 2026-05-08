import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_file_log_printer.dart';
import 'package:lazurite/core/logging/daily_log_file_output.dart';

void main() {
  group('DailyLogFileOutput', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('lazurite_logs_test_');
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('writes logs to a daily file in the target directory', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path);
      final logger = Logger(
        filter: ProductionFilter(),
        printer: AppFileLogPrinter(),
        output: output,
        level: Level.trace,
      );
      await logger.init;

      logger.i('AppLogger: App started', time: DateTime(2026, 3, 16, 14, 32, 1, 123));
      await logger.close();

      final file = File(
        '${tempDirectory.path}/${DailyLogFileOutput.fileNameFor(DateTime(2026, 3, 16, 14, 32, 1, 123))}',
      );
      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), contains('[I] TIME: 2026-03-16T14:32:01.123 AppLogger: App started'));
    });

    test('clears all log files', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path);
      await output.init();

      final logFile = File('${tempDirectory.path}/lazurite_2026-03-16.log');
      await logFile.writeAsString('test');

      await output.clearAllLogs();

      expect(await logFile.exists(), isFalse);
    });

    test('removes files older than retention window', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path, retentionDays: 3);
      await output.init();

      final staleFile = File('${tempDirectory.path}/lazurite_2026-03-12.log');
      final keptFile = File('${tempDirectory.path}/lazurite_2026-03-14.log');
      await staleFile.writeAsString('old');
      await keptFile.writeAsString('keep');

      await output.cleanupOldLogs(referenceTime: DateTime(2026, 3, 16, 12));

      expect(await staleFile.exists(), isFalse);
      expect(await keptFile.exists(), isTrue);
    });

    test('trims oldest entries when the daily file reaches its size cap', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path, maxFileBytes: 420);
      final logger = Logger(
        filter: ProductionFilter(),
        printer: AppFileLogPrinter(),
        output: output,
        level: Level.trace,
      );
      await logger.init;

      for (var index = 0; index < 12; index += 1) {
        logger.i(
          'AppLogger: bounded entry $index ${List.filled(48, 'x').join()}',
          time: DateTime(2026, 3, 16, 14, 32, index),
        );
      }
      await logger.close();

      final file = File('${tempDirectory.path}/${DailyLogFileOutput.fileNameFor(DateTime(2026, 3, 16))}');
      final content = await file.readAsString();
      expect(await file.length(), lessThanOrEqualTo(420));
      expect(content, contains('Older log entries trimmed'));
      expect(content, isNot(contains('bounded entry 0')));
      expect(content, contains('bounded entry 11'));
    });

    test('bounds a single oversized log event', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path, maxFileBytes: 260);
      final logger = Logger(
        filter: ProductionFilter(),
        printer: AppFileLogPrinter(),
        output: output,
        level: Level.trace,
      );
      await logger.init;

      logger.e('AppLogger: ${List.filled(1000, 'x').join()}', time: DateTime(2026, 3, 16, 14, 32));
      await logger.close();

      final file = File('${tempDirectory.path}/${DailyLogFileOutput.fileNameFor(DateTime(2026, 3, 16))}');
      expect(await file.length(), lessThanOrEqualTo(260));
      expect(await file.readAsString(), contains('x'));
    });

    test('keeps file within cap when the trim marker and incoming event compete for a tiny budget', () async {
      final output = DailyLogFileOutput(directoryPath: tempDirectory.path, maxFileBytes: 64);
      final logger = Logger(
        filter: ProductionFilter(),
        printer: AppFileLogPrinter(),
        output: output,
        level: Level.trace,
      );
      await logger.init;

      for (var index = 0; index < 6; index += 1) {
        logger.w('AppLogger: tiny cap entry $index ${List.filled(80, 'y').join()}');
      }
      await logger.close();

      final file = File('${tempDirectory.path}/${DailyLogFileOutput.fileNameFor(DateTime.now())}');
      expect(await file.length(), lessThanOrEqualTo(64));
    });
  });
}
