import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/error_reporting/crash_report_bundle.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
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
  static const int _maxEmailStackTraceCharacters = 4000;

  late Future<CrashReportBundle> _reportFuture;
  var _reportBuildFailed = false;

  @override
  void initState() {
    super.initState();
    _reportFuture = _createReportFuture();
  }

  Future<CrashReportBundle> _buildReport() {
    final builder = widget._reportBuilder;
    if (builder != null) {
      return builder(widget.details);
    }
    return CrashReportBundle.fromFlutterErrorDetails(widget.details, todaysLogFileProvider: log.getTodaysLogFile);
  }

  Future<CrashReportBundle> _createReportFuture() async {
    await Future<void>.delayed(Duration.zero);
    try {
      return await _buildReport();
    } catch (error, stackTrace) {
      _reportBuildFailed = true;
      return CrashReportBundle.fallbackFromFlutterErrorDetails(
        widget.details,
        reportError: error,
        reportStackTrace: stackTrace,
      );
    }
  }

  Future<void> _copyReport(CrashReportBundle report) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: report.copyText));
    if (!mounted) {
      return;
    }
    messenger?.showSnackBar(SnackBar(content: Text(context.l10n.messageCrashReportCopied)));
  }

  Future<void> _emailReport(CrashReportBundle report) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final uri = Uri(
      scheme: 'mailto',
      path: CrashReportScreen.supportEmail,
      queryParameters: {
        'subject': l10n.subjectLazuriteCrashReport,
        'body': l10n.formatCrashReportEmailBody(report.error, _stackTraceForEmail(report.stackTrace, l10n)),
      },
    );

    final launcher = widget._emailLauncher ?? ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));
    final launched = await launcher(uri);
    if (!mounted) {
      return;
    }
    if (!launched) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.messageUnableToOpenEmailApp)));
    }
  }

  void _retryReport() {
    setState(() {
      _reportBuildFailed = false;
      _reportFuture = _createReportFuture();
    });
  }

  String _stackTraceForEmail(String stackTrace, AppLocalizations l10n) {
    if (stackTrace.length <= _maxEmailStackTraceCharacters) {
      return stackTrace;
    }
    return '${stackTrace.substring(0, _maxEmailStackTraceCharacters)}\n${l10n.messageCrashReportEmailStackTraceTruncated}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: FutureBuilder<CrashReportBundle>(
          future: _reportFuture,
          builder: (context, snapshot) {
            final report =
                snapshot.data ??
                (snapshot.hasError
                    ? CrashReportBundle.fallbackFromFlutterErrorDetails(
                        widget.details,
                        reportError: snapshot.error,
                        reportStackTrace: snapshot.stackTrace,
                      )
                    : null);
            final errorText = report?.error ?? widget.details.exceptionAsString();
            final reportBuildFailed = snapshot.hasError || _reportBuildFailed;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(l10n.errorGenericTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      l10n.messageCrashReportInstructions,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (reportBuildFailed) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.messageCrashReportPartial,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: report == null ? null : () => unawaited(_copyReport(report)),
                          icon: const Icon(Icons.copy_outlined),
                          label: Text(l10n.buttonCopyReport),
                        ),
                        OutlinedButton.icon(
                          onPressed: report == null ? null : () => unawaited(_emailReport(report)),
                          icon: const Icon(Icons.email_outlined),
                          label: Text(l10n.buttonEmailReport),
                        ),
                        if (reportBuildFailed)
                          TextButton.icon(
                            onPressed: _retryReport,
                            icon: const Icon(Icons.refresh_outlined),
                            label: Text(l10n.buttonRetry),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ReportPreview(title: l10n.labelCrashReportError, text: errorText),
                    const SizedBox(height: 12),
                    if (report == null)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _ReportPreview(title: l10n.labelCrashReportStackTrace, text: report.stackTrace),
                      const SizedBox(height: 12),
                      _ReportPreview(
                        title: l10n.labelCrashReportRelevantLogs,
                        text: report.relevantLogs.isEmpty ? l10n.messageNoRecentLogLinesAvailable : report.relevantLogs,
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
            SelectableText(
              text,
              style: context.codeTextStyle(
                fontSize: theme.textTheme.bodySmall?.fontSize ?? 12,
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: theme.textTheme.bodySmall?.letterSpacing,
                height: theme.textTheme.bodySmall?.height,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
