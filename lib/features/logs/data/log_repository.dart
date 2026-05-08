import 'dart:convert';
import 'dart:io';

import 'package:lazurite/features/logs/data/log_entry.dart';

class LogRepository {
  const LogRepository();

  Future<List<LogEntry>> readEntries(List<File> files) async {
    final sortedFiles = [...files]..sort((a, b) => a.path.compareTo(b.path));
    final entries = <LogEntry>[];

    for (final file in sortedFiles) {
      await for (final line in file.openRead().transform(systemEncoding.decoder).transform(const LineSplitter())) {
        final entry = LogEntry.tryParse(line);
        if (entry != null) {
          entries.add(entry);
        }
      }
    }

    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(entries);
  }

  Future<String> snapshotKey(List<File> files) async {
    final sortedFiles = [...files]..sort((a, b) => a.path.compareTo(b.path));
    final parts = <String>[];
    for (final file in sortedFiles) {
      final stat = await file.stat();
      parts.add('${file.path}:${stat.size}:${stat.modified.microsecondsSinceEpoch}');
    }
    return parts.join('|');
  }
}
