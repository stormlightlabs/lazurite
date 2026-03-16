import 'dart:convert';

import 'package:logger/logger.dart';

class AppFileLogPrinter extends LogPrinter {
  AppFileLogPrinter();

  @override
  List<String> log(LogEvent event) {
    final buffer = StringBuffer()
      ..write(_labelFor(event.level))
      ..write(' TIME: ')
      ..write(event.time.toIso8601String())
      ..write(' ')
      ..write(_sanitize(_stringifyMessage(event.message)));

    if (event.error != null) {
      buffer
        ..write('  ERROR: ')
        ..write(_sanitize(event.error.toString()));
    }

    final stackTrace = _sanitizeStackTrace(event.stackTrace);
    if (stackTrace != null) {
      buffer
        ..write('  STACK: ')
        ..write(stackTrace);
    }

    return [buffer.toString()];
  }

  String _labelFor(Level level) {
    switch (level) {
      case Level.trace:
        return '[T]';
      case Level.debug:
        return '[D]';
      case Level.info:
        return '[I]';
      case Level.warning:
        return '[W]';
      case Level.error:
        return '[E]';
      case Level.fatal:
        return '[FATAL]';
      default:
        return '[D]';
    }
  }

  String _stringifyMessage(dynamic message) {
    final resolvedMessage = message is Function ? message() : message;
    if (resolvedMessage is Map || resolvedMessage is Iterable) {
      return const JsonEncoder.withIndent(null).convert(resolvedMessage);
    }
    return resolvedMessage.toString();
  }

  String _sanitize(String value) {
    return value.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join(' | ');
  }

  String? _sanitizeStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) {
      return null;
    }

    final sanitized = _sanitize(stackTrace.toString());
    return sanitized.isEmpty ? null : sanitized;
  }
}
