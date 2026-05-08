import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

class DailyLogFileOutput extends LogOutput {
  DailyLogFileOutput({required this.directoryPath, this.retentionDays = 3, this.maxFileBytes = defaultMaxFileBytes})
    : assert(retentionDays > 0),
      assert(maxFileBytes > 0);

  static const int defaultMaxFileBytes = 2 * 1024 * 1024;

  final String directoryPath;
  final int retentionDays;
  final int maxFileBytes;

  String? _lastCleanupDateKey;
  Future<void> _pendingWrites = Future<void>.value();

  @override
  Future<void> init() async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    await cleanupOldLogs();
    _lastCleanupDateKey = _dateKey(DateTime.now());
  }

  @override
  void output(OutputEvent event) {
    final localTime = event.origin.time.toLocal();
    final currentDateKey = _dateKey(localTime);
    if (_lastCleanupDateKey != currentDateKey) {
      _lastCleanupDateKey = currentDateKey;
      unawaited(cleanupOldLogs(referenceTime: localTime));
    }

    final separator = Platform.isWindows ? '\r\n' : '\n';
    final content = '${event.lines.join(separator)}$separator';
    final filePath = p.join(directoryPath, fileNameFor(localTime));
    final shouldFlush = event.level.index >= Level.warning.index;
    _pendingWrites = _pendingWrites
        .then((_) => _appendLine(filePath: filePath, content: content, flush: shouldFlush))
        .catchError(_reportWriteFailure);
  }

  Future<void> clearAllLogs() async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        await entity.delete();
      }
    }
  }

  Future<void> cleanupOldLogs({DateTime? referenceTime}) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return;
    }

    final referenceDate = _normalizeDate((referenceTime ?? DateTime.now()).toLocal());
    final oldestRetainedDate = referenceDate.subtract(Duration(days: retentionDays - 1));

    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('.log')) {
        continue;
      }

      final fileDate = parseDateFromFileName(entity.path);
      if (fileDate != null && fileDate.isBefore(oldestRetainedDate)) {
        await entity.delete();
      }
    }
  }

  @override
  Future<void> destroy() async {
    await _pendingWrites;
  }

  Future<void> _appendLine({required String filePath, required String content, required bool flush}) async {
    final file = File(filePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    final maxEventBytes = maxFileBytes > 1 ? maxFileBytes ~/ 2 : maxFileBytes;
    final contentBytes = utf8.encode(content);
    final boundedContent = contentBytes.length > maxEventBytes ? _tailUtf8(contentBytes, maxEventBytes) : content;
    final boundedContentBytes = utf8.encode(boundedContent);
    if (await file.exists() && await file.length() + boundedContentBytes.length > maxFileBytes) {
      await _trimFileForAppend(file: file, incomingByteCount: boundedContentBytes.length);
    }
    await file.writeAsString(boundedContent, mode: FileMode.writeOnlyAppend, flush: flush);
  }

  Future<void> _trimFileForAppend({required File file, required int incomingByteCount}) async {
    final existingBytes = await file.readAsBytes();
    final marker = _trimMarker();
    final markerBytes = utf8.encode(marker);
    final retainedBudget = maxFileBytes - incomingByteCount - markerBytes.length;
    if (retainedBudget <= 0) {
      await file.writeAsString(marker, flush: true);
      return;
    }

    final retainedByteCount = retainedBudget.clamp(0, maxFileBytes ~/ 2);
    final tailStart = existingBytes.length > retainedByteCount ? existingBytes.length - retainedByteCount : 0;
    var tailBytes = existingBytes.sublist(tailStart);
    final firstNewline = tailBytes.indexOf(10);
    if (tailStart > 0 && firstNewline >= 0 && firstNewline + 1 < tailBytes.length) {
      tailBytes = tailBytes.sublist(firstNewline + 1);
    }

    final tail = utf8.decode(tailBytes, allowMalformed: true);
    await file.writeAsString('$marker$tail', flush: true);
  }

  String _tailUtf8(List<int> bytes, int maxBytes) {
    if (bytes.length <= maxBytes) {
      return utf8.decode(bytes, allowMalformed: true);
    }

    final tailBytes = bytes.sublist(bytes.length - maxBytes);
    return utf8.decode(tailBytes, allowMalformed: true);
  }

  String _trimMarker() {
    return '[W] TIME: ${DateTime.now().toIso8601String()} '
        'AppLogger: Older log entries trimmed to keep this log file below $maxFileBytes bytes.\n';
  }

  void _reportWriteFailure(Object error, StackTrace stackTrace) {
    stderr.writeln('Lazurite log write failed: $error');
  }

  static String fileNameFor(DateTime timestamp) {
    return 'lazurite_${_dateKey(timestamp.toLocal())}.log';
  }

  static DateTime? parseDateFromFileName(String filePath) {
    final match = RegExp(r'lazurite_(\d{4}-\d{2}-\d{2})\.log$').firstMatch(p.basename(filePath));
    if (match == null) {
      return null;
    }

    final parsed = DateTime.tryParse(match.group(1)!);
    return parsed == null ? null : _normalizeDate(parsed);
  }

  static String _dateKey(DateTime timestamp) {
    return '${timestamp.year}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')}';
  }

  static DateTime _normalizeDate(DateTime timestamp) {
    final localTimestamp = timestamp.toLocal();
    return DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);
  }
}
