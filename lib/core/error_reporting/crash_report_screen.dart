import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/error_reporting/crash_report_bundle.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CrashReportBuilder = Future<CrashReportBundle> Function(FlutterErrorDetails details);
typedef CrashReportEmailLauncher = Future<bool> Function(Uri uri);

class CrashReportScreen extends StatefulWidget {
  const CrashReportScreen({
    super.key,
    required this.details,
    CrashReportBuilder? reportBuilder,
    CrashReportEmailLauncher? emailLauncher,
  }) : _reportBuilder = reportBuilder,
       _emailLauncher = emailLauncher;

  static const String supportEmail = 'info@stormlightlabs.org';

  final FlutterErrorDetails details;
  final CrashReportBuilder? _reportBuilder;
  final CrashReportEmailLauncher? _emailLauncher;

  @override
  State<CrashReportScreen> createState() => _CrashReportScreenState();
}

class _CrashReportScreenState extends State<CrashReportScreen> {
  late Future<CrashReportBundle> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _buildReport();
  }

  Future<CrashReportBundle> _buildReport() {
    final builder = widget._reportBuilder;
    if (builder != null) {
      return builder(widget.details);
    }
    return CrashReportBundle.fromFlutterErrorDetails(widget.details, todaysLogFileProvider: log.getTodaysLogFile);
  }

  Future<void> _copyReport(CrashReportBundle report) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: report.copyText));
    if (!mounted) {
      return;
    }
    messenger?.showSnackBar(const SnackBar(content: Text('Crash report copied')));
  }

  Future<void> _emailReport(CrashReportBundle report) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri(
      scheme: 'mailto',
      path: CrashReportScreen.supportEmail,
      queryParameters: {'subject': 'Lazurite crash report', 'body': report.copyText},
    );

    final launcher = widget._emailLauncher ?? ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));
    final launched = await launcher(uri);
    if (!mounted) {
      return;
    }
    if (!launched) {
      messenger?.showSnackBar(const SnackBar(content: Text('Unable to open email app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: FutureBuilder<CrashReportBundle>(
          future: _reportFuture,
          builder: (context, snapshot) {
            final report = snapshot.data;
            final errorText = report?.error ?? widget.details.exceptionAsString();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Something went wrong', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'You can copy the crash report or open an email to send it to Stormlight Labs.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: report == null ? null : () => unawaited(_copyReport(report)),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copy report'),
                        ),
                        OutlinedButton.icon(
                          onPressed: report == null ? null : () => unawaited(_emailReport(report)),
                          icon: const Icon(Icons.email_outlined),
                          label: const Text('Email report'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ReportPreview(title: 'Error', text: errorText),
                    const SizedBox(height: 12),
                    if (report == null)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _ReportPreview(title: 'Stack trace', text: report.stackTrace),
                      const SizedBox(height: 12),
                      _ReportPreview(
                        title: 'Relevant logs',
                        text: report.relevantLogs.isEmpty ? 'No recent log lines were available.' : report.relevantLogs,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SelectableText(text, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
