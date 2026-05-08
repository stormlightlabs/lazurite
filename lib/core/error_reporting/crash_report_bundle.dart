import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lazurite/core/logging/log_redactor.dart';

class CrashReportBundle {
  const CrashReportBundle({
    required this.generatedAt,
    required this.error,
    required this.stackTrace,
    required this.library,
    required this.context,
    required this.information,
    required this.relevantLogs,
  });

  static const int maxLogLines = 160;
  static const int maxLogCharacters = 24000;

  final DateTime generatedAt;
  final String error;
  final String stackTrace;
  final String? library;
  final String? context;
  final List<String> information;
  final String relevantLogs;

  static Future<CrashReportBundle> fromFlutterErrorDetails(
    FlutterErrorDetails details, {
    required Future<File?> Function() todaysLogFileProvider,
    DateTime? generatedAt,
  }) async {
    return CrashReportBundle(
      generatedAt: generatedAt ?? DateTime.now(),
      error: LogRedactor.redact(details.exceptionAsString()),
      stackTrace: LogRedactor.redact(details.stack?.toString() ?? StackTrace.current.toString()),
      library: _redactNullable(details.library),
      context: _redactNullable(details.context?.toDescription()),
      information: _collectInformation(details),
      relevantLogs: await _loadRelevantLogs(todaysLogFileProvider),
    );
  }

  String get copyText {
    final buffer = StringBuffer()
      ..writeln('Lazurite crash report')
      ..writeln('Generated: ${generatedAt.toIso8601String()}')
      ..writeln('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}')
      ..writeln()
      ..writeln('Error:')
      ..writeln(error)
      ..writeln();

    if (library != null && library!.isNotEmpty) {
      buffer
        ..writeln('Library:')
        ..writeln(library)
        ..writeln();
    }

    if (context != null && context!.isNotEmpty) {
      buffer
        ..writeln('Context:')
        ..writeln(context)
        ..writeln();
    }

    if (information.isNotEmpty) {
      buffer
        ..writeln('Diagnostics:')
        ..writeln(information.join('\n'))
        ..writeln();
    }

    buffer
      ..writeln('Stack trace:')
      ..writeln(stackTrace)
      ..writeln()
      ..writeln('Relevant logs:')
      ..writeln(relevantLogs.isEmpty ? 'No recent log lines were available.' : relevantLogs);

    return buffer.toString();
  }

  static String? _redactNullable(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return LogRedactor.redact(value);
  }

  static List<String> _collectInformation(FlutterErrorDetails details) {
    final collector = details.informationCollector;
    if (collector == null) {
      return const [];
    }

    return collector()
        .map((node) => LogRedactor.redact(node.toStringDeep(minLevel: DiagnosticLevel.info).trim()))
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  static Future<String> _loadRelevantLogs(Future<File?> Function() todaysLogFileProvider) async {
    final file = await todaysLogFileProvider();
    if (file == null || !await file.exists()) {
      return '';
    }

    final lines = (await file.readAsString())
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map(LogRedactor.redact)
        .toList(growable: false);
    if (lines.isEmpty) {
      return '';
    }

    var selected = lines.length > maxLogLines ? lines.sublist(lines.length - maxLogLines) : lines;
    var joined = selected.join('\n');
    if (joined.length <= maxLogCharacters) {
      return joined;
    }

    final trimmed = joined.substring(joined.length - maxLogCharacters);
    final firstNewline = trimmed.indexOf('\n');
    joined = firstNewline == -1 ? trimmed : trimmed.substring(firstNewline + 1);
    selected = joined.split('\n');
    return '[Earlier log lines omitted]\n${selected.join('\n')}';
  }
}
