import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/features/logs/cubit/log_viewer_cubit.dart';

void main() {
  group('LogViewerState', () {
    test('initial state has default values', () {
      final state = LogViewerState.initial();
      expect(state.status, LogViewerStatus.initial);
      expect(state.entries, isEmpty);
      expect(state.filteredEntries, isEmpty);
      expect(state.searchQuery, isEmpty);
      expect(state.hasOlderEntries, isFalse);
      expect(state.isLoadingOlderEntries, isFalse);
      expect(
        state.enabledLevels,
        containsAll([Level.trace, Level.debug, Level.info, Level.warning, Level.error, Level.fatal]),
      );
    });

    test('copyWith preserves values when not specified', () {
      final state = LogViewerState.initial().copyWith(status: LogViewerStatus.loaded);
      expect(state.status, LogViewerStatus.loaded);
      expect(state.entries, isEmpty);
      expect(state.enabledLevels.length, 6);
    });

    test('copyWith updates specified values', () {
      final state = LogViewerState.initial().copyWith(status: LogViewerStatus.error, errorMessage: 'Test error');
      expect(state.status, LogViewerStatus.error);
      expect(state.errorMessage, 'Test error');
    });

    test('copyWith clears error message when null is provided', () {
      final state = LogViewerState.initial().copyWith(status: LogViewerStatus.error, errorMessage: 'Test error');
      final cleared = state.copyWith(status: LogViewerStatus.loaded, errorMessage: null);
      expect(cleared.status, LogViewerStatus.loaded);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('LogViewerCubit', () {
    blocTest<LogViewerCubit, LogViewerState>(
      'toggleLevel removes level when enabled',
      build: () => LogViewerCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.toggleLevel(Level.info),
      verify: (cubit) {
        expect(cubit.state.enabledLevels.contains(Level.info), isFalse);
      },
    );

    blocTest<LogViewerCubit, LogViewerState>(
      'toggleLevel adds level when disabled',
      build: () => LogViewerCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) {
        cubit.toggleLevel(Level.info);
        cubit.toggleLevel(Level.info);
      },
      verify: (cubit) {
        expect(cubit.state.enabledLevels.contains(Level.info), isTrue);
      },
    );

    blocTest<LogViewerCubit, LogViewerState>(
      'setSearchQuery updates search query',
      build: () => LogViewerCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.setSearchQuery('test query'),
      verify: (cubit) {
        expect(cubit.state.searchQuery, 'test query');
      },
    );

    test('getTodaysLogFile returns a redacted share copy', () async {
      final sourceDir = await Directory.systemTemp.createTemp('lazurite_log_viewer_test_');
      final sourceFile = File('${sourceDir.path}/lazurite_2026-05-05.log');
      await sourceFile.writeAsString(
        '[I] TIME: 2026-05-05T10:00:00.000 AuthRepository: '
        'Login for did:plc:ewvi7nxzyoun6zhxrhs64oiz river.bsky.social '
        '/oauth/callback?code=abc123&state=xyz\n',
      );

      final cubit = LogViewerCubit(todaysLogFileProvider: () async => sourceFile);
      addTearDown(() async {
        await cubit.close();
        if (await sourceDir.exists()) {
          await sourceDir.delete(recursive: true);
        }
      });

      final sharedFile = await cubit.getTodaysLogFile();
      expect(sharedFile, isNotNull);
      expect(sharedFile!.path, isNot(equals(sourceFile.path)));
      expect(sharedFile.uri.pathSegments.last, 'lazurite_logs_2026_05_05_share.log');
      addTearDown(() async {
        final shareDirectory = sharedFile.parent;
        if (await shareDirectory.exists()) {
          await shareDirectory.delete(recursive: true);
        }
      });
      final sharedContent = await sharedFile.readAsString();
      expect(sharedContent, contains('did:plc:ewvi7nxzyoun6zhxrhs64oiz'));
      expect(sharedContent, contains('river.bsky.social'));
      expect(sharedContent, isNot(contains('code=abc123')));
      expect(sharedContent, isNot(contains('state=xyz')));
      expect(sharedContent, contains('code=[REDACTED]'));
      expect(sharedContent, contains('state=[REDACTED]'));
    });

    test('reuses a stable shared file path across repeated shares', () async {
      final tempRoot = await Directory.systemTemp.createTemp('lazurite_log_viewer_temp_root_');
      final sourceDir = await tempRoot.createTemp('lazurite_log_source_');
      final sourceFile = File('${sourceDir.path}/lazurite_2026-05-06.log');
      await sourceFile.writeAsString('[I] TIME: 2026-05-06T10:00:00.000 code=abc123');

      final cubit = LogViewerCubit(
        todaysLogFileProvider: () async => sourceFile,
        systemTempDirectoryProvider: () => tempRoot,
      );
      addTearDown(() async {
        await cubit.close();
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final first = await cubit.getTodaysLogFile();
      final second = await cubit.getTodaysLogFile();

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(second!.path, equals(first!.path));
    });

    test('cleans up stale per-share temp directories', () async {
      final tempRoot = await Directory.systemTemp.createTemp('lazurite_log_viewer_temp_root_');
      final sourceDir = await tempRoot.createTemp('lazurite_log_source_');
      final sourceFile = File('${sourceDir.path}/lazurite_2026-05-06.log');
      await sourceFile.writeAsString('[I] TIME: 2026-05-06T10:00:00.000 state=xyz');

      final legacyOne = await tempRoot.createTemp('lazurite_logs_share_');
      final legacyTwo = await tempRoot.createTemp('lazurite_logs_share_');
      await File('${legacyOne.path}/old.log').writeAsString('legacy 1');
      await File('${legacyTwo.path}/old.log').writeAsString('legacy 2');

      final cubit = LogViewerCubit(
        todaysLogFileProvider: () async => sourceFile,
        systemTempDirectoryProvider: () => tempRoot,
      );
      addTearDown(() async {
        await cubit.close();
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final sharedFile = await cubit.getTodaysLogFile();
      expect(sharedFile, isNotNull);
      expect(await legacyOne.exists(), isFalse);
      expect(await legacyTwo.exists(), isFalse);
    });

    test('loads only the latest initial page', () async {
      final sourceDir = await Directory.systemTemp.createTemp('lazurite_log_viewer_source_');
      final oldFile = File('${sourceDir.path}/lazurite_2026-05-05.log');
      final newFile = File('${sourceDir.path}/lazurite_2026-05-06.log');
      await oldFile.writeAsString(
        List.generate(
          10,
          (index) =>
              '[I] TIME: ${DateTime(2026, 5, 5, 10).add(Duration(seconds: index)).toIso8601String()} '
              'Log: old $index',
        ).join('\n'),
      );
      await newFile.writeAsString(
        List.generate(
          LogViewerCubit.initialVisibleEntries + 5,
          (index) =>
              '[I] TIME: ${DateTime(2026, 5, 6, 10).add(Duration(seconds: index)).toIso8601String()} '
              'Log: new $index',
        ).join('\n'),
      );

      final cubit = LogViewerCubit(
        refreshInterval: const Duration(hours: 1),
        logFilesProvider: () async => [newFile, oldFile],
      );
      addTearDown(() async {
        await cubit.close();
        if (await sourceDir.exists()) {
          await sourceDir.delete(recursive: true);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await cubit.loadLogs(showLoading: false);

      expect(cubit.state.entries, hasLength(LogViewerCubit.initialVisibleEntries));
      expect(cubit.state.entries.first.message, contains('new 5'));
      expect(cubit.state.entries.last.message, contains('new ${LogViewerCubit.initialVisibleEntries + 4}'));
      expect(cubit.state.entries.any((entry) => entry.message.contains('old')), isFalse);
      expect(cubit.state.hasOlderEntries, isTrue);
    });

    test('loads older entries before the visible tail', () async {
      final sourceDir = await Directory.systemTemp.createTemp('lazurite_log_viewer_source_');
      final sourceFile = File('${sourceDir.path}/lazurite_2026-05-06.log');
      await sourceFile.writeAsString(
        List.generate(
          LogViewerCubit.initialVisibleEntries + 25,
          (index) =>
              '[I] TIME: ${DateTime(2026, 5, 6, 10).add(Duration(seconds: index)).toIso8601String()} '
              'Log: entry $index',
        ).join('\n'),
      );

      final cubit = LogViewerCubit(
        refreshInterval: const Duration(hours: 1),
        logFilesProvider: () async => [sourceFile],
      );
      addTearDown(() async {
        await cubit.close();
        if (await sourceDir.exists()) {
          await sourceDir.delete(recursive: true);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await cubit.loadLogs(showLoading: false);
      expect(cubit.state.entries.first.message, contains('entry 25'));

      await cubit.loadOlderEntries();

      expect(cubit.state.entries, hasLength(LogViewerCubit.initialVisibleEntries + 25));
      expect(cubit.state.entries.first.message, contains('entry 0'));
      expect(cubit.state.entries.last.message, contains('entry ${LogViewerCubit.initialVisibleEntries + 24}'));
      expect(cubit.state.hasOlderEntries, isFalse);
      expect(cubit.state.isLoadingOlderEntries, isFalse);
    });
  });
}
