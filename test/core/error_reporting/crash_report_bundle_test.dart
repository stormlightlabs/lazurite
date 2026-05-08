import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/error_reporting/crash_report_bundle.dart';

void main() {
  group('CrashReportBundle', () {
    test('includes error, stack trace, diagnostics, platform, and redacted relevant logs', () async {
      final tempDir = await Directory.systemTemp.createTemp('lazurite_crash_report_test_');
      final logFile = File('${tempDir.path}/lazurite_2026-05-08.log');
      await logFile.writeAsString(
        '[I] TIME: 2026-05-08T10:00:00.000 App started\n'
        '[E] TIME: 2026-05-08T10:01:00.000 Failed url=/oauth/callback?code=abc&state=xyz\n',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final details = FlutterErrorDetails(
        exception: StateError('boom access_token=secret'),
        stack: StackTrace.fromString('#0 main (file:///app/main.dart:1:1)'),
        library: 'widgets library',
        context: ErrorDescription('building ProfileScreen'),
        informationCollector: () => [ErrorDescription('route token=hidden')],
      );

      final report = await CrashReportBundle.fromFlutterErrorDetails(
        details,
        todaysLogFileProvider: () async => logFile,
        generatedAt: DateTime.utc(2026, 5, 8, 12),
      );

      expect(report.error, contains('Bad state: boom access_token: [REDACTED]'));
      expect(report.stackTrace, contains('#0 main'));
      expect(report.library, 'widgets library');
      expect(report.context, 'building ProfileScreen');
      expect(report.information.single, 'route token: [REDACTED]');
      expect(report.relevantLogs, contains('App started'));
      expect(report.relevantLogs, contains('code=[REDACTED]'));
      expect(report.relevantLogs, contains('state=[REDACTED]'));
      expect(report.relevantLogs, isNot(contains('abc')));
      expect(report.relevantLogs, isNot(contains('xyz')));
      expect(report.copyText, contains('Platform:'));
      expect(report.copyText, contains('Generated: 2026-05-08T12:00:00.000Z'));
    });

    test('tails long log files to the latest relevant lines', () async {
      final tempDir = await Directory.systemTemp.createTemp('lazurite_crash_report_tail_test_');
      final logFile = File('${tempDir.path}/lazurite_2026-05-08.log');
      await logFile.writeAsString(List.generate(200, (index) => '[I] line $index').join('\n'));
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final report = await CrashReportBundle.fromFlutterErrorDetails(
        FlutterErrorDetails(exception: Exception('boom'), stack: StackTrace.empty),
        todaysLogFileProvider: () async => logFile,
      );

      expect(report.relevantLogs, isNot(contains('[I] line 0')));
      expect(report.relevantLogs, contains('[I] line 199'));
      expect(report.relevantLogs.split('\n'), hasLength(CrashReportBundle.maxLogLines));
    });
  });
}
