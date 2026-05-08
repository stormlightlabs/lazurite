import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/error_reporting/crash_report_bundle.dart';
import 'package:lazurite/core/error_reporting/crash_report_screen.dart';

void main() {
  CrashReportBundle reportFor(FlutterErrorDetails details) => CrashReportBundle(
    generatedAt: DateTime.utc(2026, 5, 8, 12),
    error: details.exceptionAsString(),
    stackTrace: '#0 BrokenWidget.build',
    library: 'widgets library',
    context: 'building BrokenWidget',
    information: const ['route=/profile'],
    relevantLogs: '[FATAL] Flutter fatal error',
  );

  Widget buildSubject({required FlutterErrorDetails details, CrashReportEmailLauncher? emailLauncher}) {
    return MaterialApp(
      home: Scaffold(
        body: CrashReportScreen(
          details: details,
          reportBuilder: (details) async => reportFor(details),
          emailLauncher: emailLauncher,
        ),
      ),
    );
  }

  group('CrashReportScreen', () {
    testWidgets('renders copyable crash details with stack trace and logs', (tester) async {
      await tester.pumpWidget(buildSubject(details: FlutterErrorDetails(exception: Exception('screen failed'))));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Copy report'), findsOneWidget);
      expect(find.text('Email report'), findsOneWidget);
      expect(find.textContaining('Exception: screen failed'), findsAtLeastNWidgets(1));
      expect(find.textContaining('#0 BrokenWidget.build'), findsOneWidget);
      expect(find.textContaining('[FATAL] Flutter fatal error'), findsOneWidget);
      expect(find.byType(SelectableText), findsNWidgets(3));
    });

    testWidgets('email action opens a mailto URL to support with the report body', (tester) async {
      final launchedUris = <Uri>[];

      await tester.pumpWidget(
        buildSubject(
          details: FlutterErrorDetails(exception: Exception('screen failed')),
          emailLauncher: (uri) async {
            launchedUris.add(uri);
            return true;
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Email report'));
      await tester.pump();

      expect(launchedUris, hasLength(1));
      expect(launchedUris.single.scheme, 'mailto');
      expect(launchedUris.single.path, CrashReportScreen.supportEmail);
      expect(launchedUris.single.queryParameters['subject'], 'Lazurite crash report');
      expect(launchedUris.single.queryParameters['body'], contains('#0 BrokenWidget.build'));
      expect(launchedUris.single.queryParameters['body'], contains('[FATAL] Flutter fatal error'));
    });
  });
}
