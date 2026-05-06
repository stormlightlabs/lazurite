import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/log_redactor.dart';

class LogEntry extends Equatable {
  const LogEntry({required this.timestamp, required this.level, required this.message, this.source});

  final DateTime timestamp;
  final Level level;
  final String message;
  final String? source;

  static LogEntry? tryParse(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return null;

    DateTime? timestamp;
    var remaining = trimmed;

    final levelPattern = RegExp(r'^\[([A-Z]+)\]\s*');
    final levelMatch = levelPattern.firstMatch(remaining);
    Level level = Level.debug;

    if (levelMatch != null) {
      level = _parseLevel(levelMatch.group(1));
      remaining = remaining.substring(levelMatch.end);
    }

    final timeTagPattern = RegExp(r'^TIME:\s*([^\s]+)\s*');
    final timeTagMatch = timeTagPattern.firstMatch(remaining);
    if (timeTagMatch != null) {
      timestamp ??= DateTime.tryParse(timeTagMatch.group(1)!)?.toLocal();
      remaining = remaining.substring(timeTagMatch.end);
    }

    String message;
    String? source;

    final colonIndex = remaining.indexOf(':');
    if (colonIndex > 0 && colonIndex < 30 && !remaining.substring(0, colonIndex).contains(' ')) {
      source = remaining.substring(0, colonIndex).trim();
      message = remaining.substring(colonIndex + 1).trim();
    } else {
      message = remaining.trim();
    }

    final redactedSource = source == null ? null : LogRedactor.redact(source);
    final redactedMessage = LogRedactor.redact(message);

    if (redactedMessage.isEmpty && redactedSource == null) return null;

    return LogEntry(
      timestamp: timestamp ?? DateTime.now(),
      level: level,
      message: redactedMessage,
      source: redactedSource,
    );
  }

  static Level _parseLevel(String? levelChar) {
    switch (levelChar?.toUpperCase()) {
      case 'TRACE':
      case 'T':
        return Level.trace;
      case 'DEBUG':
      case 'D':
        return Level.debug;
      case 'INFO':
      case 'I':
        return Level.info;
      case 'WARNING':
      case 'W':
        return Level.warning;
      case 'ERROR':
      case 'E':
        return Level.error;
      case 'FATAL':
      case 'F':
        return Level.fatal;
      default:
        return Level.debug;
    }
  }

  String get levelPrefix {
    switch (level) {
      case Level.trace:
        return 'T';
      case Level.debug:
        return 'D';
      case Level.info:
        return 'I';
      case Level.warning:
        return 'W';
      case Level.error:
        return 'E';
      case Level.fatal:
        return 'F';
      default:
        return 'D';
    }
  }

  String formatTimestamp() {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  @override
  List<Object?> get props => [timestamp, level, message, source];
}
