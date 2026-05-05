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
      addTearDown(() async {
        final parent = sharedFile.parent;
        if (await parent.exists()) {
          await parent.delete(recursive: true);
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
  });
}
