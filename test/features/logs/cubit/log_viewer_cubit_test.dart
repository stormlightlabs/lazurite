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
  });
}
