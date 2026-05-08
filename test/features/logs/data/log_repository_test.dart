import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/logs/data/log_repository.dart';

void main() {
  group('LogRepository', () {
    late Directory tempDirectory;
    late LogRepository repository;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('lazurite_log_repository_test_');
      repository = const LogRepository();
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('reads parseable entries from retained files in timestamp order', () async {
      final newerFile = File('${tempDirectory.path}/lazurite_2026-05-06.log');
      final olderFile = File('${tempDirectory.path}/lazurite_2026-05-05.log');
      await newerFile.writeAsString(
        '[I] TIME: 2026-05-06T10:00:01.000 Log: newer\n'
        'not a structured log line\n',
      );
      await olderFile.writeAsString('[W] TIME: 2026-05-05T10:00:01.000 Log: older\n');

      final entries = await repository.readEntries([newerFile, olderFile]);

      expect(entries, hasLength(3));
      expect(entries[0].message, 'older');
      expect(entries[1].message, 'newer');
      expect(entries[2].message, 'not a structured log line');
    });

    test('snapshot key changes when a retained file changes', () async {
      final file = File('${tempDirectory.path}/lazurite_2026-05-06.log');
      await file.writeAsString('[I] TIME: 2026-05-06T10:00:01.000 Log: first\n');

      final firstSnapshot = await repository.snapshotKey([file]);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await file.writeAsString('[I] TIME: 2026-05-06T10:00:02.000 Log: second\n', mode: FileMode.append);
      final secondSnapshot = await repository.snapshotKey([file]);

      expect(secondSnapshot, isNot(firstSnapshot));
    });
  });
}
