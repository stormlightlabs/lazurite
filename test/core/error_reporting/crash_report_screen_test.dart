import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/error_reporting/crash_report_bundle.dart';
import 'package:lazurite/core/error_reporting/crash_report_screen.dart';

void main() {
  CrashReportBundle reportFor(FlutterErrorDetails details, {String stackTrace = '#0 BrokenWidget.build'}) =>
      CrashReportBundle(
        generatedAt: DateTime.utc(2026, 5, 8, 12),
        error: details.exceptionAsString(),
        stackTrace: stackTrace,
        library: 'widgets library',
        context: 'building BrokenWidget',
        information: const ['route=/profile'],
        relevantLogs: '[FATAL] Flutter fatal error',
      );

  Widget buildSubject({
    required FlutterErrorDetails details,
    CrashReportBuilder? reportBuilder,
    CrashReportEmailLauncher? emailLauncher,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CrashReportScreen(
          details: details,
          reportBuilder: reportBuilder ?? (details) async => reportFor(details),
          emailLauncher: emailLauncher,
        ),
      ),
    );
  }

  group('CrashReportScreen', () {
    testWidgets('renders copyable crash details with stack trace and logs', (tester) async {
      await tester.pumpWidget(buildSubject(details: FlutterErrorDetails(exception: Exception('screen failed'))));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Copy report'), findsOneWidget);
      expect(find.text('Email report'), findsOneWidget);
      expect(find.textContaining('Exception: screen failed'), findsAtLeastNWidgets(1));
      expect(find.textContaining('#0 BrokenWidget.build'), findsOneWidget);
      expect(find.textContaining('[FATAL] Flutter fatal error'), findsOneWidget);
      expect(find.byType(SelectableText), findsNWidgets(3));
    });

    testWidgets('email action opens a compact mailto URL to support', (tester) async {
      final launchedUris = <Uri>[];

      await tester.pumpWidget(
        buildSubject(
          details: FlutterErrorDetails(exception: Exception('screen failed')),
          reportBuilder: (details) async =>
              reportFor(details, stackTrace: '#0 BrokenWidget.build\n${List.filled(6000, 'frame').join('\n')}'),
          emailLauncher: (uri) async {
            launchedUris.add(uri);
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Email report'));
      await tester.pump();

      expect(launchedUris, hasLength(1));
      expect(launchedUris.single.scheme, 'mailto');
      expect(launchedUris.single.path, CrashReportScreen.supportEmail);
      expect(launchedUris.single.queryParameters['subject'], 'Lazurite crash report');
      expect(launchedUris.single.queryParameters['body'], contains('#0 BrokenWidget.build'));
      expect(launchedUris.single.queryParameters['body'], contains('[Stack trace truncated for email]'));
      expect(launchedUris.single.queryParameters['body'], isNot(contains('[FATAL] Flutter fatal error')));
      expect(launchedUris.single.toString().length, lessThan(7000));
    });

    testWidgets('report generation errors render a minimal report with retry', (tester) async {
      var attempts = 0;

      await tester.pumpWidget(
        buildSubject(
          details: FlutterErrorDetails(
            exception: Exception('screen failed'),
            stack: StackTrace.fromString('#0 BrokenWidget.build'),
          ),
          reportBuilder: (_) async {
            attempts += 1;
            throw Exception('log read failed');
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Some report details could not be loaded. A minimal report is still available.'),
        findsOneWidget,
      );
      expect(find.text('Copy report'), findsOneWidget);
      expect(find.text('Email report'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('#0 BrokenWidget.build'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
    });
  });
}
